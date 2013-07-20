//
//  MGMController.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMThemeManager, MGMAccountController, MGMAccountSetup, MGMReverseLookup, MGMInstance, MGMVoiceMultiSMS;

#if MGMSIPENABLED
@class MGMSIPCallView;
#endif

@interface MGMController : UIViewController {
	IBOutlet UIWindow *mainWindow;
	
	BOOL inBackground;
	
	MGMThemeManager *themeManager;
	MGMAccountController *accountController;
}
- (BOOL)isInBackground;
- (MGMThemeManager *)themeManager;
- (MGMAccountController *)accountController;

- (void)showAccountSetup;
- (void)dismissAccountSetup:(MGMAccountSetup *)theAccountSetup;

- (void)showReverseLookupWithNumber:(NSString *)theNumber;
- (void)dismissReverseLookup:(MGMReverseLookup *)theReverseLookup;

- (void)showMultiSMSWithInstance:(MGMInstance *)theInstance;
- (void)dismissMultiSMS:(MGMVoiceMultiSMS *)theMultiSMS;

#if MGMSIPENABLED
- (void)showCallView:(MGMSIPCallView *)theCallView;
- (void)dismissCallView:(MGMSIPCallView *)theCallView;
#endif
@end