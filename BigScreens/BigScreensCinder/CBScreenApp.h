/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#ifndef _CBSCREEN_APP_
#define _CBSCREEN_APP_

#import <Cocoa/Cocoa.h>

#import "CBScreenView.h"
#import "CBScreenFileIO.h"

struct Screen {
    NSWindow*       sWindow;
    NSRect          sRect;
    CBScreenView*   sView;
};

@interface CBScreenApp : NSApplication {
    CBScreenWrap*   appCinder;
    vector<Screen>  screens;
}

@end

#endif