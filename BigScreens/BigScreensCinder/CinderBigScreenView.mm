/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#import "CinderBigScreenView.h"

@implementation CinderBigScreenView

- (void)setCinderApp: (CinderAppWrap*)theApp {
    appCinder = theApp;
    appCinder->setup();
}

- (void) setup {
	[super setup];
}

- (void) draw {
    appCinder->draw();
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
