/**
 * Manages one spray can.
 */
class SprayCan
{ 
 private ArrayList<Path> paths;
 private color col;
 private float size;
 
 public SprayCan()
 {
   paths = new ArrayList<Path>();
   col = color(0);
 }
 
 /**
  * Draws all its strokes.
  * NOTE: points are only drawn once so you should not redraw the background
  */
 public void draw(PGraphics buffer, PShader shader)
 {
   for (Path p: this.paths)
   {
     p.draw(buffer, shader);
   }
 }
 
 /*
  * Deletes all the strokes.
  */
 public void clearAll()
 {
   for (Path p: this.paths)
   {
     p.clear();
   }
   this.paths.clear();
 }
 
 /**
  * Starts a stroke.
  */
 public void newStroke(float x, float y, float weight)
 {  
   Knot startingKnot = new Knot(x, y, weight, col);
   Path p = new Path(startingKnot);
   this.paths.add(p); 
 }
 
 /**
  * Adds a point the the current stroke.
  */
 public void newKnot(float x, float y, float weight)
 {
   Knot newKnot = new Knot(x, y, weight, col);
   Path activePath = this.getActivePath();
   if (activePath == null)
   {
     this.newStroke(x, y, weight);
     return;
   }
   else
   {
     activePath.add(newKnot);
   }
 }
 
 /**
  * Return the stroke beeing drawn at the moment.
  */
 private Path getActivePath()
 {
   if (this.paths.size() == 0)
   {
     return null;
   }
   else
   {
     return this.paths.get(this.paths.size() - 1);
   }
 }
 
 /**
  * Sets the size of the spray.
  */
 public void setWeight(float weight)
 {
   this.size = weight;
 }
 
 /**
  * Sets the color of the spray.
  */
 public void setColor(color tint)
 {
   this.col = tint;
 }
 
 public color getColor()
 {
   return col;
 }
}