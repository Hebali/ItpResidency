/*  Cinder BigScreens   */
/* Patrick Hebron, 2011 */

#ifndef _CINDER_BIGSCREEN_VIEW_
#define _CINDER_BIGSCREEN_VIEW_

#include "CCGLView.h"
#include "CinderAppWrap.h"

@interface CinderBigScreenView : CCGLView {
    CinderAppWrap* appCinder;
}
@end

#endif