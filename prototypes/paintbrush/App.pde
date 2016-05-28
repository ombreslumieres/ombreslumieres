import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;


final String VERSION = "0.3.0";


class App
{
  // private constants
  private final int OSC_SEND_PORT = 13333;
  private final String OSC_SEND_HOST = "127.0.0.1";
  private final int BLOB_INPUT_WIDTH = 640;
  private final int BLOB_INPUT_HEIGHT = 480;
  private final int NUM_SPRAY_CANS = 10;
  private final int MOUSE_GRAFFITI_IDENTIFIER = 0;
  private final String BACKGROUND_IMAGE_NAME = "background.png";
  /*
   * Now, the /force we receive from the Arduino over wifi is 
   * within the range [0,1023] and we invert the number, so that
   * if we received, 100, example, we will turn it here into
   * 1023 - 100, which results in 923. Now we will compare it to
   * a threshold, for example 400. If that inverted force is over
   * 400, the brush will be on. FORCE_THRESHOLD is what you will
   * need to change often. See below.
   */
  final int FORCE_MAX = 1023; // DO NOT change this
  final int FORCE_THRESHOLD = 150; // you will need to change this. Used to be 623, then 200

  // private attributes
  private boolean _verbose = false;
  private int _osc_receive_port = 31340;
  private int _width = 640; // window width
  private int _height = 480; // window height
  private PGraphics _test_buffer = null;
  PImage _background_image;
  OscP5 _osc_receiver;
  NetAddress _osc_send_address;
  ArrayList<SprayCan> _spray_cans;
  ArrayList<Brush> _brushes;
  ArrayList<Command> _commands;

  /**
   * Constructor.
   * 
   * See this.setup_cb() for more initialization. (OSC receiver, etc.)
   */
  public App()
  {
    this._brushes = new ArrayList<Brush>();
    this._commands = new ArrayList<Command>();
    this._load_brushes();
    this._background_image = loadImage(BACKGROUND_IMAGE_NAME);

    this._spray_cans = new ArrayList<SprayCan>();
    for (int i = 0; i < this.NUM_SPRAY_CANS; i++)
    {
      SprayCan item = new SprayCan(width, height); // FIXME using global vars here.
      item.set_color(color(255, 127, 63, 255)); // default color is orange
      item.set_brush_size(32); // default brush size
      item.set_current_brush(this._brushes.get(0));
      this._spray_cans.add(item);
    }
    
    // XXX See this.setup_cb() for more initialization. (OSC receiver, etc.)
  }
  
  private synchronized void _push_command(Command command)
  {
    this._commands.add(command);
  }
  
  private synchronized Command _pop_command()
  {
    Command ret = null;
    if (this._commands.size() > 0)
    {
      int index = this._commands.size() - 1;
      ret = this._commands.get(index);
      this._commands.remove(index);
    }
    return ret;
  }
  
  private void _consume_commands()
  {
    final int MAX_COMMANDS = 1000;
    for (int i = 0; i < MAX_COMMANDS; i ++)
    {
      Command command = this._pop_command();
      if (command == null)
      {
        break;
      }
      else
      {
        command.apply(this);
      }
    }
  }
  
  private void _load_brushes()
  {
    Brush point_shader_brush = new PointShaderBrush();
    this._brushes.add(point_shader_brush);
    
    Brush image_brush = new ImageBrush();
    ((ImageBrush) image_brush).load_image("brush_A_1.png");
    this._brushes.add(image_brush);
  }
  
  public boolean choose_brush(int spray_can_index, int brush_index)
  {
    // TODO: test this
    if (spray_can_index < this.NUM_SPRAY_CANS)
    {
      if (brush_index >= this._brushes.size())
      {
        println("Warning: no such brush index: " + brush_index); 
        return false;
      }
      else
      {
        this._spray_cans.get(spray_can_index).set_current_brush(this._brushes.get(brush_index));
        return true;
      }
    }
    else
    {
      println("Warning: no such spray can index: " + spray_can_index); 
      return false;
    }
  }

