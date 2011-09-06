class ImageMan {
  
  int       MAX_DISPLAY_WIDTH  = 1024;
  int       MAX_DISPLAY_HEIGHT =  768;
  
  ImgWrap[] imgs;
  PImage    outputImg;
  boolean   isLoaded;
  boolean   genMode;
  float     oversizeScale;
  int       imgCount;
  int       masterWidth;
  int       masterHeight;
  int       border;

  PFont     font;

  ButtonMan buttonMan;
  Button[]  controlButtons;

  ImageMan(int Border) {
    // Load settings
    border = Border;
    isLoaded = false;
    genMode  = false;
    font     = createFont("Georgia", 12);
    // Load default master dimensions and display scaling
    masterWidth   = 500;
    masterHeight  = 500;
    oversizeScale = 1.0;
  }

  void setup() {
    loadImageFiles();
    if(isLoaded && (masterWidth > MAX_DISPLAY_WIDTH || masterHeight > MAX_DISPLAY_HEIGHT)) { 
      float wRatio = masterWidth/(float)MAX_DISPLAY_WIDTH;
      float hRatio = masterHeight/(float)MAX_DISPLAY_HEIGHT;
      if(wRatio >= hRatio) {oversizeScale = 2.0-wRatio;}
      else                 {oversizeScale = 2.0-hRatio;}
      size((int)(masterWidth*oversizeScale)+border,(int)(masterHeight*oversizeScale));
      println("Note: The display has been scaled to your screen. However, the output image will use the original unscaled dimensions.");
    }
    else {
      size(masterWidth+border,masterHeight);
    }
    
    // Create buttons
    if(isLoaded) {
        int scaledWidth = (int)(masterWidth*oversizeScale);
        buttonMan = new ButtonMan(imgCount, scaledWidth+border, 180, font);
        controlButtons = new Button[9];
        controlButtons[0] = new Button(scaledWidth+30, 10, 20, 20, font, "-");
        controlButtons[1] = new Button(scaledWidth+50, 10, 20, 20, font, "+");
        controlButtons[2] = new Button(scaledWidth+30, 55, 20, 20, font, "L");
        controlButtons[3] = new Button(scaledWidth+50, 55, 20, 20, font, "R");
        controlButtons[4] = new Button(scaledWidth+40, 75, 20, 20, font, "D");
        controlButtons[5] = new Button(scaledWidth+40, 35, 20, 20, font, "U");
        controlButtons[6] = new Button(scaledWidth+10, 100, 80, 20, font, "GENERATE");
        controlButtons[7] = new Button(scaledWidth+10, 125, 80, 20, font, "RESET");
        controlButtons[8] = new Button(scaledWidth+10, 150, 80, 20, font, "SAVE");
    }
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
        int[] orderedIndices = buttonMan.getIndexOrder();
        for(int i = 0; i < orderedIndices.length; i++) {
          pushMatrix();
          if(oversizeScale != 1.0)
            scale(oversizeScale);
          imgs[orderedIndices[i]].draw(128);
          popMatrix();
        }
      }

      noStroke();
      fill(32);
      rect(masterWidth*oversizeScale,0,border,masterHeight);
      buttonMan.draw();
      for (int i = 0; i < controlButtons.length; i++) {
        controlButtons[i].draw();
      }
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
  
  boolean inBounds(int X, int Y) {
    if(X >= 0 && X < masterWidth && Y >= 0 && Y < masterHeight)
      return true;
    return false;
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
  
  void resetTransforms() {
    for (int i = 0; i < imgCount; i++) {
      imgs[i].tx = 0;
      imgs[i].ty = 0;
      imgs[i].zoom = 1.0;
    }
  }

  boolean handleMouse() {
    boolean handled = false;
    
    for(int i = 0; i < controlButtons.length; i++) {
      if(controlButtons[i].isOver()) {
        // Handle generate image button
        if(i == 6) {
          generateImage();
          genMode = true;
          println("Generating interlaced image...");
        }
        // Handle transform reset
        else if(i == 7) {
          resetTransforms();
          genMode = false;
          println("Resetting transforms...");
        }
        // Handle image saving
        else if(i == 8) {
          if(!genMode) {
            generateImage();
            genMode = true;
          }
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
        // Handle image-specific buttons
        else {
          // Iterate over selected indices
          int[] selectedIndices = buttonMan.getSelectedIndices();
          for(int j = 0; j < selectedIndices.length; j++) {
            if(i == 0) {
              imgs[selectedIndices[j]].zoom -= 0.01;
            }
            else if(i == 1) {
              genMode = false;
              imgs[selectedIndices[j]].zoom += 0.01;
            }
            else if(i == 2) {
              genMode = false;
              imgs[selectedIndices[j]].tx -= 1;
            }
            else if(i == 3) {
              genMode = false;
              imgs[selectedIndices[j]].tx += 1;
            }
            else if(i == 4) {
              genMode = false;
              imgs[selectedIndices[j]].ty += 1;
            }
            else if(i == 5) {
              genMode = false;
              imgs[selectedIndices[j]].ty -= 1;
            }
          }
        }
        
        handled = true;
        break;
      }
    }

    if (!handled) {
      if (buttonMan.handleMouse())
        handled = true;
    }
    return handled;
  }
}

