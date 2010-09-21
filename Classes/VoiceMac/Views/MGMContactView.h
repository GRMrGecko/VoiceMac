//
//  MGMContactView.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/20/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMThemeManager;

@interface MGMContactView : NSView {
	MGMThemeManager *themeManager;
	NSImageView *photoView;
	NSTextField *nameField;
	NSTextField *phoneField;
	NSMutableDictionary *contact;
}
+ (id)viewWithFrame:(NSRect)frameRect themeManager:(MGMThemeManager *)theThemeManager;
- (id)initWithFrame:(NSRect)frameRect themeManager:(MGMThemeManager *)theThemeManager;
- (NSDictionary *)contact;
- (void)setContact:(NSDictionary *)theContact;
@end