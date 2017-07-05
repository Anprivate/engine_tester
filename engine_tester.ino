#include <Wire.h>
#include <LiquidCrystal_PCF8574.h>
#include <Servo.h>

#define key_down 4
#define key_up 3
#define key_stop 2

LiquidCrystal_PCF8574 lcd(0x27);  // set the LCD address to 0x27 for a 16 chars and 2 line display

Servo Engine;  // create servo object to control a servo

uint16_t pwm_value;
uint16_t prev_pwm_value;

boolean prev_key1, prev_key2, prev_key3;

void setup() {
  int error;

  pinMode(key_down, INPUT_PULLUP);
  pinMode(key_up, INPUT_PULLUP);
  pinMode(key_stop, INPUT_PULLUP);

  prev_key1 = HIGH;
  prev_key2 = HIGH;
  prev_key3 = HIGH;

  pwm_value = 1000;
  prev_pwm_value = 1000;

  Engine.attach(9);
  Engine.writeMicroseconds(pwm_value);

  Serial.begin(115200);
  Serial.println("LCD...");

  while (! Serial);

  Serial.println("Dose: check for LCD");

  // See http://playground.arduino.cc/Main/I2cScanner
  Wire.begin();
  Wire.beginTransmission(0x27);
  error = Wire.endTransmission();
  Serial.print("Error: ");
  Serial.print(error);

  if (error == 0) {
    Serial.println(": LCD found.");

  } else {
    Serial.println(": LCD not found.");
  } // if

  lcd.begin(16, 2); // initialize the lcd
  lcd.setBacklight(255);
  lcd.home();
  lcd.clear();
  lcd.print("Engine");
  lcd.setCursor(0, 1);
  lcd.print("tester");
  delay(500);
}

void loop() {
  boolean now_key1 = digitalRead(key_down);
  if (now_key1 != prev_key1) {
    if (now_key1 == LOW) {
      if (pwm_value >= 1000) pwm_value -= 100;
    }
    prev_key1 = now_key1;
  }

  boolean now_key2 = digitalRead(key_up);
  if (now_key2 != prev_key2) {
    if (now_key2 == LOW) {
      if (pwm_value <= 2000) pwm_value += 100;
    }
    prev_key2 = now_key2;
  }

  uint16_t tmp_pwm_value = 1000;
  boolean now_key3 = digitalRead(key_stop);
  if (now_key3 == LOW) tmp_pwm_value = pwm_value;
  if (tmp_pwm_value != prev_pwm_value) {
    Engine.writeMicroseconds(tmp_pwm_value);
    prev_pwm_value = tmp_pwm_value;
  }

  uint16_t inU = analogRead(0);
  uint16_t inI = analogRead(1);
  float realU = float(inU) * 0.0454;
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("U=");
  lcd.print(realU,1);
  lcd.print("V");
  lcd.setCursor(8, 0);
  lcd.print("I=");
  lcd.print(inI);
  lcd.setCursor(0, 1);
  lcd.print("PWM=");
  lcd.print(pwm_value);
  if (now_key3 == HIGH) {
    lcd.setCursor(12,1);
    lcd.print("STOP");
  }

  delay(100);
}