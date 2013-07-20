//
//  MGMContactsController.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMAccountController, MGMContacts;

@interface MGMContactsController : NSObject <UITableViewDelegate, UITableViewDataSource> {
	MGMAccountController *accountController;
	
	IBOutlet UISearchBar *searchBar;
	IBOutlet UIButton *searchCancelButton;
	IBOutlet UITableView *contactsTable;
	
	NSLock *filterLock;
	NSString *contactsMatchString;
	int filterWaiting;
	NSMutableArray *contactViews;
	int contactsCount;
	NSRange contactsLoading;
	NSRange contactsVisible;
}
- (id)initWithAccountController:(MGMAccountController *)theAccountController;

- (void)awakeFromNib;
- (void)releaseView;
- (void)cleanup;

- (MGMContacts *)contacts;
- (NSString *)filterString;
- (void)updateMatchString;

- (IBAction)cancelSearch:(id)sender;

- (void)checkContactRow:(int)row;

- (void)filterContacts;
- (void)backgroundFilter;
- (void)loadContacts:(BOOL)updatingCount;

- (void)updatedContacts;

- (void)selectedContact:(NSDictionary *)theContact;
@end