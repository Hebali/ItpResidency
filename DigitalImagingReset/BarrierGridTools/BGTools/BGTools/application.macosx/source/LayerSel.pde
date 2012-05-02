class LayerSel {
  Toggle             selectButton,visibleButton;
  boolean            isSel,isVis,isCalib;
  String             name;
  int                id;
  
  LayerSel(String Name, int Id, int X, int Y, boolean isLast, ControlGroup cGroup) {
    name          = Name;
    id            = Id;
    isSel         = false;
    isVis         = isLast;
    isCalib       = false;
    cP5.addToggle((name+"_select"),    isSel,  X,    Y,98,15).setGroup(cGroup);
    cP5.addToggle((id+"_visible"),     isVis,  X+100,Y,48,15).setGroup(cGroup);
    cP5.addToggle((id+"_calibrate"),   isCalib,X+150,Y,48,15).setGroup(cGroup);
  }
  
  void handleLayer(String LName) {
    if(LName.equals(name+"_select")) {
      isSel=!isSel;
    }
    else if(LName.equals(id+"_visible")) {
      isVis=!isVis;
    }
    else if(LName.equals(id+"_calibrate")) {
      isCalib=!isCalib;
    }
  }
  
}
