#include "SparkFunLSM6DS3.h"
#include <SPI.h>
#include <Wire.h>
#include <WiFi101.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
#include <OSCData.h>
 

const char* ssid     = "mmLinksysEA7500-2.4";
// const char* ssid     = "sideroxylon";
const char* password = "ddcgrvc4zw";
 
WiFiUDP udp; // A UDP instance to let us send and receive packets over UDP
const IPAddress outIp(192,168,109,103); // remote IP of your computer
// const IPAddress outIp(10,42,0,1); // remote IP of your computer
const unsigned int outPort = 50501; // remote port to receive OSC
const unsigned int localPort = 50502; // local port to listen for OSC packets


// const int butPins[10] = { 0,1,20,21,5,6,9,10,11,12 };
// GPIO 9 can be used as A7 to monitor battery voltage.
// Use GPIO 16 (A2) instead.
const int butPins[10] = { 0,1,20,21,5,6,16,10,11,12 };
const int ledPin = 17; // Controler pin for LED strip.

OSCErrorCode error;

LSM6DS3 SensorOne( SPI_MODE, 18 );  // pin A4 on feather
LSM6DS3 SensorTwo( SPI_MODE, 19 );  // pin A5 on feather

void setup(){
  //Configure pins for Adafruit ATWINC1500 Feather
  WiFi.setPins(8,7,4,2);
  
  Serial.begin(115200);
  analogReadResolution(12);
  // Make butPins INPUT pins with pull up resistor.
  for (int i=0; i < 10; i++){
    pinMode(butPins[i], INPUT_PULLUP);
  }

  // pinMode(12, INPUT);
  /* Wire.begin(); */

  delay(100);
 
  // We start by connecting to a WiFi network
 
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  
  // WiFi.begin(ssid, password);
  WiFi.begin(ssid,password);
  
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
 
  Serial.println("");
  Serial.println("WiFi connected");  
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  Serial.println("Starting UDP");
  udp.begin(localPort);
  Serial.print("Local port: ");
  Serial.println(localPort);
  //Over-ride default settings if desired
  SensorOne.settings.gyroEnabled = 1;  //Can be 0 or 1
  SensorOne.settings.gyroRange = 2000;   //Max deg/s.  Can be: 125, 245, 500, 1000, 2000
  SensorOne.settings.gyroSampleRate = 1666;   //Hz.  Can be: 13, 26, 52, 104, 208, 416, 833, 1666
  SensorOne.settings.gyroBandWidth = 400;  //Hz.  Can be: 50, 100, 200, 400;
  SensorOne.settings.accelEnabled = 1;
  SensorOne.settings.accelRange = 2;      //Max G force readable.  Can be: 2, 4, 8, 16
  SensorOne.settings.accelSampleRate = 13330;  //Hz.  Can be: 13, 26, 52, 104, 208, 416, 833, 1666, 3332, 6664, 13330
  SensorOne.settings.accelBandWidth = 400;  //Hz.  Can be: 50, 100, 200, 400;
  SensorOne.settings.fifoModeWord = 0;  //FIFO mode.

    //Over-ride default settings if desired
  SensorTwo.settings.gyroEnabled = 1;  //Can be 0 or 1
  SensorTwo.settings.gyroRange = 2000;   //Max deg/s.  Can be: 125, 245, 500, 1000, 2000
  SensorTwo.settings.gyroSampleRate = 1666;   //Hz.  Can be: 13, 26, 52, 104, 208, 416, 833, 1666
  SensorTwo.settings.gyroBandWidth = 400;  //Hz.  Can be: 50, 100, 200, 400;
  SensorTwo.settings.accelEnabled = 1;
  SensorTwo.settings.accelRange = 2;      //Max G force readable.  Can be: 2, 4, 8, 16
  SensorTwo.settings.accelSampleRate = 13330;  //Hz.  Can be: 13, 26, 52, 104, 208, 416, 833, 1666, 3332, 6664, 13330
  SensorTwo.settings.accelBandWidth = 400;  //Hz.  Can be: 50, 100, 200, 400;
  SensorTwo.settings.fifoModeWord = 0;  //FIFO mode.

  //FIFO mode.  Can be:
  //  0 (Bypass mode, FIFO off)
  //  1 (Stop when full)
  //  3 (Continuous during trigger)
  //  4 (Bypass until trigger)
  //  6 (Continous mode)


  delay(1000);
  if( SensorOne.begin() != 0 ) {
    Serial.println("Problem starting the sensor with CS @ Pin 18 (A4).");
  } else {
    Serial.println("Sensor with CS @ Pin 18 (A4) started.");
  }
  if( SensorTwo.begin() != 0 ) {
    Serial.println("Problem starting the sensor with CS @ Pin 19 (A5).");
  } else {
    Serial.println("Sensor with CS @ Pin 19 (A5) started.");
  }
}

