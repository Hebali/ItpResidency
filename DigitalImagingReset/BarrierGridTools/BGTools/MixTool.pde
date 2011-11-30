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
  float          DISPLAY_SCALE      = 1.0;
  int            SOURCE_WIDTH       = 500;
  int            SOURCE_HEIGHT      = 500;
  float          MOVE_BY            = 1.0;
  float          LPI                = 10.0;
  float          LCD_WIDTH          = 14.0;
  
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
    scale_box.setMultiplier(0.01);
    
    moveBy_box =  cP5.addNumberbox("MOVE_BY",MOVE_BY,550,0,90,14);
    moveBy_box.setGroup(mixTools);
    moveBy_box.setMultiplier(0.01);
    
    lpi_box = cP5.addNumberbox("LPI",LPI,250,35,90,14);
    lpi_box.setGroup(mixTools);
    lpi_box.setMultiplier(0.1);
    
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
        if(scale_box.value() != 1.0)
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
          if(scale_box.value() != 1.0)
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
        if(wRatio >= hRatio) {scale_box.setValue(2.0-wRatio);}
        else                 {scale_box.setValue(2.0-hRatio);}
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
    if(masterW_box.value() < 1)          {masterW_box.setValue(1.0);}
    else if(masterW_box.value() > 10000) {masterW_box.setValue(10000.0);}
    if(masterH_box.value() < 1)          {masterH_box.setValue(1.0);}
    else if(masterH_box.value() > 10000) {masterH_box.setValue(10000.0);}
    if(scale_box.value() < 0.001)        {scale_box.setValue(0.001);}
    else if(scale_box.value() > 2.5)     {scale_box.setValue(2.5);}
    if(moveBy_box.value() < 0.01)        {moveBy_box.setValue(0.01);}
    else if(moveBy_box.value() > 100.0)  {moveBy_box.setValue(100.0);}
    if(lpi_box.value() < 1)              {lpi_box.setValue(1.0);}
    else if(lpi_box.value() > 100)       {lpi_box.setValue(100.0);}
    if(lcdW_box.value() < 1)             {lcdW_box.setValue(1.0);}
    else if(lcdW_box.value() > 100)      {lcdW_box.setValue(100.0);}
    return false;
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
                
        for(int x = 0; x < outputW; x++) {
          int cx = x % imgCount;
          
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

