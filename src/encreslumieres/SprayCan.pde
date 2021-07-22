/**
 * Manages one spray can.
 */
class SprayCan {
  // constants
  private final float DEFAULT_STEP_SIZE = 1.0; // how many pixels between each brush drawn - interpolated. See PointShaderBrush
  private final float DEFAULT_BRUSH_WEIGHT = 64; // size of the brush in pixels
  private final int NUMBER_OF_UNDO_LEVELS = 5;
  private final boolean ENABLE_UNDO = false; // Set to true to enable the undo system!

  // attributes
  private ArrayList<Stroke> _strokes; // Lists of nodes - to be drawn only once
  private color _color; // Current color
  private float _brush_weight = DEFAULT_BRUSH_WEIGHT; // Set for each can using OSC messages.
  private Brush _current_brush; // Instance of a Brush to draw on our buffer
  private PGraphics _buffer = null; // Our pixel buffer.
  private int _image_width; // sketch size
  private int _image_height; // sketch size
  private float _default_step_size; // how many pixels between each brush drawn - interpolated. See PointShaderBrush
  private float _cursor_x = 0.0; // blob X
  private float _cursor_y = 0.0; // blob Y
  private float _cursor_blob_size = 0.0; // blob size
  private boolean _is_spraying = false; // set when we receive /force
  private Undo _undo;
  private float _alpha_ratio = 1.0; // range: [0,1]
  private float _scale_center_x = 0.5;
  private float _scale_center_y = 0.5;
  private float _scale_factor = 1.0;
  private int _layer = 0;
  private boolean _enable_linked_strokes = false;

  /**
   * Represents a spray can.
   * There can be up to a few cans drawing at the same time.
   * Each can sends OSC messages via the Wifi network. (/blob position, /force amount, /color, etc.)
   */
  public SprayCan(int image_width, int image_height) {
    this._strokes = new ArrayList<Stroke>();
    this._color = color(255, 255, 255, 255);
    //this._brush_size = this.DEFAULT_BRUSH_SIZE; // FIXME
    this._default_step_size = this.DEFAULT_STEP_SIZE;
    this._image_width = image_width;
    this._image_height = image_height;
    this._undo = new Undo(this.NUMBER_OF_UNDO_LEVELS, this._image_width, this._image_height);
    this.clear_all_strokes(); // Creates the this._buffer
  }
  
  /**
   * Sets the scale center for this spray can.
   */
  public void set_scale_center(float x, float y) {
    this._scale_center_x = x;
    this._scale_center_y = y;
  }
  
  /**
   * Sets the scale factor for this spray can.
   */
  public void set_scale_factor(float scale_factor) {
    this._scale_factor = scale_factor;
  }
  
  public float get_scale_center_x() {
    return this._scale_center_x;
  }
  
  public float get_scale_center_y() {
    return this._scale_center_y;
  }
  
  public float get_scale_factor() {
    return this._scale_factor;
  }
  
  public void set_step_size(float value) {
    this._default_step_size = value;
  }
  
  public void set_layer(int value) {
    this._layer = value;
  }
  
  public int get_layer() {
    return this._layer;
  }
  
  public void set_enable_linked_strokes(boolean value) {
    this._enable_linked_strokes = value;
  }
  
  public boolean get_enable_linked_strokes() {
    return this._enable_linked_strokes;
  }

  /**
   * Sets whether or not it is spraying.
   *
   * Set when we receive the /force OSC message from the Wifi spray can.
   * (useful for adding more node when we receive new blob positions)
   */
  void set_is_spraying(boolean value) {
    this._is_spraying = value;
  }
  
  /**
   * Returns whether or not it is spraying.
   *
   * (useful for adding more node when we receive new blob positions)
   */
  public boolean get_is_spraying() {
    return this._is_spraying;
  }

  public void set_alpha_ratio(float value) {
    //println("alpha ratio " + value);
    this._alpha_ratio = value;
  }

  /**
   * Sets the current brush instance.
   */
  void set_current_brush(Brush brush) {
    this._current_brush = brush;
  }

  /**
   * Draws all its strokes.
   *
   * We draw in a buffer each stroke's node once.
   * Then, when this is done, we simply display that buffer's image on the canvas.
   * FIXME: each nodes should be drawn only once.
   * Right now, each node is drawn on each frame. This is O(n) where n = number of nodes.
   */
  public void draw_spraycan() {
    this._buffer.beginDraw();
    for (Stroke stroke : this._strokes) {
      stroke.draw_stroke(this._buffer); // , shader);
    }
    image(this._buffer, 0, 0);
    this._buffer.endDraw();
  }
  
