//
//  MGMAccounts.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/27/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMAccountController;

@interface MGMAccounts : NSObject {
	MGMAccountController *accountController;
	
	IBOutlet UITableView *tableView;
}
- (id)initWithAccountController:(MGMAccountController *)theAccountController;

- (UIView *)view;
- (void)releaseView;
@end