void loop(){
  OSCMessage message;
  int size = udp.parsePacket();
  int butVal[10]; // valeurs des boutons
  int compButVal=0; // composed into a single 32 bit integer (only 10 are used).
  int analVal[2]; // valeurs des capateurs analogiques

  if (size) {
    while (size--) {
      message.fill(udp.read());
    }
    if (!message.hasError()) {
      /* message.dispatch("/set_register", osc_set_register); */
    } else {
      error = message.getError();
      Serial.print("error: ");
      Serial.println(error);
    }
  }

  // Serial.println( (SensorOne.readRawAccelX() >> 6) + 512);
  // Serial.print(SensorOne.readRawAccelY());
  // Serial.print(SensorOne.readRawAccelZ());
  // Serial.print(SensorOne.readRawGyroX());
  // Serial.print(SensorOne.readRawGyroY());
  // Serial.print(SensorOne.readRawGyroZ());


  // int anal0 = analogRead(1);
  // OSCBundle bndl;
  OSCMessage msg("/sponge"); // 8 bytes
  // OSCMessage time("/time");
  // uint64_t timetag;
  // msg.add(anal0);
  // types are ,iiiiiiiiiiiii // 4 bytes
  msg.add(int(SensorOne.readRawAccelX())); // int 0
  msg.add(int(SensorOne.readRawAccelY())); // int 1
  msg.add(int(SensorOne.readRawAccelZ())); // int 2
  // msg.add(int(SensorOne.readRawGyroX()));
  // msg.add(int(SensorOne.readRawGyroY()));
  // msg.add(int(SensorOne.readRawGyroZ()));
  msg.add(int(SensorTwo.readRawAccelX())); // int 3
  msg.add(int(SensorTwo.readRawAccelY())); // int 4
  msg.add(int(SensorTwo.readRawAccelZ())); // int 5
  // msg.add(int(SensorTwo.readRawGyroX()));
  // msg.add(int(SensorTwo.readRawGyroY()));
  // msg.add(int(SensorTwo.readRawGyroZ()));
  for (int i=0; i < 2; i ++){ // ints 6 and 7
    analVal[i] = analogRead(i);
    msg.add(int(analogRead(i)));
  };


  for (int i=0; i < 10; i ++){
    butVal[i] = digitalRead(butPins[i]);
    compButVal |= (butVal[i] << (9-i));
    /* La ligne précédente place les valeurs binaires de chacun des boutons
       dans un seul entier à 16 bit.  Si on représente l'entier en binaire:
       (b01001011001 = d601),  on a une représentation des boutons activés.
       Dans ce cas, les boutons 0,3,4,6 et 9 sont enfoncés.
    */
  };

  msg.add(compButVal ^ 1023); // 4 bytes  (^ is a bitwise XOR)

  // bndl.add("/sponge").add("one");
  // msg.add(1).add(2).add(3).add(4).add(5).add(6).add(7).add(8).add(9).add(10).add(11).add(12); // 48 bytes of arbitrary ints.
  // Total size is 64 bytes. (excluding the UDP packet stuff)
  // time.add((uint32_t)micros() & 0xFFFF);
  udp.beginPacket(outIp, outPort);
  // bndl.setTimetag(oscTime());
  msg.send(udp);
  udp.endPacket();
  msg.empty();

  // wait a bit.
  // delay(5);
  delay(20);
  // delay(1);
  // delayMicroseconds(10);

  if (WiFi.status() != WL_CONNECTED) {
    // WiFi.end();
    while (WiFi.begin(ssid) != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }
    Serial.print("Reconnected to ");
    Serial.print(ssid);
  }
}
