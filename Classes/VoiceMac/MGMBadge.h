//
//  MGMBadge.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/8/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@interface MGMBadge : NSObject {
	NSString *label;
	BOOL visable;
	NSImage *applicationIcon;
}
- (void)drawIcon;

- (void)setLabel:(NSString *)badgeLabel;
- (NSString *)label;

- (void)setVisable:(BOOL)isVisable;
- (BOOL)visable;
@end