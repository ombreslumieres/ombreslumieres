/**
 * Encres & lumières
 * Spray paint controlled via OSC.
 * Syphon output.
 * Dependencies:
 * - oscP5
 * - syphon
 */
// XXX comment out next line if not using Syphon
//import codeanticode.syphon.SyphonServer;
import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;

final int OSC_RECEIVE_PORT = 31340;
final int OSC_SEND_PORT = 13333;
final String OSC_SEND_HOST = "127.0.0.1";
final String SYPHON_SERVER_NAME = "encres&lumieres";
final boolean debug = false; // also draw a red stroke
final int BLOB_INPUT_WIDTH = 640;
final int BLOB_INPUT_HEIGHT = 480;
final int FORCE_MAX = 1023; // no need to change this
final int FORCE_THRESHOLD = 623; // you might need to change this
final int BRUSH_MIN = 50;
final int BRUSH_MAX = 150;
final String VERSION = "0.2.1";
final float BRUSH_SCALE = 0.3; // FIXME: ratio taken from Knot.pde (not quite right)

SprayManager spray_manager;
PShader global_point_shader; // See http://glsl.heroku.com/e#4633.5
// Spray density distribution expressed in grayscale gradient
PImage sprayMap;
float brush_weight;
float depth_offset;
float offsetVel;
PImage background_image;
PGraphics paintscreen;
//Path s;
color spray_color;
OscP5 osc_receiver;
NetAddress osc_send_address;
// XXX comment out next line if not using Syphon
//SyphonServer syphon_server;
int spray_x = 0;
int spray_y = 0;
boolean force_is_pressed = false;
float blob_x = 0.0;
float blob_y = 0.0;
float blob_size = 0.0;
boolean force_was_pressed = false;
int VIDEO_OUTPUT_WIDTH;
int VIDEO_OUTPUT_HEIGHT;

