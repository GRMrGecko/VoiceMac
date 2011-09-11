//
//  MGMPreferences.h
//  MGMUsers
//
//  Created by Mr. Gecko on 7/27/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMPreferencesPane;

@interface MGMPreferences : NSObject
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1060)
<NSWindowDelegate, NSToolbarDelegate>
#endif
{
@private
    NSWindow *preferencesWindow;
    NSMutableArray *preferencesPanes;
    MGMPreferencesPane *currentPane;
    int defaultPane;
    BOOL titleIsToolbar;
}
- (NSWindow *)preferencesWindow;

- (void)addPreferencesPaneClass:(Class)theClass;
- (void)removePreferencesPaneClass:(Class)theClass;
- (void)addPreferencesPaneClassName:(NSString *)theClass;
- (void)removePreferencesPaneClassName:(NSString *)theClass;
- (NSArray *)preferencesPanes;
- (void)setSelectedPaneIndex:(int)theIndex;
- (void)setupToolbar;

- (NSArray *)arrayForKey:(NSString *)theKey;
- (BOOL)boolForKey:(NSString *)theKey;
- (NSData *)dataForKey:(NSString *)theKey;
- (NSDictionary *)dictionaryForKey:(NSString *)theKey;
- (float)floatForKey:(NSString *)theKey;
- (int)integerForKey:(NSString *)theKey;
- (id)objectForKey:(NSString *)theKey;
- (NSArray *)stringArrayForKey:(NSString *)theKey;
- (NSString *)stringForKey:(NSString *)theKey;
- (double)doubleForKey:(NSString *)theKey;

- (void)setBool:(BOOL)theValue forKey:(NSString *)theKey;
- (void)setFloat:(float)theValue forKey:(NSString *)theKey;
- (void)setInteger:(int)theValue forKey:(NSString *)theKey;
- (void)setObject:(id)theValue forKey:(NSString *)theKey;
- (void)setDouble:(double)theValue forKey:(NSString *)theKey;

- (void)removeObjectForKey:(NSString *)theKey;

- (void)setupWindowForPane:(MGMPreferencesPane *)thePane animate:(BOOL)shouldAnimate;
- (void)showPreferences;
- (void)closePreferences;
@end

@interface NSWindow (MGMToolbar)
- (NSSize)toolbarSize;
@end