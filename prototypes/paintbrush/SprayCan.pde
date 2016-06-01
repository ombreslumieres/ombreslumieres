/**
 * Manages one spray can.
 */
class SprayCan
{
  // constants
  private final float DEFAULT_STEP_SIZE = 5.0; // how many pixels between each brush drawn - interpolated. See PointShaderBrush
  private final float DEFAULT_BRUSH_SIZE = 64; // size of the brush in pixels
  private final float BRUSH_SCALE = 0.3; // FIXME: what is this?
  
  // attributes
  private ArrayList<Stroke> _strokes; // Lists of nodes - to be drawn only once
  private color _color; // Current color
  private float _brush_size; // XXX duplicate with _cursor_size
  private float _brush_weight; // We use this. Set for each can using OSC messages.
  private Brush _current_brush; // Instance of a Brush to draw on our buffer
  private PGraphics _buffer = null; // Our pixel buffer.
  private int _image_width; // sketch size
  private int _image_height; // sketch size
  private float _default_step_size; // how many pixels between each brush drawn - interpolated. See PointShaderBrush
  private float _cursor_x = 0.0; // blob X
  private float _cursor_y = 0.0; // blob Y
  private float _cursor_size = 0.0; // blob size
  private boolean _is_spraying = false; // set when we receive /force
    // TODO: add undo here

  /**
   * Represents a spray can.
   * There can be up to a few cans drawing at the same time.
   * Each can sends OSC messages via the Wifi network. (/blob position, /force amount, /color, etc.)
   */
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

  /**
   * Sets whether or not it is spraying.
   * Set when we receive the /force OSC message from the Wifi spray can.
   * (useful for adding more node when we receive new blob positions)
   */
  void set_is_spraying(boolean value)
  {
    this._is_spraying = value;
  }
  
  /**
   * Returns whether or not it is spraying.
   * (useful for adding more node when we receive new blob positions)
   */
  boolean get_is_spraying()
  {
    return this._is_spraying;
  }

  /**
   * Sets the current brush instance.
   */
  void set_current_brush(Brush brush)
  {
    this._current_brush = brush;
  }

  /**
   * Draws all its strokes.
   * We draw in a buffer each stroke's node once.
   * Then, when this is done, we simply display that buffer's image on the canvas.
   * NOTE: nodes are only drawn once.
   */
  public void draw_spraycan()
  {
    this._buffer.beginDraw();
    for (Stroke stroke : this._strokes)
    {
      stroke.draw_stroke(this._buffer); // , shader);
    }
    image(this._buffer, 0, 0);
    this._buffer.endDraw();
  }
  
  /**
   * Simply draw the cursor on the canvas.
   */
  public void draw_cursor()
  {
    // TODO
    pushStyle();
    noFill();
    strokeWeight(1.0);
    stroke(255, 0, 0);
    float ellipse_size = this._brush_size * BRUSH_SCALE;
    float cursor_x = this._cursor_x;
    float cursor_y = this._cursor_y;
    ellipse(cursor_x, cursor_y, ellipse_size, ellipse_size);
    popStyle();
  }
  
  /**
   * Sets the cursor X and Y position, as well as its size.
   */
  public void set_cursor_x_y_size(float x, float y, float size)
  {
    this._cursor_x = x;
    this._cursor_y = y;
    this._cursor_size = size;
  }
  
  /**
   * Sets the weight of the brush.
   * (done via a separate OSC message)
   * FIXME: set_brush_size vs set_brush_weight?
   */
  public void set_brush_weight(float value)
  {
    this._brush_weight = value;
  }
  
  /**
   * Returns the cursor X position.
   */
  public float get_cursor_x()
  {
    return this._cursor_x;
  }
  
  /**
   * Returns the cursor Y position.
   */
  public float get_cursor_y()
  {
    return this._cursor_y;
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
   * Starts a stroke with a given first node position and size.
   */
  public void start_new_stroke(float x, float y, float brush_size)
  {  
    Node starting_node = new Node(x, y, brush_size, this._color);
    this._brush_size = brush_size;
    Stroke stroke = new Stroke(starting_node, this._default_step_size);
    stroke.set_brush(this._current_brush);
    this._strokes.add(stroke);
  }
  
  /**
   * Starts a stroke.
   * Creates a first node with the default size. 
   */
  public void start_new_stroke(float x, float y)
  {  
    this.start_new_stroke(x, y, this._brush_size);
  }
  
  /**
   * Starts a stroke.
   * Creates no first node.
   */
  public void start_new_stroke()
  {  
    Stroke stroke = new Stroke();
    stroke.set_step_size(this._default_step_size);
    stroke.set_brush(this._current_brush);
    this._strokes.add(stroke);
  }

  /**
   * Adds a node to the current stroke.
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
  
  /**
   * Adds a node to the current stroke, with the same size as the one before.
   */
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
   * FIXME: set_brush_size vs set_brush_weight?
   */
  public void set_brush_size(float value)
  {
    this._brush_size = value;
  }

  /**
   * Sets the color of the spray.
   * The brush should take into account the alpha.
   */
  public void set_color(color value)
  {
    this._color = value;
  }

  /**
   * Returns the color of this spray.
   */
  public color get_color()
  {
    return this._color;
  }
}