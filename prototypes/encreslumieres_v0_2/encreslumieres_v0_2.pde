/**
 * Encres & lumières
 * Spray paint controlled via OSC.
 * Syphon output.
 * Dependencies:
 * - oscP5
 * - syphon
 *
 * To run: Command-R (or Control-R)
 * To run full screen: Command-Shift-R (or Control-Shift-R)
 * 
 * Interactive controls:
 * - z: undo 
 * - r: redo
 * - x: reset
 * - s: save snapshot
 */
// XXX comment out next line if not using Syphon
import codeanticode.syphon.SyphonServer;
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
/*
 * Now, the /force we receive from the Arduino over wifi is 
 * within the range [0,1023] and we invert the number, so that
 * if we received, 100, example, we will turn it here into
 * 1023 - 100, which results in 923. Now we will compare it to
 * a threshold, for example 400. If that inverted force is over
 * 400, the brush will be on. FORCE_THRESHOLD is what you will
 * need to change often. See below.
 */
final int FORCE_MAX = 1023; // DO NOT change this
final int FORCE_THRESHOLD = 150; // you will need to change this. Used to be 623, then 200
final int BRUSH_MIN = 50;
final int BRUSH_MAX = 150;
final String VERSION = "0.2.1";
final float BRUSH_SCALE = 0.3; // FIXME: ratio taken from Knot.pde (not quite right)
final int MOUSE_GRAFFITI_IDENTIFIER = 0;


PShader point_shader; // See http://glsl.heroku.com/e#4633.5
// Spray density distribution expressed in grayscale gradient
PImage sprayMap;
PImage background_image;
Undo undo;
PGraphics paintscreen;
OscP5 osc_receiver;
NetAddress osc_send_address;
// XXX comment out next line if not using Syphon
SyphonServer syphon_server;
int VIDEO_OUTPUT_WIDTH;
int VIDEO_OUTPUT_HEIGHT;
ArrayList<GraffitiInfo> graffitis;


void settings()
{
  size(displayWidth, displayHeight, P3D);
  // XXX comment out next line if not using Syphon
  PJOGL.profile = 1;
}


void setup()
{
  println("Encres & lumieres version " + VERSION);
  //size(640, , P3D);
  
  frameRate(60);
  VIDEO_OUTPUT_WIDTH = width;
  VIDEO_OUTPUT_HEIGHT = height;
  undo = new Undo(10, VIDEO_OUTPUT_WIDTH, VIDEO_OUTPUT_HEIGHT);
  // start oscP5, listening for incoming messages at a given port
  osc_receiver = new OscP5(this, OSC_RECEIVE_PORT);
  osc_send_address = new NetAddress(OSC_SEND_HOST, OSC_SEND_PORT);
  // XXX comment out next line if not using Syphon
  syphon_server = new SyphonServer(this, SYPHON_SERVER_NAME);
  paintscreen = createGraphics(width, height, P3D);
  background_image = loadImage("background.png");
  sprayMap = loadImage("sprayMap.png");
  point_shader = loadShader("pointfrag.glsl", "pointvert.glsl");  
  //point_shader.set("sharpness", 0.9);
  point_shader.set("sprayMap", sprayMap);
  paintscreen.beginDraw();
  paintscreen.image(background_image, 0, 0);
  undo.takeSnapshot(paintscreen); // might need to move this after paintscreen.endDraw() below
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
  syphon_server.sendScreen();
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
    graffitis.get(i).spray_can.draw_spraycan(paintscreen, point_shader);
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
  undo.takeSnapshot(paintscreen); // might need to move this after paintscreen.endDraw() below
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
  graffitis.get(MOUSE_GRAFFITI_IDENTIFIER).graffiti_start_stroke(
          mouseX, mouseY,
          graffitis.get(MOUSE_GRAFFITI_IDENTIFIER).brush_weight);
}


void mouseReleased()
{
  paintscreen.beginDraw();
  undo.takeSnapshot(paintscreen);
  paintscreen.endDraw();
}


void do_redo()
{
  println("redo");
  paintscreen.beginDraw();
  undo.redo(paintscreen);
  paintscreen.endDraw();
  // FIXME: we probably need to re-add a path from our spraycan here
}


void do_undo()
{
  println("undo");
  paintscreen.beginDraw();
  undo.undo(paintscreen);
  paintscreen.endDraw();
  // FIXME: we probably need to remove a path from our spraycan here
}


void keyPressed()
{
  if (key == 'x' || key == 'X')
  {
    graffiti_reset();
  }
  else if (key == 's' || key == 'S')
  {
    graffiti_snapshot();
  }
  else if (key == 'z' || key == 'Z')
  {
    do_undo();
  }
  else if (key == 'r' || key == 'R')
  {
    do_redo();
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
    if (identifier == 0)
    {
      println("handle_force: no graffiti stroke yet");
    }
    else
    {
      println("handle_force: No such index " + identifier);
    }
    return;
    //identifier = 0; // FIXME: so that we support old legacy cannette Arduino code.
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
  
  // FIXME: I don't think this belongs here.
  //create_points_if_needed();
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
    // Start pressing:
    if ((! graffiti.force_was_pressed) && graffiti.force_is_pressed)
    {
      if (debug)
      {
        println("begin at " + graffiti.blob_x + " " + graffiti.blob_y);
      }
      // TODO: use blob_size and force to calculate brush_weight
      graffiti.graffiti_start_stroke(
              (int) graffiti.blob_x,
              (int) graffiti.blob_y,
              (int) graffiti.brush_weight);
    }
    // continue to press:
    else if (graffiti.force_was_pressed && graffiti.force_is_pressed)
    {
      // TODO: use blob_size and force to calculate brush_weight
      graffiti.graffiti_add_knot_to_stroke(
              (int) graffiti.blob_x,
              (int) graffiti.blob_y,
              (int) graffiti.brush_weight);
    }
    // stop pressing:
    else if (graffiti.force_was_pressed && (! graffiti.force_is_pressed))
    {
      graffiti.force_was_pressed = false;
      graffiti.force_is_pressed = false;
      if (debug)
      {
        //println("end");
        println("end at " + graffiti.blob_x + " " + graffiti.blob_y);
      }
      // spray_end();
      undo.takeSnapshot(paintscreen);
    }
    graffiti.force_was_pressed = graffiti.force_is_pressed;
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
    else
    {
      println("Wrong OSC typetags for /force.");
      // we use to support only the value - no identifier, but
      // not anymore
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
    else
    {
      println("Wrong OSC typetags for /blob.");
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
    }
    else if (message.checkTypetag("ifff"))
    {
      identifier = message.get(0).intValue();
      r = (int) message.get(1).floatValue();
      g = (int) message.get(2).floatValue();
      b = (int) message.get(3).floatValue();
    }
    else
    {
      println("Wrong OSC typetags for /color.");
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
    }
    else if (message.checkTypetag("if"))
    {
      identifier = message.get(0).intValue();
      weight = (int) message.get(1).floatValue();
    }
    else
    {
      println("Wrong OSC typetags for /brush/weight.");
    }
    handle_brush_weight(identifier, weight);
  }
  else if (message.checkAddrPattern("/undo"))
  {
    do_undo();
  }
  else if (message.checkAddrPattern("/redo"))
  {
    do_redo();
  }
}