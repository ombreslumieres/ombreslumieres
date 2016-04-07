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
final int MOUSE_GRAFFITI_IDENTIFIER = 0;

class GraffitiInfo
{
  public SprayCan spray_can;
  public float brush_weight;
  public float depth_offset;
  public float offsetVel;
  public color spray_color;
  public int spray_x = 0;
  public int spray_y = 0;
  public boolean force_is_pressed = false;
  public float blob_x = 0.0;
  public float blob_y = 0.0;
  public float blob_size = 0.0;
  public boolean force_was_pressed = false;

  GraffitiInfo()
  {
    this.spray_can = new SprayCan();
  }
  /**
   * Starts a graffiti stroke.
   */
  void graffiti_start_stroke(int x, int y, float the_weight)
  {
    this.spray_can.newStroke(x, y, the_weight);
  }
  /**
   * Sets the graffiti color.
   */
  void graffiti_set_color(color new_color)
  {
    this.spray_color = new_color;
  }
  /**
   * Sets the graffiti brush weight.
   */
  void graffiti_set_weight(float new_weight)
  {
    this.brush_weight = new_weight;
  }
  /**
   * Add a knot to the current graffiti stroke.
   */
  void graffiti_add_knot_to_stroke(int x, int y, float the_weight)
  {
    this.spray_can.newKnot(x, y, the_weight);
  }
}

PShader point_shader; // See http://glsl.heroku.com/e#4633.5
// Spray density distribution expressed in grayscale gradient
PImage sprayMap;
PImage background_image;
PGraphics paintscreen;
OscP5 osc_receiver;
NetAddress osc_send_address;
// XXX comment out next line if not using Syphon
//SyphonServer syphon_server;

int VIDEO_OUTPUT_WIDTH;
int VIDEO_OUTPUT_HEIGHT;
ArrayList<GraffitiInfo> graffitis;

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
  sprayMap = loadImage("sprayMap.png");
  point_shader = loadShader("pointfrag.glsl", "pointvert.glsl");  
  //point_shader.set("sharpness", 0.9);
  point_shader.set("sprayMap", sprayMap);
  paintscreen.beginDraw();
  paintscreen.image(background_image, 0, 0);
  paintscreen.endDraw();

  graffitis = new ArrayList<GraffitiInfo>();
  for (int i = 0; i < 10; i++)
  {
    graffitis.add(new GraffitiInfo());
    graffitis.get(i).spray_color = color(#ffcc33);
    graffitis.get(i).brush_weight = 100;
  }
}

void draw()
{
  background(0);
  create_points_if_needed();
  draw_graffitis();
  draw_cursors();
  // XXX comment out next line if not using Syphon
  // syphon_server.sendScreen();
}

/**
 * Draw the graffiti strokes.
 */
void draw_graffitis()
{
  paintscreen.beginDraw();
  paintscreen.strokeCap(SQUARE);
  for (int i = 0; i < graffitis.size(); i++)
  {
    graffitis.get(i).spray_can.draw(paintscreen, point_shader);
  }
  paintscreen.endDraw();
  image(paintscreen, 0, 0);
}

/**
 * Draw the cursor.
 */
void draw_cursors()
{
  stroke(100);
  noFill();
  strokeWeight(1.0);
  stroke(255, 0, 0);
  for (int i = 0; i < graffitis.size(); i++)
  {
    GraffitiInfo info = graffitis.get(i);
    float ellipse_size = info.brush_weight * BRUSH_SCALE;
    ellipse(info.blob_x, info.blob_y, ellipse_size, ellipse_size);
  }
}

/**
 * Clears all the graffiti strokes.
 */
void graffiti_reset()
{
  paintscreen.beginDraw();
  paintscreen.image(background_image, 0, 0);
  paintscreen.endDraw();

  for (int i = 0; i < graffitis.size(); i++)
  {
    graffitis.get(i).spray_can.clearAll();
  }
}

/**
 * Take a snapshot.
 */
void graffiti_snapshot()
{
  saveFrame();
}

