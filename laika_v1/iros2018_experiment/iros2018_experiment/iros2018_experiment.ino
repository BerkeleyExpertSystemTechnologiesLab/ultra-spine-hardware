// IROS 2018 Data Collection sketch
// Andrew P. Sabelhaus, BEST Lab, 2018-02-28

 /** 
  *  This script does the following.
  * (1) moves horizontal cables along desired trajectory (retract until amount, in rad)
  * (2) turns on an LED when testing begins
  * (3) slowly varies setpoint for rotating vert
  * (4) repeatedly outputs data to the terminal in (time, rot vert pos) pairs
  * (4) checks for serial terminal input to stop the test,
  * (5) resets both sets of cables once stopped
  */

// Logic: when a new command is received, need to check if it's one of the main ones,
// and break out of whatever else was running.
// Else, if it's appropriate for the subroutine, just alert the caller that a command
// was received. So, here's what we'll do:
// (1) set up and interrupt for any serial terminal data, which can do something at a newline. DONE
// (2) in that interrupt, call a function to check if the input was one of the main commands, return true or false DONE
// (3) in the main loop, just keep switching on whatever current command is, since the subroutine will control its own wait/timing
// (4) In each subroutine, when we want to get a specific (not main) command, we do:
//    (4.1) wait until new command complete (while loop)
//    (4.2) check if main command - if so, break, and let the main loop() handle the new main command
//    (4.2) if not, then continue with the current task.
// Thus, we leave it to the responsibility of the subroutine to ALWAYS check if a new command is a main one, and return back to 
// the main loop(). 

// First, some constants.
// We'll assume that motor 1 will be the horizontal motor, for whichever side.
// Reminder: Laika's motors have GND as the red, rightmost wire in the flat cable.

// Constants for pins with each motor
// Motor 1: (assumed horizontal.)
#define InA1_M1 6                   // INA motor pin
#define InB1_M1 5                     // INB motor pin
#define PWM1_M1 9                 // PWM motor 1 pin
#define encodPinA1_M1 2                       // encoder A pin
#define encodPinB1_M1 11    // encoder B pin
// Motor 2: (assumed center vert.)
#define InA1_M2 7
#define InB1_M2 8
#define PWM1_M2 10
#define encodPinA1_M2 3
#define encodPinB1_M2 12

// make it easier to remember direction of rotation:
#define FORWARD         1                       // direction of rotation
#define BACKWARD        2                       // direction of rotation

int pwmVal = 100; // defaults to only 100/255 of the max power

// for motor control: need interrupts for both motors, and checking
// if each is supposed to be running. 1 = horiz, 2 = center
boolean runh = false;
boolean runc = false;
// counting rotations for each motor, in both rad and encoder ticks
long counth = 0;
long countc = 0;
// 

// for storing comm data:
String input;
double radians = 0;
double Pi = 3.1415;
long count = 0;                                 // rotation counter
long countInit;
long tickNumber = 0;
byte incomingByte = 0;
// When using the SerialEvent function for interrupts, we need to add to
// a string, until a newline is received. This is because the fcn only gets
// one character at a time.
// Thanks/Credit to https://www.arduino.cc/en/Tutorial/SerialEvent
boolean commandComplete = false;  // whether the string is complete
boolean isMainCommand = true; // each subroutine will check and return to main loop if needed.

// When running the main loop, we need a variety of different behaviors.
// We'll use a switch-case statement, switching on integers.
// The string that we'll store the command in
String commandString = ""; // default to no command

// ...it makes things easier if we do this as an ENUM so we can avoid passing around strings as "commands."
// POSSIBLECOMMANDS is the name of the type of this enumeration
typedef enum {STOPALL, STOPH, STOPC, RESETH, RESETC, RESETALL, MOVEH, MOVEC, RUNTEST, NOTACOMMAND} POSSIBLECOMMANDS;

// an enum we store, of the type of the above, with the variable name commandEnum.
POSSIBLECOMMANDS commandEnum = NOTACOMMAND; // default value will be do nothing. This is (type) (variable name) = (value).


// We'll be correlating timestamp with encoder values
unsigned long lastMilli = 0;                    // loop timing
unsigned long lastMilliPrint = 0;               // loop timing

