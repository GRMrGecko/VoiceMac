//
//  MGMSIPContacts.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#if MGMSIPENABLED
#import <UIKit/UIKit.h>
#import "MGMContactsController.h"

@class MGMSIPUser;

@interface MGMSIPContacts : MGMContactsController {
	MGMSIPUser *SIPUser;
	
	IBOutlet UIView *view;
}
+ (id)tabWithSIPUser:(MGMSIPUser *)theSIPUser;
- (id)initWithSIPUser:(MGMSIPUser *)theSIPUser;

- (MGMSIPUser *)SIPUser;

- (UIView *)view;
- (void)releaseView;
@end
#endif