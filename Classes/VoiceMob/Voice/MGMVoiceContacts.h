//
//  MGMVoiceContacts.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>
#import "MGMContactsController.h"

@class MGMVoiceUser;

@interface MGMVoiceContacts : MGMContactsController <UIActionSheetDelegate> {
	MGMVoiceUser *voiceUser;
	
	IBOutlet UIView *view;
	NSDictionary *selectedContact;
}
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser;
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser;

- (MGMVoiceUser *)voiceUser;

- (UIView *)view;
- (void)releaseView;
@end