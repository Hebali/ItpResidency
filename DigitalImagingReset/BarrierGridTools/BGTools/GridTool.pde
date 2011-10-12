public class GridTool {
  PImage          outputImg;
  ControlGroup    gridTools;
   
  boolean         isVertical        = false;
  boolean         toolsAreVisible   = false;

  public float    MASTER_WIDTH      = 1024.0;
  public float    MASTER_HEIGHT     = 768.0;
  
  public float    LCD_WIDTH         = 14.0;
  public float    LCD_HEIGHT        =  8.0;
  
  public float    LPI               = 10.0;
  
  public float    PERCENT_BLACK     = 60.0;
  
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
    
    lcdW_box = cP5.addNumberbox("LCD_WIDTH",LCD_WIDTH,300,0,90,14);
    lcdW_box.setGroup(gridTools);
    lcdW_box.setMultiplier(1);
    
    lcdH_box = cP5.addNumberbox("LCD_HEIGHT",LCD_HEIGHT,400,0,90,14);
    lcdH_box.setGroup(gridTools);
    lcdH_box.setMultiplier(1);
        
    lpi_box = cP5.addNumberbox("LPI",LPI,500,0,90,14);
    lpi_box.setGroup(gridTools);
    lpi_box.setMultiplier(0.1);
    
    black_box = cP5.addNumberbox("PERCENT_BLACK",PERCENT_BLACK,600,0,90,14);
    black_box.setGroup(gridTools);
    black_box.setMultiplier(5.0);
    
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
      lpi_box.setValue(max(lpi_box.value()-0.1,10.0));
      generateImg();
    }
    else if(key == '.') {
      lpi_box.setValue(min(lpi_box.value()+0.1,40.0));
      generateImg();
    }
  }
  
  public boolean handleMouse() {
    return false;
  }
  
  public void generateImg() {    
    float wRatio = (float)masterW_box.value()/lcdW_box.value();
    float hRatio = (float)masterH_box.value()/lcdH_box.value();
    float pixelsPerInch = ((wRatio>hRatio)?(wRatio):(hRatio));
    float lineWidth     = pixelsPerInch/lpi_box.value();
    
    int blackLines = (int)(lineWidth*(black_box.value()/100.0));
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
    // Clear background
    background(255);
    // Draw grid
    pushMatrix();
    if(isVertical) {
      translate(masterH_box.value(),0);
      rotate(PI/2);
    }
    image(outputImg,0,0);
    popMatrix();
    // Draw tool background 
    if(toolsAreVisible) {
      fill(25,25,25,200);
      rect(0,0,width,50);
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
    if(masterW_box.value() < 1)          {masterW_box.setValue(1.0);}
    else if(masterW_box.value() > 10000) {masterW_box.setValue(10000.0);}
    if(masterH_box.value() < 1)          {masterH_box.setValue(1.0);}
    else if(masterH_box.value() > 10000) {masterH_box.setValue(10000.0);}
    if(lcdW_box.value() < 1)             {lcdW_box.setValue(1.0);}
    else if(lcdW_box.value() > 100)      {lcdW_box.setValue(100.0);}
    if(lcdH_box.value() < 1)             {lcdH_box.setValue(1.0);}
    else if(lcdH_box.value() > 100)      {lcdH_box.setValue(100.0);}
    if(lpi_box.value() < 10)             {lpi_box.setValue(10.0);}
    else if(lpi_box.value() > 40)        {lpi_box.setValue(40.0);}
    if(black_box.value() < 50)           {black_box.setValue(50.0);}
    else if(black_box.value() > 90)      {black_box.setValue(90.0);}
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
