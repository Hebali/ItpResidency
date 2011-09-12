/*    BigScreens for Cinder    */
/* ITP Residency Code Projects */
/*  Patrick Hebron, 2011-2012  */
/*    patrick.hebron@nyu.edu   */

#import "CBScreenApp.h"

@implementation CBScreenApp

- (id) init {
    [self setDelegate:[super init]];
	return self;
}


-(void) cleanUp {
    appCinder->shutdown();
    delete appCinder;
    
    int sCount = screens.size();
    for(int i = 0; i < sCount; i++) {
        [screens[i].sWindow release];
    }
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
    appCinder = new CBScreenWrap();
	
    vector<string> conf;
    // TODO: temp file path
    if(CBScreenFileIO::readFile("/Users/pjh/Desktop/Work/ItpResidency/BigScreens/BigScreensCinder/resources/Config.txt",&conf)) {
        // Iterate over file lines
        int clCount = conf.size();
        for(int i = 0; i < clCount; i++) {
            vector<string> confTok;
            CBScreenFileIO::tokenizeString(conf[i],'=',&confTok);
            int cltCount = confTok.size();
            if(cltCount > 0) {
                if(confTok[0].compare("SCREEN_DEF") == 0) {
                    vector<string> confTokPts;
                    CBScreenFileIO::tokenizeString(confTok[1],',',&confTokPts);
                    if(confTokPts.size() == 4) {
                        // Create screen
                        Screen aScreen;
                        
                        // Set rect
                        aScreen.sRect = NSMakeRect(atoi(confTokPts[0].c_str()),
                                                   atoi(confTokPts[1].c_str()),
                                                   atoi(confTokPts[2].c_str()),
                                                   atoi(confTokPts[3].c_str()));  
                        
                        // Set window
                        aScreen.sWindow = [[NSWindow alloc] initWithContentRect:aScreen.sRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreNonretained defer:NO];
                        [aScreen.sWindow setOpaque:YES];
                        [aScreen.sWindow setBackgroundColor:[NSColor clearColor]]; 
                        [aScreen.sWindow setIgnoresMouseEvents:FALSE];
                        [aScreen.sWindow setAcceptsMouseMovedEvents:YES];
                        [aScreen.sWindow makeKeyAndOrderFront:nil];
                        
                        aScreen.sView = [[CBScreenView alloc] initWithFrame:aScreen.sRect];
                        [aScreen.sView awakeFromNib];
                        
                        [aScreen.sView setCinderApp:appCinder];
                        
                        [aScreen.sWindow setContentView:aScreen.sView];
                        [aScreen.sWindow setInitialFirstResponder:aScreen.sView];
                        
                        [aScreen.sWindow setFrame:aScreen.sRect display:YES];   // Set window dimensions
                        
                        [aScreen.sWindow setLevel:NSScreenSaverWindowLevel]; // Force application to front
                        //[aScreen.sWindow setLevel:NSNormalWindowLevel];    // Don't force application to front
                        
                        //[NSCursor hide];                           // Hide cursor
                        //[NSCursor unhide];                         // Unhide cursor
                        
                        screens.push_back(aScreen);
                    }
                }
            }
        }
    }    
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
