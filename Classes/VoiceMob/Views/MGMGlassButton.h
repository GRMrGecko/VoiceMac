//
//  MGMGlassButton.h
//  VoiceMob
//
//  Created by Mr. Gecko on 10/1/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@interface MGMGlassButton : UIButton {
	UIColor *buttonColor;
	UIColor *buttonTouchColor;
	UIColor *buttonDisabledColor;
	BOOL touching;
}

@end