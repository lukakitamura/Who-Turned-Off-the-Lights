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
seesaw_NeoPixel sspixel = seesaw_NeoPixel(1, SS_NEOPIX, NEO_GRB + NEO_KHZ800);

int32_t encoder_position;

// 7 segment display stuff
Adafruit_7segment display = Adafruit_7segment();

// button stuff
const int button = 3; 
volatile bool buttonFlag = true; 
// volatile int buttonState;

// counter
volatile int countVal = 100; 

// timer stuff 
/*
// Last decimal value written to the display
unsigned long lastTimeDisplayed = -1;

Adafruit_ZeroTimer timer = Adafruit_ZeroTimer(3);

void TC3_Handler() {
  Adafruit_ZeroTimer::timerHandler(3);
}

// the timer callback
volatile unsigned long secondsPassed = 0;

void TimerCallback0(void)
{
  secondsPassed += 1;
}
*/
volatile unsigned long secondsPassed = 0;
unsigned long startMillis;  //some global variables available anywhere in the program
unsigned long currentMillis;
const unsigned long period = 1000;


void setup() {
  // Serial.begin(9600); 
  // rotary setup 
  ss.begin(SEESAW_ADDR);
  sspixel.begin(SEESAW_ADDR); 
  // set not so bright!
  sspixel.setBrightness(20);
  sspixel.show();
  // use a pin for the built in encoder switch
  ss.pinMode(SS_SWITCH, INPUT_PULLUP);

  // get starting position
  encoder_position = ss.getEncoderPosition();

  delay(10);
  ss.setGPIOInterrupts((uint32_t)1 << SS_SWITCH, 1);
  ss.enableEncoderInterrupt();

  sspixel.setPixelColor(0, Wheel(100 & 0xFF));
  sspixel.show();

  // 7-segment display stuff 
  display.begin(0x70); 
  display.setBrightness(15); 
  display.print(countVal); 
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

  // setup timer
  /*
  // Set up the flexible compare/prescaler for 1Hz, see Adafruit_ZeroTimer examples
  uint16_t compare = 48000000/1024;
  tc_clock_prescaler prescaler = TC_CLOCK_PRESCALER_DIV1024;

  timer.enable(false);
  timer.configure(prescaler,           // prescaler
          TC_COUNTER_SIZE_16BIT,       // bit width of timer/counter
          TC_WAVE_GENERATION_MATCH_PWM // frequency or PWM mode
          );

  timer.setCompare(0, compare);
  timer.setCallback(true, TC_CALLBACK_CC_CHANNEL0, TimerCallback0);
  timer.enable(true);
  */


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
  startMillis = millis();
}

void loop() {
  #ifdef TINYUSB_NEED_POLLING_TASK
  // Manual call tud_task since it isn't called by Core's background
  TinyUSBDevice.task();
  #endif

  // not enumerated()/mounted() yet: nothing to do
  if (!TinyUSBDevice.mounted()) {
    return;
  }

  if (!usb_hid.ready()) return;

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
    delay(10); 
    countVal = 100; 
    startMillis = millis();
  }

  int32_t new_position = ss.getEncoderPosition() % 101;
  // did we move arounde?
  if (encoder_position != new_position && countVal < 100) {
    // Serial.println(new_position);         // display new position
    display.clear(); 
    countVal = countVal + abs(new_position);
    display.print(countVal); 
    display.writeDisplay(); 
    // change the neopixel color
    sspixel.setPixelColor(0, Wheel(countVal & 0xFF));
    sspixel.show();
    encoder_position = new_position;      // and save for next round
    startMillis = millis(); 
  }
  currentMillis = millis();  //get the current "time" (actually the number of milliseconds since the program started)
  if (currentMillis - startMillis >= period) {
    secondsPassed += 1;
    startMillis = currentMillis; 
  }
  // secondsPass
  if(countVal != 0) {
    display.clear(); 
    countVal = countVal - secondsPassed;
    display.print(countVal); 
    display.writeDisplay(); 
  }

  else if(countVal == 0) { 
    secondsPassed = 0; 
  }

  // gp.ry = -127; 
  // usb_hid.sendReport(0, &gp, sizeof(gp)); 
  // delay(1000); 
  // gp.ry =127; 
  // usb_hid.sendReport(0, &gp, sizeof(gp)); 
  // delay(1000); 

}


uint32_t Wheel(byte WheelPos) {
  WheelPos = 255 - WheelPos;
  if (WheelPos < 85) {
    return sspixel.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  }
  if (WheelPos < 170) {
    WheelPos -= 85;
    return sspixel.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
  WheelPos -= 170;
  return sspixel.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
}

void ISR() {
  buttonFlag = true; 
}