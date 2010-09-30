//
//  MGMVoicePad.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMVoiceUser, MGMNumberView;

@interface MGMVoicePad : NSObject {
	MGMVoiceUser *voiceUser;
	
	IBOutlet UIView *view;
	
	NSString *numberString;
	IBOutlet MGMNumberView *numberView;
}
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser;
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser;

- (MGMVoiceUser *)voiceUser;

- (UIView *)view;
- (void)releaseView;

- (IBAction)dial:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)call:(id)sender;
@end