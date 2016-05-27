/**
 * Manages one spray can.
 */
class SprayCan
{
  // constants
  private final float DEFAULT_STEP_SIZE = 5.0;
  private final float DEFAULT_BRUSH_SIZE = 64;
  
  // attributes
  private ArrayList<Stroke> _strokes;
  private color _color;
  private float _brush_size;
  private Brush _current_brush;
  private PGraphics _buffer = null;
  private int _image_width;
  private int _image_height;
  private float _default_step_size;
  // TODO: add layers here
  // TODO: add undo here
  //private boolean _force_is_pressed = false;
  //private boolean _force_was_pressed = false;
  //private float _blob_x = 0.0;
  //private float _blob_y = 0.0;
  //private float _blob_size = 0.0;


  public SprayCan(int image_width, int image_height)
  {
    this._strokes = new ArrayList<Stroke>();
    this._color = color(255, 255, 255, 255);
    this._brush_size = this.DEFAULT_BRUSH_SIZE; // FIXME
    this._default_step_size = this.DEFAULT_STEP_SIZE;
    this._image_width = image_width;
    this._image_height = image_height;
    this._buffer = createGraphics(this._image_width, this._image_height, P3D);
  }

  void set_current_brush(Brush brush)
  {
    this._current_brush = brush;
  }

  /**
   * Draws all its strokes.
   * NOTE: nodes are only drawn once.
   */
  public void draw_spraycan()
  {
    // TODO: draw each spray can layer separately
    this._buffer.beginDraw();
    for (Stroke stroke : this._strokes)
    {
      stroke.draw_stroke(this._buffer); // , shader);
    }
    image(this._buffer, 0, 0);
    this._buffer.endDraw();
  }
  
  public void draw_cursor()
  {
    // TODO
  }

  /*
  * Deletes all the strokes.
   */
  public void clear_all_strokes()
  {
    for (Stroke stroke : this._strokes)
    {
      stroke.clear_stroke();
    }
    this._strokes.clear();
    // FIXME: we probably need to remove each path in our array list, we is not done here.
    this._buffer = createGraphics(_image_width, _image_height, P3D);
  }

  /**
   * Starts a stroke.
   */
  public void start_new_stroke(float x, float y, float brush_size)
  {  
    Node starting_node = new Node(x, y, brush_size, this._color);
    this._brush_size = brush_size;
    Stroke stroke = new Stroke(starting_node, this._default_step_size);
    stroke.set_brush(this._current_brush);
    this._strokes.add(stroke);
  }
  
  public void start_new_stroke(float x, float y)
  {  
    this.start_new_stroke(x, y, this._brush_size);
  }
  
  public void start_new_stroke()
  {  
    Stroke stroke = new Stroke();
    stroke.set_step_size(this._default_step_size);
    stroke.set_brush(this._current_brush);
    this._strokes.add(stroke);
  }

  /**
   * Adds a node the the current stroke.
   */
  public void add_node(float x, float y, float brush_size)
  {
    Stroke active_stroke = this._get_active_stroke();
    if (active_stroke == null)
    {
      this.start_new_stroke(x, y, brush_size);
      return;
    } else
    {
      Node newKnot = new Node(x, y, brush_size, this._color);
      this._brush_size = brush_size;
      active_stroke.add_knot(newKnot);
      return;
    }
  }
  
  public void add_node(float x, float y)
  {
    this.add_node(x, y, this._brush_size);
  }

  /**
   * Return the stroke beeing drawn at the moment.
   *
   * FIXME: does this take into account the undo stack?
   */
  private Stroke _get_active_stroke()
  {
    if (this._strokes.size() == 0)
    {
      return null;
    } else
    {
      return this._strokes.get(this._strokes.size() - 1);
    }
  }

  /**
   * Sets the size of the spray.
   */
  public void set_brush_size(float value)
  {
    this._brush_size = value;
  }

  /**
   * Sets the color of the spray.
   */
  public void set_color(color value)
  {
    this._color = value;
  }

  public color get_color()
  {
    return this._color;
  }
}