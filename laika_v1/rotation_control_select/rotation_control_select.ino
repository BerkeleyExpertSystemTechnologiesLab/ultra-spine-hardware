
// Default to motor 1
int InA1 = 6;                   // INA motor pin
int InB1 = 5;                     // INB motor pin

int PWM1 = 9;                 // PWM motor 1 pin
int encodPinA1  = 2;                       // encoder A pin
int encodPinB1 = 11;// encoder B pin
int pwmVal = 100; // defaults to only 100/255 of the max power

#define LOOPTIME        100                     // PID loop time
#define FORWARD         1                       // direction of rotation
#define BACKWARD        2                       // direction of rotation

String input;
double radians = 0;
boolean sendCommand = false;

double Pi = 3.1415;
unsigned long lastMilli = 0;                    // loop timing
unsigned long lastMilliPrint = 0;               // loop timing
long count = 0;                                 // rotation counter
long countInit;
long tickNumber = 0;
boolean run = false;                                     // motor moves
boolean forward = false;
boolean backward = false;
boolean motorSelection = true;
byte incomingByte = 0;

// Setup runs before 'loop'
void setup() {
  Serial.begin(115200);
  Serial.println("Motor Selection:");

  // Start with specifying the motor. 
  // Read from the terminal until the user has selected an option.
  // Once selected, break out of the loop by setting motorSelction=false.
  while (motorSelection) {
    if (Serial.available() > 0) {
       incomingByte = Serial.read();
       // ASCII table: 49 = "1", 50 = "2"
       if (incomingByte == 49) {
        Serial.println("First motor");
        motorSelection = false;
       } else if(incomingByte == 50) {
        InA1 = 7;
        InB1 = 8;
        PWM1 = 10;
        encodPinA1 = 3;
        encodPinB1 = 12;
        pwmVal = 255;
        Serial.println("Second Motor");
        motorSelection = false;
       }
    }
  }

  // Now that the motor is selected, set up the pins,
  // move down to the main loop() 
  pinMode(InA1, OUTPUT);
  pinMode(InB1, OUTPUT);
  pinMode(PWM1, OUTPUT);
  pinMode(encodPinA1, INPUT);
  pinMode(encodPinB1, INPUT);
  digitalWrite(encodPinA1, HIGH);                      // turn on pullup resistor
  digitalWrite(encodPinB1, HIGH);
  // will run the reconderA1 function below when interrupt is received
  attachInterrupt(digitalPinToInterrupt(encodPinA1), rencoderA1, RISING);

  Serial.println("Number of radians to rotate the motor?");
 
}

// Now that motor is selected, continuously poll terminal and 
// move the motor via PID control.
void loop() {
  if (Serial.available() > 0) {
    input = Serial.readString();
    radians = input.toDouble();
    // This main loop only enters the following "if" blocks
    // when an angle in radians is commanded
    sendCommand = true;
  }
  if (sendCommand) {
    // When the zero input is commanded, reset the motor.
    // We've been counting ticks ("count"), so this reverses everything.
    if (radians==0) {
      if (count > 0) {
        moveMotor(BACKWARD, pwmVal, abs(count));
      }
      if (count < 0) {
        moveMotor(FORWARD, pwmVal, abs(count));
      }
      // This value is only set if radians = 0  is commanded.
      // Otherwise, the next "if" block is also executed.
      sendCommand = false;
    }
  }
  if (sendCommand) {
    // A nonzero radians command was received.
    // Number of encoder ticks to move, converted from radians:
    double tickmarks = (radians / (2 * Pi)) * 3000;     // MOTOR ROTATION,CHANGE FOR CENTER
    // reset so the the loop is only run on next command.
    sendCommand = false;
    // Depending on + or - radians...
    if (tickmarks > 0) {
      Serial.println("Move FORWARD radians: ");
      Serial.print(radians);
      Serial.println("");
      moveMotor(FORWARD, pwmVal, tickmarks);
      // TO-DO: make this delay more general. In milliseconds.
      delay(5000);
    }
    if (tickmarks < 0) {
      Serial.println("Move BACKWARD radians: ");
      Serial.print(abs(radians));  
      Serial.println("");    
      moveMotor(BACKWARD, pwmVal, abs(tickmarks));
      delay(5000);
    }
  }

}

void moveMotor(int direction, int PWM_val, long tick)  {
  run = true;
  countInit = count;    // abs(count)
  tickNumber = tick;
  if (direction == FORWARD)          motorForward(PWM_val);
  else if (direction == BACKWARD)    motorBackward(PWM_val);
}

// This interrupt is responsible for checking once encoder position
// has been reached, and then braking the motors.
void rencoderA1()  {
  if (digitalRead(encodPinA1) == HIGH) {
    if (digitalRead(encodPinB1) == LOW) {
      count++;
    } else {
      count--;
    }
  }
  if (run)  {
    //Serial.println(count);
    if (forward) {
      if ((count - countInit) >= tickNumber)  {
        motorBrake();
        Serial.println("done");
      };
    };
    if (backward) {
      if (abs(count - countInit) >= tickNumber) {
        motorBrake();
        Serial.println("done");
      };
    };
  };
}

void motorForward(int PWM_val)  {
  analogWrite(PWM1, PWM_val);
  digitalWrite(InA1, LOW);
  digitalWrite(InB1, HIGH);
  run = true;
  forward = true;
  backward = false;
}

void motorBackward(int PWM_val)  {
  analogWrite(PWM1, PWM_val);
  digitalWrite(InA1, HIGH);
  digitalWrite(InB1, LOW);
  run = true;
  forward = false;
  backward = true;
}

void motorBrake()  {
  analogWrite(PWM1, 0);
  digitalWrite(InA1, HIGH);
  digitalWrite(InB1, HIGH);
  run = false;
}