// From Kim and Jesus' original code:
//boolean run = false;                                     // motor moves
//boolean forward = false;
//boolean backward = false;
//boolean motorSelection = true;

// We're going to want to convert from string inputs to these enums, for easier looping.
// So, do the following:
//https://stackoverflow.com/questions/16844728/converting-from-string-to-enum-in-c

const static struct {
    POSSIBLECOMMANDS commandAsEnum;
    String str;
} conversion [] = {
    {STOPALL, "stopall"},
    {STOPH, "stoph"},
    {STOPC, "stopc"},
    {RESETH, "reseth"},
    {RESETC, "resetc"},
    {RESETALL, "resetall"},
    {MOVEH, "moveh"},
    {MOVEC, "movec"},
    {RUNTEST, "runtest"}
};

// This function converts between strings coming from the terminal,
// and our enum variable that's used to differentiate behaviors.
POSSIBLECOMMANDS str2enum (String str)
{
  // Will iterate through the conversion struct.
  int j;
  for (j = 0;  j < sizeof (conversion) / sizeof (conversion[0]);  ++j){
    // previously used strcmp, !strcmp (str, conversion[j].str)
    if (str == conversion[j].str) {
      // If we've found a match:
      return conversion[j].commandAsEnum;     
    } 
  }
  // If we've not found anything, return NOTACOMMAND. 
  return NOTACOMMAND;
}

// the executeCommand function is a short litle helper for switching over enums
// and calling the right subroutine.
void executeMainCommand(POSSIBLECOMMANDS commandToExecute) {
  // Switch on the enum
  // Just before calling the subroutine, reset the command, since we've
  // gotten our use from it right now.
  // This makes it easier for the subroutines to read in new data, resetting commandComplete = 0;
  switch(commandToExecute){
    case STOPALL:
      Serial.println("Executing stopall");
      resetCommand();
      execute_stopall();
      break;
    case STOPH:
      Serial.println("Executing stoph");
      resetCommand();
      execute_stoph();
      break;
    case STOPC:
      Serial.println("Executing stopc");
      resetCommand();
      execute_stopc();
      break;
    case RESETALL:
      Serial.println("Executing resetall");
      resetCommand();
      break;
    case RESETH:
      Serial.println("Executing reseth");
      resetCommand();
      break;
    case RESETC:
      Serial.println("Executing resetc");
      resetCommand();
      break;
    case MOVEH:
      Serial.println("Executing moveh");
      resetCommand();
      execute_moveh();
      break;
    case MOVEC:
      Serial.println("Executing movec");
      resetCommand();
      break;
    case RUNTEST:
      Serial.println("Executing runtest");
      resetCommand();
      break;
    default:
      Serial.println("not executing a command.");  
      resetCommand();
  }
}

// a short helper: reset the command (both string and enum), so we won't forget.
void resetCommand(){
  commandString = "";
  commandEnum = NOTACOMMAND;
  commandComplete = false;
}

/**
 * SETUP
 * The setup function has the responsibility of configuring all pins.
 */
void setup() {
  // a nice instructional message
  Serial.begin(115200);
  Serial.println("Testing for IROS 2018 Laika results. Options: (lowercase)");
  Serial.println("stopall, stoph, stopc, reseth, resetc, moveh, movec, runtest");
  Serial.println("Remember, you need to set line ending to Newline in the serial monitor.");
  // Configure all pins.
  // For motor 1 (horizontal, h)
  pinMode(InA1_M1, OUTPUT);
  pinMode(InB1_M1, OUTPUT);
  pinMode(PWM1_M1, OUTPUT);
  pinMode(encodPinA1_M1, INPUT);
  pinMode(encodPinB1_M1, INPUT);
  digitalWrite(encodPinA1_M1, HIGH);                      // turn on pullup resistor
  digitalWrite(encodPinB1_M1, HIGH);
  // For motor 2 (center, c)
  pinMode(InA1_M2, OUTPUT);
  pinMode(InB1_M2, OUTPUT);
  pinMode(PWM1_M2, OUTPUT);
  pinMode(encodPinA1_M2, INPUT);
  pinMode(encodPinB1_M2, INPUT);
  digitalWrite(encodPinA1_M2, HIGH);                      // turn on pullup resistor
  digitalWrite(encodPinB1_M2, HIGH);
}

