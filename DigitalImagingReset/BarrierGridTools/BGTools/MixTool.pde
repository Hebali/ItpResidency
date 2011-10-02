class MixTool {
  
  ImgWrap[] imgs;
  PImage    outputImg;
  boolean   isLoaded;
  boolean   genMode;
  float     oversizeScale;
  int       imgCount;
  int       masterWidth;
  int       masterHeight;

  PFont     font;
  
  ControlGroup mixTools;
  Textfield widthField,heightField;
  Slider scaleSlider;
  MixTool() {
    isLoaded = false;
    genMode  = false;
    font     = createFont("Georgia", 12);
    // Load default master dimensions and display scaling
    masterWidth   = 500;
    masterHeight  = 500;
    oversizeScale = 1.0;
    
    mixTools = cP5.addGroup("mixTools",120,0);
    mixTools.hideBar();
    cP5.addButton("generate",0,0,0,75,15).setGroup(mixTools);
    cP5.addButton("load",0,80,0,75,15).setGroup(mixTools);
    cP5.addButton("export",0,160,0,75,15).setGroup(mixTools);

    widthField  = cP5.addTextfield("width", 250,0,50,20);
    widthField.setGroup(mixTools);
    widthField.setText("0");
    heightField = cP5.addTextfield("height",310,0,50,20);
    heightField.setGroup(mixTools);
    heightField.setText("0");
    
    scaleSlider = cP5.addSlider("resize",0.0,2.0,1.0,370,0,100,10);
    scaleSlider.setGroup(mixTools);
  }
  void setup() {
  }
  void draw() {
    if(isLoaded) {
      if(genMode) {
        pushMatrix();
        if(oversizeScale != 1.0)
            scale(oversizeScale); 
        noTint();
        image(outputImg, 0, 0);
        popMatrix();
      }
      else {
        // Draw using layer-ordering indices...
        int imgCount = imgs.length;
        for(int i = 0; i < imgCount; i++) {
          pushMatrix();
          if(oversizeScale != 1.0)
            scale(oversizeScale);
          imgs[i].draw(128);
          popMatrix();
        }
      }
    }
  }
  boolean handleMouse() {
    return false;
  }
  
  boolean handleEvent(ControlEvent theEvent) {
    //println(theEvent.name());
    if(theEvent.name().equals("load")) {
      loadImageFiles();
      if(isLoaded && (masterWidth > width || masterHeight > height)) { 
        float wRatio = (float)masterWidth/(float)width;
        float hRatio = (float)masterHeight/(float)height;
        if(wRatio >= hRatio) {oversizeScale = 2.0-wRatio;}
        else                 {oversizeScale = 2.0-hRatio;}
        cP5.controller("resize").setValue(oversizeScale);
        // TODO: THE RESIZE HERE IS NOT WORKING PROPERLY
      }
      genMode = false;
    }
    else if(theEvent.name().equals("generate")) {
      generateImage();
      genMode = true;
    }
    else if(theEvent.name().equals("resize")){
      oversizeScale = theEvent.controller().value();
      if(oversizeScale <= 0.0) {oversizeScale = 0.01;}
    }
    return false;
  }
  
  void toggleUiVisibility(boolean Show) {
    if(Show) {
      mixTools.show();
    }
    else {
      mixTools.hide();
    }
  }  
  
  boolean loadImageFiles() {
    String loadPath = selectFolder();
    if (loadPath == null) {
      println("No folder was selected.");
    } 
    else {
      // Load files
      println("Reading .jpg and .png files from " + loadPath);
      java.io.File folder = new java.io.File(loadPath);
      java.io.FilenameFilter imgFilter = new java.io.FilenameFilter() {
        public boolean accept(File dir, String name) {
          return (name.toLowerCase().endsWith(".jpg") || name.toLowerCase().endsWith(".png"));
        }
      };
      // Get loaded files
      String[] filenames = folder.list(imgFilter);
      // Prepare images
      imgCount = filenames.length;
      imgs = new ImgWrap[imgCount];
      // Load images
      for (int i = 0; i < imgCount; i++) {
        imgs[i] = new ImgWrap(loadImage(loadPath+"/"+filenames[i]));
      }
      // Check if images have same dimensions
      if (imgCount > 1) {
        masterWidth  = imgs[0].img.width;
        masterHeight = imgs[0].img.height;
        widthField.setText(Integer.toString(masterWidth));
        heightField.setText(Integer.toString(masterHeight));
        isLoaded = true;
        for (int i = 1; i < imgCount; i++) {
          if (imgs[i].img.width != masterWidth || imgs[i].img.height != masterHeight) {
            isLoaded = false;
          }
        }
      }      
    }
    return isLoaded;
  }
  
  void generateImage() {
    // Load pixels
    for (int i = 0; i < imgCount; i++) {
      imgs[i].img.loadPixels();
    }
    // Interlace images
    outputImg = createImage(masterWidth, masterHeight, RGB);
    for (int x = 0; x < masterWidth; x++) {
      int s = x % imgCount;
      for (int y = 0; y < masterHeight; y++) {
        int transX = (int)((x-imgs[s].tx)/imgs[s].zoom);
        int transY = (int)((y-imgs[s].ty)/imgs[s].zoom);
        if(inBounds(transX,transY)) {
          // Copy input pixel to output
          outputImg.pixels[y*masterWidth + x] = imgs[s].img.pixels[transY*masterWidth+transX];
        }
        else {
          // Input pixel is out of bounds, output black
          outputImg.pixels[y*masterWidth + x] = color(0,0,0);
        }
      }
    }
    // Update pixels
    outputImg.updatePixels();
  }
  
  boolean inBounds(int X, int Y) {
    if(X >= 0 && X < masterWidth && Y >= 0 && Y < masterHeight)
      return true;
    return false;
  }
}

