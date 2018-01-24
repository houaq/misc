#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"

/************************* WiFi Access Point *********************************/

#define WLAN_SSID       "DVS"
#define WLAN_PASS       "33554432"

/************************* Broker Setup *********************************/

#define AIO_SERVER      "192.168.1.2"
#define AIO_SERVERPORT  1883                   // use 8883 for SSL
#define AIO_USERNAME    ""
#define AIO_KEY         ""

/************ Global State (you don't need to change this!) ******************/
static uint32_t fwVersion = 2;
static uint32_t mqttLostTimes = 0;
static uint32_t sentMessages = 0;
static uint32_t msForMessages = 0;
static uint32_t msForWiFi = 0;
static uint32_t msForMQTT = 0;
static IPAddress localIp;
static unsigned long pubTimer = 0;
 
// Create an ESP8266 WiFiClient class to connect to the MQTT server.
WiFiClient client;
// or... use WiFiFlientSecure for SSL
//WiFiClientSecure client;

// Setup the MQTT client class by passing in the WiFi client and MQTT server and login details.
Adafruit_MQTT_Client mqtt(&client, AIO_SERVER, AIO_SERVERPORT, AIO_USERNAME, AIO_KEY);

// Topics
Adafruit_MQTT_Publish pub = Adafruit_MQTT_Publish(&mqtt, "/test/wifi/message");
Adafruit_MQTT_Subscribe sub = Adafruit_MQTT_Subscribe(&mqtt, "/test/wifi/config");

/*************************** Sketch Code ************************************/

// Bug workaround for Arduino 1.6.6, it seems to need a function declaration
// for some reason (only affects ESP8266, likely an arduino-builder bug).
void MQTT_connect();

void setup() {
  Serial.begin(115200);
  delay(10);

  Serial.println(F("WiFi Tester started."));
  
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW); // turn led on during setup
  
  WiFi.mode(WIFI_STA);
  WiFi.setAutoReconnect(true);
  msForWiFi = millis();
  WiFi.begin(WLAN_SSID, WLAN_PASS);
  if (WiFi.waitForConnectResult() != WL_CONNECTED) {
    Serial.print("Failed to connect AP, resetting...");
    ESP.restart();
  }
  msForWiFi = millis() - msForWiFi;
  localIp = WiFi.localIP();
  Serial.print("WiFi Connected, IP address: "); Serial.println(localIp);

  // setup OTA
  ArduinoOTA.onStart([]() {
    String type;
    if (ArduinoOTA.getCommand() == U_FLASH)
      type = "sketch";
    else // U_SPIFFS
      type = "filesystem";

    // NOTE: if updating SPIFFS this would be the place to unmount SPIFFS using SPIFFS.end()
    Serial.println("Start updating " + type);
  });
  
  ArduinoOTA.onEnd([]() {
    Serial.println("\nEnd");
  });
  
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
  });
  
  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });
  
  ArduinoOTA.begin();
  
  // Setup MQTT subscription for config topic.
  mqtt.subscribe(&sub);
  digitalWrite(LED_BUILTIN, HIGH);  // setup done, turn led off
}

void modemSleep(uint32_t ms) {
  WiFi.setSleepMode(WIFI_MODEM_SLEEP);
  delay(ms);
  WiFi.setSleepMode(WIFI_NONE_SLEEP);
}

void loop() {
  unsigned long beginTime;
  bool ret;
  
  // Check wifi status
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi connection lost, resetting...");
    delay(5000);
    ESP.restart();
  }

  ArduinoOTA.handle();
  
  // Ensure the connection to the MQTT server is alive (this will make the first
  // connection and automatically reconnect when disconnected).  See the MQTT_connect
  // function definition further below.
  if (!mqtt.connected()) {
    mqttLostTimes++;
    beginTime = millis();
    if ((ret = mqtt.connect()) != 0) { // connect will return 0 for connected
         Serial.println(mqtt.connectErrorString(ret));
         mqtt.disconnect();
         return;
    }
    msForMQTT += millis() - beginTime;
    Serial.println("MQTT Connected!");
  }

  // first, check for config message
  Adafruit_MQTT_Subscribe *subscription;
  while ((subscription = mqtt.readSubscription(1))) {
    if (subscription == &sub) {
      Serial.print(F("Got: "));
      Serial.println((char *)sub.lastread);
    }
  }

  if (millis() < pubTimer)
    return;

  // Now we can publish stuff!
  digitalWrite(LED_BUILTIN, LOW);
  Serial.print(sentMessages);
  beginTime = millis();
  pubTimer = beginTime + 500;

  String message = String(localIp[3], 10);
  message += ", "; message += sentMessages;
  message += ", "; message += beginTime;
  message += ", "; message += fwVersion;
  message += ", "; message += mqttLostTimes;
  message += ", "; message += msForWiFi;
  message += ", "; message += WiFi.RSSI();
  message += ", "; message += msForMessages;
  message += F("$PADDINGPADDINGPADDINGPADDINGPADDINGPADDINGPADDINGPADDINGPADDINGPADDING");

  ret = pub.publish(message.c_str());
  msForMessages += millis() - beginTime;
  if (!ret) {
    Serial.println(F(" Failed"));
  } else {
    Serial.print("\r");
    sentMessages++;
  }
  digitalWrite(LED_BUILTIN, HIGH);
}