/**
 * MAIN LOOP
 * Responsible for switching between modes / commands. All subroutines will return back to here
 * once either (a) they're finished, or (b) they received one of the main commands while 
 * going about their business.
 */
void loop() {
  // If nothing else is happening, wait until a string command has fully arrived
  // over the serial terminal.
  if (commandComplete) {
    // Now, we have a new command. Let's switch on that value.
    // Switch on the enum and perform behavior.
    // Whatever subroutine is called via executeMainCommand will have control
    // of the arduino, and this main loop will not be executed "for a while"
    executeMainCommand(commandEnum);
     // Finally, clear the string, reset the enum:
    resetCommand();
  }
}

// The SerialEvent function is already tied to an interrrupt on the serial port.
// This runs whenever data is available in the serial buffer.
void serialEvent() {
  // data is available
  //DEBUGGING
  Serial.println("Serial event occurred");
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // Check if we got a newline, and either return or add the next character.
    if (inChar == '\n') {
      // if the incoming character is a newline, set a flag so the main loop can
      // do something about it:
      commandComplete = true;
      // Now, we have a command. 
      // We'll check if this is one of the main commands, so that whatever is doing the command-checking
      // will know to return back to the main loop.
      isMainCommand = checkIfMainCommand(commandString);
    }    
    else {
    // add it to the inputString:
    commandString += inChar; 
    }
  }
}

// this function checks if the argument string exists in our array of main commands
bool checkIfMainCommand(String possibleMain){
  // value to return
  bool isMain = 0;
  // Use the conversion function to check against our enumeration
  // already declared commandEnum as a global variable
  commandEnum = str2enum(possibleMain); 
  // Looping and checking occurs in str2enum! If the convert function returned NOTACOMMAND then this value is easily set.
  if( commandEnum != NOTACOMMAND){
    isMain = 1;
  }
  return isMain;
}

/**
 * Some helpers for motor control.
 */
void brakeMotor1(){
  analogWrite(PWM1_M1, 0);
  digitalWrite(InA1_M1, HIGH);
  digitalWrite(InB1_M1, HIGH);
}
void brakeMotor2(){
  analogWrite(PWM1_M2, 0);
  digitalWrite(InA1_M2, HIGH);
  digitalWrite(InB1_M2, HIGH);
}
/*
void moveMotorH(int direction, int PWM_val, long tick)  {
  runh = true;
  //countInit = count;    // abs(count)
  //tickNumber = tick;
  if (direction == FORWARD)          motorForward(PWM_val);
  else if (direction == BACKWARD)    motorBackward(PWM_val);
}
*/

/**
 * FUNCTIONS FOR EACH COMMAND
 * Below, we have the behavior for each command that's input.
 * A quick note about how data is read from the serial terminal from here out:
 * Say, for example, one of these functions is running, and expects an angle from the terminal.
 * We'd wait until commandComplete (the global bool) is set, maybe a while loop.
 * Then, check if isMainCommand, in which case, it's this functions responsibility
 * to return to the main loop (just call return.)
 */
void execute_stopall(){
  // Stopping all the motors is braking both.
  brakeMotor1();
  brakeMotor2();
}
 
// Motor 1 is horizontal, 2 is center.
void execute_stoph(){
  brakeMotor1(); 
}
void execute_stopc(){
  brakeMotor2();
}

// Manually moving either motor.
void execute_moveh(){
  // Here, we get an amount, in rad, to move.
  Serial.println("Enter an amount in radians for horizontal motor (M1) to move:");
  // keep checking until we get a new command, and confirm that it's not something
  // that should break out to the main loop
  while( !commandComplete ){
    // do nothing
    delay(100);
    //Serial.println("Waiting patiently...");
  }
  //DEBUGGING
  Serial.println(commandString);
  // Next, check if break out:
  if( isMainCommand ){
    // go back and stop doing what we're doing!
    return;
  }
  // OK! Great. Let's assume we've got a double.
  double radians = commandString.toDouble();
  //DEBUGGING: print the double.
  Serial.println(radians);

  // ...finally, once this is complete, need to reset the command entirely,
  // for the main loop to operate properly.
  resetCommand();
}

