class ButtonMan {
  ArrayList buttons;
  int       count;
  PFont     font;

  ButtonMan(int Count,int WinWidth,int StartY, PFont Font) {
    count = Count;
    font  = Font;
    
    buttons = new ArrayList();
    for(int i = 0; i < count; i++) {
      buttons.add(new ButtonGroup(WinWidth,StartY,font,i));
    }
  }
  
  void draw() {
    for(int i = 0; i < count; i++) {
      ButtonGroup currButton = (ButtonGroup)buttons.get(i);
      currButton.draw();
    }
  }
  
  boolean handleMouse() {
    for(int i = 0; i < count; i++) {
      ButtonGroup currButton = (ButtonGroup)buttons.get(i);
      int bMsg = currButton.handleMouse();
      if(bMsg == 1) {
        if(i > 0) {
          ButtonGroup prevButton = (ButtonGroup)buttons.get(i-1);
          swapButtonGroups(currButton,prevButton);
        }
      }
      else if(bMsg == 2) {
        if(i+1 < count) {
          ButtonGroup nextButton = (ButtonGroup)buttons.get(i+1);
          swapButtonGroups(currButton,nextButton);
        }
      }
    }
    return false;
  }
  
  void swapButtonGroups(ButtonGroup GA, ButtonGroup GB) {
    // Swap index
    int tIndex = GA.index;
    GA.index = GB.index;
    GB.index = tIndex;
    // Swap isVis
    boolean tIsVis = GA.isVis;
    GA.isVis = GB.isVis;
    GB.isVis = tIsVis;
    // Swap visi pressed
    boolean tVP = GA.visi.pressed;
    GA.visi.pressed = GB.visi.pressed;
    GB.visi.pressed = tVP;
    // Swap primary pressed
    boolean tPP = GA.primary.pressed;
    GA.primary.pressed = GB.primary.pressed;
    GB.primary.pressed = tPP;
    // Swap txt
    String tTxt = GA.primary.txt;
    GA.primary.txt = GB.primary.txt;
    GB.primary.txt = tTxt;
  }
  
  int[] getSelectedIndices() {
    int selInds = 0;
    for(int i = 0; i < count; i++) {
      ButtonGroup currButton = (ButtonGroup)buttons.get(i);
      if(currButton.primary.pressed)
        selInds++;
    }
    int[] sinds = new int[selInds];
    int si = 0;
    for(int i = 0; i < count; i++) {
      ButtonGroup currButton = (ButtonGroup)buttons.get(i);
      if(currButton.primary.pressed) {
        sinds[si] = currButton.index;
        si++;
      }
    }
    return sinds;
  }
  
  int[] getIndexOrder() {
    int visInds = 0;
    for(int i = 0; i < count; i++) {
      ButtonGroup currButton = (ButtonGroup)buttons.get(i);
      if(currButton.isVis)
        visInds++;
    }
    int[] iorder = new int[visInds];
    int vi = 0;
    for(int i = 0; i < count; i++) {
      ButtonGroup currButton = (ButtonGroup)buttons.get(i);
      if(currButton.isVis) {
        iorder[vi] = currButton.index;
        vi++;
      }
    }
    return iorder;
  }
  
}
  
  
