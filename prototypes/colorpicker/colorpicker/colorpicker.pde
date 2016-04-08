/**
 * Color picker for Encres & Lumieres.
 *
 * 4 horizontal sliders controlling the RGBA channels of a color.
 * See www.sojamo.de/libraries/controlP5
 */
import controlP5.ControlP5;
import controlP5.ControlEvent;
import controlP5.ColorPicker;
import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;

final int OSC_RECEIVE_PORT = 31331;
final int OSC_SEND_PORT = 31340;
final String OSC_SEND_HOST = "127.0.0.1";

ControlP5 control_p5;
ColorPicker color_picker;
NetAddress osc_send_address;
OscP5 osc_receiver;
int current_identifier = 0; // TODO: allow to change this

void setup()
{
  size(300, 150);
  noStroke();
  control_p5 = new ControlP5(this);
  color_picker = control_p5.addColorPicker("picker")
          .setPosition(10, 10)
          .setColorValue(color(255, 128, 0, 255));
  // start oscP5, listening for incoming messages at a given port
  osc_receiver = new OscP5(this, OSC_RECEIVE_PORT);
  osc_send_address = new NetAddress(OSC_SEND_HOST, OSC_SEND_PORT);
}

void draw()
{
  background(color_picker.getColorValue());
}

public void controlEvent(ControlEvent c)
{
  // when a value change from a ColorPicker is received, extract the ARGB values
  // from the controller's array value
  if (c.isFrom(color_picker))
  {
    int r = int(c.getArrayValue(0));
    int g = int(c.getArrayValue(1));
    int b = int(c.getArrayValue(2));
    int a = int(c.getArrayValue(3));
    color col = color(r, g, b, a);
    send_color(r, g, b); // TODO: a
    // println("event\talpha:"+a+"\tred:"+r+"\tgreen:"+g+"\tblue:"+b+"\tcol"+col);
  }
}

/**
 * Color information from ColorPicker 'picker' are forwarded to
 * the picker(int) function.
 */
void picker(int col)
{
  // println("picker\talpha:"+alpha(col)+"\tred:"+red(col)+"\tgreen:"+green(col)+"\tblue:"+blue(col)+"\tcol"+col);
}

void keyPressed()
{
  switch(key)
  {
    case('1'):
      // method A to change color
      color_picker.setArrayValue(new float[] {120, 0, 120, 255});
      break;
    case('2'):
      // method B to change color
      color_picker.setColorValue(color(255, 0, 0, 255));
      break;
  }
}

void send_color(float r, float g, float b)
{
  OscMessage message = new OscMessage("/color");
  message.add(current_identifier);
  message.add(r);
  message.add(g);
  message.add(b);
  // println("/color" + r + " " + g + " " + b);
  osc_receiver.send(message, osc_send_address);
}