  public void set_verbose(boolean value)
  {
    this._verbose = value;
  }

  public void set_osc_receive_port(int value)
  {
    this._osc_receive_port = value;
  }

  public void set_size(int size_width, int size_height)
  {
    this._width = size_width;
    this._height = size_height;
  }

  public void setup_cb()
  {
    this._test_buffer = createGraphics(this._width, this._height, P3D);
    // start oscP5, listening for incoming messages at a given port
    this._osc_receiver = new OscP5(this, this._osc_receive_port);
    this._osc_send_address = new NetAddress(OSC_SEND_HOST, OSC_SEND_PORT);
  }

  public void draw_cb(float mouse_x, float mouse_y)
  {
    background(0);
    image(this._background_image, 0, 0);
    
    if (mousePressed)
    {
      //SprayCan spray_can = this._spray_cans.get(MOUSE_GRAFFITI_IDENTIFIER);
      //spray_can.add_node(mouseX, mouseY); // FIXME
      this._push_command((Command) new AddNodeCommand(MOUSE_GRAFFITI_IDENTIFIER, mouse_x, mouse_y)); // , float size
    }
    this._consume_commands();
    this.create_points_if_needed();

    for (int i = 0; i < this._spray_cans.size(); i++)
    {
      // TODO: draw each spray can layer separately
      this._spray_cans.get(i).draw_spraycan();
    }
    for (int i = 0; i < this._spray_cans.size(); i++)
    {
      this._spray_cans.get(i).draw_cursor();
    }
  }

  private void log_debug(String message)
  {
    if (this._verbose)
    {
      println(message);
    }
  }

  private void log_info(String message)
  {
    println(message);
  }

  public void mousePressed_cb(float mouse_x, float mouse_y)
  {
    //SprayCan spray_can = this._spray_cans.get(MOUSE_GRAFFITI_IDENTIFIER);
    //spray_can.start_new_stroke(mouse_x, mouse_y);
    this._push_command((Command) new NewStrokeCommand(MOUSE_GRAFFITI_IDENTIFIER));
  }

  public void mouseReleased_cb(float mouse_x, float mouse_y)
  {
    // TODO: record on the undo stack
    // add EndStrokeCommand
  }

  public void keyPressed_cb()
  {
  }

  /**
   * Convert a X coordinate from blob range to display range.
   */
  private float map_x(float value)
  {
    return map(value, 0.0, BLOB_INPUT_WIDTH, 0.0, this._width);
  }

  /**
   * Convert a Y coordinate from blob range to display range.
   */
  private float map_y(float value)
  {
    float height_3_4 = this._width * (3.0 / 4.0);
    return map(value, 0.0, BLOB_INPUT_HEIGHT, 0.0, height_3_4);
  }

  /**
   * Handles /color OSC messages.
   */
  private void handle_color(int spray_can_index, int r, int g, int b)
  {
    // TODO
  }

  /**
   * Handles /brush/weight OSC messages.
   */
  private void handle_brush_weight(int spray_can_index, int weight)
  {
    // TODO
  }

  /**
   * Handles /blob OSC messages.
   */
  private void handle_blob(int spray_can_index, float x, float y, float size)
  {
    // TODO
  }

  /**
   * Handles /force OSC messages.
   */
  private void handle_force(int spray_can_index, int force)
  {
    // TODO
  }

  /**
   * Handles redo OSC messages.
   */
  private void handle_redo(int spray_can_index)
  {
    // TODO
  }

  /**
   * Handles undo OSC messages.
   */
  private void handle_undo(int spray_can_index)
  {
    // TODO
  }
  
  public void apply_add_node(int spray_can_index, float x, float y) // , float size)
  {
    SprayCan spray_can = this._spray_cans.get(spray_can_index);
    spray_can.add_node(x, y);
  }
  
