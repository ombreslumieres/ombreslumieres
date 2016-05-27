import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;


final String VERSION = "0.2.1";


class App
{
  // private attributes
  private boolean _verbose = false;
  private int _osc_receive_port = 31340;
  private int _width = 640; // window width
  private int _height = 480; // window height
  private PGraphics _test_buffer = null;
  private Brush _test_brush;
  
  /**
   * Constructor.
   */
  public App()
  {
    this._test_brush = new ImageBrush();
    ((ImageBrush) this._test_brush).load_image("brush_A_1.png");
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
  }
  
  public void draw_cb(float mouse_x, float mouse_y)
  {
    background(0);
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
}