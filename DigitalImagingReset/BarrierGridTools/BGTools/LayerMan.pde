class LayerMan {
  ArrayList layers;
  int       count;
  int       sx,sy;

  LayerMan(int Count,int SX,int SY, ControlGroup cGroup) {
    count   = Count;
    sx      = SX;
    sy      = SY;
    
    layers = new ArrayList();
    for(int i = 0; i < count; i++) {
      layers.add(new LayerSel(Integer.toString(i), sx, sy+i*40, (i == count-1), cGroup));
    }
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
  
  
