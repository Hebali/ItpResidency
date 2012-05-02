 ///////////////////////////////////////
// BARRIER GRID TOOLS FOR PROCESSING //
//                 BY                //
//  ERIC ROSENTHAL & PATRICK HEBRON  //
///////////////////////////////////////

// NOTE: The Barrier Grid Tools require the ControlP5 Processing Library
// http://www.sojamo.de/libraries/controlP5/

// NOTES:
/*
TODO:
-Layer reordering

COMPLETED:
- Open dialog selects folders but files are ghosted... fix highlighting.
- After load, just top layer should be visible by default.
- MOVE_BY should allow increments much smaller than 1.0.
- Subsample depth 1 to 16 levels.
- Allow clicking on image pane to move the display position of images.
- Add a calibration layer (which can be derived from any of the image layers, selectable by user) that adds a white border around that image...
This allows user to calibrate the alignment with pure white rather than trying to align using image content. When the image is calibrated the border will be pure white for one eye and black for the other.
-Micro adjustments on keyboard.
-Each column (which is a pair of white and black) should represent each src image. So if a col is 10px wide and we have 10 src images, 
each src would have 1 pixel along the horizontal of a col. DONE??

*/

import controlP5.*;
import java.awt.*;
import java.io.*;
import javax.swing.JFileChooser;

// Global Constants
int MODE_MIX = 0;
int MODE_GEN = 1;
int TIME_OUT = 10000;

// Global UI
ControlP5     cP5;
DropdownList  modeListBox;

// Global Variables
int tMode = MODE_MIX;
int lastMoveTime;
PVector prevMousePos;
MixTool  mixer;
GridTool grid;

int M_PRESS   = 0;
int M_DRAG    = 1;
int M_RELEASE = 2;

void setup() {
  size(screenWidth,screenHeight);
    
  // Initialize cP5 UI
  cP5 = new ControlP5(this);
  // Add dropdown list of tool modes
  modeListBox = cP5.addDropdownList("modes",0,15,100,100);
  modeListBox.setItemHeight(15);
  modeListBox.setBarHeight(15);
  modeListBox.captionLabel().set("Tools");
  modeListBox.captionLabel().style().marginTop = 3;
  modeListBox.valueLabel().style().marginTop = 3;
  modeListBox.addItem("Image Mixer",MODE_MIX);
  modeListBox.addItem("Grid Generator",MODE_GEN);
  modeListBox.setColorBackground(color(255,128));
  modeListBox.setColorActive(color(0,0,255,128));
  
  // Initialize Tools
  mixer = new MixTool();
  mixer.setup();
  grid  = new GridTool();
  grid.setup();
  
  // Initialize UI visibility vars
  lastMoveTime = millis();
  prevMousePos = new PVector(0,0);
}

void draw() {
  background(128);
  
  if(tMode == MODE_MIX)       {mixer.draw();}
  else if(tMode == MODE_GEN)  {grid.draw();}
  
  // Handle UI visibility
  int currTime = millis();
  if(abs(mouseX-prevMousePos.x) > 2 || 
     abs(mouseY-prevMousePos.y) > 2) {
       lastMoveTime = currTime;
       cP5.show();
       mixer.toolsAreVisible = true;
       grid.toolsAreVisible  = true;
  }
  prevMousePos = new PVector(mouseX,mouseY);
  if(currTime-lastMoveTime > TIME_OUT) {
    cP5.hide();
    mixer.toolsAreVisible = false;
    grid.toolsAreVisible  = false;
  }
}

void mousePressed() {
  if(tMode == MODE_MIX)       {mixer.handleMouse(M_PRESS);}
  else if(tMode == MODE_GEN)  {grid.handleMouse(M_PRESS);}
}
void mouseDragged() {
  if(tMode == MODE_MIX)       {mixer.handleMouse(M_DRAG);}
  else if(tMode == MODE_GEN)  {grid.handleMouse(M_DRAG);}
}
void mouseReleased() {
  if(tMode == MODE_MIX)       {mixer.handleMouse(M_RELEASE);}
  else if(tMode == MODE_GEN)  {grid.handleMouse(M_RELEASE);}
}

void keyPressed() {
  int kv = -1;
  if (key == CODED) {
    if (keyCode == UP)               {kv=0;} 
    else if (keyCode == DOWN)        {kv=1;} 
    else if (keyCode == LEFT)        {kv=2;}  
    else if (keyCode == RIGHT)       {kv=3;}
  }
  else if (key == '+' || key == '=') {kv=4;}
  else if (key == '-')               {kv=5;}
  else if (key == ',')               {kv=6;}
  else if (key == '.')               {kv=7;}
  if(tMode == MODE_MIX) {mixer.handleKey(kv);}
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isGroup()) { 
    if(theEvent.group().name().equals("modes")) {
      tMode = (int)theEvent.group().value();
      if(tMode == MODE_MIX) {
        mixer.toggleUiVisibility(true);
        grid.toggleUiVisibility(false);
      }
      else if(tMode == MODE_GEN) {
        grid.toggleUiVisibility(true);
        mixer.toggleUiVisibility(false);
      }
    }
  }
  else {
    if(tMode == MODE_MIX)       {mixer.handleEvent(theEvent);}
    else if(tMode == MODE_GEN)  {grid.handleEvent(theEvent);}
  }
  lastMoveTime = millis();
  cP5.show();
}



