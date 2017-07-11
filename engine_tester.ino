#include <Key.h>
#include <Keypad.h>

#include <Wire.h>
#include <LiquidCrystal_PCF8574.h>
#include <Servo.h>

#include <Q2HX711.h>

const byte key_down = 4;
const byte key_up = 3;
const byte key_stop = 2;

const byte hx_data_pin = 5;
const byte hx_clock_pin = 6;

const uint16_t hx_scaler = 500;
int32_t hx_zero_value;
int32_t hx_zero_summ = 0;
int8_t hx_sample_counter = 0;

Q2HX711 hx711(hx_data_pin, hx_clock_pin);

LiquidCrystal_PCF8574 lcd(0x27);  // set the LCD address to 0x27 for a 16 chars and 2 line display

Servo Engine;  // create servo object to control a servo

uint16_t pwm_value;
uint16_t prev_pwm_value;

boolean prev_key1, prev_key2, prev_key3;

char line1[17] = "U=12.0V I=1.5A   \0";
char line2[17] = "PWM=1000    STOP\0";

char stop_line[] = "STOP";

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

  hx711.read();

  Serial.begin(115200);
  Serial.println("LCD...");

  while (! Serial);

  Serial.println("Dose: check for LCD");

  Wire.begin();
  Wire.beginTransmission(0x27);
  error = Wire.endTransmission();

  if (error == 0) {
    Serial.println("LCD found.");

  } else {
    Serial.print("Error: ");
    Serial.print(error);
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
      else pwm_value = 900;
    }
    prev_key1 = now_key1;
  }

  boolean now_key2 = digitalRead(key_up);
  if (now_key2 != prev_key2) {
    if (now_key2 == LOW) {
      if (pwm_value <= 2000) pwm_value += 100;
      else pwm_value = 2100;
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
  float realU = float(inU) * 0.0437;
  float realI = float(inI) * 0.0776;

  int32_t hx_curr_reading = hx711.read();
  if (hx_sample_counter < 10) {
    hx_sample_counter++;
    hx_zero_summ += hx_curr_reading;
    hx_zero_value = hx_zero_summ / hx_sample_counter;
  }

  int16_t real_weight = (hx_curr_reading - hx_zero_value) / 500;

  Serial.print("U=");
  Serial.print(realU, 1);
  Serial.print("V I=");
  Serial.print(realI, 1);
  Serial.print("A PWM=");
  Serial.print(pwm_value);
  Serial.print(" T=");
  Serial.print(real_weight);
  Serial.print("g ");

  dtostrf(realU, 4, 1, line1 + 2);
  line1[6] = 'V';

  dtostrf(realI, 4, 1, line1 + 10);
  line1[14] = 'A';

  for (uint8_t i = 4; i < 16; i++) line2[i] = ' ';
  itoa(pwm_value, line2 + 4, 10);
  for (uint8_t i = 0; i < 16; i++) if (line2[i] == 0) line2[i] = ' ';

  if (now_key3 == HIGH) {
    uint8_t i = 0;
    while (stop_line[i] != 0) {
      line2[i + 12] = stop_line[i];
      i++;
    }
    Serial.println("STOP");
  } else {
    for (uint8_t i = 12; i < 16; i++) line2[i] = ' ';
    Serial.println("RUN");
  }

  line1[16] = 0;
  line2[16] = 0;

  lcd.setCursor(0, 0);
  lcd.print(line1);
  lcd.setCursor(0, 1);
  lcd.print(line2);

  if (Serial.available() > 0) {
    static uint16_t ser_pwm_value = 0;
    char inchar = Serial.read();
    if (isDigit(inchar)) {
      ser_pwm_value *= 10;
      ser_pwm_value += inchar - '0';
    } else {
      if (inchar == '\r') {
        if ((ser_pwm_value >= 900) && (ser_pwm_value <= 2100))
          pwm_value = ser_pwm_value;
      }
      ser_pwm_value = 0;
    }
  }

  delay(100);
}
