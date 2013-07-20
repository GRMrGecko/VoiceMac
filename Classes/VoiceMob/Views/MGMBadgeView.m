//
//  MGMInboxItem.m
//  VoiceMob
//
//  Created by James on 11/21/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMBadgeView.h"
#import <MGMUsers/MGMUsers.h>

@implementation MGMBadgeView
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		nameField = [[UILabel alloc] initWithFrame:CGRectZero];
		[nameField setBackgroundColor:[UIColor clearColor]];
		[nameField setFont:[UIFont boldSystemFontOfSize:20.0]];
		[[self contentView] addSubview:nameField];
	}
	return self;
}
- (void)dealloc {
	[badge release];
	[nameField release];
	[super dealloc];
}
- (void)setName:(NSString *)theName {
	[nameField setText:theName];
}
- (void)setBadge:(NSString *)theBadge {
	[badge release];
	badge = [theBadge copy];
	[self setNeedsDisplay];
}
- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect frameRect = [[self contentView] bounds];
	if (badge!=nil && ![badge isEqual:@""]) {
		UIFont *badgeFont = [UIFont systemFontOfSize:18];
		CGSize badgeSize = [badge sizeWithFont:badgeFont];
		[nameField setFrame:CGRectMake(5, (frameRect.size.height/2)-12, (frameRect.size.width-badgeSize.width)-20, 24)];
	} else {
		[nameField setFrame:CGRectMake(5, (frameRect.size.height/2)-12, frameRect.size.width-10, 24)];
	}
}

- (void)drawRect:(CGRect)rect {
	if (badge!=nil && ![badge isEqual:@""]) {
		CGRect frameRect = [[self contentView] bounds];
		UIFont *badgeFont = [UIFont systemFontOfSize:18];
		CGSize badgeSize = [badge sizeWithFont:badgeFont];
		CGRect borderRect = CGRectMake((frameRect.size.width-(badgeSize.width+13))-5, (frameRect.size.height/2)-(badgeSize.height/2), badgeSize.width+13, badgeSize.height);
		MGMPath *path = [MGMPath pathWithRoundedRect:borderRect cornerRadius:borderRect.size.height/2];
		[[UIColor colorWithRed:0.5019 green:0.5843 blue:0.7412 alpha:1.0] setFill];
		[path fill];
		[[UIColor whiteColor] setFill];
		[badge drawInRect:CGRectMake(borderRect.origin.x+((borderRect.size.width-badgeSize.width)/2), borderRect.origin.y-((borderRect.size.height-badgeSize.height)/2), badgeSize.width, badgeSize.height) withFont:badgeFont];
	}
	[super drawRect:rect];
}
@end