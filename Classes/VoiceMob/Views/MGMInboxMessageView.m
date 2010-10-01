//
//  MGMInboxMessageView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/30/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMInboxMessageView.h"
#import <VoiceBase.h>

@implementation MGMInboxMessageView
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		nameField = [[UILabel alloc] initWithFrame:CGRectZero];
		[nameField setBackgroundColor:[UIColor clearColor]];
		[nameField setFont:[UIFont boldSystemFontOfSize:18.0]];
		[[self contentView] addSubview:nameField];
		dateField = [[UILabel alloc] initWithFrame:CGRectZero];
		[dateField setBackgroundColor:[UIColor clearColor]];
		[dateField setFont:[UIFont systemFontOfSize:12.0]];
		[dateField setTextAlignment:UITextAlignmentRight];
		[dateField setTextColor:[UIColor blueColor]];
		[[self contentView] addSubview:dateField];
		messageField = [[UILabel alloc] initWithFrame:CGRectZero];
		[messageField setBackgroundColor:[UIColor clearColor]];
		[messageField setFont:[UIFont systemFontOfSize:12.0]];
		[messageField setLineBreakMode:UILineBreakModeWordWrap];
		[messageField setNumberOfLines:0];
		[messageField setTextColor:[UIColor grayColor]];
		[[self contentView] addSubview:messageField];
	}
	return self;
}
- (void)dealloc {
	if (nameField!=nil)
		[nameField release];
	if (dateField!=nil)
		[dateField release];
	if (messageField!=nil)
		[messageField release];
	[super dealloc];
}

- (void)setInstance:(MGMInstance *)theInstance {
	instance = theInstance;
}
- (void)setMessageData:(NSDictionary *)theMessageData {
	if (messageData!=nil) [messageData release];
	messageData = [theMessageData retain];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
    CGRect frameRect = [[self contentView] bounds];
	
	if (messageField!=nil) {
		[nameField setText:[[instance contacts] nameForNumber:[messageData objectForKey:MGMIPhoneNumber]]];
		int type = [[messageData objectForKey:MGMIType] intValue];
		if (type==MGMIVoicemailType) {
			[messageField setText:[messageData objectForKey:MGMIText]];
		} else if (type==MGMISMSIn || type==MGMISMSOut) {
			[messageField setText:[[[[messageData objectForKey:MGMIMessages] lastObject] objectForKey:MGMIText] flattenHTML]];
		} else {
			[messageField setText:[[[messageData objectForKey:MGMIPhoneNumber] areaCode] areaCodeLocation]];
		}
		NSDate *today = [NSDate dateWithTimeIntervalSinceNow:-86400];
		if ([[messageData objectForKey:MGMITime] earlierDate:today]==today) {
			NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
			[formatter setDateFormat:@"h:mm a"];
			[dateField setText:[formatter stringFromDate:[messageData objectForKey:MGMITime]]];
		} else {
			NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
			[formatter setDateFormat:@"M/d/yy"];
			[dateField setText:[formatter stringFromDate:[messageData objectForKey:MGMITime]]];
		}
	}
	
	[nameField setFrame:CGRectMake(8, 3, frameRect.size.width-74, 20)];
	[dateField setFrame:CGRectMake(frameRect.size.width-64, 3, 60, 20)];
	[messageField setFrame:CGRectMake(8, frameRect.size.height-35, frameRect.size.width-12, 32)];
}
@end