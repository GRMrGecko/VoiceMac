//
//  MGMNumberView.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/28/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@interface MGMNumberView : UIControl {
	NSString *number;
	NSString *alphabet;
	BOOL touching;
}
- (NSString *)number;
- (void)setNumber:(NSString *)theNumber;
- (NSString *)alphabet;
@end