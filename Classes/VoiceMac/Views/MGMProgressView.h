//
//  MGMLoginProcessView.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/19/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@interface MGMProgressView : NSView {
	NSProgressIndicator *progress;
	NSTextField *pleaseWaitField;
	NSTextField *progressField;
}
- (void)startProgess;
- (void)stopProgess;
- (void)setProgressTitle:(NSString *)theTitle;
@end