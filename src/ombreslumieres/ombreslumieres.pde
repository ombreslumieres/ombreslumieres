/**
 * Ombres & lumières
 * Spray paint controlled via OSC.
 * Syphon output.
 * Dependencies:
 * - oscP5
 * - syphon
 */
 
import oscP5.*;
import netP5.*;
import codeanticode.syphon.*;


final int OSC_RECEIVE_PORT = 31337;
final int FRAME_RATE = 30;
final int VIDEO_OUTPUT_WIDTH = 1280;
final int VIDEO_OUTPUT_HEIGHT = 720;
final int OSC_SEND_PORT = 13333;
final String OSC_SEND_HOST = "127.0.0.1";
final String SYPHON_SERVER_NAME = "ombres&lumieres";

OscP5 osc_receiver;
NetAddress osc_send_address;
SyphonServer syphon_server;

void settings()
{
  size(VIDEO_OUTPUT_WIDTH, VIDEO_OUTPUT_HEIGHT, P3D);
  // frameRate(FRAME_RATE);
  PJOGL.profile = 1; // taken from the Syphon examples
}

void setup()
{
  // start oscP5, listening for incoming messages at a given port
  osc_receiver = new OscP5(this, OSC_RECEIVE_PORT);
  osc_send_address = new NetAddress(OSC_SEND_HOST, OSC_SEND_PORT);
  syphon_server = new SyphonServer(this, SYPHON_SERVER_NAME);
}


void draw()
{
  background(0);
  syphon_server.sendScreen();
}


void mousePressed()
{
  OscMessage message = new OscMessage("/lumieres/debug/mouse");
  message.add(mouseX);
  message.add(mouseY);
  osc_receiver.send(message, osc_send_address); 
}


/**
 * Incoming osc message are forwarded to the oscEvent method.
 */
void oscEvent(OscMessage message)
{
  print("Received OSC " + message.addrPattern() + " " + message.typetag());
}