  public void apply_new_stroke(int spray_can_index)
  {
    SprayCan spray_can = this._spray_cans.get(spray_can_index);
    spray_can.start_new_stroke();
  }
  
  

  /**
   * Does the job of creating the points in the stroke, if we received OSC messages.
   */
  private void create_points_if_needed()
  {
    //if (mousePressed)
    //{
    //  SprayCan spray_can = this._spray_cans.get(MOUSE_GRAFFITI_IDENTIFIER);
    //  spray_can.add_node(mouseX, mouseY); // FIXME
    //}

    for (int i = 0; i < _spray_cans.size(); i++)
    {
      SprayCan spray_can = _spray_cans.get(i);
      // TODO
    }
  }

  /**
   * Incoming osc message are forwarded to the oscEvent method.
   *
   * The name of this method is set up by the oscP5 library.
   */
  public void oscEvent(OscMessage message)
  {
    int identifier = 0;
    //print("Received " + message.addrPattern() + " " + message.typetag() + "\n");
    
    // ---  /force ---
    if (message.checkAddrPattern("/force"))
    {
      // TODO: parse string identifier as a first OSC argument
      int force = 0;
      if (message.checkTypetag("ii"))
      {
        identifier = message.get(0).intValue();
        force = message.get(1).intValue();
      }
      else if (message.checkTypetag("if"))
      {
        identifier = message.get(0).intValue();
        force = (int) message.get(1).floatValue();
      }
      else
      {
        println("Wrong OSC typetags for /force.");
        // we use to support only the value - no identifier, but
        // not anymore
      }
      handle_force(identifier, force);
    }
    
    // ---  /blob ---
    else if (message.checkAddrPattern("/blob"))
    {
      float x = 0.0;
      float y = 0.0;
      float size = 0.0;
      if (message.checkTypetag("ifff"))
      {
        identifier = message.get(0).intValue();
        x = message.get(1).floatValue();
        y = message.get(2).floatValue();
        size = message.get(3).floatValue();
      }
      else
      {
        println("Wrong OSC typetags for /blob.");
      }
      handle_blob(identifier, x, y, size);
    }
    
    // ---  /color ---
    else if (message.checkAddrPattern("/color"))
    {
      int r = 255;
      int g = 255;
      int b = 255;
      if (message.checkTypetag("iiii"))
      {
        identifier = message.get(0).intValue();
        r = message.get(1).intValue();
        g = message.get(2).intValue();
        b = message.get(3).intValue();
      }
      else if (message.checkTypetag("ifff"))
      {
        identifier = message.get(0).intValue();
        r = (int) message.get(1).floatValue();
        g = (int) message.get(2).floatValue();
        b = (int) message.get(3).floatValue();
      }
      else
      {
        println("Wrong OSC typetags for /color.");
      }
      handle_color(identifier, r, g, b);
    }
    
    // ---  /brush/weight ---
    else if (message.checkAddrPattern("/brush/weight"))
    {
      int weight = 100;
      if (message.checkTypetag("ii"))
      {
        identifier = message.get(0).intValue();
        weight = message.get(1).intValue();
      }
      else if (message.checkTypetag("if"))
      {
        identifier = message.get(0).intValue();
        weight = (int) message.get(1).floatValue();
      }
      else
      {
        println("Wrong OSC typetags for /brush/weight.");
      }
      handle_brush_weight(identifier, weight);
    }
    
    // ---  /undo ---
    else if (message.checkAddrPattern("/undo"))
    {
      if (message.checkTypetag("i"))
      {
        identifier = message.get(0).intValue();
        this.handle_undo(identifier);
      }
    }
    
    // ---  /redo ---
    else if (message.checkAddrPattern("/redo"))
    {
      if (message.checkTypetag("i"))
      {
        identifier = message.get(0).intValue();
        this.handle_redo(identifier);
      }
    }
  }
}