import processing.core.*; 
import processing.xml.*; 

import controlP5.*; 
import java.awt.*; 
import java.io.*; 
import javax.swing.JFileChooser; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class BGTools extends PApplet {

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

public void setup() {
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

public void draw() {
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

public void mousePressed() {
  if(tMode == MODE_MIX)       {mixer.handleMouse(M_PRESS);}
  else if(tMode == MODE_GEN)  {grid.handleMouse(M_PRESS);}
}
public void mouseDragged() {
  if(tMode == MODE_MIX)       {mixer.handleMouse(M_DRAG);}
  else if(tMode == MODE_GEN)  {grid.handleMouse(M_DRAG);}
}
public void mouseReleased() {
  if(tMode == MODE_MIX)       {mixer.handleMouse(M_RELEASE);}
  else if(tMode == MODE_GEN)  {grid.handleMouse(M_RELEASE);}
}

public void keyPressed() {
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

public void controlEvent(ControlEvent theEvent) {
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



public class GridTool {
  PImage          outputImg;
  ControlGroup    gridTools;
   
  boolean         isVertical        = false;
  boolean         toolsAreVisible   = false;

  public float    MASTER_WIDTH      = 1024.0f;
  public float    MASTER_HEIGHT     = 768.0f;
  
  public float    LCD_WIDTH         = 14.0f;
  public float    LCD_HEIGHT        =  8.0f;
  
  public float    LPI               = 10.0f;
  
  public float    PERCENT_BLACK     = 60.0f;
  
  Numberbox       masterW_box,masterH_box,lcdW_box,lcdH_box,lpi_box,black_box;
  
  public GridTool() {}
  
  public void setup() {
    gridTools = cP5.addGroup("gridTools",120,0);
    gridTools.hideBar();
    cP5.addButton("rotate",0,0,0,90,14).setGroup(gridTools);
    
    masterW_box = cP5.addNumberbox("MASTER_WIDTH",MASTER_WIDTH,100,0,90,14);
    masterW_box.setGroup(gridTools);
    masterW_box.setMultiplier(1);
    
    masterH_box = cP5.addNumberbox("MASTER_HEIGHT",MASTER_HEIGHT,200,0,90,14);
    masterH_box.setGroup(gridTools);
    masterH_box.setMultiplier(1);
    
    lcdW_box = cP5.addNumberbox("GRID_LCD_WIDTH",LCD_WIDTH,300,0,90,14);
    lcdW_box.setGroup(gridTools);
    lcdW_box.setMultiplier(1);
    
    lcdH_box = cP5.addNumberbox("GRID_LCD_HEIGHT",LCD_HEIGHT,400,0,90,14);
    lcdH_box.setGroup(gridTools);
    lcdH_box.setMultiplier(1);
        
    lpi_box = cP5.addNumberbox("GRID_LPI",LPI,500,0,90,14);
    lpi_box.setGroup(gridTools);
    lpi_box.setMultiplier(0.1f);
    
    black_box = cP5.addNumberbox("PERCENT_BLACK",PERCENT_BLACK,600,0,90,14);
    black_box.setGroup(gridTools);
    black_box.setMultiplier(5.0f);
    
    toggleUiVisibility(toolsAreVisible);
    generateImg();
  }
  
  public void keyPressed() {
    if(key == '-') {
      black_box.setValue(max(black_box.value()-5,50));
      generateImg();
    }
    else if(key == '+') {
      black_box.setValue(min(black_box.value()+5,90));
      generateImg();
    }
    else if(key == ',') {
      lpi_box.setValue(max(lpi_box.value()-0.1f,10.0f));
      generateImg();
    }
    else if(key == '.') {
      lpi_box.setValue(min(lpi_box.value()+0.1f,40.0f));
      generateImg();
    }
  }
  
  public boolean handleMouse(int Type) {
    return false;
  }
  
  public void generateImg() {    
    float wRatio = (float)masterW_box.value()/lcdW_box.value();
    float hRatio = (float)masterH_box.value()/lcdH_box.value();
    //float pixelsPerInch = ((wRatio>hRatio)?(wRatio):(hRatio)); ??
    float pixelsPerInch = wRatio;
    float lineWidth     = pixelsPerInch/lpi_box.value();
    
    int blackLines = (int)(lineWidth*(black_box.value()/100.0f));
    int clearLines = (int)lineWidth-blackLines;

    outputImg = createImage((int)masterW_box.value(),(int)masterH_box.value(),ARGB);
    for(int x = 0; x < masterW_box.value(); x++) {
        int s = x % (int)lineWidth;
        for(int y = 0; y < masterH_box.value(); y++) {
          if(s < clearLines) {outputImg.pixels[y*(int)masterW_box.value() + x] = color(255,255,255,255);}
          else {outputImg.pixels[y*(int)masterW_box.value() + x] = color(0,0,0,255);}
        }
    }
    outputImg.updatePixels();
  }
  
  public void draw() {
    // Draw grid
    pushMatrix();
    if(isVertical) {
      translate(masterH_box.value(),0);
      rotate(PI/2);
    }
    fill(255);
    image(outputImg,0,0);
    popMatrix();
    // Draw tool background 
    if(toolsAreVisible) {
      fill(25,25,25,200);
      rect(0,0,width,42);
    }
  }
  
  public boolean handleEvent(ControlEvent theEvent) {
    // Handle rotation
    if(theEvent.name().equals("rotate")) {
      isVertical   = !isVertical;
      float curMW  = masterW_box.value();
      float curMH  = masterH_box.value();
      masterW_box.setValue(curMH);
      masterH_box.setValue(curMW);
      float curLW  = lcdW_box.value();
      float curLH  = lcdH_box.value();
      lcdW_box.setValue(curLH);
      lcdH_box.setValue(curLW);
    }
    // Lock ranges
    if(masterW_box.value() < 1)          {masterW_box.setValue(1.0f);}
    else if(masterW_box.value() > 10000) {masterW_box.setValue(10000.0f);}
    if(masterH_box.value() < 1)          {masterH_box.setValue(1.0f);}
    else if(masterH_box.value() > 10000) {masterH_box.setValue(10000.0f);}
    if(lcdW_box.value() < 1)             {lcdW_box.setValue(1.0f);}
    else if(lcdW_box.value() > 100)      {lcdW_box.setValue(100.0f);}
    if(lcdH_box.value() < 1)             {lcdH_box.setValue(1.0f);}
    else if(lcdH_box.value() > 100)      {lcdH_box.setValue(100.0f);}
    if(lpi_box.value() < 10)             {lpi_box.setValue(10.0f);}
    else if(lpi_box.value() > 40)        {lpi_box.setValue(40.0f);}
    if(black_box.value() < 50)           {black_box.setValue(50.0f);}
    else if(black_box.value() > 90)      {black_box.setValue(90.0f);}
    // Update image
    generateImg();
    return false;
  }
  
  public void toggleUiVisibility(boolean Show) {
    if(Show)  {gridTools.show();}
    else      {gridTools.hide();}
    toolsAreVisible = Show;
  } 
}
// No enums in Processing?
int NO_CALIB = 0;
int BL_CALIB = 1;
int WH_CALIB = 2;

class ImgWrap {
  PImage    img;
  PImage    imgCalibBlack;
  PImage    imgCalibWhite;
  int       tx,ty;
  float     zoom;
  
  ImgWrap(PImage Img) {
    img  = Img;
    tx   = 0;
    ty   = 0;
    zoom = 1.0f;
    
    int CALIB_BORDER = 25;
    
    img.loadPixels();
    imgCalibBlack = createImage(img.width,img.height, RGB);
    imgCalibWhite = createImage(img.width,img.height, RGB);
    for(int x = 0; x < img.width; x++) {
      for(int y = 0; y < img.height; y++) {
        int i = y*img.width + x;
        if(x <= CALIB_BORDER || x >= img.width - CALIB_BORDER || 
           y <= CALIB_BORDER || y >= img.height - CALIB_BORDER) {
          imgCalibBlack.pixels[i] = color(0,0,0);
          imgCalibWhite.pixels[i] = color(255,255,255);
        }
        else {
          imgCalibBlack.pixels[i] = img.pixels[i];
          imgCalibWhite.pixels[i] = img.pixels[i];
        }
      }
    }
    imgCalibBlack.updatePixels();
    imgCalibWhite.updatePixels();
  }
  
  public void draw(int Transparency, int drawMode) {
    pushMatrix();
    scale(zoom);
    translate(tx,ty); 
    if(Transparency < 255) {tint(255,Transparency);}
    if(drawMode == NO_CALIB)      {image(img,0,0);}
    else if(drawMode == BL_CALIB) {image(imgCalibBlack,0,0);}
    else if(drawMode == WH_CALIB) {image(imgCalibWhite,0,0);}
    popMatrix();
  }
}
class LayerMan {
  ArrayList layers;
  int       count;
  int       sx,sy;

  LayerMan(String[] names, int SX,int SY, ControlGroup cGroup) {
    count   = names.length;
    sx      = SX;
    sy      = SY;
    
    layers = new ArrayList();
    for(int i = 0; i < count; i++) {
      layers.add(new LayerSel(names[i],i, sx, sy+i*40, (i == count-1), cGroup));
    }
  }
  
  public boolean isCalibrationIndex(int index) {
    if(layers.size() > index) {
      LayerSel currLayer = (LayerSel)layers.get(index);
      return currLayer.isCalib;
    }
    return false;
  }

  public int[] getSelectedIndices() {
    int selInds = 0;
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      if(currLayer.isSel)
        selInds++;
    }
    int si = 0;
    int[] sinds = new int[selInds];
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      if(currLayer.isSel) {
        sinds[si++] = i;
      }
    }
    return sinds;
  }
  public int[] getVisibleIndices() {
    int visInds = 0;
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      if(currLayer.isVis)
        visInds++;
    }
    int vi = 0;
    int[] vinds = new int[visInds];
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      if(currLayer.isVis) {
        vinds[vi++] = i;
      }
    }
    return vinds;
  }

  public void handleLayer(String LName) {
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      currLayer.handleLayer(LName);
    }
  }

}
  
  
class LayerSel {
  Toggle             selectButton,visibleButton;
  boolean            isSel,isVis,isCalib;
  String             name;
  int                id;
  
