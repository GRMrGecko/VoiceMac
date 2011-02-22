//
//  MGMBadge.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/8/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMBadge.h"

@implementation MGMBadge
- (id)init {
	if ((self = [super init])) {
		applicationIcon = [[[NSApplication sharedApplication] applicationIconImage] copy];
		visable = NO;
	}
	return self;
}
- (void)dealloc {
	[label release];
	[applicationIcon release];
	[super dealloc];
}

- (void)drawIcon {
	NSImage *left = [NSImage imageNamed:@"badgel"];
	NSImage *middle = [NSImage imageNamed:@"badgem"];
	NSImage *right = [NSImage imageNamed:@"badger"];
	NSSize leftSize = [left size];
	NSSize middleSize = [middle size];
	NSSize rightSize = [right size];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:30], NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, nil];
	NSSize textSize = [label sizeWithAttributes:attributes];
	NSImage *icon = [[applicationIcon copy] autorelease];
	NSSize iconSize = [icon size];
	if (visable) {
		NSSize imageSize = NSMakeSize(((textSize.width+leftSize.width+rightSize.width)>=iconSize.width ? iconSize.width : textSize.width+leftSize.width+rightSize.width), middleSize.height);
		NSImage *badge = [[[NSImage alloc] initWithSize:imageSize] autorelease];
		[badge lockFocus];
		[left drawInRect:NSMakeRect(0, 0, leftSize.width, leftSize.height) fromRect:NSMakeRect(0, 0, leftSize.width, leftSize.height) operation:NSCompositeSourceOver fraction:1.0];
		for (int y=leftSize.width; y<(imageSize.width-rightSize.width); y++) {
			[middle drawInRect:NSMakeRect(y, 0, middleSize.width, middleSize.height) fromRect:NSMakeRect(0, 0, middleSize.width, middleSize.height) operation:NSCompositeSourceOver fraction:1.0];
		}
		[right drawInRect:NSMakeRect(imageSize.width-rightSize.width, 0, rightSize.width, rightSize.height) fromRect:NSMakeRect(0, 0, rightSize.width, rightSize.height) operation:NSCompositeSourceOver fraction:1.0];
		
		[label drawInRect:NSMakeRect(leftSize.width, ((imageSize.height+2)-textSize.height)/2, textSize.width, textSize.height) withAttributes:attributes];
		[badge unlockFocus];
		[icon lockFocus];
		[badge drawInRect:NSMakeRect(iconSize.width-imageSize.width, iconSize.height-imageSize.height, imageSize.width, imageSize.height) fromRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) operation:NSCompositeSourceOver fraction:1.0];
		[icon unlockFocus];
	}
	[[NSApplication sharedApplication] setApplicationIconImage:icon];
}

- (void)setLabel:(NSString *)badgeLabel {
	[label release];
	label = [badgeLabel copy];
	if (label==nil || [label isEqual:@""])
		[self setVisable:NO];
	else
		[self setVisable:YES];
}
- (NSString *)label {
	return label;
}

- (void)setVisable:(BOOL)isVisable {
	visable = isVisable;
	[self drawIcon];
}
- (BOOL)visable {
	return visable;
}
@end