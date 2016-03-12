/**
 * Ombres & lumières
 * Spray paint controlled via OSC.
 * Syphon output.
 * Dependencies:
 * - oscP5
 * - syphon
 */

import codeanticode.syphon.SyphonServer;
import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;


final int OSC_RECEIVE_PORT = 31337;
final int FRAME_RATE = 30;
final int VIDEO_OUTPUT_WIDTH = 1280;
final int VIDEO_OUTPUT_HEIGHT = 720;
final int OSC_SEND_PORT = 13333;
final String OSC_SEND_HOST = "127.0.0.1";
final String SYPHON_SERVER_NAME = "ombres&lumieres";
final boolean debug = false;

PShader pointShader;
OscP5 osc_receiver;
NetAddress osc_send_address;
SyphonServer syphon_server;
Path spray_path;

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
  pointShader = loadShader("pointfrag.glsl", "pointvert.glsl");
  strokeCap(SQUARE);
  background(0);
}


void draw()
{
  if (mousePressed)
  {
    if (spray_path != null)
    {
      spray_path.add(new Knot(mouseX, mouseY));
    }
  }
  if(spray_path != null)
  {
    spray_path.draw();
  }
  syphon_server.sendScreen();
}


void mousePressed()
{
  Knot mouse_pos_knot = new Knot(mouseX, mouseY);
  spray_path = new Path(mouse_pos_knot, 10);
}


/**
 * Incoming osc message are forwarded to the oscEvent method.
 */
void oscEvent(OscMessage message)
{
  print("Received OSC " + message.addrPattern() + " " + message.typetag());
}