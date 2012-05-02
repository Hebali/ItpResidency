class LayerMan {
  ArrayList layers;
  int       count;
  int       sx,sy;

  LayerMan(String[] names, int SX,int SY, ControlGroup cGroup) {
    count   = names.length;
    sx      = SX;
    sy      = SY;
    
    layers = new ArrayList();
    for(int i = 0; i < count; i++) {
      layers.add(new LayerSel(names[i],i, sx, sy+i*40, (i == count-1), cGroup));
    }
  }
  
  boolean isCalibrationIndex(int index) {
    if(layers.size() > index) {
      LayerSel currLayer = (LayerSel)layers.get(index);
      return currLayer.isCalib;
    }
    return false;
  }

  int[] getSelectedIndices() {
    int selInds = 0;
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      if(currLayer.isSel)
        selInds++;
    }
    int si = 0;
    int[] sinds = new int[selInds];
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      if(currLayer.isSel) {
        sinds[si++] = i;
      }
    }
    return sinds;
  }
  int[] getVisibleIndices() {
    int visInds = 0;
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      if(currLayer.isVis)
        visInds++;
    }
    int vi = 0;
    int[] vinds = new int[visInds];
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      if(currLayer.isVis) {
        vinds[vi++] = i;
      }
    }
    return vinds;
  }

  void handleLayer(String LName) {
    for(int i = 0; i < count; i++) {
      LayerSel currLayer = (LayerSel)layers.get(i);
      currLayer.handleLayer(LName);
    }
  }

}
  
  
