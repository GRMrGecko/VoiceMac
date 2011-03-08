//
//  MGMAbout.h
//  MGMUsers
//
//  Created by Mr. Gecko on 1/29/11.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@interface MGMAbout : NSObject {
	IBOutlet NSWindow *window;
	IBOutlet NSImageView *iconView;
	IBOutlet NSTextField *applicationField;
	IBOutlet NSTextView *aboutView;
}
- (NSWindow *)window;
- (void)show;
@end