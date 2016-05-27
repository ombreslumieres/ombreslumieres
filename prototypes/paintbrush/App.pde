import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;


final String VERSION = "0.2.1";
final String BACKGROUND_IMAGE_NAME = "background.png";


class App
{
  // private constants
  private final int OSC_SEND_PORT = 13333;
  private final String OSC_SEND_HOST = "127.0.0.1";
  private final int BLOB_INPUT_WIDTH = 640;
  private final int BLOB_INPUT_HEIGHT = 480;

  // private attributes
  private boolean _verbose = false;
  private int _osc_receive_port = 31340;
  private int _width = 640; // window width
  private int _height = 480; // window height
  private PGraphics _test_buffer = null;
  private Brush _test_brush;
  PImage _background_image;
  OscP5 _osc_receiver;
  NetAddress _osc_send_address;

  /**
   * Constructor.
   */
  public App()
  {
    this._test_brush = new ImageBrush();
    ((ImageBrush) this._test_brush).load_image("brush_A_1.png");
    this._background_image = loadImage(BACKGROUND_IMAGE_NAME);
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
    image(this._test_buffer, 0, 0);
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
    this._test_buffer.beginDraw();
    this._test_brush.draw_brush(this._test_buffer, mouse_x, mouse_y, 64, color(255, 127, 0, 127)); // FIXME
    this._test_buffer.endDraw();
  }

  public void mouseReleased_cb(float mouse_x, float mouse_y)
  {
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