/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#import "CBScreenView.h"

@implementation CBScreenView

- (void)setCinderApp: (CBScreenWrap*)theApp {
    appCinder = theApp;
}
- (void)setPrimary: (bool)IsPrimary {
    isPrimary = IsPrimary;
}

- (void) setup {
	[super setup];
    if(isPrimary) {
        appCinder->setup();
    }
    [self reshape];
}

- (void) draw {
    if(isPrimary) {
        appCinder->update();
    }
    appCinder->draw();
    NSLog(@"framerate: %f \n",[self getElapsedFrames]/[self getElapsedSeconds]);
}

- (void)reshape {
	[super reshape];
    appCinder->resize(ResizeEvent(Vec2i([self getWindowWidth],[self getWindowHeight])));
}

- (void)keyDown:(NSEvent*)theEvent {
	[super keyDown:(NSEvent *)theEvent];
    //if(theEvent keyCode] == 53) // esc key
}

@end
