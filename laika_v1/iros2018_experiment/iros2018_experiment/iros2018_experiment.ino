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
// (1) set up and interrupt for any serial terminal data, which can do something at a newline
// (2) in that interrupt, call a function to check if the input was one of the main commands, return true or false
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
#define InA1_M1 = 6;                   // INA motor pin
#define InB1_M1 = 5;                     // INB motor pin
#define PWM1_M1 = 9;                 // PWM motor 1 pin
#define encodPinA1_M1  = 2;                       // encoder A pin
#define encodPinB1_M1 = 11;// encoder B pin
// Motor 2: (assumed center vert.)
#define InA1_M2 = 7;
#define InB1_M2 = 8;
#define PWM1_M2 = 10;
#define encodPinA1_M2 = 3;
#define encodPinB1_M2 = 12;

// make it easier to remember direction of rotation:
#define FORWARD         1                       // direction of rotation
#define BACKWARD        2                       // direction of rotation

// For switching between commands
// Since we've already defined some above, start at 100.
// TO-DO: check that these aren't something that would otherwise be put in as a command, like a double or something
/*
#define STOPALL 100 // will stop all motors
#define STOP1 101   // only stop motor 1 or 2 (maybe unused.)
#define STOP2 102
#define RESET1 103  // reset the first motor to its original position
#define RESET2 104
#define MOVE1 105   // for when we're manually adjusting the horiz cables
#define MOVE2 106   // maybe we want to manually adjust the center vert also
#define RUNTEST 107 // run the test for the center vertebra
*/
// Also, we're going to set a value if a string input does NOT represent a command.
//#define NOTACOMAMAND = 9999;

int pwmVal = 100; // defaults to only 100/255 of the max power

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
// POSSIBLECOMMANDS is an enum variable of something from this list
typedef enum {STOPALL, STOPH, STOPC, RESETH, RESETC, RESETALL, MOVEH, MOVEC, RUNTEST, NOTACOMMAND} POSSIBLECOMMANDS;
// an enum we store
POSSIBLECOMMANDS commandEnum = NOTACOMMAND; // default value will be do nothing. This is (type) (variable name) = (value).

// If we need to iterate over enums: https://www.geeksforgeeks.org/enumeration-enum-c/, iterating over enums easier.

//boolean sendCommand = false;

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
// NOTE: SINCE OUR COMMANDS END WITH NEWLINES, NEED TO USE \n AT THE END OF ALL THESE
const static struct {
    POSSIBLECOMMANDS commandAsEnum;
    String str;
} conversion [] = {
    {STOPALL, "stopall\n"},
    {STOPH, "stoph\n"},
    {STOPC, "stopc\n"},
    {RESETH, "reseth\n"},
    {RESETC, "resetc\n"},
    {RESETALL, "resetall\n"},
    {MOVEH, "moveh\n"},
    {MOVEC, "movec\n"},
    {RUNTEST, "runtest\n"}
};

// changed const char* to String everywhere
POSSIBLECOMMANDS str2enum (String str)
{
  //Serial.println(str);
  // Will iterate through the conversion struct.
  int j;
  for (j = 0;  j < sizeof (conversion) / sizeof (conversion[0]);  ++j){
    // previously used strcmp, !strcmp (str, conversion[j].str)
    if (str == conversion[j].str) {
      // If we've found a match:
      Serial.print("Assigning enum for string: ");
      Serial.println(conversion[j].str);
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
  switch(commandToExecute){
    case STOPALL:
      Serial.println("Executing stopall");
      break;
    default:
      Serial.println("not executing a command.");  
  }
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("Testing for IROS 2018 Laika results. Options: (lowercase)");
  Serial.println("stopall, stoph, stopc, reseth, resetc, moveh, movec, runtest");
  Serial.println("Remember, you need to set line ending to Newline in the serial monitor.");
}

void loop() {
  // put your main code here, to run repeatedly:
  // print the string when a newline arrives:
  if (commandComplete) {
    Serial.println(commandString);
    // Now, we have a new command. Let's switch on that value.
    // Finally, clear the string, reset the int:
    //Serial.println(commandEnum);
    // Switch on the enum and perform behavior.
    executeMainCommand(commandEnum);
    commandString = "";
    commandEnum = NOTACOMMAND;
    commandComplete = false;
  }
}

// The SerialEvent function is already tied to an interrrupt on the serial port.
// This runs whenever data is available in the serial buffer.
void serialEvent() {
  // data is available
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    commandString += inChar;
    // if the incoming character is a newline, set a flag so the main loop can
    // do something about it:
    if (inChar == '\n') {
      commandComplete = true;
      // Now, we have a command. 
      // We'll check if this is one of the main commands, so that whatever is doing the command-checking
      // will know to return back to the main loop. This function also sets the commandInt value.
      isMainCommand = checkIfMainCommand(commandString);
      // Moving it here as opposed to main loop because we want to do interrupts everywhere,
      // and also, this allows us to differentiate between main commands "stop", etc. versus
      // inputs to the individual functions (like a number in radians.)
      // good programming practice is to pass this string around, even though it's global.
      //parseCommand(command);
    }
  }
}

// this function checks if the argument string exists in our array of main commands
bool checkIfMainCommand(String possibleMain){
  // value to return
  bool isMain = 0;
  // Use the conversion function to check against our enumeration
  // already declared this global variable
  commandEnum = str2enum(possibleMain); 
  //Serial.println(possibleMain);
  // No more need for looping! If the convert function returned NOTACOMMAND then this value is easily set.
  if( commandEnum != NOTACOMMAND){
    isMain = 1;
    //Serial.print("Found a main command. Passed in:");
    //Serial.println(possibleMain);
  }
  return isMain;
}

// The parseCommand function switches on a command string.
// Primarily, it checks if any of the main commands were run, and
// breaks out of whatever function was previously running

