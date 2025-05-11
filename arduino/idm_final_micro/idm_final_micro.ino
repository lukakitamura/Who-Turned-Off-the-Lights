#include <I2Cdev.h>
#include <MPU6050.h>
#include <Mouse.h>
#include <Keyboard.h>

// MPU6050 accelerometer 
MPU6050 mpu;
int16_t ax, ay, az, gx, gy, gz;
int vx, vy;

// vibration motor
const int motorPin = 9;

// toggle switch 
const int onOffSwitch = 8; 
bool onORoff; 

// 3-way sliding switch
const int switchPin1 = 6;
const int switchPin2 = 7; 
volatile int switchPin1State; 
volatile int switchPin2State; 

#define STATE_OFF 0
#define STATE_ONE 1
#define STATE_TWO 2

volatile int current_state; 
volatile int prev_state; 

int angleToDistanceX(int a)
{
  if (a < -80)
  {
    return -25;
  }
  else if (a < -65) {
    return -15;
  }
  else if (a < -50) {
    return -8;
  }
  else if (a < -15) {
    return -3;
  }
  else if (a < -5) {
    return -1;
  }
  else if (a > 80) {
    return 25;
  }
  else if (a > 65) {
    return 15;
  }
  else if (a > 32) {
    return 8; 
  }
  else if (a > 15) {
    return 5;
  }
  else if (a > 5) {
    return 1;
  }
  else if (a < 5) { 
    return 0; 
  }
}

int angleToDistanceY(int a)
{
  // if (a < -80)
  if (a < -100)
  {
    return -20;
    // return 0;
  }
  // else if (a < -65) {
  else if (a < -85) {
    return -10;
    // return 0;
  }
  // else if (a < -50) {
  else if (a < -70) {
    return -5;
    // return 0;
  }
  else if (a < -60) {
    return -1; 
  }
  else if (a < -50) {
    return 0; 
  }
  // else if (a < -15) {
  else if (a < -35) {
    return 0;
  }
  else if (a < -5) {
    return 0;
  }
  else if (a > 80) {
    return 20;
    // return 0;
  }
  else if (a > 65) {
    // return 20;
    return 10;
  }
  else if (a > 25) {
    return 8; 
  }
  else if (a > 15) {
    return 5;
    // return 0; 
  }
  else if (a > 5) {
    return 1;
  }
  else if (a < 5) { 
    return 0; 
  }
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Mouse.begin();
  Keyboard.begin(); 
  Wire.begin();
  pinMode(motorPin, OUTPUT); 

  mpu.initialize();
  if (!mpu.testConnection()) {
    Serial.println("MPU6050 not connected");
    while (1);
  }
  mpu.setXAccelOffset(-3000);
  mpu.setYAccelOffset(800); //800 
  mpu.setZAccelOffset(200); 
  mpu.setXGyroOffset(-42);
  mpu.setYGyroOffset(-42);
  mpu.setZGyroOffset(16); 

  pinMode(switchPin1, INPUT_PULLUP);
  pinMode(switchPin2, INPUT_PULLUP); 
  pinMode(onOffSwitch, INPUT_PULLUP); 

  onORoff = !digitalRead(onOffSwitch); 
}

// flag to only send keyboard commands once 
volatile bool flag = true; 
volatile bool OffFlag = true; 

void loop() {
  // put your main code here, to run repeatedly:
  mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
  onORoff = !digitalRead(onOffSwitch); 
  // Serial.print("on or off: ");
  // Serial.println(onORoff); 
  // vx = (gx - 200) / 200; 
  // vy = -(gz - 33) / 200; 
  vx = map(ax, -16000, 16000, 90, -90);
  vy = map(ay, -16000, 16000, 90, -90);

  // Serial.print("vx = ");
  // Serial.print(vx); 
  // Serial.print(" "); 
  // Serial.print("vy = "); 
  // Serial.print(vy); 
  // Serial.print(" "); 
  // Serial.print("az = "); 
  // Serial.print(az); 
  // Serial.print(" "); 
  // Serial.print("gx = ");
  // Serial.print(gx); 
  // Serial.print(" "); 
  // Serial.print("gy = ");

  // Serial.print(gy); 
  // Serial.print(" "); 
  // Serial.print("gz = ");
  // Serial.println(gz); 
  
  /*
  if(!switch1State) {
    // Serial.println("here");
    Mouse.move(angleToDistanceX(-1 * vy), angleToDistanceX(vx)); 
    if(button1State) {
      Mouse.press(); 
      analogWrite(motorPin, 255); 
    }
    else {
      Mouse.release(); 
      analogWrite(motorPin, 0); 
    }
  }
  */

  switchPin1State = digitalRead(switchPin1); 
  switchPin2State = digitalRead(switchPin2); 
  // Serial.println(prev_state); 
  if(switchPin1State && switchPin2State) {
    current_state = STATE_OFF;
    delay(10);
  }
  else if(switchPin1State && !switchPin2State) { 
    current_state = STATE_ONE; 
    delay(7); 
  }
  else if(!switchPin1State && !switchPin2State) {
    current_state = STATE_TWO; 
    delay(5); 
  }
  // Serial.println(current_state);
  if(prev_state != current_state) { 
    flag = true; 
  }
  if(onORoff) {
    OffFlag = true; 
    switch(current_state) { 
      case STATE_OFF: 
        // do nothing 
        if(flag == true) { 
          analogWrite(motorPin, 0); 
          Mouse.release(); 
          // delay(5); 
          flag = false;
          delay(10); 
          Keyboard.releaseAll(); 
        }
        Mouse.move(angleToDistanceX(vy), angleToDistanceX(vx)); 
        // Serial.println("state off");
        break;
      case STATE_ONE: 
        if(flag == true) { 
          Mouse.release(); 
          Keyboard.releaseAll(); 
          // delay(5); 
          analogWrite(motorPin, 128); 
          // Mouse.press(MOUSE_LEFT); 
          Keyboard.press('o');
          // delay(10); 
          flag = false;
        }
        Mouse.move(angleToDistanceX(vy), angleToDistanceX(vx)); 
        // Serial.println("state one");
        break; 
      case STATE_TWO: 
      if(flag == true) { 
          Mouse.release();
          Keyboard.releaseAll(); 
          // delay(5); 
          analogWrite(motorPin, 255); 
          // Mouse.press(MOUSE_RIGHT); 
          Keyboard.press('i');
          // delay(10); 
          flag = false;
          // Serial.println("right click");
        }
         Mouse.move(angleToDistanceX(vy), angleToDistanceX(vx)); 
        // Serial.println("state_two");
        break;
    }
  }
  else{
    if(OffFlag == true){ 
      Keyboard.press(KEY_RIGHT_ARROW);
      delay(50); 
      Keyboard.releaseAll(); 
      OffFlag = false; 
    } 
    Mouse.release(); 
  }
  prev_state = current_state; 
  
}
