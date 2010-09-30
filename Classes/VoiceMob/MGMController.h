//
//  MGMController.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/24/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMThemeManager, MGMAccountController, MGMAccountSetup;

@interface MGMController : UIViewController {
	IBOutlet UIWindow *mainWindow;
	
	MGMThemeManager *themeManager;
	MGMAccountController *accountController;
}
- (MGMThemeManager *)themeManager;

- (void)showAccountSetup;
- (void)dismissAccountSetup:(MGMAccountSetup *)theAccountSetup;
@end