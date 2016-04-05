/**
 * Sends OSC messages to our main sketch.
 * - Mouse around the mouse and press-drag its first button
 * - Press keys 1,2,3,4,5,6,7,8,9,0 to change color.
 */

import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;

final int OSC_RECEIVE_PORT = 31333;
final int OSC_SEND_PORT = 31340;
final String OSC_SEND_HOST = "127.0.0.1";
final color COLOR_1 = #FF0000;
final color COLOR_2 = #FFFF00;
final color COLOR_3 = #00FF00;
final color COLOR_4 = #00FFFF;
final color COLOR_5 = #0000FF;
final color COLOR_6 = #FF00FF;
final color COLOR_7 = #FFFFFF;
final color COLOR_8 = #333333;
final color COLOR_9 = #666666;
final color COLOR_0 = #CCCCCC;
final int MIN_BRUSH_WEIGHT = 40;
final int MAX_BRUSH_WEIGHT = 200;
final int BRUSH_WEIGHT_STEP = 10;
final String DEFAULT_IDENTIFIER = "default";
final boolean VERBOSE = false;
// FIXME: if force < 400, it means it's pressed. Counter-intuitive, I know.
final int FORCE_IF_PRESSED = 0;
final int FORCE_IF_NOT_PRESSED = 1023;
final float BRUSH_SCALE = 0.3; // FIXME: ratio taken from Knot.pde (not quite right)

NetAddress osc_send_address;
OscP5 osc_receiver;
boolean force_is_pressed = false;
float blob_x = 0.0;
float blob_y = 0.0;
float blob_size = 100.0;
int brush_weight = 100;

void setup()
{
  size(640, 480);
  frameRate(30);
  // start oscP5, listening for incoming messages at a given port
  osc_receiver = new OscP5(this, OSC_RECEIVE_PORT);
  osc_send_address = new NetAddress(OSC_SEND_HOST, OSC_SEND_PORT);
}

void draw()
{
  background(0);
  
  blob_x = mouseX;
  blob_y = mouseY;
  
  send_force();
  send_blob();
  send_brush_weight();
  draw_cursor();
  draw_head_up_display();
}

void draw_head_up_display()
{
  fill(255, 255, 255);
  textAlign(LEFT);
  int x_pos = 10;
  int force_value = (force_is_pressed ? FORCE_IF_PRESSED : FORCE_IF_NOT_PRESSED);
  text("Send to osc.udp://" + OSC_SEND_HOST + ":" + OSC_SEND_PORT, x_pos, 20);
  text("/blob " + DEFAULT_IDENTIFIER + " " + blob_x + " " + blob_y + " " + blob_size, x_pos, 40);
  text("/brush/weight " + DEFAULT_IDENTIFIER + " " + brush_weight, x_pos, 60);
  text("/force " + DEFAULT_IDENTIFIER + " " + force_value, x_pos, 80);
}

void mousePressed()
{
  force_is_pressed = true;
}

void mouseReleased()
{
  force_is_pressed = false;
}

void keyPressed()
{
  if (key == '1')
  {
    send_color(red(COLOR_1), green(COLOR_1), blue(COLOR_1));
  }
  else if (key == '2')
  {
    send_color(red(COLOR_2), green(COLOR_2), blue(COLOR_2));
  }
  else if (key == '3')
  {
    send_color(red(COLOR_3), green(COLOR_3), blue(COLOR_3));
  }
  else if (key == '4')
  {
    send_color(red(COLOR_4), green(COLOR_4), blue(COLOR_4));
  }
  else if (key == '5')
  {
    send_color(red(COLOR_5), green(COLOR_5), blue(COLOR_5));
  }
  else if (key == '6')
  {
    send_color(red(COLOR_6), green(COLOR_6), blue(COLOR_6));
  }
  else if (key == '7')
  {
    send_color(red(COLOR_7), green(COLOR_7), blue(COLOR_7));
  }
  else if (key == '8')
  {
    send_color(red(COLOR_8), green(COLOR_8), blue(COLOR_8));
  }
  else if (key == '9')
  {
    send_color(red(COLOR_9), green(COLOR_9), blue(COLOR_9));
  }
  else if (key == '0')
  {
    send_color(red(COLOR_0), green(COLOR_0), blue(COLOR_0));
  }
  else if (keyCode == UP)
  {
    increase_brush_weight();
  }
  else if (keyCode == DOWN)
  {
    decrease_brush_weight();
  }
}

void increase_brush_weight()
{
  brush_weight = min(MAX_BRUSH_WEIGHT, brush_weight + BRUSH_WEIGHT_STEP);
}

void decrease_brush_weight()
{
  brush_weight = max(MIN_BRUSH_WEIGHT, brush_weight - BRUSH_WEIGHT_STEP);
}

void draw_cursor()
{
  stroke(100);
  noFill();
  strokeWeight(1.0);
  if (force_is_pressed)
  {
    stroke(#ffcc33);
  }
  else
  {
    stroke(#33ccff);
  }
  float ellipse_size = brush_weight * BRUSH_SCALE;
  ellipse(blob_x, blob_y, ellipse_size, ellipse_size);
}

void send_blob()
{
  OscMessage message = new OscMessage("/blob");
  message.add(DEFAULT_IDENTIFIER);
  message.add(blob_x);
  message.add(blob_y);
  message.add(blob_size);
  if (VERBOSE)
  {
    println("/color " + DEFAULT_IDENTIFIER + " " + blob_x + " " + blob_y + " " + blob_size);
  }
  osc_receiver.send(message, osc_send_address);
}

void send_color(float r, float g, float b)
{
  OscMessage message = new OscMessage("/color");
  message.add(DEFAULT_IDENTIFIER);
  message.add(r);
  message.add(g);
  message.add(b);
  if (VERBOSE)
  {
    println("/color " + DEFAULT_IDENTIFIER + " " + r + " " + g + " " + b);
  }
  osc_receiver.send(message, osc_send_address);
}

void send_brush_weight()
{
  OscMessage message = new OscMessage("/brush/weight");
  message.add(DEFAULT_IDENTIFIER);
  message.add(brush_weight);
  if (VERBOSE)
  {
    println("/brush/weight " + DEFAULT_IDENTIFIER + " " + brush_weight);
  }
  osc_receiver.send(message, osc_send_address);
}

void send_force()
{
  OscMessage message = new OscMessage("/force");
  message.add(DEFAULT_IDENTIFIER);
  if (force_is_pressed)
  {
    message.add(FORCE_IF_PRESSED);
  }
  else
  {
    message.add(FORCE_IF_NOT_PRESSED);
  }
  if (VERBOSE)
  {
    println("/force " + DEFAULT_IDENTIFIER + " " + "?");
  }
  osc_receiver.send(message, osc_send_address);
}