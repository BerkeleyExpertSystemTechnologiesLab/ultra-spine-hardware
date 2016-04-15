#include <SoftwareSerial.h>

//#include <Encoder.h>
//#include <SoftwareSerial.h>

//#define rxpin 10
//#define txpin 11

//SoftwareSerial mySerial=SoftwareSerial(rxpin,txpin);

// Set values of pins for CW and CCW motor directions
int motor3A = 3;  //(+)?
int motor3B = 4; //(-)?
int motor1B = 5; 
int motor1A = 6; 
int motor2A = 20;
int motor2B = 21; 
int motor4B = 22; 
int motor4A = 23;
int led = 13; 
float delayMotion = 400;
void setup() {
  
  // Declare pins  
  pinMode(motor1A, OUTPUT); // To BIN1 on motor driverA
  pinMode(motor1B, OUTPUT); // To BIN2 on on motor driverA
  pinMode(motor3B, OUTPUT); // To AIN2 on motor driverA
  pinMode(motor3A, OUTPUT); // To AIN1 on motor driverA

  pinMode(motor2A, OUTPUT); // To AIN1 on motor driverB
  pinMode(motor2B, OUTPUT); // To AIN2 on on motor driverB
  pinMode(motor4B, OUTPUT); // To BIN2 on motor driverB
  pinMode(motor4A, OUTPUT); // To BIN1 on motor driverB
  pinMode(led, OUTPUT);  
  
}

void loop() {

   StopMotors();
   LightFunction();
   Motor1(true,200); 
   delay(delayMotion);
   StopMotors();
   LightFunction();
   Motor1(false,200);
   delay(delayMotion);  
   StopMotors(); 
   LightFunction();
   Motor2(true,200); 
   delay(delayMotion);
   StopMotors();
   LightFunction();
   Motor2(false,200);
   delay(delayMotion);  
   StopMotors(); 
   LightFunction();
   Motor3(true,200); 
   delay(delayMotion);
   StopMotors();
   LightFunction();
   Motor3(false,200);
   delay(delayMotion);  
   StopMotors(); 
   LightFunction();
   Motor4(true,200); 
   delay(delayMotion);
   StopMotors();
   LightFunction();
   Motor4(false,200);
   delay(delayMotion);  
   StopMotors(); 
}

void Motor1(bool dir, int spd){
  if(dir == true){
    analogWrite(motor1A,spd);
    analogWrite(motor1B,0); 
  }
  else {
    analogWrite(motor1A,0);
    analogWrite(motor1B,spd); 
  }
}


void Motor2(bool dir, int spd){
  if(dir == true){
    analogWrite(motor2A,spd);
    analogWrite(motor2B,0); 
  }
  else {
    analogWrite(motor2A,0);
    analogWrite(motor2B,spd); 
  }
}

void Motor3(bool dir, int spd){
  if(dir == true){
    analogWrite(motor3A,spd);
    analogWrite(motor3B,0); 
  }
  else {
    analogWrite(motor3A,0);
    analogWrite(motor3B,spd); 
  }
}

void Motor4(bool dir, int spd){
  if(dir == true){
    analogWrite(motor4A,spd);
    analogWrite(motor4B,0); 
  }
  else {
    analogWrite(motor4A,0);
    analogWrite(motor4B,spd); 
  }
}

void StopMotors() {
  analogWrite(motor3A,0);
  analogWrite(motor3B,0); 
  analogWrite(motor1A,0);
  analogWrite(motor1B,0);
  analogWrite(motor2A,0);
  analogWrite(motor2B,0);
  analogWrite(motor4A,0);
  analogWrite(motor4B,0);
}
void LightFunction() {
digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1000);               // wait for a second
  digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
  delay(1000);               // wait for a second
}
