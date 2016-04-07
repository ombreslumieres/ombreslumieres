/**
 * Reads a force sensor and broadcasts its value via OSC on a Wifi network.
 * This code is for the ESP8266 wifi device.
 *
 * @author Louis-Robert Bouchard
 * @author Alexandre Quessy
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
#include <WiFiUdp.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
    
// WiFi parameters
const char* WIFI_SSID = "blues";
const char* WIFI_PASSWORD = "10002000300040005000600070";

// OSC settings
IPAddress osc_send_host(192, 168, 1, 108);
const unsigned int OSC_SEND_PORT = 31340;
const bool USE_BROADCAST = true; // if set to true will broadcast
const int SPRAY_IDENTIFIER = 0;

// business logic data
int last_force_value = 0;
WiFiUDP wifi_udp;
const bool RESEND_REPETITIVE_VALUES = true;

void setup(void)
{ 
    // Start Serial
    Serial.begin(115200);
    // Connect to WiFi
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
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
        osc_send_host = WiFi.localIP();
        osc_send_host[3] = 255;
    }
    int force_value = analogRead(A0);
    if (last_force_value != force_value || RESEND_REPETITIVE_VALUES)
    {
        OSCMessage osc_message("/force");
        osc_message.add(SPRAY_IDENTIFIER);
        osc_message.add(force_value);
        wifi_udp.beginPacket(osc_send_host, OSC_SEND_PORT);
        osc_message.send(wifi_udp);
        wifi_udp.endPacket();
        osc_message.empty();
   }
   last_force_value = force_value;
   delay(30);
}
