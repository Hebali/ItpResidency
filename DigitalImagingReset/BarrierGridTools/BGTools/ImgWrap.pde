class ImgWrap {
  PImage    img;
  int       tx,ty;
  float     zoom;
  
  ImgWrap(PImage Img) {
    img  = Img;
    tx   = 0;
    ty   = 0;
    zoom = 1.0;
  }
  
  void draw(int Transparency) {
    pushMatrix();
    scale(zoom);
    translate(tx,ty); 
    if(Transparency < 255) {tint(255,Transparency);}
    image(img,0,0);
    popMatrix();
  }
}
