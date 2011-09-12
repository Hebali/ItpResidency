/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#ifndef _CINDER_BIGSCREEN_APP_
#define _CINDER_BIGSCREEN_APP_

#include "CCGLView.h"

class CinderAppWrap {
public:
    CinderAppWrap();
        
    void setup();
    void update();
    void draw();
    void shutdown();
    
    void resize(ResizeEvent event);
        
    bool isRunning;   
};

#endif