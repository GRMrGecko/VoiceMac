//
//  MGMSIPHistory.h
//  VoiceMob
//
//  Created by Mr. Gecko on 10/14/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMSIPUser, MGMLiteConnection;

@interface MGMSIPInbox : NSObject {
	MGMSIPUser *SIPUser;
	MGMLiteConnection *inboxConnection;
	
	NSDate *lastUpdate;
	
	int currentView;
	NSArray *inboxItems;
	
	IBOutlet UITableView *inboxesTable;
	IBOutlet UITableView *inboxTable;
	
	int currentInbox;
	int maxResults;
	unsigned int start;
	int resultsCount;
	
	NSMutableArray *currentData;
}
+ (id)tabWithSIPUser:(MGMSIPUser *)theSIPUser;
- (id)initWithSIPUser:(MGMSIPUser *)theSIPUser;

- (void)registerSettings;

- (MGMSIPUser *)SIPUser;

- (UIView *)view;
- (void)releaseView;

- (void)addPhoneNumber:(NSString *)thePhoneNumber type:(int)theType;

- (NSArray *)dataForType:(int)theType start:(unsigned int)theStart;

- (void)loadInbox;

- (void)addData:(NSArray *)theData;
- (int)currentInbox;
@end