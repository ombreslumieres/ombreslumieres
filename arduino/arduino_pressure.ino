// Import required libraries
#include <mem.h>
#include <ESP8266WiFi.h>
#include <WiFiUDP.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
    
    // WiFi parameters
    long sendCount = 0;
    const char* ssid = "Westside-FU124";
    const char* password = "Betterave$pasFine122";
    int valueSendi = 0;
    float valueSendf = 0.0;
    boolean isUp = true;
​
WiFiUDP Udp;
const IPAddress outIp(192, 168, 0, 102);
const unsigned int outPort = 31340;
    
    void setup(void)
    { 
    // Start Serial
    Serial.begin(115200);
    
    // Connect to WiFi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    }
    Serial.println("");
    Serial.println("WiFi connected");
    // Print the IP address
    Serial.println(WiFi.localIP());
    }
    
   
    void loop() {
  sendCount ++;
  if (sendCount > 100000){
​
  
  if (valueSendf >= 10.0){
​
    isUp = false;
  }else if ( valueSendf <= 0){
    isUp = true;
  }
​
  if (isUp){
  valueSendf = valueSendf + 0.001;
  }else{
    valueSendf = valueSendf - 0.001;
  }
​
   
  OSCMessage msg("/test/");
  msg.add(valueSendf);
  Udp.beginPacket(outIp, outPort);
  msg.send(Udp);
  Udp.endPacket();
  msg.empty();
      
    }
    }
