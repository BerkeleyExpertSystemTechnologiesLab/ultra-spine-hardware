#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055_I2C1.h>
#include <Encoder.h>
#include <elapsedMillis.h>
#include <i2c_t3.h>
#include <utility/imumaths.h>
#include <XBee.h>
#include <tensegrity_wireless.h>

// ID is 00 for the master controller, 01 through 06 for slaves.
// This needs to be changed depending on the slave being deployed to.
#define ID 06
#define IMU_ID ID

#define IMU_READING_DELAY     100
#define ENCODER_READING_DELAY 100
#define ENCODER_DIFF_THRESHOLD 25 // if the encoders say we're within this tolerance, assume we've reached our goal

elapsedMillis next_imu_reading;
elapsedMillis next_reading;
elapsedMillis print_debug_data;

////////////////////////////////////////////////////////////////////
////////////////// MOTOR INIT AND OTHER PID STUFF //////////////////
////////////////////////////////////////////////////////////////////
Encoder motor4(16, 17);
int sp4 = 22, spb4 = 23;
Encoder motor3(14, 15);
int sp3 = 20, spb3 = 21;
Encoder motor2(7, 8);
int sp2 = 5, spb2 = 6;
Encoder motor1(1, 2);
int sp1 = 3, spb1 = 4;

float K_1 = .5,K_2 = .5, K_3 = .5, K_4 = .5;
int   Kp_1 = 2, Kp_2 = 2, Kp_3 = 2, Kp_4 = 2;
int   Ki_1 = 1,Ki_2 = 1,Ki_3 = 1,Ki_4 = 1;
int   Kd_1 = 2, Kd_2 = 2, Kd_3 = 2, Kd_4 = 2;
int last_error_1 = 0, last_error_2 = 0, last_error_3 = 0, last_error_4 = 0;
int integrated_error_1 = 0, integrated_error_2 = 0, integrated_error_3 = 0, integrated_error_4 = 0;

int pTerm_1 = 0, iTerm_1 = 0, dTerm_1 = 0;
int pTerm_2 = 0, iTerm_2 = 0, dTerm_2 = 0;
int pTerm_3 = 0, iTerm_3 = 0, dTerm_3 = 0;
int pTerm_4 = 0, iTerm_4 = 0, dTerm_4 = 0;

int target_1, target_2, target_3, target_4;
int error_1 = 0, error_2 = 0, error_3 = 0, error_4 = 0;
float updatePid1 = 0,  updatePid2 = 0,  updatePid3 = 0,  updatePid4 = 0;

int GUARD_GAIN = 10;

int encoder1Pos = 0, encoder2Pos = 0, encoder3Pos = 0, encoder4Pos = 0;
int lastEncoder1Pos = 0, lastEncoder2Pos = 0, lastEncoder3Pos = 0, lastEncoder4Pos = 0;
//////////////////////////////////////////////////////////////
////////////////// END MOTOR AND PID CONFIG //////////////////
//////////////////////////////////////////////////////////////

Adafruit_BNO055_I2C1 bno = Adafruit_BNO055_I2C1();

void setup() {
  // configure motor outputs
  pinMode(sp1, OUTPUT);
  pinMode(spb1, OUTPUT);
  pinMode(sp2, OUTPUT);
  pinMode(spb2, OUTPUT);
  pinMode(sp3, OUTPUT);
  pinMode(spb3, OUTPUT);
  pinMode(sp4, OUTPUT);
  pinMode(spb4, OUTPUT);

  Serial.begin(57600); // debug serial init
  radio_init(ID);

  pinMode(13, OUTPUT);
  digitalWrite(13, HIGH);

  if(!bno.begin())
  {
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }
  delay(1000);
}

