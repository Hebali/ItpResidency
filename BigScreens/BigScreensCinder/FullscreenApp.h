/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#ifndef _FULL_SCREEN_APP_
#define _FULL_SCREEN_APP_

#import <Cocoa/Cocoa.h>

#import "CinderBigScreenView.h"
#import "FileIO.h"

struct Screen {
    NSWindow*               sWindow;
    NSRect                  sRect;
    CinderBigScreenView*    sView;
};

@interface FullscreenApp : NSApplication {
    CinderAppWrap*  appCinder;
    vector<Screen>  screens;
}

@end

#endif