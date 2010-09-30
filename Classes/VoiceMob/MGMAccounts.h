//
//  MGMAccounts.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/27/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

@class MGMAccountController;

@interface MGMAccounts : NSObject {
	MGMAccountController *accountController;
	
	IBOutlet UITableView *tableView;
}
- (id)initWithAccountController:(MGMAccountController *)theAccountController;

- (UIView *)view;
- (void)releaseView;
@end