void loop() {
  encoder1Pos = motor1.read();
  encoder2Pos = motor2.read();
  encoder3Pos = motor3.read();
  encoder4Pos = motor4.read();

  // we want to send imu data only when we're not sending encoder data to avoid
  // using too much bandwidth
  bool send_imu_readings = true;

  if (next_reading >= ENCODER_READING_DELAY) {
    uint32_t diff1 = abs(encoder1Pos - lastEncoder1Pos);
    uint32_t diff2 = abs(encoder2Pos - lastEncoder2Pos);
    uint32_t diff3 = abs(encoder3Pos - lastEncoder3Pos);
    uint32_t diff4 = abs(encoder4Pos - lastEncoder4Pos);
    if (diff1 > ENCODER_DIFF_THRESHOLD || diff2 > ENCODER_DIFF_THRESHOLD ||
        diff3 > ENCODER_DIFF_THRESHOLD || diff4 > ENCODER_DIFF_THRESHOLD ) {
      send_encoder_reading(0/*master ID*/, encoder1Pos, encoder2Pos, encoder3Pos, encoder4Pos);
      send_imu_readings = false;
      next_reading = 0;
    }
    lastEncoder1Pos = encoder1Pos;
    lastEncoder2Pos = encoder2Pos;
    lastEncoder3Pos = encoder3Pos;
    lastEncoder4Pos = encoder4Pos;
  }

  if (send_imu_readings && next_reading >= IMU_READING_DELAY) {
    imu::Vector<3> gravity = bno.getVector(Adafruit_BNO055_I2C1::VECTOR_GRAVITY);
    send_imu_reading(0, IMU_ID, gravity.x(), gravity.y(), gravity.z());
    next_reading = 0;
  }

  if (radio_has_data()) {
    Message *m = receive_message();
    switch(m->message_id) {
      if (m->controller_id != 0) {
        Serial.println("Messages should only be incoming from master.");
      }
      case ECHO:
        Serial.println("Echo received. Replying.");
        send_echo(m->controller_id, m->payload.verification_number);
        break;
      case MOTOR_COMMAND:
        Serial.println("Received motor command.");
        target_1 = (m->payload.motor_command.m1 != MOTOR_STAY)
          ? m->payload.motor_command.m1 : encoder1Pos;
        target_2 = (m->payload.motor_command.m2 != MOTOR_STAY)
          ? m->payload.motor_command.m2 : encoder2Pos;
        target_3 = (m->payload.motor_command.m3 != MOTOR_STAY)
          ? m->payload.motor_command.m3 : encoder3Pos;
        target_4 = (m->payload.motor_command.m4 != MOTOR_STAY)
          ? m->payload.motor_command.m4 : encoder4Pos;
        break;
      // the slave side should never have to deal with receiving encoder/imu data
      case ENCODER_READING:
      case IMU_READING:
        break;
      case ERROR: //TODO(vdonato): add more nontrivial error handling
        Serial.println("Something went wrong.");
        break;
    }
  }

  error_1 = target_1 - encoder1Pos;
  error_2 = target_2 - encoder2Pos;
  error_3 = target_3 - encoder3Pos;
  error_4 = target_4 - encoder4Pos;

  pTerm_1 = Kp_1 * error_1;
  pTerm_2 = Kp_2 * error_2;
  pTerm_3 = Kp_3 * error_3;
  pTerm_4 = Kp_4 * error_4;

  integrated_error_1 += error_1;
  integrated_error_2 += error_2;
  integrated_error_3 += error_3;
  integrated_error_4 += error_4;

  iTerm_1 = Ki_1 * constrain(integrated_error_1, -GUARD_GAIN, GUARD_GAIN);
  iTerm_2 = Ki_2 * constrain(integrated_error_2, -GUARD_GAIN, GUARD_GAIN);
  iTerm_3 = Ki_3 * constrain(integrated_error_3, -GUARD_GAIN, GUARD_GAIN);
  iTerm_4 = Ki_4 * constrain(integrated_error_4, -GUARD_GAIN, GUARD_GAIN);

  dTerm_1 = Kd_1 * (error_1 - last_error_1);
  dTerm_2 = Kd_2 * (error_2 - last_error_2);
  dTerm_3 = Kd_3 * (error_3 - last_error_3);
  dTerm_4 = Kd_4 * (error_4 - last_error_4);

  last_error_1 = error_1;
  last_error_2 = error_2;
  last_error_3 = error_3;
  last_error_4 = error_4;

  updatePid1 = constrain(K_1*(pTerm_1 + iTerm_1 + dTerm_1), -255, 255);
  updatePid2 = constrain(K_2*(pTerm_2 + iTerm_2 + dTerm_2), -255, 255);
  updatePid3 = constrain(K_3*(pTerm_3 + iTerm_3 + dTerm_3), -255, 255);
  updatePid4 = constrain(K_4*(pTerm_4 + iTerm_4 + dTerm_4), -255, 255);

  if (updatePid4 < 0) {
    analogWrite(sp4, abs(updatePid4));
  }
  else {
    analogWrite(spb4, updatePid4);
  }
  if (updatePid3 < 0) {
    analogWrite(sp3, abs(updatePid3));
  }
  else {
    analogWrite(spb3, updatePid3);
  }
  if (updatePid2 < 0) {
    analogWrite(sp2, abs(updatePid2));
  }
  else {
    analogWrite(spb2, updatePid2);
  }
  if (updatePid1 < 0) {
    analogWrite(sp1, abs(updatePid1));
  }
  else {
    analogWrite(spb1, updatePid1);
  }
}
