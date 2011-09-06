/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#ifndef _CINDER_BIGSCREEN_VIEW_
#define _CINDER_BIGSCREEN_VIEW_

#include "CCGLView.h"
#include "CinderAppWrap.h"

@interface CinderBigScreenView : CCGLView {
    CinderAppWrap* appCinder;
}
@end

#endif