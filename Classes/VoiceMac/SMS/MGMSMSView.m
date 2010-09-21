//
//  MGMSMSView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/27/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSMSView.h"
#import "MGMSMSMessageView.h"
#import "MGMVoiceUser.h"
#import "MGMController.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMSMSView
+ (id)viewWithMessageView:(MGMSMSMessageView *)theMessageView {
	return [[[self alloc] initWithMessageView:theMessageView] autorelease];
}
- (id)initWithMessageView:(MGMSMSMessageView *)theMessageView {
	if (self = [super initWithFrame:NSMakeRect(0, 0, 100, 40)]) {
		messageView = theMessageView;
		[self setToolTip:[[messageView messageInfo] objectForKey:MGMTInName]];
		NSRect frameRect = [self frame];
		photoView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.height, frameRect.size.height)];
		[photoView setRefusesFirstResponder:YES];
		[self addSubview:photoView];
		NSData *photoData = [[[messageView instance] contacts] photoDataForNumber:[[messageView messageInfo] objectForKey:MGMIPhoneNumber]];
		if (photoData==nil) {
			[photoView setImage:[[[NSImage alloc] initWithContentsOfFile:[[[(MGMVoiceUser *)[[messageView instance] delegate] controller] themeManager] incomingIconPath]] autorelease]];
		} else {
			[photoView setImage:[[[NSImage alloc] initWithData:photoData] autorelease]];
		}
		read = NO;
		int size = 12;
		nameField = [[NSTextField alloc] initWithFrame:NSMakeRect(frameRect.size.height+4, (frameRect.size.height/2)-4, frameRect.size.width-(frameRect.size.height+20), size)];
		[nameField setEditable:NO];
		[nameField setSelectable:NO];
		[nameField setBezeled:NO];
		[nameField setBordered:NO];
		[nameField setDrawsBackground:NO];
		[nameField setFont:[NSFont boldSystemFontOfSize:10]];
		[[nameField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
		[self addSubview:nameField];
		[nameField setStringValue:[[messageView messageInfo] objectForKey:MGMTInName]];
		
		closeButton = [[NSButton alloc] initWithFrame:NSMakeRect(frameRect.size.width-14, (frameRect.size.height/2)-6, 14, 14)];
		[closeButton setButtonType:NSMomentaryChangeButton];
		[closeButton setBezelStyle:NSRegularSquareBezelStyle];
		[closeButton setBordered:NO];
		[closeButton setImagePosition:NSImageOnly];
		[closeButton setImage:[NSImage imageNamed:@"Close"]];
		[closeButton setAlternateImage:[NSImage imageNamed:@"ClosePressed"]];
		[closeButton setTarget:messageView];
		[closeButton setAction:@selector(close:)];
		[self addSubview:closeButton];
	}
	return self;
}
- (void)dealloc {
	if (photoView!=nil)
		[photoView release];
	if (nameField!=nil)
		[nameField release];
	if (closeButton!=nil)
		[closeButton release];
	[super dealloc];
}

- (void)setRead:(BOOL)isRead {
	read = isRead;
	[nameField setFont:[NSFont boldSystemFontOfSize:(isRead ? 10 : 12)]];
	[self resizeSubviewsWithOldSize:[self frame].size];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
	[super resizeSubviewsWithOldSize:oldBoundsSize];
	NSRect frameRect = [self frame];
	[photoView setFrame:NSMakeRect(0, 0, frameRect.size.height, frameRect.size.height)];
	int size = 0;
	if (read)
		size = 12;
	else
		size = 14;
	[nameField setFrame:NSMakeRect(frameRect.size.height+4, (frameRect.size.height/2)-4, frameRect.size.width-(frameRect.size.height+20), size)];
	[closeButton setFrame:NSMakeRect(frameRect.size.width-14, (frameRect.size.height/2)-6, 14, 14)];
}
- (void)setFontColor:(NSColor *)theColor {
	[nameField setTextColor:theColor];
}
@end