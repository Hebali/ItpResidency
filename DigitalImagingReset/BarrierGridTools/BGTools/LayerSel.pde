class LayerSel {
  Toggle             selectButton,visibleButton;
  boolean            isSel,isVis;
  String             name;
  
  LayerSel(String Name, int X, int Y, ControlGroup cGroup) {
    name          = Name;
    isSel         = false;
    isVis         = true;
    cP5.addToggle((name+"_selection"), isSel,X,   Y,80,15).setGroup(cGroup);
    cP5.addToggle((name+"_visibility"),isVis,X+82,Y,18,15).setGroup(cGroup);
  }
  
  void handleLayer(String LName) {
    if(LName.equals(name+"_selection")) {
      isSel=!isSel;
    }
    else if(LName.equals(name+"_visibility")) {
      isVis=!isVis;
    }
  }
  
}
