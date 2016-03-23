/**
* Contains a list of knots.
*/
class Path
{  
  ArrayList<Knot> pointList;       // raw point list
  Knot previousKnot;
  Knot currentKnot;
  float mag;
  float numSteps;
  float distMin = 3;
  float stepSize = 20;
  
  Path()
  {
  }

  Path(Knot startingPoint)
  {
    this.initialize(startingPoint);
  }
  
  Path(Knot startingPoint, float d)
  {
    this.stepSize = d;
    this.initialize(startingPoint);
  }
  
  void initialize(Knot k)
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
  
  void add(Knot p)
  {
    int size = this.pointList.size();
    this.previousKnot = this.pointList.get(size-1);
    this.currentKnot = p;
    // Compute the vector from previous to current knot
    PVector prevPos = this.previousKnot.getPos();
    PVector newPos  = this.currentKnot.getPos();
    PVector velocity = PVector.sub(newPos, prevPos);
    // How many points can we fit between the two last knots?
    float mag = velocity.mag();
    if (mag > stepSize)
    {
      numSteps = mag / stepSize;
      for(int i = 1; i < numSteps; i++)
      {
        PVector stepper = new PVector();
        PVector.mult(velocity, 1 / numSteps * i, stepper);
        stepper.add(prevPos);
        Knot k = new Knot(stepper.x, stepper.y);
        p.setColor(color(0, 255, 0));
        this.pointList.add(k);
      }
    }
    else
    {
      p.setColor(color(255, 0, 0));
      this.pointList.add(p);
    }
  }
  
  void draw()
  {
    for(Knot p: pointList)
    {
      p.draw();
    }
  }
}