  LayerSel(String Name, int Id, int X, int Y, boolean isLast, ControlGroup cGroup) {
    name          = Name;
    id            = Id;
    isSel         = false;
    isVis         = isLast;
    isCalib       = false;
    cP5.addToggle((name+"_select"),    isSel,  X,    Y,98,15).setGroup(cGroup);
    cP5.addToggle((id+"_visible"),     isVis,  X+100,Y,48,15).setGroup(cGroup);
    cP5.addToggle((id+"_calibrate"),   isCalib,X+150,Y,48,15).setGroup(cGroup);
  }
  
  public void handleLayer(String LName) {
    if(LName.equals(name+"_select")) {
      isSel=!isSel;
    }
    else if(LName.equals(id+"_visible")) {
      isVis=!isVis;
    }
    else if(LName.equals(id+"_calibrate")) {
      isCalib=!isCalib;
    }
  }
  
}
public class MixTool {
  ImgWrap[]      imgs;
  PImage         outputImg;

  ControlGroup   mixTools;
  Numberbox      masterW_box,masterH_box,scale_box,moveBy_box,lcdW_box,lpi_box;
  LayerMan       layerMan;
  
  boolean        isLoaded           = false;
  boolean        genMode            = false;
  boolean        toolsAreVisible    = true;
  boolean        calibrationIsBlack = true;
  
