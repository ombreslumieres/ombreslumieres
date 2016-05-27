import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;


final String VERSION = "0.2.1";


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

  /**
   * Constructor.
   */
  public App()
  {
    this._brushes = new ArrayList<Brush>();
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
    SprayCan spray_can = this._spray_cans.get(MOUSE_GRAFFITI_IDENTIFIER);
    spray_can.start_new_stroke(mouse_x, mouse_y);
  }

  public void mouseReleased_cb(float mouse_x, float mouse_y)
  {
    // TODO: record on the undo stack
  }

  public void keyPressed_cb()
  {
  }

  /**
   * Convert a X coordinate from blob range to display range.
   */
  float map_x(float value)
  {
    return map(value, 0.0, BLOB_INPUT_WIDTH, 0.0, this._width);
  }

  /**
   * Convert a Y coordinate from blob range to display range.
   */
  float map_y(float value)
  {
    float height_3_4 = this._width * (3.0 / 4.0);
    return map(value, 0.0, BLOB_INPUT_HEIGHT, 0.0, height_3_4);
  }

  /**
   * Handles /color OSC messages.
   */
  void handle_color(int identifier, int r, int g, int b)
  {
    // TODO
  }

  /**
   * Handles /brush/weight OSC messages.
   */
  void handle_brush_weight(int identifier, int weight)
  {
    // TODO
  }

  /**
   * Handles /blob OSC messages.
   */
  void handle_blob(int identifier, float x, float y, float size)
  {
    // TODO
  }

  /**
   * Handles /force OSC messages.
   */
  void handle_force(int identifier, int force)
  {
    // TODO
  }

  void do_redo()
  {
    // TODO
  }


  void do_undo()
  {
    // TODO
  }

  /**
   * Does the job of creating the points in the stroke, if we received OSC messages.
   */
  private void create_points_if_needed()
  {
    if (mousePressed)
    {
      SprayCan spray_can = this._spray_cans.get(MOUSE_GRAFFITI_IDENTIFIER);
      spray_can.add_node(mouseX, mouseY); // FIXME
    }

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
  void oscEvent(OscMessage message)
  {
    int identifier = 0;
    //print("Received " + message.addrPattern() + " " + message.typetag() + "\n");
    if (message.checkAddrPattern("/force"))
    {
      // TODO: parse string identifier as a first OSC argument
      int force = 0;
      if (message.checkTypetag("ii"))
      {
        identifier = message.get(0).intValue();
        force = message.get(1).intValue();
      } else if (message.checkTypetag("if"))
      {
        identifier = message.get(0).intValue();
        force = (int) message.get(1).floatValue();
      } else
      {
        println("Wrong OSC typetags for /force.");
        // we use to support only the value - no identifier, but
        // not anymore
      }
      handle_force(identifier, force);
    } else if (message.checkAddrPattern("/blob"))
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
      } else
      {
        println("Wrong OSC typetags for /blob.");
      }
      handle_blob(identifier, x, y, size);
    } else if (message.checkAddrPattern("/color"))
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
      } else if (message.checkTypetag("ifff"))
      {
        identifier = message.get(0).intValue();
        r = (int) message.get(1).floatValue();
        g = (int) message.get(2).floatValue();
        b = (int) message.get(3).floatValue();
      } else
      {
        println("Wrong OSC typetags for /color.");
      }
      handle_color(identifier, r, g, b);
    } else if (message.checkAddrPattern("/brush/weight"))
    {
      int weight = 100;
      if (message.checkTypetag("ii"))
      {
        identifier = message.get(0).intValue();
        weight = message.get(1).intValue();
      } else if (message.checkTypetag("if"))
      {
        identifier = message.get(0).intValue();
        weight = (int) message.get(1).floatValue();
      } else
      {
        println("Wrong OSC typetags for /brush/weight.");
      }
      handle_brush_weight(identifier, weight);
    } else if (message.checkAddrPattern("/undo"))
    {
      do_undo();
    } else if (message.checkAddrPattern("/redo"))
    {
      do_redo();
    }
  }
}