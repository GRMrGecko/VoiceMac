//
//  MGMContactView.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>

@class MGMThemeManager;

@interface MGMContactView : UITableViewCell {
	MGMThemeManager *themeManager;
	UIImageView *photoView;
	UILabel *nameField;
	UILabel *phoneField;
	NSDictionary *contact;
}
- (void)setThemeManager:(MGMThemeManager *)theThemeManager;
- (void)setContact:(NSDictionary *)theContact;
@end