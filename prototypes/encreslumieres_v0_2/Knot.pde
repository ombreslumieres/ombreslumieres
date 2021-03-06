/**
 * One knot in a path.
 * 
 * FIXME: accesses the global_point_shader varible.
 */
class Knot extends PVector
{  
  private float size;
  private color col;
  private float angle;  
  private float noiseDepth; // for spray pattern generation
  private float timestamp;  // for replay
  //PGraphics targetBuffer;
  private boolean isDrawn = false;
  private boolean debug = false;
  
  public Knot(float x, float y, float weight, color tint)
  {
    super(x, y);
    this.size = weight;
    this.col = tint;
    this.angle = 0.0;
    this.noiseDepth = random(1.0);
    this.timestamp  = millis();
  }
  
  public PVector getPos()
  {
    return new PVector(this.x, this.y);
  }
  
  public float getSize()
  {
    return this.size;
  }
  
  public color getColor()
  {
    return this.col;
  }
  
  /**
   * @param shader: Our point shader.
   */
  public void draw(PGraphics targetBuffer, PShader shader)
  {
    PVector dir = new PVector(this.x, this.y);
    dir.normalize();
    
    if (this.isDrawn)
    {
      return; // we draw each knot only once! (using a shader)
      // we store those pixels in a pixel buffer.
    }
    else
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
      targetBuffer.point(this.x, this.y); 
      
      //targetBuffer.resetShader();
      this.isDrawn = true;
    }
    if (this.debug) 
    {
      pushMatrix();
        pushStyle();
          fill(255, 0, 0);
          noStroke();
          translate(this.x, this.y);
          ellipse(0, 0, 5, 5);
        popStyle();
      popMatrix();
    }   
  }
  
  public void set_debug(boolean value)
  {
    this.debug = value;
  }
}