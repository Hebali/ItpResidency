/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#ifndef _CBSCREEN_VIEW_
#define _CBSCREEN_VIEW_

#include "CCGLView.h"
#include "CBScreenWrap.h"

@interface CBScreenView : CCGLView {
    CBScreenWrap* appCinder;
}
@end

#endif