  /**
   * Draws the cursor on the canvas.
   */
  public void draw_cursor() {
    // we could use an image instead, but scaling it might be more complicated
    pushStyle();
    noFill();
    
    float ellipse_size = this._brush_weight;
    float cursor_x = this._cursor_x;
    float cursor_y = this._cursor_y;
    float line_size = ellipse_size / 2.0;
    
    strokeWeight(3.0);
    stroke(#cccccc);
    ellipse(cursor_x, cursor_y, ellipse_size, ellipse_size);
    line(cursor_x - line_size, cursor_y, cursor_x + line_size, cursor_y);
    line(cursor_x, cursor_y - line_size, cursor_x, cursor_y + line_size);
    
    strokeWeight(1.0);
    stroke(#333333);
    ellipse(cursor_x, cursor_y, ellipse_size, ellipse_size);
    line(cursor_x - line_size, cursor_y, cursor_x + line_size, cursor_y);
    line(cursor_x, cursor_y - line_size, cursor_x, cursor_y + line_size);
    
    popStyle();
  }
  
  /**
   * Sets the cursor X and Y position, as well as its size.
   */
  public void set_cursor_x_y_size(float x, float y, float cursor_blob_size) {
    this._cursor_x = x;
    this._cursor_y = y;
    this._cursor_blob_size = cursor_blob_size;
  }
  
  /**
   * Sets the weight of the brush.
   *
   * (done via a separate OSC message)
   * FIXME: set_brush_size vs set_brush_weight?
   */
  public void set_brush_weight(float value) {
    this._brush_weight = value;
  }
  
  /**
   * Returns the cursor X position.
   */
  public float get_cursor_x() {
    return this._cursor_x;
  }
  
  /**
   * Returns the cursor Y position.
   */
  public float get_cursor_y() {
    return this._cursor_y;
  }

  /**
   * Deletes all the strokes.
   */
  public void clear_all_strokes() {
    //for (Stroke stroke : this._strokes)
    //{
      // Uneeded
      // And seems to cause a NullPointerException - sometimes when we have been drawing a bit
      // stroke.clear_stroke();
    //}
    this._strokes.clear();
    this._buffer = createGraphics(this._image_width, this._image_height);
    // we used to use the P3D renderer, as a 3rd argument
    this._buffer.colorMode(RGB, 255);
    this._buffer.beginDraw();
    this._buffer.background(0, 0, 0, 0);
    this._buffer.endDraw();
    this._save_snapshot_for_undo_stack();
  }
  
  private float _get_node_weight() {
    // we might use 
    return this._brush_weight;
  }
  
  color _generate_color_with_alpha_from_force() {
    color ret = color(red(this._color), green(this._color), blue(this._color), (int) alpha(this._color) * this._alpha_ratio);
    return ret;
  }

  /**
   * Starts a stroke with a given first node position and size.
   */
  public void start_new_stroke(float x, float y, float cursor_blob_size) {
    this._save_snapshot_for_undo_stack();
    color colour = this._generate_color_with_alpha_from_force();
    Node starting_node = new Node(x, y, this._get_node_weight(), colour);
    this._cursor_blob_size = cursor_blob_size;
    Stroke stroke = new Stroke(starting_node, this._default_step_size);
    stroke.set_brush(this._current_brush);
    this._strokes.add(stroke);
  }
  
  private void _save_snapshot_for_undo_stack() {
    if (ENABLE_UNDO) {
      this._undo.take_snapshot(this._buffer);
    }
  }
  
  /**
   * Starts a stroke.
   * Creates a first node with the default size. 
   */
  public void start_new_stroke(float x, float y) {  
    this.start_new_stroke(x, y, this._get_node_weight());
  }
  
  /**
   * Starts a stroke.
   * Creates no first node.
   */
  public void start_new_stroke() {
    this._save_snapshot_for_undo_stack();
    
    Stroke stroke = new Stroke();
    stroke.set_step_size(this._default_step_size);
    stroke.set_brush(this._current_brush);
    this._strokes.add(stroke);
  }

  /**
   * Adds a node to the current stroke.
   */
  public void add_node(float x, float y, float cursor_blob_size) {
    Stroke active_stroke = this._get_active_stroke();
    if (active_stroke == null) {
      this.start_new_stroke(x, y, this._get_node_weight());
      return;
    } else {
      this._cursor_blob_size = cursor_blob_size;
      color colour = this._generate_color_with_alpha_from_force();
      Node newKnot = new Node(x, y, this._get_node_weight(), colour);
      
      active_stroke.add_knot(newKnot);
      return;
    }
  }
  
  /**
   * Adds a node to the current stroke, with the same size as the one before.
   */
  public void add_node(float x, float y) {
    this.add_node(x, y, this._get_node_weight());
  }

  /**
   * Return the stroke beeing drawn at the moment.
   *
   * FIXME: does this take into account the undo stack?
   */
  private Stroke _get_active_stroke() {
    if (this._strokes.size() == 0) {
      return null;
    } else {
      return this._strokes.get(this._strokes.size() - 1);
    }
  }

  /**
   * Sets the color of the spray.
   *
   * The brush should take into account the alpha.
   */
  public void set_color(color value) {
    this._color = value;
  }

  /**
   * Returns the color of this spray.
   */
  public color get_color() {
    return this._color;
  }
  
  public void undo() {
    // FIXME: we save the pixel buffer, and can undo/redo it,
    // but we don't delete the strokes and their nodes.
    // The nodes are drawn only once, anyways
    // and we save that to our pixel buffer
    // so we don't care for now about there arrays
    // but some day, when we want to save/playback the strokes
    // we will want to cleanup these strokes when we done with one
    // (since it was cancelled, for example)

    if (ENABLE_UNDO) {
      this._buffer.beginDraw();
      this._buffer.pushStyle();
      this._buffer.tint(color(255, 255, 255, 255));
      this._undo.undo(this._buffer);
      this._buffer.popStyle();
      this._buffer.endDraw();
    } else {
      println("The undo system is disabled.");
    }
  }
  
  public void redo() {
    if (ENABLE_UNDO) {
      this._buffer.beginDraw();
      this._buffer.pushStyle();
      this._buffer.tint(color(255, 255, 255, 255));
      this._undo.redo(this._buffer);
      this._buffer.popStyle();
      this._buffer.endDraw();
    } else {
      println("The undo system is disabled.");
    }
  }
}