  int            MENU_HEIGHT        = 65;
  
  int            dispTransX         = 0;
  int            dispTransY         = MENU_HEIGHT;
  int            prevMouseX         = 0;
  int            prevMouseY         = 0;
  int            mouseDownY         = 0;
  
  // Default settings
  float          DISPLAY_SCALE      = 1.0f;
  int            SOURCE_WIDTH       = 500;
  int            SOURCE_HEIGHT      = 500;
  float          MOVE_BY            = 1.0f;
  float          LPI                = 10.0f;
  float          LCD_WIDTH          = 14.0f;
  
  public MixTool() {
    mixTools = cP5.addGroup("mixTools",120,0);
    mixTools.hideBar();
    cP5.addButton("generate",0,0,0,75,15).setGroup(mixTools);
    cP5.addButton("load",0,80,0,75,15).setGroup(mixTools);
    cP5.addButton("export",0,160,0,75,15).setGroup(mixTools);
    
    cP5.addButton("up",   0,700, 0,30,20).setGroup(mixTools);
    cP5.addButton("down", 0,700,22,30,20).setGroup(mixTools);
    cP5.addButton("left", 0,668,10,30,20).setGroup(mixTools);
    cP5.addButton("right",0,732,10,30,20).setGroup(mixTools);
    
    cP5.addButton("BLACK/WHITE CALIBRATION",0,780,10,112,20).setGroup(mixTools);
    
    masterW_box = cP5.addNumberbox("SOURCE_WIDTH",SOURCE_WIDTH,250,0,90,14);
    masterW_box.setGroup(mixTools);
    masterW_box.setMultiplier(1);
    
    masterH_box = cP5.addNumberbox("SOURCE_HEIGHT",SOURCE_HEIGHT,350,0,90,14);
    masterH_box.setGroup(mixTools);
    masterH_box.setMultiplier(1);
    
    scale_box = cP5.addNumberbox("DISPLAY_SCALE",DISPLAY_SCALE,450,0,90,14);
    scale_box.setGroup(mixTools);
    scale_box.setMultiplier(0.01f);
    
    moveBy_box =  cP5.addNumberbox("MOVE_BY",MOVE_BY,550,0,90,14);
    moveBy_box.setGroup(mixTools);
    moveBy_box.setMultiplier(0.01f);
    
    lpi_box = cP5.addNumberbox("LPI",LPI,250,35,90,14);
    lpi_box.setGroup(mixTools);
    lpi_box.setMultiplier(0.1f);
    
    lcdW_box = cP5.addNumberbox("LCD_WIDTH",LCD_WIDTH,350,35,90,14);
    lcdW_box.setGroup(mixTools);
    lcdW_box.setMultiplier(1);
    
    toggleUiVisibility(toolsAreVisible);
  }
  
