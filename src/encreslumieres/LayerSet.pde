// FIXME: This is unused for now, right?
class LayerSet
{
  ArrayList<PGraphics> layers;
  public int number;
  
  public LayerSet(int number_of_layers, int image_width, int image_height)
  {
    this.number = number_of_layers;
    for (int i = 0; i < number_of_layers; i++)
    {
    }
    
    createGraphics(width, height, P3D);
  }
  
}