class StackOfImages
{
  int amount;
  int current;
  PImage[] img;
  
  StackOfImages(int amountOfImages, int images_width, int images_height)
  {
    this.amount = amountOfImages;
 
    // Initialize all images as copies of the current display
    this.img = new PImage[this.amount];
    for (int i = 0; i < this.amount; i++)
    {
      this.img[i] = createImage(images_width, images_height, RGB);
      this.img[i] = get();
    }
  }
  
  void next()
  {
    this.current = (this.current + 1) % this.amount;
  }
  
  void prev()
  {
    this.current = (this.current - 1 + this.amount) % this.amount;
  }
  
  void capture(PGraphics screen)
  {
    this.img[this.current] = screen.get();
  }
  
  void show(PGraphics screen)
  {
    screen.image(this.img[current], 0, 0);
  }
}