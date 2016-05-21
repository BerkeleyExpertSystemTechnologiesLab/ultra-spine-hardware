/*
  Motor Demonstration that bends the spine to the left and back, then to the right, and back
  Used 5-16-2016 for Ankita's Interview

  NOTE: Must have StopMotors function in between each motor action
 */

// Set values of pins for CW and CCW motor directions
int motor3A = 3;  
int motor3B = 4; 
int motor1B = 5; 
int motor1A = 6; 
int motor2A = 20;
int motor2B = 21; 
int motor4B = 22; 
int motor4A = 23;
int led = 13; 
float delayMotion = 1000;

// Initializes the pins as outputs
void setup() {  
  pinMode(motor1A, OUTPUT); 
  pinMode(motor1B, OUTPUT); 
  pinMode(motor3B, OUTPUT); 
  pinMode(motor3A, OUTPUT); 
  pinMode(motor2A, OUTPUT); 
  pinMode(motor2B, OUTPUT); 
  pinMode(motor4B, OUTPUT); 
  pinMode(motor4A, OUTPUT); 
  pinMode(led, OUTPUT);  
}

// The following functions control the 4 motors using direction (true or false) and speed (0 - 255) as inputs
void Motor1(bool dir, int spd){  //Motor 1 moves 
  if(dir == true){
    analogWrite(motor1A,spd);
    analogWrite(motor1B,0); 
  }
  else {
    analogWrite(motor1A,0);
    analogWrite(motor1B,spd); 
  }
}

void Motor2(bool dir, int spd){  //Motor 2 moves 
  if(dir == true){
    analogWrite(motor2A,spd);
    analogWrite(motor2B,0); 
  }
  else {
    analogWrite(motor2A,0);
    analogWrite(motor2B,spd); 
  }
}

void Motor3(bool dir, int spd){ //Motor 3 moves
  if(dir == true){
    analogWrite(motor3A,spd);
    analogWrite(motor3B,0); 
  }
  else {
    analogWrite(motor3A,0);
    analogWrite(motor3B,spd); 
  }
}

void Motor4(bool dir, int spd){ //Motor 4 moves
  if(dir == true){
    analogWrite(motor4A,spd);
    analogWrite(motor4B,0); 
  }
  else {
    analogWrite(motor4A,0);
    analogWrite(motor4B,spd); 
  }
}

void StopMotors() {              //Stops all motors
  analogWrite(motor3A,0);
  analogWrite(motor3B,0); 
  analogWrite(motor1A,0);
  analogWrite(motor1B,0);
  analogWrite(motor2A,0);
  analogWrite(motor2B,0);
  analogWrite(motor4A,0);
  analogWrite(motor4B,0);
}
void LightFunction() {           //Blinks the LED on the Teensy
digitalWrite(led, HIGH);   
  delay(100);               
  digitalWrite(led, LOW);    
  delay(100);               
}


// The loop routine runs until manually stopped
void loop() {
  StopMotors();
  LightFunction();   //Light blinks for 1 second
  Motor4(true,200);  //Motor4 rotates for 1 second CW
  delay(delayMotion); 
  StopMotors();      //Motor stops
  LightFunction();   
  Motor4(false,200); //Motor4 rotates for 1 second CCW
  delay(delayMotion);  
  StopMotors(); 
  LightFunction();
  Motor2(false,200); //Motor2 rotates for 1 second CW
  delay(delayMotion);
  StopMotors();
  LightFunction();
  Motor2(true,200);  //Motor2 rotates for 1 second CCW
  delay(delayMotion);  
}

