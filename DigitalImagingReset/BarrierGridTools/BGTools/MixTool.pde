public class MixTool {
  ImgWrap[]      imgs;
  PImage         outputImg;

  ControlGroup   mixTools;
  Numberbox      masterW_box,masterH_box,scale_box,moveBy_box;
  LayerMan       layerMan;
  
  boolean        isLoaded           = false;
  boolean        genMode            = false;
  boolean        toolsAreVisible    = true;
  boolean        calibrationIsBlack = true;
  
  int            dispTransX         = 0;
  int            dispTransY         = 0;
  int            prevMouseX         = 0;
  int            prevMouseY         = 0;
  
  // Default settings
  float          DISPLAY_SCALE      = 1.0;
  int            SOURCE_WIDTH       = 500;
  int            SOURCE_HEIGHT      = 500;
  float          MOVE_BY            = 1.0;
  
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
      rect(0,0,width,42);
    }
  }
  
  public boolean handleMouse(int Type) {
    if(Type == M_PRESS) {
      prevMouseX = mouseX;
      prevMouseY = mouseY;
    }
    else if(Type == M_DRAG) {
      dispTransX += (mouseX-prevMouseX);
      dispTransY += (mouseY-prevMouseY);
      prevMouseX = mouseX;
      prevMouseY = mouseY;
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
        layerMan = new LayerMan(imgs.length, width-300, 100, mixTools);
      }
    }
    
    return isLoaded;
  }
  
  public void generateImage() {   
    if(isLoaded) {
      // Load pixels
      int imgCount = imgs.length;
      for (int i = 0; i < imgCount; i++) {
        imgs[i].img.loadPixels();
      }
      
      //float wRatio = (float)masterW_box.value()/lcdW_box.value();
      float wRatio = 640/12.0;
      //float hRatio = (float)masterH_box.value()/lcdH_box.value();
      float hRatio = 480/10.0;
      float pixelsPerInch = wRatio;
      //float lineWidth     = pixelsPerInch/lpi_box.value();
      float lineWidth = pixelsPerInch/16.0;
      
      int SUBSAMPLE_DEPTH = (int)(lineWidth/(float)imgCount);

      
      // Each line should represent each src image. So if a line is 10px wide and we have 10 src images, 
// each src would have 1 pixel along the horizontal of a line

      int outputW = (int)masterW_box.value();
      int outputH = (int)masterH_box.value();
      outputImg = createImage(outputW*SUBSAMPLE_DEPTH,outputH,ARGB);
      
      for(int x = 0; x < outputW; x++) {
        int currImgSrcInd = x % imgCount;
        
        for(int y = 0; y < outputH; y++) {
        }
      }
      
      
      
      for(int x = 0; x < outputW; x++) {
          int s = x % imgCount;
          
          for(int y = 0; y < outputH; y++) {
            int transX = (int)((x-imgs[s].tx)/imgs[s].zoom);
            int transY = (int)((y-imgs[s].ty)/imgs[s].zoom);
            int inInd  = transY*outputW+transX;
            if(inBounds(transX,transY)) { 
              for(int subs = 0; subs < subsampPixelsPerSrcLine; subs++) {
                int outInd = y*SUBSAMPLE_DEPTH*outputW + x * subs;
                if(layerMan.isCalibrationIndex(s)) {
                   if(calibrationIsBlack)
                     outputImg.pixels[outInd] = imgs[s].imgCalibBlack.pixels[inInd];
                   else
                     outputImg.pixels[outInd] = imgs[s].imgCalibWhite.pixels[inInd];
                }
                else {
                  outputImg.pixels[outInd] = imgs[s].img.pixels[inInd];
                }
              } 
            }
//            else {
//              // Input pixel is out of bounds, output black
//              outputImg.pixels[outInd] = color(0,0,0);
//            }
          }
      }
      outputImg.updatePixels();
      //outputImg.resize(outputW,outputH);
      
      
//      
//      // Interlace images
//      outputImg = createImage((int)masterW_box.value(),(int)masterH_box.value(), RGB);
//      for (int x = 0; x < (int)masterW_box.value(); x++) {
//        int s = x % imgCount;
//        for (int y = 0; y < (int)masterH_box.value(); y++) {
//          int transX = (int)((x-imgs[s].tx)/imgs[s].zoom);
//          int transY = (int)((y-imgs[s].ty)/imgs[s].zoom);
//          int outInd = y*(int)masterW_box.value() + x;
//          if(inBounds(transX,transY)) {      
//            if(layerMan.isCalibrationIndex(s)) {
//               if(calibrationIsBlack)
//                 outputImg.pixels[outInd] = imgs[s].imgCalibBlack.pixels[transY*(int)masterW_box.value()+transX];
//               else
//                 outputImg.pixels[outInd] = imgs[s].imgCalibWhite.pixels[transY*(int)masterW_box.value()+transX];
//            }
//            else {
//              outputImg.pixels[outInd] = imgs[s].img.pixels[transY*(int)masterW_box.value()+transX];
//            }
//          }
//          else {
//            // Input pixel is out of bounds, output black
//            outputImg.pixels[outInd] = color(0,0,0);
//          }
//        }
//      }
//      // Update pixels
//      outputImg.updatePixels();
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
  
  public boolean inBounds(int X, int Y) {
    if(X >= 0 && X < (int)masterW_box.value() && Y >= 0 && Y < (int)masterH_box.value()) {return true;}
    return false;
  }
}

