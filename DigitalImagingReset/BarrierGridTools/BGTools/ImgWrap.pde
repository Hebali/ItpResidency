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
    zoom = 1.0;
    
    int CALIB_BORDER = 50;
    
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
  
  void draw(int Transparency, int drawMode) {
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
