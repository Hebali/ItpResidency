/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#ifndef _CBSCREEN_WRAP_
#define _CBSCREEN_WRAP_

#include "CCGLView.h"

class CBScreenWrap {
public:
    CBScreenWrap();
        
    void setup();
    void update();
    void draw();
    void shutdown();
    
    void resize(ResizeEvent event);
        
    bool isRunning;   
    
    CameraPersp			mCam;
	Matrix44f			mCubeRotation;
};

#endif