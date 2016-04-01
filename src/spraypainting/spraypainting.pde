// http://glsl.heroku.com/e#4633.5
// Wall texture from: http://texturez.com/textures/concrete/4092
boolean debug = false;
SprayManager spray_manager;
PShader global_point_shader;
// Spray density distribution expressed in grayscale gradient
PImage sprayMap;
float weight;
float depth_offset;
float offsetVel;
PImage wall;
PGraphics paintscreen;
Path s;
color col;

void setup()
{
  //size(640, , P3D);
  size(displayWidth, displayHeight, P3D);
  frameRate(60);
  paintscreen = createGraphics(width, height, P3D);
  wall = loadImage("background.png");
  spray_manager = new SprayManager();
  sprayMap = loadImage("sprayMap.png");
  depth_offset = 0.0;
  offsetVel = 0.0005;
  global_point_shader = loadShader("pointfrag.glsl", "pointvert.glsl");  
  //global_point_shader.set("sharpness", 0.9);
  global_point_shader.set("sprayMap", sprayMap);
  paintscreen.beginDraw();
  paintscreen.image(wall, 0, 0);
  paintscreen.endDraw();
  
  col = color(#ffcc33);
  weight = 100;
}

void draw()
{
  spray_manager.setColor(col);
  spray_manager.setWeight(weight);
  //println(weight);

  if (mousePressed)
  {
    graffiti_add_knot_to_stroke(mouseX, mouseY, weight);
  }
  
  paintscreen.beginDraw();
  paintscreen.strokeCap(SQUARE);
  if (spray_manager != null)
  {
    spray_manager.draw(paintscreen);
  }
  paintscreen.endDraw();
  image(paintscreen, 0, 0);
}

void graffiti_set_color(color new_color)
{
  col = new_color;
}

void graffiti_set_weight(float new_weight)
{
  weight = new_weight;
}

void graffiti_reset()
{
  paintscreen.beginDraw();
  paintscreen.image(wall, 0, 0);
  paintscreen.endDraw();
  spray_manager.clearAll();
}

void graffiti_snapshot()
{
  saveFrame();
}

void graffiti_start_stroke(int x, int y, float the_weight)
{
  spray_manager.newStroke(x, y, the_weight);
}

void graffiti_add_knot_to_stroke(int x, int y, float the_weight)
{
  if (spray_manager != null)
  {
    spray_manager.newKnot(x, y, the_weight);
  }
}

void mousePressed()
{
  graffiti_start_stroke(mouseX, mouseY, weight);
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