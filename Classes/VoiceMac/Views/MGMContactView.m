//
//  MGMContactView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/20/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMContactView.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMContactView
+ (id)viewWithFrame:(NSRect)frameRect themeManager:(MGMThemeManager *)theThemeManager {
	return [[[self alloc] initWithFrame:frameRect themeManager:theThemeManager] autorelease];
}
- (id)initWithFrame:(NSRect)frameRect themeManager:(MGMThemeManager *)theThemeManager {
	themeManager = theThemeManager;
	if (self = [super initWithFrame:frameRect]) {
		photoView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.height, frameRect.size.height)];
		[photoView setRefusesFirstResponder:YES];
		[self addSubview:photoView];
		nameField = [[NSTextField alloc] initWithFrame:NSMakeRect(frameRect.size.height+8, frameRect.size.height-27, frameRect.size.width-(frameRect.size.height+12), 18)];
		[nameField setEditable:NO];
		[nameField setSelectable:NO];
		[nameField setBezeled:NO];
		[nameField setBordered:NO];
		[nameField setDrawsBackground:NO];
		[nameField setFont:[NSFont boldSystemFontOfSize:14]];
		[self addSubview:nameField];
		phoneField = [[NSTextField alloc] initWithFrame:NSMakeRect(frameRect.size.height+8, 10, frameRect.size.width-(frameRect.size.height+12), 17)];
		[phoneField setEditable:NO];
		[phoneField setSelectable:NO];
		[phoneField setBezeled:NO];
		[phoneField setBordered:NO];
		[phoneField setDrawsBackground:NO];
		[phoneField setFont:[NSFont systemFontOfSize:13]];
		[self addSubview:phoneField];
	}
	return self;
}
- (void)dealloc {
	if (photoView!=nil)
		[photoView release];
	if (nameField!=nil)
		[nameField release];
	if (phoneField!=nil)
		[phoneField release];
	if (contact!=nil)
		[contact release];
	[super dealloc];
}
- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize {
	[super resizeSubviewsWithOldSize:oldBoundsSize];
	NSRect frameRect = [self frame];
	[photoView setFrame:NSMakeRect(0, 0, frameRect.size.height, frameRect.size.height)];
	[nameField setFrame:NSMakeRect(frameRect.size.height+8, frameRect.size.height-27, frameRect.size.width-(frameRect.size.height+12), 18)];
	[phoneField setFrame:NSMakeRect(frameRect.size.height+8, 10, frameRect.size.width-(frameRect.size.height+12), 17)];
}

- (NSDictionary *)contact {
	return contact;
}
- (void)setContact:(NSDictionary *)theContact {
	if (contact!=nil) [contact release];
	contact = [theContact mutableCopy];
	if ([contact objectForKey:MGMCPhoto]==nil || [[contact objectForKey:MGMCPhoto] isKindOfClass:[NSNull class]])
		[photoView setImage:[[[NSImage alloc] initWithContentsOfFile:[themeManager incomingIconPath]] autorelease]];
	else
		[photoView setImage:[[[NSImage alloc] initWithData:[contact objectForKey:MGMCPhoto]] autorelease]];
	if ([[contact objectForKey:MGMCName] isEqual:@""])
		[nameField setStringValue:[contact objectForKey:MGMCCompany]];
	else
		[nameField setStringValue:[contact objectForKey:MGMCName]];
	if ([[contact objectForKey:MGMCLabel] isEqual:@""])
		[phoneField setStringValue:[[contact objectForKey:MGMCNumber] readableNumber]];
	else
		[phoneField setStringValue:[NSString stringWithFormat:@"%@ %@", [[contact objectForKey:MGMCNumber] readableNumber], [contact objectForKey:MGMCLabel]]];
}

- (void)setFontColor:(NSColor *)theColor {
	[nameField setTextColor:theColor];
	[phoneField setTextColor:theColor];
}
@end