/*  Cinder BigScreens   */
/* Patrick Hebron, 2011 */

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
    
	if([theEvent keyCode] == 53 && [self isInFullScreenMode] == YES) // 53 = ESC key
        [self exitFullScreenModeWithOptions:nil];
}

@end
