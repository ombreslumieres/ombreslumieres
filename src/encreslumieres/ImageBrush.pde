class ImageBrush extends Brush
{
  private PImage _image = null;
  private boolean _enable_rotation = true;
  
  public ImageBrush()
  {
    super();
    this._image = null;
  }
  
  public void set_enable_rotation(boolean value)
  {
    this._enable_rotation = value;
  }
  
  public void load_image(String image_file_name)
  {
    this._image = loadImage(image_file_name);
  }
  
  public final void draw_brush(PGraphics buffer, float x, float y, float size, color colour)
  {
    if (this._image == null)
    {
      println("ImageBrush::draw_brush: Warning: No image loaded yet.");
      return;
    }
    
    buffer.pushStyle();
    buffer.pushMatrix();
    
    buffer.colorMode(RGB);
    buffer.tint(red(colour), green(colour), blue(colour), alpha(colour));
    buffer.translate(x, y);
    if (this._enable_rotation)
    {
      buffer.rotate(radians(random(0.0, 360.0)));
    }
    buffer.imageMode(CENTER);
    buffer.image(this._image, 0, 0, size, size);
    
    buffer.popMatrix();
    buffer.popStyle();
  }
}