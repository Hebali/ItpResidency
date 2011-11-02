class LayerSel {
  Toggle             selectButton,visibleButton;
  boolean            isSel,isVis,isCalib;
  String             name;
  
  LayerSel(String Name, int X, int Y, boolean isLast, ControlGroup cGroup) {
    name          = Name;
    isSel         = false;
    isVis         = isLast;
    isCalib       = isLast;
    cP5.addToggle((name+"_select"),    isSel,  X,    Y,48,15).setGroup(cGroup);
    cP5.addToggle((name+"_visible"),   isVis,  X+50, Y,48,15).setGroup(cGroup);
    cP5.addToggle((name+"_calibrate"), isCalib,X+100,Y,48,15).setGroup(cGroup);
  }
  
  void handleLayer(String LName) {
    if(LName.equals(name+"_select")) {
      isSel=!isSel;
    }
    else if(LName.equals(name+"_visible")) {
      isVis=!isVis;
    }
    else if(LName.equals(name+"_calibrate")) {
      isCalib=!isCalib;
    }
  }
  
}
