//
//  MGMVoiceInbox.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/30/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMVoiceUser, MGMProgressView, MGMInstance;

@interface MGMVoiceInbox : NSObject {
	MGMVoiceUser *voiceUser;
	
	IBOutlet UITableView *inboxesTable;
	IBOutlet UITableView *messagesTable;
	MGMProgressView *progressView;
	int currentView;
	
	NSArray *messagesItems;
	
	int progressStartCount;
	
	int currentInbox;
	int maxResults;
	unsigned int start;
	int resultsCount;
	
	float rightMax;
	float leftMax;
	NSMutableArray *currentData;
	NSDate *lastDate;
}
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser;
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser;

- (MGMVoiceUser *)voiceUser;

- (UIView *)view;
- (void)releaseView;

- (void)startProgress;
- (void)stopProgress;

- (void)loadInbox;
- (void)addData:(NSArray *)theData;
- (int)currentInbox;
@end