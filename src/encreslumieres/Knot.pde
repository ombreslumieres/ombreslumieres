/**
 * One knot in a path.
 * 
 * FIXME: accesses the global_point_shader varible.
 */
class Knot extends PVector
{  
  float size;
  color col;
  float angle;  
  float noiseDepth; // for spray pattern generation
  float timestamp;  // for replay
  //PGraphics targetBuffer;
  boolean isDrawn = false;
  
  Knot(float x, float y, float weight, color tint)
  {
    super(x, y);
    this.size = weight;
    this.col = tint;
    this.angle = 0.0;
    this.noiseDepth = random(1.0);
    this.timestamp  = millis();
  }
  
  PVector getPos()
  {
    return new PVector(x, y);
  }
  
  float getSize()
  {
    return this.size;
  }
  
  color getColor()
  {
    return this.col;
  }
  
  /**
   * @param shader: Our point shader.
   */
  void draw(PGraphics targetBuffer, PShader shader)
  {
    float x = this.x;
    float y = this.y;
    PVector dir = new PVector(x, y);
    dir.normalize();
    if (! isDrawn)
    {
      shader.set("weight", this.size);
      shader.set("direction", dir.x, dir.y);
      shader.set("rotation", random(0.0, 1.0), random(0.0, 1.0));
      shader.set("scale", 0.3); 
      shader.set("soften", 1.0); // towards 0.0 for harder brush, towards 2.0 for lighter brush
      shader.set("depthOffset", this.noiseDepth);
      
      // println("drawing");
      targetBuffer.strokeWeight(this.size);
      targetBuffer.stroke(this.col);
      targetBuffer.shader(shader, POINTS);
      targetBuffer.point(x, y); 
      
      //targetBuffer.resetShader();
      isDrawn = true;
    }
    if (debug) 
    {
      pushMatrix();
        pushStyle();
          fill(255,0,0);
          noStroke();
          translate(x,y);
          ellipse(0,0,5,5);
        popStyle();
      popMatrix();
    }   
  }
}