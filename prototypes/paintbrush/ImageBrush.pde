class ImageBrush extends Brush
{
  private PImage _image = null;
  
  public ImageBrush()
  {
    this._image = null;
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
    buffer.colorMode(RGB);
    buffer.tint(red(colour), green(colour), blue(colour), alpha(colour));
    buffer.imageMode(CENTER);
    buffer.image(this._image, x, y, size, size);
    buffer.popStyle();
  }
}