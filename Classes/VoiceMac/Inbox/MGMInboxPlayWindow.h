//
//  MGMInboxPlayWindow.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/4/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMInstance, MGMURLConnectionManager, QTMovieView;

@interface MGMInboxPlayWindow : NSWindow <NSWindowDelegate> {
	MGMInstance *instance;
	MGMURLConnectionManager *connectionManager;
	IBOutlet NSView *view;
	IBOutlet QTMovieView *audioPlayer;
	IBOutlet NSTextField *transcriptionField;
	BOOL forceDisplay;
}
- (id)initWithNibNamed:(NSString *)theNib data:(NSDictionary *)theData instance:(MGMInstance *)theInstance;
- (NSColor *)whiteBackground;
@end