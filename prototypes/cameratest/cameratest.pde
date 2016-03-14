/**
 * Getting Started with Capture.
 * 
 * Reading and displaying an image from an attached Capture device. 
 */

import processing.video.Capture;

Capture cam;

void setup()
{
  size(320, 240);
  String[] cameras = Capture.list();
  if (cameras == null)
  {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 320, 240);
  }
  if (cameras.length == 0)
  {
    println("There are no cameras available for capture.");
    exit();
  }
  else
  {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[59]); // fixme magic number
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);
    
    // Start capturing the images from the camera
    println("cam.start()");
    cam.start();
  }
}

void draw()
{
  if (cam.available() == true)
  {
    println("cam.read()");
    cam.read();
  }
  else 
  {
    println("No image available.");
  }
  //image(cam, 0, 0, width, height);
  // The following does the same as the above image() line, but 
  // is faster when just drawing the image without any additional 
  // resizing, transformations, or tint.
  set(0, 0, cam);
}