/**
 * Each stroke/path contains a list of points/knots.
 */
class Path
{
  private ArrayList<Knot> knots; // raw point list
  private Knot previousKnot;
  private Knot currentKnot;
  private float mag;
  private float numSteps;
  private float distMin = 0;
  private float stepSize = 1;
  
  public Path()
  {
    // nothing to do
  }

  public Path(Knot startingPoint)
  {
    this.add(startingPoint);
  }
  
  public Path(Knot startingPoint, float step_size)
  {
    this.stepSize = step_size;
    this.add(startingPoint);
  }
  
  /**
   * TODO: rename this method.
   */
  public void add(Knot k)
  {
    if (this.knots == null)
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
    
    if (this.knots == null)
    {
      this.knots = new ArrayList<Knot>();
    }
    this.knots.add(this.previousKnot);
    this.knots.add(this.currentKnot);
  }
  
  /** 
   * Add a new knot and all knots between it and 
   * the previous knot, based on the defined step size.
   */
  private void newKnot(Knot k)
  {
    int size = this.knots.size();
    if (size == 0)
    {
      this.createList(k);
      return;
    }
    this.previousKnot = this.knots.get(size - 1);
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
        this.knots.add(stepKnot);
      }
    }
    else
    {
      this.knots.add(this.currentKnot);
    }
  }
  
  public void draw(PGraphics buffer, PShader shader)
  {
    for (Knot p: this.knots)
    {
      p.draw(buffer, shader);
    }
  }
  
  public void clear()
  {
    this.knots.clear();
  }
}
