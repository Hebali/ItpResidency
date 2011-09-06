class Button {
  int     x,y,w,h;
  boolean pressed;
  color   bse,ovr,sel;
  String  txt;
  PFont   font;
   
  Button(int X, int Y, int W, int H, PFont Font, String Txt) {
    x       = X;
    y       = Y;
    w       = W;
    h       = H;
    font    = Font;
    txt     = Txt;
    bse     = color(128);
    ovr     = color(96);
    sel     = color(64);
    pressed = false;
  }
  
  void draw() {
    stroke(255);
    if(pressed)
      fill(sel);
    else if(isOver())
      fill(ovr);
    else
      fill(bse);
    rect(x,y,w,h);
    textFont(font);
    fill(255);
    textAlign(CENTER,CENTER);
    text(txt,x,y,w,h);
  }
  
  boolean isOver() {
    if(mouseX>=x && mouseX<=x+w && mouseY>=y && mouseY<=y+h) {
      return true;
    }
    return false;
  }

}
