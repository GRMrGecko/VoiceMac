//
//  MGMInboxItem.h
//  VoiceMob
//
//  Created by James on 11/21/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@interface MGMBadgeView : UITableViewCell {
	NSString *badge;
	UILabel *nameField;
}
- (void)setName:(NSString *)theName;
- (void)setBadge:(NSString *)theBadge;
@end