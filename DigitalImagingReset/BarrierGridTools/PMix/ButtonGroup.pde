class ButtonGroup {
  PFont     font;
  int       index;
  boolean   isVis;
  Button    primary,visi; //aux1,aux2;
  
  ButtonGroup(int WinWidth,int StartY, PFont Font, int Index) {
    font    = Font;
    index   = Index;
    isVis   = true;
    primary = new Button(WinWidth-88,StartY+index*30,40,30,font,str(index));
    visi    = new Button(WinWidth-48,StartY+index*30,35,30,font,"V");
    //aux1    = new Button(WinWidth-28,StartY+index*30,15,15,font,"U");
    //aux2    = new Button(WinWidth-28,StartY+index*30+15,15,15,font,"D");
    primary.pressed = false;
    visi.pressed = true;
  }
  
  void draw() {
    primary.draw();
    visi.draw();
    //aux1.draw();
    //aux2.draw();
  }
  
  int handleMouse() {
    if(primary.isOver()) {
      primary.pressed = !primary.pressed;
      return 0;
    }
    else if(visi.isOver()) {
      visi.pressed = !visi.pressed;
      isVis = visi.pressed;
      return 3;
    }
    /*
    else if(aux1.isOver()) {
      return 1;
    }
    else if(aux2.isOver()) {
      return 2;
    }
    */
    else {
     // primary.pressed = false;
    }
    return -1;
  }

}
