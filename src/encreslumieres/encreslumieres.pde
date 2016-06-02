// XXX comment out next line if not using Syphon
import codeanticode.syphon.SyphonServer;


// constants
final String SYPHON_SERVER_NAME = "encres&lumieres";
final boolean VERBOSE = true;
final int OSC_RECEIVE_PORT = 31340;


// variables
App app;
// XXX comment out next line if not using Syphon
SyphonServer syphon_server;


void settings()
{
  size(displayWidth, displayHeight, P3D);
  // XXX comment out next line if not using Syphon
  PJOGL.profile = 1;
}


void setup()
{
  frameRate(60);
  app = new App();
  app.set_osc_receive_port(OSC_RECEIVE_PORT);
  app.set_verbose(VERBOSE);
  app.set_size(width, height);
  app.setup_cb();
  // XXX comment out next line if not using Syphon
  syphon_server = new SyphonServer(this, SYPHON_SERVER_NAME);
}


void draw()
{
  app.draw_cb(mouseX, mouseY);
  // XXX comment out next line if not using Syphon
  syphon_server.sendScreen();
}


void mousePressed()
{
  app.mousePressed_cb(mouseX, mouseY);
}


void mouseReleased()
{
  app.mouseReleased_cb(mouseX, mouseY);
}


void keyPressed()
{
  app.keyPressed_cb();
}