  public void setup() {}
  
  public void draw() {
    if(isLoaded) {
      pushMatrix();
      translate(dispTransX,dispTransY);
      if(genMode) {
        pushMatrix();
        if(scale_box.value() != 1.0f)
            scale(scale_box.value()); 
        noTint();
        image(outputImg, 0, 0);
        popMatrix();
      }
      else {
        int CALIBRATION_BORDER = 50;
        
        // Draw visible layers
        int[] visibleIndices = layerMan.getVisibleIndices();
        int viCount = visibleIndices.length;
        
        for(int i = 0; i < viCount; i++) {
          pushMatrix();
          if(scale_box.value() != 1.0f)
            scale(scale_box.value()); 
          // Draw calibration boxes if necessary
          if(layerMan.isCalibrationIndex(visibleIndices[i])) {
             // Draw image
            imgs[visibleIndices[i]].draw(128,(calibrationIsBlack)?(BL_CALIB):(WH_CALIB));
          }
          else {
            // Draw image
            imgs[visibleIndices[i]].draw(128,NO_CALIB);
          }
          popMatrix();
        }
      }
      popMatrix();
    }
    // Draw tool background 
    if(toolsAreVisible) {
      fill(25,25,25,200);
      rect(0,0,width,MENU_HEIGHT);
    }
  }
  
  public boolean handleMouse(int Type) {
    if(Type == M_PRESS) {    
      prevMouseX = mouseX;
      prevMouseY = mouseY;
      mouseDownY = mouseY;
    }
    else if(Type == M_DRAG && isLoaded && mouseDownY > MENU_HEIGHT) { // Make sure we're not in the menu bar
      if(inDisplayBounds(mouseX,mouseY)) {
        dispTransX += (mouseX-prevMouseX);
        dispTransY += (mouseY-prevMouseY);
        prevMouseX  = mouseX;
        prevMouseY  = mouseY;
      }
    }
    return false;
  }
  
