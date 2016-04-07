/**
 * Manages one spray can.
 */
class SprayCan
{ 
 ArrayList<Path> strokeList;
 color col;
 float size;
 
 SprayCan()
 {
   strokeList = new ArrayList<Path>();
   col = color(0);
 }
 
 /**
  * Draws all its strokes.
  * NOTE: points are only drawn once so you should not redraw the background
  */
 void draw(PGraphics buffer, PShader shader)
 {
   for (Path p: this.strokeList)
   {
     p.draw(buffer, shader);
   }
 }
 
 /*
  * Deletes all the strokes.
  */
 void clearAll()
 {
   for (Path p: this.strokeList)
   {
     p.clear();
   }
   this.strokeList.clear();
 }
 
 /**
  * Starts a stroke.
  */
 void newStroke(float x, float y, float weight)
 {  
   Knot startingKnot = new Knot(x, y, weight, col);
   Path p = new Path(startingKnot);
   this.strokeList.add(p); 
 }
 
 /**
  * Adds a point the the current stroke.
  */
 void newKnot(float x, float y, float weight)
 {
   Knot newKnot = new Knot(x, y, weight, col);
   Path activePath = this.getActivePath();
   activePath.add(newKnot);
 }
 
 /**
  * Return the stroke beeing drawn at the moment.
  */
 Path getActivePath()
 {
   return this.strokeList.get(this.strokeList.size() - 1);
 }
 
 /**
  * Sets the size of the spray.
  */
 void setWeight(float weight)
 {
   this.size = weight;
 }
 
 /**
  * Sets the color of the spray.
  */
 void setColor(color tint)
 {
   this.col = tint;
 }
 
 color getColor()
 {
   return col;
 }
}