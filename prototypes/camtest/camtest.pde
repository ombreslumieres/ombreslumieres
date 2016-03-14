import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;
int CAMERA_INDEX = 0;
final int VIDEO_OUTPUT_WIDTH = 640;
final int VIDEO_OUTPUT_HEIGHT = 480;
final int VIDEO_INPUT_WIDTH = 320;
final int VIDEO_INPUT_HEIGHT = 240;
final int VIDEO_INPUT_FPS = 30;
final int DEFAULT_CAMERA_INDEX = 59;
final float BLOB_BRIGHTNESS_THRESHOLD = 0.2f; // will detect bright areas whose luminosity if greater than this value
//final String VIDEO_CAMERA_NAME_PATTERN = "/dev/video[0-9]*,size=320x240,fps=30"; // play station 3 eye (linux)
final String VIDEO_CAMERA_NAME_PATTERN = "/dev/video1,size=320x240,fps=30"; // play station 3 eye (linux)


void setup() {
  println("Guess video camera name...");
  String camera_name = guess_video_camera_name(VIDEO_CAMERA_NAME_PATTERN);
  size(640, 480);
  video = new Capture(this, VIDEO_INPUT_WIDTH, VIDEO_INPUT_HEIGHT, camera_name, VIDEO_INPUT_FPS);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  video.start();
}

void draw() {
  
  scale(2);
  opencv.loadImage(video);

  image(video, 0, 0 );

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  Rectangle[] faces = opencv.detect();
  println(faces.length);

  for (int i = 0; i < faces.length; i++) {
    println(faces[i].x + "," + faces[i].y);
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
}

void captureEvent(Capture c) {
  c.read();
}
/**
 * For the name pattern, see http://docs.oracle.com/javase/6/docs/api/java/util/regex/Pattern.html
 */
String guess_video_camera_name(String name_pattern)
{
  //return "/dev/video0,size=320x240,fps=30";
  print("Listing caputre devices...");
  String[] cameras = Capture.list();
  println("Done listing devices.");
  String camera_name = "";
  int camera_index = DEFAULT_CAMERA_INDEX;
  
  if (cameras.length == 0)
  {
    println("There are no cameras available for capture.");
    exit();
  }
  else
  {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++)
    {
      println("Camera index: " + i + ", name: " + cameras[i]);
      if (match(cameras[i], name_pattern) != null)
      {
        camera_index = i;
      }
    }
    if (cameras.length <= camera_index)
    {
      camera_index = 0;
    }
    println("Choosing camera index: " + camera_index + ", name: " + cameras[camera_index]);
    camera_name = cameras[camera_index];
  }
  return camera_name;
}