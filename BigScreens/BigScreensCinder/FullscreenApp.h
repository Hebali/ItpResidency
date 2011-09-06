/*  Cinder BigScreens   */
/* Patrick Hebron, 2011 */

#ifndef _FULL_SCREEN_APP_
#define _FULL_SCREEN_APP_

#import <Cocoa/Cocoa.h>
#import "CinderBigScreenView.h"

@interface FullscreenApp : NSApplication {
	NSWindow*               windowA;
    NSWindow*               windowB;
    
    NSRect                  cinderRectA;
    NSRect                  cinderRectB;
    
    CinderBigScreenView*    cinderViewA;
    CinderBigScreenView*    cinderViewB;
    
    CinderAppWrap*          appCinder;
}

@end

#endif