  public boolean handleEvent(ControlEvent theEvent) {
    // Handle events
    if(theEvent.name().equals("load")) {
      loadImageFiles();
      if(isLoaded && (masterW_box.value() > width || masterH_box.value() > height)) { 
        float wRatio = (float)masterW_box.value()/(float)width;
        float hRatio = (float)masterH_box.value()/(float)height;
        if(wRatio >= hRatio) {scale_box.setValue(2.0f-wRatio);}
        else                 {scale_box.setValue(2.0f-hRatio);}
      }
      genMode = false;
    }
    else if(theEvent.name().equals("generate")) {
      generateImage();
      genMode = true;
    }
    else if(theEvent.name().equals("export")) {
      exportFile();
    }
    else if(theEvent.name().equals("up")){
      int[] selIndices = layerMan.getSelectedIndices();
      int siCount = selIndices.length;
      for(int i = 0; i < siCount; i++) {
        imgs[selIndices[i]].ty -= moveBy_box.value();
      }
      genMode = false;
    }
    else if(theEvent.name().equals("down")){
      int[] selIndices = layerMan.getSelectedIndices();
      int siCount = selIndices.length;
      for(int i = 0; i < siCount; i++) {
        imgs[selIndices[i]].ty += moveBy_box.value();
      }
      genMode = false;
    }
    else if(theEvent.name().equals("left")){
      int[] selIndices = layerMan.getSelectedIndices();
      int siCount = selIndices.length;
      for(int i = 0; i < siCount; i++) {
        imgs[selIndices[i]].tx -= moveBy_box.value();
      }
      genMode = false;
    }
    else if(theEvent.name().equals("right")){
      int[] selIndices = layerMan.getSelectedIndices();
      int siCount = selIndices.length;
      for(int i = 0; i < siCount; i++) {
        imgs[selIndices[i]].tx += moveBy_box.value();
      }
      genMode = false;
    }
    else if(theEvent.name().equals("BLACK/WHITE CALIBRATION")){
      calibrationIsBlack = !calibrationIsBlack;
      genMode = false;
    }
    else if(theEvent.name().equals("LPI")){
      generateImage();
      genMode = true;
    }
    else {
      // Pass to layerMan
      if(isLoaded) {
        layerMan.handleLayer(theEvent.name());
      }
    }
    // Lock ranges
    if(masterW_box.value() < 1)          {masterW_box.setValue(1.0f);}
    else if(masterW_box.value() > 10000) {masterW_box.setValue(10000.0f);}
    if(masterH_box.value() < 1)          {masterH_box.setValue(1.0f);}
    else if(masterH_box.value() > 10000) {masterH_box.setValue(10000.0f);}
    if(scale_box.value() < 0.001f)        {scale_box.setValue(0.001f);}
    else if(scale_box.value() > 2.5f)     {scale_box.setValue(2.5f);}
    if(moveBy_box.value() < 0.01f)        {moveBy_box.setValue(0.01f);}
    else if(moveBy_box.value() > 100.0f)  {moveBy_box.setValue(100.0f);}
    if(lpi_box.value() < 1)              {lpi_box.setValue(1.0f);}
    else if(lpi_box.value() > 100)       {lpi_box.setValue(100.0f);}
    if(lcdW_box.value() < 1)             {lcdW_box.setValue(1.0f);}
    else if(lcdW_box.value() > 100)      {lcdW_box.setValue(100.0f);}
    return false;
  }
  
  public void handleKey(int K) {
    if     (K == 0) { //up
      dispTransY -= 1;
    } 
    else if(K == 1) { //down
      dispTransY += 1;
    } 
    else if(K == 2) { //left
      dispTransX -= 1;
    } 
    else if(K == 3) { //right
      dispTransX += 1;
    } 
    else if(K == 4) { //zoom+.0001
      scale_box.setValue(scale_box.value()+0.0001f);
    } 
    else if(K == 5) { //zoom-.0001
      scale_box.setValue(scale_box.value()-0.0001f);
    } 
    else if(K == 6) { //zoom-.00001
      scale_box.setValue(scale_box.value()-0.00001f);
    } 
    else if(K == 7) { //zoom+.00001
      scale_box.setValue(scale_box.value()+0.00001f);
    } 
  }
  
  public void toggleUiVisibility(boolean Show) {
    if(Show)  {mixTools.show();}
    else      {mixTools.hide();}
    toolsAreVisible = Show;
  }  
  
  public boolean loadImageFiles() {
    JFileChooser chooser = new JFileChooser();
    chooser.setMultiSelectionEnabled(true);
    chooser.setFileFilter(chooser.getAcceptAllFileFilter());
    int returnVal = chooser.showOpenDialog(null);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      File[] files = chooser.getSelectedFiles();
      int imgCount = files.length;
      imgs = new ImgWrap[imgCount];
      for(int fi = 0; fi < imgCount; fi++) {
        if(files[fi].getName().toLowerCase().endsWith(".jpg") || files[fi].getName().toLowerCase().endsWith(".png")) {
          imgs[fi] = new ImgWrap(loadImage(files[fi].getAbsolutePath()));
        }
      }
      
      // Check if images have same dimensions
      if(imgCount > 1) {
        masterW_box.setValue(imgs[0].img.width);
        masterH_box.setValue(imgs[0].img.height);
        isLoaded = true;
        for(int i = 1; i < imgCount; i++) {
          if(imgs[i].img.width != masterW_box.value() || imgs[i].img.height != masterH_box.value()) {
            isLoaded = false;
          }
        }
      }
  
      if(isLoaded) {
        String[] imgNames = new String[imgCount];
        for(int fi = 0; fi < imgCount; fi++) {
          imgNames[fi] = files[fi].getName().toLowerCase();
        }
        layerMan = new LayerMan(imgNames, width-400, 100, mixTools);
      }
    }
    
