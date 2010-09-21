//
//  MGMViewCell.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/20/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@protocol MGMViewCellProtocol
- (void)setFontColor:(NSColor *)theColor;
@end

@interface MGMViewCell : NSCell {
	NSView<MGMViewCellProtocol> *subview;
	BOOL gradient;
}
- (id)initGradientCell;

- (void)addSubview:(NSView *)theView;
- (NSView *)view;
@end