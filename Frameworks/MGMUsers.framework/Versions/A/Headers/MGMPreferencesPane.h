//
//  MGMPreferencesPane.h
//  MGMUsers
//
//  Created by Mr. Gecko on 7/27/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMPreferences;

@interface MGMPreferencesPane : NSObject {
    MGMPreferences *preferences;
@private
    NSTextField *textField;
}
+ (id)paneWithPreferences:(MGMPreferences *)thePreferences;
- (id)initWithPreferences:(MGMPreferences *)thePreferences;
+ (void)setUpToolbarItem:(NSToolbarItem *)theItem;
+ (NSString *)title;
- (NSView *)preferencesView;
- (void)preferencesDisplayed;
- (BOOL)isResizable;
- (NSSize)viewSize;
- (NSSize)maxSize;
- (NSSize)minSize;
- (BOOL)preferencesWindowShouldClose;
@end