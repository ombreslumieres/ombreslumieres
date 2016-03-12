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
boolean is_painting = false;
int spray_x = 0;
int spray_y = 0;

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
  if (is_painting && spray_path != null)
  {
    if (mousePressed)
    {
      spray_path.add(new Knot(mouseX, mouseY));
    }
  }
  if (spray_path != null)
  {
    spray_path.draw();
  }
  syphon_server.sendScreen();
}

void spray_at(int x, int y)
{
  if (! is_painting)
  {
    spray_begin(x, y);
  }
  else
  {
    spray_path.add(new Knot(x, y));
  }
}

void spray_begin(int x, int y)
{
  is_painting = true;
  Knot mouse_pos_knot = new Knot(x, y);
  spray_path = new Path(mouse_pos_knot, 10);
}

void spray_end()
{
  is_painting = false;
}

void mousePressed()
{
  spray_begin(mouseX, mouseY);
}

void mouseReleased()
{
  spray_end();
}

/**
 * Incoming osc message are forwarded to the oscEvent method.
 */
void oscEvent(OscMessage message)
{
  print("Received " + message.addrPattern() + " " + message.typetag() + "\n");
  if (message.checkAddrPattern("/spray/begin"))
  {
    int x;
    int y;
    if (message.checkTypetag("ii"))
    {
      x = message.get(0).intValue();
      y = message.get(1).intValue();
    }
    else if (message.checkTypetag("ff"))
    {
      x = (int) message.get(0).floatValue();
      y = (int) message.get(1).floatValue();
    }
    else
    {
      print("bad typetag\n");
      return;
    }
    println("  x = " + x + " y = " + y);
    spray_begin(x, y);
  }
  else if (message.checkAddrPattern("/spray/at"))
  {
    int x;
    int y;
    if (message.checkTypetag("ii"))
    {
      println("oui");
      x = message.get(0).intValue();
      y = message.get(1).intValue();
    }
    else if (message.checkTypetag("ff"))
    {
      x = (int) message.get(0).floatValue();
      y = (int) message.get(1).floatValue();
    }
    else
    {
      println("bad typetag");
      return;
    }
    println("  x = " + x + " y = " + y);
    spray_at(x, y);
  }
  if (message.checkAddrPattern("/spray/end"))
  {
    spray_end();
  }
}