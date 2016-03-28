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

NetAddress osc_send_address;
OscP5 osc_receiver;
boolean force_is_pressed = false;
float blob_x = 0.0;
float blob_y = 0.0;
float blob_size = 100.0;

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
  draw_cursor();
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
  // TODO: 7,8,9,0
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
  ellipse(blob_x, blob_y, 30.0, 30.0);
}

void send_blob()
{
  OscMessage message = new OscMessage("/blob");
  message.add(blob_x);
  message.add(blob_y);
  message.add(blob_size);
  osc_receiver.send(message, osc_send_address);
}

void send_color(float r, float g, float b)
{
  OscMessage message = new OscMessage("/color");
  message.add(r);
  message.add(g);
  message.add(b);
  println("/color" + r + " " + g + " " + b);
  osc_receiver.send(message, osc_send_address);
}

void send_force()
{
  OscMessage message = new OscMessage("/force");
  if (force_is_pressed)
  {
    message.add(0); // FIXME: if force < 400, it means it's pressed. Counter-intuitive, I know.
  }
  else
  {
    message.add(1023);
  }
  osc_receiver.send(message, osc_send_address);
}