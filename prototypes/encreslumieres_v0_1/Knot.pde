/**
 * One knot in a Stroke
 */
class Knot extends PVector
{  
  float size;
  float angle;    
  color tint;
  float noiseDepth; // for spray pattern generation
  float timestamp;  // for replay
  boolean isDrawn = false;
  
  Knot(float posX, float posY)
  {
    super(posX, posY);
    this.size  = 70.0;
    this.angle = 0.0;
    this.tint = color(255, 0, 0);
    this.noiseDepth = random(1.0);
    this.timestamp  = millis();
  }
  
  Knot(float posX, float posY, float size, float angle, color tint, float noiseDepth, float timeStamp)
  {
    super(posX, posY);
    this.size = size;
    this.angle = angle;
    this.tint = tint;
    this.noiseDepth = noiseDepth;
    this.timestamp = timeStamp;
  }
  
  void setColor(color c)
  {
    this.tint = c;
  }
  
  color getColor()
  {
    return this.tint;
  }
  
  PVector getPos()
  {
    return new PVector(x, y);
  }
  
  /**
   * FIXME: uses the global pointShader variable from the main sketch!
   */
  void draw()
  {
    float x = this.x;
    float y = this.y;
    if (! isDrawn)
    {
      pointShader.set("weight", this.size);
      pointShader.set("refAngle", -1.0, 0.0);
      pointShader.set("dispersion", 0.2);
      pointShader.set("depthOffset", this.noiseDepth);
      strokeWeight(this.size);
      shader(pointShader, POINTS);
      point(x, y);
      resetShader();     
      this.isDrawn = true;
    }
    
    if (debug)
    {
      pushMatrix();
        pushStyle();
          fill(tint);
          noStroke();
          translate(x, y);
          ellipse(0,0,5,5);
        popStyle();
      popMatrix();
    }
  }
}