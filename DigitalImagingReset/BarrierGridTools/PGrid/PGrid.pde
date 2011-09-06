///////////////////////////////////////
// BARRIER GRID TOOLS FOR PROCESSING //
//        GRID GENERATOR v001        //
//                 BY                //
//  ERIC ROSENTHAL & PATRICK HEBRON  //
///////////////////////////////////////

PImage    outputImg;

int       masterWidth  = 1920;
int       masterHeight = 1080;

float     lcdWidth     = 14.0;
float     lcdHeight    =  8.0;

float     lpi          = 10.0;

int       blackPercen  = 60;

int       loadStartTime,loadEndTime;

void setup() {
  generateImg();
  size(masterWidth,masterHeight);
}

void keyPressed() {
  if(key == '-') {
    blackPercen -= 5;
    max(blackPercen,50);
    generateImg();
  }
  else if(key == '+') {
    blackPercen += 5;
    min(blackPercen,90);
    generateImg();
  }
  else if(key == ',') {
    lpi -= 0.1;
    max(lpi,10.0);
    generateImg();
  }
  else if(key == '.') {
    lpi += 0.1;
    min(lpi,40.0);
    generateImg();
  }
}

void generateImg() {
  loadStartTime = millis();
  
  float pixelsPerInch = (float)masterWidth/lcdWidth;
  float lineWidth     = pixelsPerInch/lpi;
  
  int blackLines = (int)(lineWidth*(blackPercen/100.0));
  int clearLines = (int)lineWidth-blackLines;
  
  println("Width: " + lineWidth);
  println("Black: " + blackLines);
  println("Clear: " + clearLines);
    
  outputImg = createImage(masterWidth,masterHeight, ARGB);
  for(int x = 0; x < masterWidth; x++) {
      for(int y = 0; y < masterHeight; y++) {
        int s = x % (int)lineWidth;
        if(s < clearLines)
          outputImg.pixels[y*masterWidth + x] = color(0,0,0,0);
        else
          outputImg.pixels[y*masterWidth + x] = color(0,0,0,255);
      }
  }
  outputImg.updatePixels();
  
  loadEndTime = millis();
  println("Loaded in " + ((loadEndTime-loadStartTime)/1000.0) + " seconds");
  
}

void draw() {
  background(255);
  pushMatrix();
  image(outputImg,0,0);
  popMatrix();
}
