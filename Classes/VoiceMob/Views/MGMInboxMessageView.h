//
//  MGMInboxMessageView.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/30/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMInstance;

@interface MGMInboxMessageView : UITableViewCell {
	MGMInstance *instance;
	
	UILabel *nameField;
	UILabel *dateField;
	UILabel *messageField;
	NSDictionary *messageData;
}
- (void)setInstance:(MGMInstance *)theInstance;
- (void)setMessageData:(NSDictionary *)theMessageData;
@end