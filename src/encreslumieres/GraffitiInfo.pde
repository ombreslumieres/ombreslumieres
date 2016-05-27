/**
 * TODO: could be merged with SprayCan.
 */
class GraffitiInfo
{
  public SprayCan spray_can;
  public float brush_weight;
  public float depth_offset;
  public float offsetVel;
  public color spray_color;
  public int spray_x = 0;
  public int spray_y = 0;
  public boolean force_is_pressed = false;
  public boolean force_was_pressed = false; // deprecated?
  public float blob_x = 0.0;
  public float blob_y = 0.0;
  public float blob_size = 0.0;
  public boolean stroking = false;

  GraffitiInfo()
  {
    this.spray_can = new SprayCan();
  }
  
  /**
   * Starts a graffiti stroke.
   */
  void graffiti_start_stroke(int x, int y, float the_weight)
  {
    this.spray_can.newStroke(x, y, the_weight);
    this.stroking = true;
  }
  
  /**
   * Ends a graffiti stroke.
   */
  void graffiti_end_stroke(int x, int y, float the_weight)
  {
    this.stroking = false;
  }
  
  /**
   * Sets the graffiti color.
   */
  void graffiti_set_color(color new_color)
  {
    this.spray_color = new_color;
  }
  
  /**
   * Sets the graffiti brush weight.
   */
  void graffiti_set_weight(float new_weight)
  {
    this.brush_weight = new_weight;
  }
  
  /**
   * Add a knot to the current graffiti stroke.
   */
  void graffiti_add_knot_to_stroke(int x, int y, float the_weight)
  {
    this.spray_can.newKnot(x, y, the_weight);
  }
}