//
//  MGMSMSView.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/27/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMSMSMessageView;

@interface MGMSMSView : NSView {
	MGMSMSMessageView *messageView;
	NSImageView *photoView;
	NSTextField *nameField;
	NSButton *closeButton;
	
	BOOL read;
}
+ (id)viewWithMessageView:(MGMSMSMessageView *)theMessageView;
- (id)initWithMessageView:(MGMSMSMessageView *)theMessageView;

- (void)setRead:(BOOL)isRead;
@end