void mousePressed()
{
  graffitis.get(MOUSE_GRAFFITI_IDENTIFIER).graffiti_start_stroke(mouseX, mouseY, graffitis.get(MOUSE_GRAFFITI_IDENTIFIER).brush_weight);
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

boolean graffiti_has_index(int index)
{
  if (index >= graffitis.size() || index < 0)
  {
    return false;
  } else
  {
    return true;
  }
}

/**
 * Handles /force OSC messages.
 */
void handle_force(int identifier, int force)
{
  if (! graffiti_has_index(identifier))
  {
    println("No such index " + identifier);
    return;
  }
  GraffitiInfo graffiti = graffitis.get(identifier);
  if (debug)
  {
    // println("/force " + identifier + " " + force);
  }
  // Store the previous state
  graffiti.force_was_pressed = graffiti.force_is_pressed;
  // Invert the number

  force = FORCE_MAX - force;
  if (force > FORCE_THRESHOLD)
  {
    graffiti.force_is_pressed = true;
    // float new_weight = map_force(force);
    // graffiti_set_weight(new_weight);
  } else
  {
    graffiti.force_is_pressed = false;
  }
}

/**
 * Handles /blob OSC messages.
 */
void handle_blob(int identifier, float x, float y, float size)
{
  if (! graffiti_has_index(identifier))
  {
    println("No such index " + identifier);
    return;
  }
  GraffitiInfo graffiti = graffitis.get(identifier);
  if (debug)
  {
    // println("/blob " + x + ", " + y + " size=" + size);
  }
  graffiti.blob_x = map_x(x);
  graffiti.blob_y = map_y(y);
  graffiti.blob_size = size; // unused
}

/**
 * Handles /brush/weight OSC messages.
 */
void handle_brush_weight(int identifier, int weight)
{
  if (! graffiti_has_index(identifier))
  {
    println("No such index " + identifier);
    return;
  }
  GraffitiInfo graffiti = graffitis.get(identifier);
  if (debug)
  {
    // println("/brush/size " + identifier + " " + size);
  }
  graffiti.brush_weight = weight;
}

/**
 * Handles /color OSC messages.
 */
void handle_color(int identifier, int r, int g, int b)
{
  if (! graffiti_has_index(identifier))
  {
    println("No such index " + identifier);
    return;
  }
  GraffitiInfo graffiti = graffitis.get(identifier);
  if (debug)
  {
    println("/color " + r + ", " + g + ", " + b);
  }
  graffiti.graffiti_set_color(color(r, g, b));
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
  for (int i = 0; i < graffitis.size(); i++)
  {
    GraffitiInfo graffiti = graffitis.get(i);
    graffiti.spray_can.setColor(graffiti.spray_color);
    graffiti.spray_can.setWeight(graffiti.brush_weight);
  }

  //println(brush_weight);

  if (mousePressed)
  {
    GraffitiInfo graffiti = graffitis.get(MOUSE_GRAFFITI_IDENTIFIER);
    graffiti.graffiti_add_knot_to_stroke(mouseX, mouseY, graffiti.brush_weight);
  }
  for (int i = 0; i < graffitis.size(); i++)
  {
    GraffitiInfo graffiti = graffitis.get(i);
    if (! graffiti.force_was_pressed && graffiti.force_is_pressed)
    {
      if (debug)
      {
        println("begin");
      }
      // TODO: use blob_size and force to calculate brush_weight
      graffiti.graffiti_start_stroke((int) graffiti.blob_x, (int) graffiti.blob_y, (int) graffiti.brush_weight);
    } else if (graffiti.force_was_pressed && graffiti.force_is_pressed)
    {
      // TODO: use blob_size and force to calculate brush_weight
      graffiti.graffiti_add_knot_to_stroke((int) graffiti.blob_x, (int) graffiti.blob_y, (int) graffiti.brush_weight);
    } else if (graffiti.force_was_pressed && ! graffiti.force_is_pressed)
    {
      if (debug)
      {
        println("end");
      }
      // spray_end();
    }
  }
}

/**
 * Incoming osc message are forwarded to the oscEvent method.
 *
 * The name of this method is set up by the oscP5 library.
 */
void oscEvent(OscMessage message)
{
  int identifier = 0;
  //print("Received " + message.addrPattern() + " " + message.typetag() + "\n");
  if (message.checkAddrPattern("/force"))
  {
    // TODO: parse string identifier as a first OSC argument
    int force = 0;
    if (message.checkTypetag("ii"))
    {
      identifier = message.get(0).intValue();
      force = message.get(1).intValue();
    }
    else if (message.checkTypetag("if"))
    {
      identifier = message.get(0).intValue();
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
    float x = 0.0;
    float y = 0.0;
    float size = 0.0;
    if (message.checkTypetag("ifff"))
    {
      identifier = message.get(0).intValue();
      x = message.get(1).floatValue();
      y = message.get(2).floatValue();
      size = message.get(3).floatValue();
    }
    handle_blob(identifier, x, y, size);
  }
  else if (message.checkAddrPattern("/color"))
  {
    int r = 255;
    int g = 255;
    int b = 255;
    if (message.checkTypetag("iiii"))
    {
      identifier = message.get(0).intValue();
      r = message.get(1).intValue();
      g = message.get(2).intValue();
      b = message.get(3).intValue();
    } else if (message.checkTypetag("ifff"))
    {
      identifier = message.get(0).intValue();
      r = (int) message.get(1).floatValue();
      g = (int) message.get(2).floatValue();
      b = (int) message.get(3).floatValue();
    }
    handle_color(identifier, r, g, b);
  }
  else if (message.checkAddrPattern("/brush/weight"))
  {
    int weight = 100;
    if (message.checkTypetag("ii"))
    {
      identifier = message.get(0).intValue();
      weight = message.get(1).intValue();
    } else if (message.checkTypetag("if"))
    {
      identifier = message.get(0).intValue();
      weight = (int) message.get(1).floatValue();
    }
    handle_brush_weight(identifier, weight);
  }
}