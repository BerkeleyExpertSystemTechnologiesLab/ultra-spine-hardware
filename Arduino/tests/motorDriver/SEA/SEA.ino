#include <SoftwareSerial.h>

//#include <Encoder.h>
//#include <SoftwareSerial.h>

//#define rxpin 10
//#define txpin 11

//SoftwareSerial mySerial=SoftwareSerial(rxpin,txpin);

// Set values of pins for CW and CCW motor directions
int CW = 5;
int CCW = 6;

char cmd;

char buf;

void setup() {
  
  // Declare pins
  pinMode(CW, OUTPUT); // To AIN1 on motor driver
  pinMode(CCW, OUTPUT); // To AIN2 on on motor driver

  // Set motor speed
  analogWrite(CW,0);
  analogWrite(CCW,0);

  // Initiate serial monitor
  Serial.begin(9600);
  
}


// Set loop delay time (ms)
float delayTime = 500;

void loop() {
  if (Serial.available()) {
    //int msgLen = 0;
    while (Serial.available()) {
      buf = Serial.read();
      }
      cmd = buf;
  }

  Serial.println(cmd);
  
  if(cmd == 'F'){
    analogWrite(CW,200);
    analogWrite(CCW,0);
  } else if(cmd=='f'){
    analogWrite(CW,100);
    analogWrite(CCW,0);
  } else if(cmd=='r'){
    analogWrite(CCW,100);
    analogWrite(CW,0);
  } else if(cmd=='R'){
    analogWrite(CCW,200);
    analogWrite(CW,0);
  } else if(cmd=='b' || cmd=='B'){
    analogWrite(CW,100);
    analogWrite(CCW,100);
  } else if(cmd=='S' || cmd == 's'){
    analogWrite(CW,0);
    analogWrite(CCW,0);
  }

  // Delay loop
  delay(delayTime);

}
