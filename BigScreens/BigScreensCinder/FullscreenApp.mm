/*  Cinder BigScreens   */
/* Patrick Hebron, 2011 */

#import "FullscreenApp.h"

@implementation FullscreenApp

- (id) init {
    [self setDelegate:[super init]];
	windowA	= NULL;
    windowB	= NULL;
	return self;
}


-(void) cleanUp {
    appCinder->shutdown();
    delete appCinder;
    
	if(windowA)	{[windowA release];}
    if(windowB)	{[windowB release];}
}

- (NSRect) getScreenRect {
    NSRect sRect = NSMakeRect(0.0,0.0,0.0,0.0);
	for(id screen in [NSScreen screens]) {
		NSRect curRect = [screen frame];
		sRect.size.width += curRect.size.width;
	}
	sRect.size.height = [[NSScreen mainScreen] frame].size.height;
    return sRect;
}

- (void) applicationDidFinishLaunching:(NSNotification*)aNotification {	
    // Set cinderRect dimensions (either from screens or manually)
    //cinderRect = [self getScreenRect];
    cinderRectA = NSMakeRect(0,0,200,200);  
    cinderRectB = NSMakeRect(250,0,200,200);  
    
	// create and set window
	windowA = [[NSWindow alloc] initWithContentRect:cinderRectA styleMask:NSBorderlessWindowMask backing:NSBackingStoreNonretained defer:NO];
	[windowA setOpaque:YES];
	[windowA setBackgroundColor:[NSColor clearColor]]; 
	[windowA setIgnoresMouseEvents:FALSE];
	[windowA setAcceptsMouseMovedEvents:YES];
	[windowA makeKeyAndOrderFront:nil];
    
    windowB = [[NSWindow alloc] initWithContentRect:cinderRectB styleMask:NSBorderlessWindowMask backing:NSBackingStoreNonretained defer:NO];
	[windowB setOpaque:YES];
	[windowB setBackgroundColor:[NSColor clearColor]]; 
	[windowB setIgnoresMouseEvents:FALSE];
	[windowB setAcceptsMouseMovedEvents:YES];
	[windowB makeKeyAndOrderFront:nil];
    
    cinderViewA = [[CinderBigScreenView alloc] initWithFrame:cinderRectA];
    [cinderViewA awakeFromNib];
    
    cinderViewB = [[CinderBigScreenView alloc] initWithFrame:cinderRectB];
    [cinderViewB awakeFromNib];
    
    appCinder = new CinderAppWrap();

    [cinderViewA setCinderApp:appCinder];
    [cinderViewB setCinderApp:appCinder];
    
	[windowA setContentView:cinderViewA];
	[windowA setInitialFirstResponder:cinderViewA];
    
    [windowB setContentView:cinderViewB];
	[windowB setInitialFirstResponder:cinderViewB];
	
	[windowA setFrame:cinderRectA display:YES];   // Set window dimensions
    [windowB setFrame:cinderRectB display:YES];   // Set window dimensions
    
	[windowA setLevel:NSScreenSaverWindowLevel]; // Force application to front
    //[windowA setLevel:NSNormalWindowLevel];    // Don't force application to front
    
    [windowB setLevel:NSScreenSaverWindowLevel]; // Force application to front
    //[windowB setLevel:NSNormalWindowLevel];    // Don't force application to front
    
	//[NSCursor hide];                           // Hide cursor
    //[NSCursor unhide];                         // Unhide cursor
}

- (void) mouseMoved:(NSEvent *)event {
	//NSPoint mouseLoc = [windowA convertScreenToBase:[NSEvent mouseLocation]];
    //NSPoint mouseLoc = [windowB convertScreenToBase:[NSEvent mouseLocation]];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
}

- (void) sendEvent:(NSEvent*)event {
	if([event type] == NSKeyDown) {
		int key = [event keyCode];
        if(key == 0x35) {
            [NSApp terminate:nil];
        }
    }
}

- (void) applicationWillTerminate:(NSNotification*)aNotification {
	[self cleanUp];
}

@end
