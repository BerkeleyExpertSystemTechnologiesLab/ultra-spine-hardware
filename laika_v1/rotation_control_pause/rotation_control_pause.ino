
#define InA1            6                      // INA motor pin
#define InB1            5                      // INB motor pin

#define PWM1            9                       // PWM motor 1 pin
#define encodPinA1      2                       // encoder A pin
#define encodPinB1      11                       // encoder B pin
#define LED             13

#define LOOPTIME        100                     // PID loop time
#define FORWARD         1                       // direction of rotation
#define BACKWARD        2                       // direction of rotation

String input;
double radians = 0;
boolean sendCommand = false;

double Pi = 3.1415;
long count = 0;                                 // rotation counter
long countInit;
long tickNumber = 0;
boolean run = false;                                     // motor moves
boolean forward = false;
boolean backward = false;

long curcount = 0;
unsigned long startMilli = millis();
unsigned long currMilli = 0;

void setup() {
  pinMode(InA1, OUTPUT);
  pinMode(InB1, OUTPUT);
  pinMode(PWM1, OUTPUT);
  pinMode(encodPinA1, INPUT);
  pinMode(encodPinB1, INPUT);
  pinMode(LED, OUTPUT);
  digitalWrite(encodPinA1, HIGH);                      // turn on pullup resistor
  digitalWrite(encodPinB1, HIGH);
  attachInterrupt(digitalPinToInterrupt(encodPinA1), rencoderA1, RISING);
  digitalWrite(LED, LOW);
  Serial.begin(115200);
  Serial.println("Number of radians to rotate the motor?");
}

void loop() {
  delay(1000);
  if (Serial.available() > 0) {
    input = Serial.readString();
    radians = input.toDouble();
    sendCommand = true;
  }
  if (sendCommand) {
    if (radians == 0) {
      Serial.println("ZERO");
      if (count > 0) {
        moveMotor(BACKWARD, 255, abs(count));
      }
      if (count < 0) {
        moveMotor(FORWARD, 255, abs(count));
      }
      sendCommand = false;
    }
  }
  if (sendCommand) {
    double tickmarks = (radians / (2 * Pi)) * 3000;     // MOTOR ROTATION,CHANGE FOR CENTER
    Serial.println(tickmarks);
    sendCommand = false;
    int curCount = count;

    if (tickmarks > 0) {
      //Serial.println("Move FORWARD radians: ");
      //Serial.print(radians);
      digitalWrite(LED, HIGH);
      startMilli = millis();

      for (int i = 0; i <= tickmarks; i = i + 50) {
        Serial.println("loop");
        moveMotor(FORWARD, 255, 50);
        delay(1000);
//        Serial.println("");
//        Serial.print("LOOP INFO: ");
//        Serial.println(count);
//        Serial.println(curCount);
//        Serial.println(tickmarks);
        
        if (count - curCount > tickmarks) {
          Serial.println("");
          Serial.print("Final num encoder ticks: ");
          Serial.print(count);
          Serial.println(",");
          Serial.print("Final Real Life Center Rotation: ");
          Serial.print((((float)(count) / 3000) * 2 *  Pi) / 4);
          Serial.println(",");
          Serial.println("");
          Serial.println("");
          break;
        }
      }
    }
    if (tickmarks < 0) {
      //Serial.println("Move BACKWARD radians: ");
      //Serial.print(abs(radians));
      //Serial.println("");
      digitalWrite(LED, HIGH);
      startMilli = millis();

      for (int i = 0; i <= abs(tickmarks); i = i + 50) {
        moveMotor(BACKWARD, 255, 50);
        delay(1000);
        if (abs(count - curCount) > abs(tickmarks)) {
          break;
        }
      }

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

void rencoderA1()  {
  boolean curPinA1 = digitalRead(encodPinA1);
  boolean curPinB1 = digitalRead(encodPinB1);
  if (curPinA1 == 1) {
    if (curPinB1 == 0) {
      count++;
      curcount++;                         //EDIT
    } else {
      count--;
      curcount--;                         //EDIT
    }
  }
  // Serial.println("Encoder Count: ");
  // Serial.println(count);

  if (run)  {
    if (abs(curcount) >= 3) {
      //Serial.print("Count: ");
      //Serial.println(count);
      pause();
      curcount = 0;
    }

    if (forward) {
      if ((count - countInit) >= tickNumber)  {
        motorBrake();
        //Serial.println("done");
      };
    };
    if (backward) {
      if (abs(count - countInit) >= tickNumber) {
        motorBrake();
        //Serial.println("done");
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

void pause() {
  currMilli = millis();
  Serial.print("Time (ms):");
  Serial.print(currMilli - startMilli);
  Serial.println(",");
  Serial.print("Count: ");
  Serial.print((float)(count));
  Serial.println(",");
  Serial.print("Rotation: ");
  Serial.print(((float)(count) / 3000) * 2 *  Pi);
  Serial.println(",");
  Serial.print("Real Life Center Rotation: ");
  Serial.print((((float)(count) / 3000) * 2 *  Pi) / 4);
  Serial.println(",");
  Serial.println("");
}

