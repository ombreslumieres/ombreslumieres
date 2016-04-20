/**
 * Press CTRL+Z to undo, CTRL+SHIFT+Z to redo.
 */

// We need these to know if CTRL/SHIFT are pressed
boolean controlDown = false;
boolean shiftDown = false;
 
Undo undo;
PGraphics paintscreen;
 
void setup()
{
  size(500, 500, P3D);
  undo = new Undo(10);
  paintscreen = createGraphics(width, height, P3D);
  paintscreen.beginDraw();
  paintscreen.background(255);
  undo.takeSnapshot(paintscreen);
  paintscreen.endDraw();
}

void draw()
{
  paintscreen.beginDraw();
  // Our two line drawing program
  if (mousePressed)
  {
    paintscreen.line(mouseX, mouseY, pmouseX, pmouseY);
  }
  paintscreen.endDraw();
  image(paintscreen, 0, 0);
}

void mouseReleased()
{
  // Save each line we draw to our stack of UNDOs
  undo.takeSnapshot(paintscreen);
}
 
void keyPressed()
{
  // Remember if CTRL or SHIFT are pressed or not
  if (key == CODED)
  {
    if (keyCode == CONTROL)
    {
      controlDown = true;
    }
    if (keyCode == SHIFT)
    {
      shiftDown = true;
    }
    return;
  }
  // Check if we pressed CTRL+Z or CTRL+SHIFT+Z
  if (controlDown)
  {
    if (keyCode == 'Z')
    {
      if (shiftDown)
      {
        paintscreen.beginDraw();
        undo.redo(paintscreen);
        paintscreen.endDraw();
      }
      else
      {
        paintscreen.beginDraw();
        undo.undo(paintscreen);
        paintscreen.endDraw();
      }
    }
    return;
  }
  // Check if we pressed the S key
  if (key=='s')
  {
    //paintscreen.saveFrame("image####.png");
  }
}

void keyReleased()
{
  // Remember if CTRL or SHIFT are pressed or not
  if (key == CODED)
  {
    if (keyCode == CONTROL)
    {
      controlDown = false;
    }
    if (keyCode == SHIFT)
    {
      shiftDown = false;
    }
  }
} 
 
class Undo
{
  // Number of currently available undo and redo snapshots
  int undoSteps = 0;
  int redoSteps = 0;
  CircImgCollection images;
 
  Undo(int levels)
  {
    this.images = new CircImgCollection(levels);
  }
 
  public void takeSnapshot(PGraphics screen)
  {
    this.undoSteps = min(this.undoSteps + 1, this.images.amount - 1);
    // each time we draw we disable redo
    this.redoSteps = 0;
    this.images.next();
    this.images.capture(screen);
  }
  
  public void undo(PGraphics screen)
  {
    if (this.undoSteps > 0)
    {
      this.undoSteps --;
      this.redoSteps ++;
      this.images.prev();
      this.images.show(screen);
    }
  }
  
  public void redo(PGraphics screen)
  {
    if (this.redoSteps > 0)
    {
      this.undoSteps ++;
      this.redoSteps --;
      this.images.next();
      this.images.show(screen);
    }
  }
}

class CircImgCollection
{
  int amount;
  int current;
  PImage[] img;
  
  CircImgCollection(int amountOfImages)
  {
    this.amount = amountOfImages;
 
    // Initialize all images as copies of the current display
    this.img = new PImage[this.amount];
    for (int i = 0; i < this.amount; i++)
    {
      this.img[i] = createImage(width, height, RGB);
      this.img[i] = get();
    }
  }
  
  void next()
  {
    this.current = (this.current + 1) % this.amount;
  }
  
  void prev()
  {
    this.current = (this.current - 1 + this.amount) % this.amount;
  }
  
  void capture(PGraphics screen)
  {
    this.img[this.current] = screen.get();
  }
  
  void show(PGraphics screen)
  {
    screen.image(this.img[current], 0, 0);
  }
}