    return isLoaded;
  }
  
  public void generateImage() {   
    if(isLoaded) {
      // Load pixels
      int imgCount = imgs.length;
      if(imgCount > 0) {
        for (int i = 0; i < imgCount; i++) {
          imgs[i].img.loadPixels();
        }
        
        int   SUBSAMPLE_DEPTH = 16;
        
        int   outputW         = (int)masterW_box.value();
        int   outputH         = (int)masterH_box.value();
        float wRatio          = (float)outputW/(float)lcdW_box.value();
        float pixelsPerInch   = wRatio;
        float pixelsPerLine   = pixelsPerInch/(float)lpi_box.value();
        
        float linesPerScreen  = outputW/pixelsPerLine;
        
        println(linesPerScreen);
      
        float pixelsPerSrcImgPerLine = pixelsPerLine/imgCount;
        
        int nearestPpsipl = (int)round(pixelsPerSrcImgPerLine);
        if(nearestPpsipl < 1) {nearestPpsipl = 1;}
                
        
        int imgLongW = outputW*SUBSAMPLE_DEPTH; 
        outputImg = createImage(imgLongW,outputH,ARGB);
        
        int theMod = imgCount;
        if((int)pixelsPerLine < imgCount && pixelsPerLine > 0) {theMod = (int)pixelsPerLine;}
                
        for(int x = 0; x < outputW; x++) {
          int cx = x % theMod;//imgCount;
          
          for(int ss = 0; ss < SUBSAMPLE_DEPTH; ss++) {
            for(int y = 0; y < outputH; y++) {
              int transX = (int)((x-imgs[cx].tx)/imgs[cx].zoom);
              int transY = (int)((y-imgs[cx].ty)/imgs[cx].zoom);
              int outInd = y*imgLongW + x*SUBSAMPLE_DEPTH + ss;
              if(inBounds(transX,transY)) {      
                if(layerMan.isCalibrationIndex(cx)) {
                   if(calibrationIsBlack)
                     outputImg.pixels[outInd] = imgs[cx].imgCalibBlack.pixels[transY*outputW+transX];
                   else
                     outputImg.pixels[outInd] = imgs[cx].imgCalibWhite.pixels[transY*outputW+transX];
                }
                else {
                  outputImg.pixels[outInd] = imgs[cx].img.pixels[transY*outputW+transX];
                }
              }
              else {
                // Input pixel is out of bounds, output black
                outputImg.pixels[outInd] = color(0,0,0);
              }
            }
          }
          
        }
  
        outputImg.updatePixels();
        outputImg.resize(outputW,outputH);
      }
    }
  }
  
  public void exportFile() {
    if(!genMode) {
      generateImage();
      genMode = true;
    }
    if(isLoaded) {
      FileDialog fileDialog = new FileDialog(new Frame(), "Save", FileDialog.SAVE);
      fileDialog.setFilenameFilter(new FilenameFilter() {
          public boolean accept(File dir, String name) {
              return name.endsWith(".txt");
          }
      });
      fileDialog.setFile("Untitled");
      fileDialog.setVisible(true);
      String savePath = fileDialog.getDirectory() + fileDialog.getFile() + ".png";
      outputImg.save(savePath);
      println("Saving output image to " + savePath);
    }
  }
  
  public boolean inDisplayBounds(int X, int Y) {
    int imgCount = imgs.length;
    if(imgCount > 0 && isLoaded) {
      for(int i = 0; i < imgCount; i++) {
        if(X >= (imgs[i].tx+dispTransX) && X <= (imgs[i].tx+imgs[i].img.width*scale_box.value()+dispTransX) && 
           Y >= (imgs[i].ty+dispTransY) && Y <= (imgs[i].ty+imgs[i].img.height*scale_box.value()+dispTransY)) {
          return true;
        }
      }
    }
    return false;
  }
  
  public boolean inBounds(int X, int Y) {
    if(X >= 0 && X < (int)masterW_box.value() && Y >= 0 && Y < (int)masterH_box.value()) {return true;}
    return false;
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "BGTools" });
  }
}
