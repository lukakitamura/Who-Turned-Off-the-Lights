#include "Adafruit_TinyUSB.h"

// HID report descriptor using TinyUSB's template
// Single Report (no ID) descriptor
uint8_t const desc_hid_report[] = {
  TUD_HID_REPORT_DESC_GAMEPAD()
};

#define IA 3
#define IB 4
#define fader A1
float fader_pos = 0.0;
float fader_position = 0.0; 
float speed = 1.0; 

// USB HID object
Adafruit_USBD_HID usb_hid;

hid_gamepad_report_t gp;

//function to move slide to desired position
void go_to_position(int new_position) {
  fader_pos = int(analogRead(fader) / 4);
  while (abs(fader_pos - new_position) > 4) {
   if (fader_pos > new_position) {
    speed = 2.25 * abs(fader_pos - new_position) / 256 + 0.2;
    speed = constrain(speed, -1.0, 1.0);
      if (speed > 0.0) {
        analogWrite(IA, 0);
        analogWrite(IB, 255);
      }
   }
   if (fader_pos < new_position) {
      speed = 2.25 * abs(fader_pos - new_position) / 256 - 0.2;
      speed = constrain(speed, -1.0, 1.0);
        if (speed > 0.0) {
          analogWrite(IA, 255);
          analogWrite(IB, 0);
        }
      }
      
    fader_pos = int(analogRead(fader) / 4);
    
  }
  analogWrite(IA, 0);
  analogWrite(IB, 0);
}

void start_and_slide() {
  go_to_position(255); 
  delay(10); 
  while((int)analogRead(fader) > 3) {
    analogWrite(IA, 0); 
    analogWrite(IB, 200); 
    fader_pos = analogRead(fader);
    fader_position = map(fader_pos, 0, 1023, -127, 127);
    gp.rx = fader_position;
    usb_hid.sendReport(0, &gp, sizeof(gp)); 
  }
  analogWrite(IA, 0); 
  analogWrite(IB, 0); 
  
}

void setup() {
  if (!TinyUSBDevice.isInitialized()) {
    TinyUSBDevice.begin(0);
  }

  Serial.begin(9600);

  // Setup HID
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

  pinMode(IA, OUTPUT);
  pinMode(IB, OUTPUT);
  // analogWriteFrequency(100);
  analogWrite(IA, 0);
  analogWrite(IB, 0);

  /*
  delay(50);
  analogWrite(IA, 255);
  analogWrite(IB, 0);
  delay(100);
  analogWrite(IA, 0);
  analogWrite(IB, 255);
  delay(100);
  analogWrite(IA, 0);
  analogWrite(IB, 0);
  delay(10);
  */

  // Reset buttons
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
  // go_to_position(126); 
  // delay(20);
  // go_to_position(10); 
  // delay(20);
  // go_to_position(250); 
  // delay(20);
  // go_to_position(126);
  // delay(20);
  // start_and_slide(); 
  // delay(20); 
  analogWrite(IA, 0); 
  analogWrite(IB, 180); 
  delay(20); 
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
  
  fader_pos = analogRead(fader);
  // Serial.print(fader_pos);
  // Serial.print(" - ");
  // Serial.print(int(fader_pos /4));
  // Serial.print(" - "); 
  fader_position = map(fader_pos, 0, 1023, -127, 127); 
  // Serial.println(fader_position); 
  gp.rx = fader_position;
  usb_hid.sendReport(0, &gp, sizeof(gp)); 
  delay(10); 
}