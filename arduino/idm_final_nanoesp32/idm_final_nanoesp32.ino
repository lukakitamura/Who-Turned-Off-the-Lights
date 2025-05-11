#include <Arduino.h>
#include <BleGamepad.h>
#include "Adafruit_seesaw.h"
#include <seesaw_neopixel.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_LEDBackpack.h>

// Rotary encoder stuff
#define SS_SWITCH        24
#define SS_NEOPIX        6

#define SEESAW_ADDR          0x36

Adafruit_seesaw ss;
seesaw_NeoPixel sspixel = seesaw_NeoPixel(1, SS_NEOPIX, NEO_GRB + NEO_KHZ800);

int32_t encoder_position;

// 7 segment display stuff
Adafruit_7segment display = Adafruit_7segment();

// BLE gamepad stuff 
BleGamepad bleGamepad; 
BleGamepadConfiguration bleGamepadConfig;

void setup() {
  Serial.begin(9600); 

  ss.begin(SEESAW_ADDR);
  sspixel.begin(SEESAW_ADDR); 
  // set not so bright!
  sspixel.setBrightness(20);
  sspixel.show();
  
  // use a pin for the built in encoder switch
  ss.pinMode(SS_SWITCH, INPUT_PULLUP);

  // get starting position
  encoder_position = ss.getEncoderPosition();

  Serial.println("Turning on interrupts");
  delay(10);
  ss.setGPIOInterrupts((uint32_t)1 << SS_SWITCH, 1);
  ss.enableEncoderInterrupt();

  sspixel.setPixelColor(0, Wheel(100 & 0xFF));
  sspixel.show();

  // 7-segment display stuff 
  display.begin(0x70); 
  display.setBrightness(15); 
  display.print(100); 
  display.writeDisplay(); 
  
  // gamepad stuff 
  bleGamepadConfig.setVid(0x18d1);
  bleGamepadConfig.setPid(0x9400);
  bleGamepad.begin(&bleGamepadConfig);
}

void loop() {
  int32_t new_position = ss.getEncoderPosition() % 101;
  // did we move arounde?
  if (encoder_position != new_position) {
    // Serial.println(new_position);         // display new position
    display.clear(); 
    int32_t down_value = 100 - abs(new_position);
    display.print(down_value); 
    display.writeDisplay(); 
    // change the neopixel color
    sspixel.setPixelColor(0, Wheel(down_value & 0xFF));
    sspixel.show();
    encoder_position = new_position;      // and save for next round
    // bleGamepad.setAxes(32767, 0, 0, 0, 0,0 ,0 ,0); 
  }
  // bleGamepad.setAxes();
  bleGamepad.setAxes(0, 32767, 0, 0, 0,0 ,0 ,0); 
  // bleGamepad.sendReport();
  // don't overwhelm serial port
  delay(2000);
  bleGamepad.setAxes(); 
  delay(2000);
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
