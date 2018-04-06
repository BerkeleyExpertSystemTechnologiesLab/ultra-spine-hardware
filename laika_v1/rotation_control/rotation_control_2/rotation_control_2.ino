// MD03A_Motor_basic + encoder

#define InA2            4                      // INA motor 2 pin
#define InB2            5                       // INB motor 2 pin
#define PWM2            10                      // PWM motor 2 pin

#define encodPinA1      2                       // encoder A pin (interrupt pin)
#define encodPinB1      12                      // encoder B pin (digital)


#define LOOPTIME        100                     // PID loop time
#define FORWARD         1                       // direction of rotation
#define BACKWARD        2                       // direction of rotation

unsigned long lastMilli = 0;                    // loop timing
unsigned long lastMilliPrint = 0;               // loop timing
long count = 0;                                 // rotation counter
long countInit;
long tickNumber = 0;
boolean run = false;                                     // motor moves

void setup() {
  pinMode(InA2, OUTPUT);
  pinMode(InB2, OUTPUT);
  pinMode(PWM2, OUTPUT);
  pinMode(encodPinA1, INPUT);
  pinMode(encodPinB1, INPUT);
  digitalWrite(encodPinA1, HIGH);                      // turn on pullup resistor
  digitalWrite(encodPinB1, HIGH);
  attachInterrupt(digitalPinToInterrupt(encodPinA1), rencoderA1, RISING);
  Serial.begin(115200);
}

void loop() {
  moveMotor(FORWARD, 255, 1000*1.5);                      // direction, PWM, ticks number
  delay(10000);
  moveMotor(BACKWARD, 255, 1000*1);                         // 3*1000 = 360
  delay(5000);
}

void moveMotor(int direction, int PWM_val, long tick)  {
  run = true;
  countInit = count;    // abs(count)
  tickNumber = tick;
  if (direction == FORWARD)          motorForward(PWM_val);
  else if (direction == BACKWARD)    motorBackward(PWM_val);
}

void rencoderA1()  {                                    // pulse and direction, direct port reading to save cycles
  if (digitalRead(encodPinA1) == HIGH) {
    if (digitalRead(encodPinB1) == LOW) {
      count++;
    } else {
      count--;
    }
  }
  if(run)  {
    if ((abs(abs(count) - abs(countInit))) >= tickNumber)  {
      Serial.println((abs(abs(count) - abs(countInit))));
      motorBrake();
    };
  };
}


void motorForward(int PWM_val)  {
  analogWrite(PWM2, PWM_val);
  digitalWrite(InA2, LOW);
  digitalWrite(InB2, HIGH);
  run = true;
}

void motorBackward(int PWM_val)  {
  analogWrite(PWM2, PWM_val);
  digitalWrite(InA2, HIGH);
  digitalWrite(InB2, LOW);
  run = true;
}

void motorBrake()  {
  analogWrite(PWM2, 0);
  digitalWrite(InA2, HIGH);
  digitalWrite(InB2, HIGH);
  run = false;
}
