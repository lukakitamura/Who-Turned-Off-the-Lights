#include "Adafruit_TinyUSB.h"
#include <Arduino.h>
#include "Adafruit_seesaw.h"
#include <seesaw_neopixel.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_LEDBackpack.h>
#include "Adafruit_ZeroTimer.h"


// gamepad stuff
uint8_t const desc_hid_report[] = {
  TUD_HID_REPORT_DESC_GAMEPAD()
};

// USB HID object
Adafruit_USBD_HID usb_hid;

hid_gamepad_report_t gp;

// Rotary encoder stuff
#define SS_SWITCH        24
#define SS_NEOPIX        6

#define SEESAW_ADDR          0x36

Adafruit_seesaw ss;

int32_t encoder_position;

// 7 segment display stuff
Adafruit_7segment display = Adafruit_7segment();

// button stuff
const int button = 3; 
volatile bool buttonFlag = true; 
// volatile int buttonState;

// counter
int countVal = 1; 
float counter_val; 

// timer stuff 
volatile unsigned long secondsPassed = 0; 
unsigned long startMillis; 
unsigned long currentMillis; 
const unsigned long period = 500; 

void setup() {
  // Serial.begin(9600); 
  // put your setup code here, to run once:
  // rotary setup 
  ss.begin(SEESAW_ADDR);

  // use a pin for the built in encoder switch
  ss.pinMode(SS_SWITCH, INPUT_PULLUP);

  // get starting position
  encoder_position = ss.getEncoderPosition();

  delay(10);
  ss.setGPIOInterrupts((uint32_t)1 << SS_SWITCH, 1);
  ss.enableEncoderInterrupt();

  // 7-segment display stuff 
  display.begin(0x70); 
  display.setBrightness(15); 
  display.print(800); 
  display.writeDisplay(); 

  // button setup 
  pinMode(button, INPUT_PULLUP); 
  buttonFlag = digitalRead(button); 
  attachInterrupt(digitalPinToInterrupt(button), ISR, RISING); 

  // gamepad setup 
  if (!TinyUSBDevice.isInitialized()) {
    TinyUSBDevice.begin(0);
  }

  TinyUSBDevice.setID(0x18d1, 0x9400); 
  usb_hid.setPollInterval(2);
  usb_hid.setReportDescriptor(desc_hid_report, sizeof(desc_hid_report));
  usb_hid.begin();

  // If already enumerated, additional class driverr begin() e.g msc, hid, midi won't take effect until re-enumeration
  if (TinyUSBDevice.mounted()) {
    TinyUSBDevice.detach();
    delay(10);
    TinyUSBDevice.attach();
  }
  // Reset gamepad buttons
  gp.x = 0;
  gp.y = 0;
  gp.z = 0;
  gp.rz = 0;
  gp.rx = 0;
  gp.ry = 0;
  gp.hat = 0;
  gp.buttons = 0;
  usb_hid.sendReport(0, &gp, sizeof(gp));
  delay(200); 

  display.begin(0x70); 
  display.setBrightness(15); 
  display.print(countVal); 
  display.writeDisplay(); 
  startMillis = millis(); 
}

bool flag = false; 

void loop() {
  // put your main code here, to run repeatedly:
  currentMillis = millis(); 
  if(currentMillis - startMillis >= period) { 
    if(flag == false) { 
      secondsPassed += 1; 
      startMillis = currentMillis; 
    }
    else { 
      // secondsPassed -= 1; 
      startMillis = currentMillis; 
    }
    
  }
  
  
  #ifdef TINYUSB_NEED_POLLING_TASK
  // Manual call tud_task since it isn't called by Core's background
  TinyUSBDevice.task();
  #endif

  // not enumerated()/mounted() yet: nothing to do
  if (!TinyUSBDevice.mounted()) {
    return;
  }

  if (!usb_hid.ready()) return;

  int32_t new_position = ss.getEncoderPosition();
  if(digitalRead(button) == 0 && buttonFlag == true) { 
    buttonFlag = false; 
    gp.buttons = (1U << 0);
    usb_hid.sendReport(0, &gp, sizeof(gp)); 
    delay(500); 
    gp.x = 0;
    gp.y = 0;
    gp.z = 0;
    gp.rz = 0;
    gp.rx = 0;
    gp.ry = 0;
    gp.hat = 0;
    gp.buttons = 0;
    usb_hid.sendReport(0, &gp, sizeof(gp));
    display.clear(); 
    display.print(countVal); 
    display.writeDisplay(); 
    countVal = 1; 
    delay(10); 
  }

  // int32_t new_position = ss.getEncoderPosition() % 101;

  // did we move arounde?
  if ((encoder_position != new_position) && (countVal < 100)) {
    // Serial.println(new_position);         // display new position
    encoder_position = new_position;      // and save for next round
    // countVal = countVal + second; 
    // startMillis = millis(); 
    display.clear(); 
    display.print(countVal); 
    display.writeDisplay(); 
    secondsPassed -= 1; 
  }

  if(countVal <= 0) {
    // startMillis = millis(); 
    flag = true;
    secondsPassed = 100; 
    display.clear(); 
    display.print(countVal); 
    display.writeDisplay(); 
  }
  else
  {
    flag = false;
  }

  display.clear();
  if (flag == false) 
    countVal = 100 - secondsPassed;
  else
    countVal = 0;
  // countVal = countVal - 1; 
  display.print(countVal); 
  display.writeDisplay(); 
  

  counter_val = map(countVal, 0, 100, -127, 127);
  // Serial.println(counter_val); 
  gp.rz = counter_val; 
  usb_hid.sendReport(0, &gp, sizeof(gp)); 
  delay(10); 


}

void ISR() {
  buttonFlag = true; 
}
