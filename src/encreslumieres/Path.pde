/**
 * Each stroke/path contains a list of points/knots.
 */
class Path
{
  ArrayList<Knot> pointList; // raw point list
  Knot previousKnot;
  Knot currentKnot;
  float mag;
  float numSteps;
  float distMin = 0;
  float stepSize = 1;
  
  Path()
  {
    // nothing to do
  }

  Path(Knot startingPoint)
  {
    this.add(startingPoint);
  }
  
  Path(Knot startingPoint, float step_size)
  {
    this.stepSize = step_size;
    this.add(startingPoint);
  }
  
  /**
   * TODO: rename this method.
   */
  void add(Knot k)
  {
    if (this.pointList == null)
    {
      this.createList(k);
    }
    else
    {
      this.newKnot(k);
    }
  }
  
  /**
   * When the first knot is added, we want to create the list.
   */
  private void createList(Knot k)
  { 
    this.previousKnot = k;
    this.currentKnot  = k;
    
    if (this.pointList == null)
    {
      this.pointList = new ArrayList<Knot>();
    }
    this.pointList.add(this.previousKnot);
    this.pointList.add(this.currentKnot);
  }
  
  /** 
   * Add a new knot and all knots between it and 
   * the previous knot, based on the defined step size.
   */
  private void newKnot(Knot k)
  {
    int size = this.pointList.size();
    this.previousKnot = this.pointList.get(size - 1);
    this.currentKnot = k;
    // Compute the vector from previous to current knot
    PVector prevPos = this.previousKnot.getPos();
    PVector newPos  = this.currentKnot.getPos();
    PVector velocity = PVector.sub(newPos, prevPos);
 
    // How many points can we fit between the two last knots?
    float mag = velocity.mag();
    
    // Create intermediate knots and pass them interpolated parameters
    if (mag > stepSize)
    {
      numSteps = mag / stepSize;
      for (int i = 1; i < numSteps; i++)
      {
        float interpolatedX = lerp(previousKnot.x,  currentKnot.x, i / numSteps);
        float interpolatedY = lerp(previousKnot.y,  currentKnot.y, i / numSteps);
        float interpolatedSize  = lerp(previousKnot.getSize(),
                currentKnot.getSize(), i / numSteps);
        color interpolatedColor = lerpColor(previousKnot.getColor(),
                currentKnot.getColor(), i / numSteps);
        Knot stepKnot = new Knot(interpolatedX, interpolatedY,
                interpolatedSize, interpolatedColor);
        this.pointList.add(stepKnot);
      }
    }
    else
    {
      this.pointList.add(this.currentKnot);
    }
  }
  
  void draw(PGraphics buffer, PShader shader)
  {
    for (Knot p: this.pointList)
    {
      p.draw(buffer, shader);
    }
  }
  
  void clear()
  {
    this.pointList.clear();
  }
}