void setup()
{
  println("Encres & lumieres version " + VERSION);
  //size(640, , P3D);
  size(displayWidth, displayHeight, P3D);
  frameRate(60);
  VIDEO_OUTPUT_WIDTH = width;
  VIDEO_OUTPUT_HEIGHT = height;
  // start oscP5, listening for incoming messages at a given port
  osc_receiver = new OscP5(this, OSC_RECEIVE_PORT);
  osc_send_address = new NetAddress(OSC_SEND_HOST, OSC_SEND_PORT);
  // XXX comment out next line if not using Syphon
  //syphon_server = new SyphonServer(this, SYPHON_SERVER_NAME);
  paintscreen = createGraphics(width, height, P3D);
  background_image = loadImage("background.png");
  spray_manager = new SprayManager();
  sprayMap = loadImage("sprayMap.png");
  depth_offset = 0.0;
  offsetVel = 0.0005;
  global_point_shader = loadShader("pointfrag.glsl", "pointvert.glsl");  
  //global_point_shader.set("sharpness", 0.9);
  global_point_shader.set("sprayMap", sprayMap);
  paintscreen.beginDraw();
  paintscreen.image(background_image, 0, 0);
  paintscreen.endDraw();
  
  spray_color = color(#ffcc33);
  brush_weight = 100;
}

void draw()
{
  background(0);
  create_points_if_needed();
  draw_graffiti();
  draw_cursor();
  // XXX comment out next line if not using Syphon
  // syphon_server.sendScreen();
}

/**
 * Draw the graffiti strokes.
 */
void draw_graffiti()
{
  paintscreen.beginDraw();
  paintscreen.strokeCap(SQUARE);
  if (spray_manager != null)
  {
    spray_manager.draw(paintscreen);
  }
  paintscreen.endDraw();
  image(paintscreen, 0, 0);
}

/**
 * Draw the cursor.
 */
void draw_cursor()
{
  stroke(100);
  noFill();
  strokeWeight(1.0);
  stroke(255, 0, 0);
  float ellipse_size = brush_weight * BRUSH_SCALE;
  ellipse(blob_x, blob_y, ellipse_size, ellipse_size);
}

/**
 * Sets the graffiti color.
 */
void graffiti_set_color(color new_color)
{
  spray_color = new_color;
}

/**
 * Sets the graffiti brush weight.
 */
void graffiti_set_weight(float new_weight)
{
  brush_weight = new_weight;
}

/**
 * Clears all the graffiti strokes.
 */
void graffiti_reset()
{
  paintscreen.beginDraw();
  paintscreen.image(background_image, 0, 0);
  paintscreen.endDraw();
  spray_manager.clearAll();
}

/**
 * Take a snapshot.
 */
void graffiti_snapshot()
{
  saveFrame();
}

/**
 * Starts a graffiti stroke.
 */
void graffiti_start_stroke(int x, int y, float the_weight)
{
  if (spray_manager != null)
  {
    spray_manager.newStroke(x, y, the_weight);
  }
  else
  {
    println("Error: spray_manager is null!");
  }
}

/**
 * Add a knot to the current graffiti stroke.
 */
void graffiti_add_knot_to_stroke(int x, int y, float the_weight)
{
  if (spray_manager != null)
  {
    spray_manager.newKnot(x, y, the_weight);
  }
  else
  {
    println("Error: spray_manager is null!");
  }
}

void mousePressed()
{
  graffiti_start_stroke(mouseX, mouseY, brush_weight);
}

void keyPressed()
{
  if (key == 'r' || key == 'R')
  {
    graffiti_reset();
  }
  if (key == 's' || key == 'S')
  {
    graffiti_snapshot(); 
  }
}

/**
 * Handles /force OSC messages.
 */
void handle_force(String identifier, int force)
{
  if (debug)
  {
    // println("/force " + identifier + " " + force);
  }
  // Store the previous state
  force_was_pressed = force_is_pressed;
  // Invert the number

  force = FORCE_MAX - force;
  if (force > FORCE_THRESHOLD)
  {
    force_is_pressed = true;
    // float new_weight = map_force(force);
    // graffiti_set_weight(new_weight);
  }
  else
  {
    force_is_pressed = false;
  }
}

/**
 * Handles /blob OSC messages.
 */
void handle_blob(String identifier, float x, float y, float size)
{
  if (debug)
  {
    // println("/blob " + x + ", " + y + " size=" + size);
  }
  blob_x = map_x(x);
  blob_y = map_y(y);
  blob_size = size; // unused
}

/**
 * Handles /brush/weight OSC messages.
 */
void handle_brush_weight(String identifier, int weight)
{
  if (debug)
  {
    // println("/brush/size " + identifier + " " + size);
  }
  brush_weight = weight;
}

/**
 * Handles /color OSC messages.
 */
void handle_color(String identifier, int r, int g, int b)
{
  if (debug)
  {
    println("/color " + r + ", " + g + ", " + b);
  }
  graffiti_set_color(color(r, g, b));
}

/**
 * Convert a X coordinate from blob range to display range.
 */
float map_x(float value)
{
  return map(value, 0.0, BLOB_INPUT_WIDTH, 0.0, VIDEO_OUTPUT_WIDTH);
}

/**
 * Convert a Y coordinate from blob range to display range.
 */
float map_y(float value)
{
  float height_3_4 = VIDEO_OUTPUT_WIDTH * (3.0 / 4.0);
  return map(value, 0.0, BLOB_INPUT_HEIGHT, 0.0, height_3_4);
}

// /**
//  * Convert FSR force to brush size.
//  *
//  * TODO: we might want to use both blob size and FSR force to calculate
//  * brush size.
//  */
// float map_force(float value)
// {
//   float ret = map(value, FORCE_THRESHOLD, FORCE_MAX, 0.0, 1.0);
//   ret = map(ret, 0.0, 1.0, BRUSH_MIN, BRUSH_MAX);
//   return ret;
// }

/**
 * Does the job of creating the points in the stroke, if we received OSC messages.
 */
void create_points_if_needed()
{
  spray_manager.setColor(spray_color);
  spray_manager.setWeight(brush_weight);
  //println(brush_weight);

  if (mousePressed)
  {
    graffiti_add_knot_to_stroke(mouseX, mouseY, brush_weight);
  }
  
  if (! force_was_pressed && force_is_pressed)
  {
    if (debug)
    {
      println("begin");
    }
    // TODO: use blob_size and force to calculate brush_weight
    graffiti_start_stroke((int) blob_x, (int) blob_y, (int) brush_weight);
  }
  else if (force_was_pressed && force_is_pressed)
  {
    // TODO: use blob_size and force to calculate brush_weight
    graffiti_add_knot_to_stroke((int) blob_x, (int) blob_y, (int) brush_weight);
  }
  else if (force_was_pressed && ! force_is_pressed)
  {
    if (debug)
    {
      println("end");
    }
    // spray_end();
  }
}

/**
 * Incoming osc message are forwarded to the oscEvent method.
 *
 * The name of this method is set up by the oscP5 library.
 */
void oscEvent(OscMessage message)
{
  //print("Received " + message.addrPattern() + " " + message.typetag() + "\n");
  if (message.checkAddrPattern("/force"))
  {
    // TODO: parse string identifier as a first OSC argument
    String identifier = "unknown";
    int force = 0;
    if (message.checkTypetag("si"))
    {
      force = message.get(1).intValue();
    }
    else if (message.checkTypetag("sf"))
    {
      force = (int) message.get(1).floatValue();
    }
    else if (message.checkTypetag("i")) // FIXME: remove this legacy signature
    {
      force = message.get(0).intValue();
    }
    else if (message.checkTypetag("f"))  // FIXME: remove this legacy signature
    {
      force = (int) message.get(0).floatValue();
    }
    handle_force(identifier, force);
  }
  else if (message.checkAddrPattern("/blob"))
  {
    // TODO: parse string identifier as a first OSC argument
    String identifier = "unknown";
    float x = 0.0;
    float y = 0.0;
    float size = 0.0;
    if (message.checkTypetag("sfff"))
    {
      //identifier = message.get(0).StringValue();
      x = message.get(1).floatValue();
      y = message.get(2).floatValue();
      size = message.get(3).floatValue();
    }
    handle_blob(identifier, x, y, size);
  }
  else if (message.checkAddrPattern("/color"))
  {
    // TODO: parse string identifier as a first OSC argument
    String identifier = "unknown";
    int r = 255;
    int g = 255;
    int b = 255;
    if (message.checkTypetag("siii"))
    {
      //identifier = message.get(0).StringValue();
      r = message.get(1).intValue();
      g = message.get(2).intValue();
      b = message.get(3).intValue();
    }
    else if (message.checkTypetag("sfff"))
    {
      //identifier = message.get(0).StringValue();
      r = (int) message.get(1).floatValue();
      g = (int) message.get(2).floatValue();
      b = (int) message.get(3).floatValue();
    }
    handle_color(identifier, r, g, b);
  }
  else if (message.checkAddrPattern("/brush/weight"))
  {
    // TODO: parse string identifier as a first OSC argument
    String identifier = "unknown";
    int weight = 100;
    if (message.checkTypetag("si"))
    {
      //identifier = message.get(0).StringValue();
      weight = message.get(1).intValue();
    }
    else if (message.checkTypetag("sf"))
    {
      //identifier = message.get(0).StringValue();
      weight = (int) message.get(1).floatValue();
    }
    handle_brush_weight(identifier, weight);
  }
}