///////////////////////////////////////
// BARRIER GRID TOOLS FOR PROCESSING //
//                 BY                //
//  ERIC ROSENTHAL & PATRICK HEBRON  //
///////////////////////////////////////

// NOTE: The Barrier Grid Tools require the ControlP5 Processing Library
// http://www.sojamo.de/libraries/controlP5/

import controlP5.*;
import java.awt.*;
import java.io.*;

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

void setup() {
  size(1024,768);
  
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
  background(0);
  
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
  if(tMode == MODE_MIX)       {mixer.handleMouse();}
  else if(tMode == MODE_GEN)  {grid.handleMouse();}
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



