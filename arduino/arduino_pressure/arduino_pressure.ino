/**
 * Reads a force sensor and broadcasts its value via OSC on a Wifi network.
 * This code is for the ESP8266 wifi device.
 * @author Louis-Robert Bouchard
 * @date 2016-03-16
 * 
 * - Start the Arduino IDE and open the Preferences window.
 * - Enter the following URL: http://arduino.esp8266.com/package_esp8266com_index.json 
 *   into Additional Board Manager URLs field.
 * - Open Boards Manager from Tools > Board menu and install the esp8266 platform.
 * - Choose the Olimex MOD-WIFI-ESP8266(-DEV) board type
 * - download zip from https://github.com/ameisso/OSCLib-for-ESP8266 and unzip it in ~/Documents/Arduino/librairies/ - or better,
 *   choose Sketch > Include Library > Add .ZIP Library...
 */
//#include <mem.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h> // Or <WiFiUDP.h> ?
#include <OSCMessage.h>
#include <OSCBundle.h>
    
// WiFi parameters
long sendCount = 0;
const char* ssid = "Dark Night";
const char* password = "bitcoin12333";
int valueSendi = 0;
int lastValue = 0;
boolean isUp = true;

WiFiUDP Udp;
IPAddress outIp(192, 168, 1, 6); // send to which IP
const unsigned int outPort = 31340;
const bool USE_BROADCAST = false; // if set to true will broadcast
const bool RESEND_REPETITIVE_VALUES = true;

void setup(void)
{ 
    // Start Serial
    Serial.begin(115200);
    // Connect to WiFi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }
    Serial.println("");
    Serial.println("WiFi connected");
    // Print the IP address
    Serial.println(WiFi.localIP());
}
   
void loop()
{
    if (USE_BROADCAST)
    {
        // Broadcast IP is the same as our local IP,
        // but we replace the last number by 255
        // Example: 192.168.0.255
        outIp = WiFi.localIP();
        outIp[3] = 255;
    }
    valueSendi = analogRead(A0);
    if (lastValue != valueSendi || RESEND_REPETITIVE_VALUES)
    {
        OSCMessage msg("/force");
        // TODO: add a string identifier as a 1st OSC argument
        msg.add(valueSendi);
        Udp.beginPacket(outIp, outPort);
        msg.send(Udp);
        Udp.endPacket();
        msg.empty();
   }
   lastValue = valueSendi;
   delay(30);  
}
