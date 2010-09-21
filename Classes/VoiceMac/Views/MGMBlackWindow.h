//
//  MGMBlackWindow.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/6/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@interface MGMBlackWindow : NSWindow {
	BOOL forceDisplay;
}
- (NSColor *)blackBackground;
@end