//
//  MGMContactView.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMThemeManager, MGMContacts;

@interface MGMContactView : UITableViewCell {
	MGMThemeManager *themeManager;
	MGMContacts *contacts;
	UIImageView *photoView;
	UILabel *nameField;
	UILabel *phoneField;
	NSDictionary *contact;
	NSString *number;
	
	NSLock *photoLock;
	int photoWaiting;
}
- (void)setThemeManager:(MGMThemeManager *)theThemeManager;
- (void)setContacts:(MGMContacts *)theContacts;
- (void)setContact:(NSDictionary *)theContact;

- (void)getPhotoForNumber:(NSString *)theNumber;
@end