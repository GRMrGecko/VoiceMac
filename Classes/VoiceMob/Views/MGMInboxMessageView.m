//
//  MGMInboxMessageView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/30/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMInboxMessageView.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>

@implementation MGMInboxMessageView
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
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
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[nameField release];
	[dateField release];
	[messageField release];
	[messageData release];
	[super dealloc];
}

- (void)setInstance:(MGMInstance *)theInstance {
	instance = theInstance;
}
- (void)setMessageData:(NSDictionary *)theMessageData {
	[messageData release];
	messageData = [theMessageData retain];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
    CGRect frameRect = [[self contentView] bounds];
	
	if (messageData!=nil) {
		[nameField setText:[[instance contacts] nameForNumber:[messageData objectForKey:MGMIPhoneNumber]]];
		int type = [[messageData objectForKey:MGMIType] intValue];
		if (type==MGMIVoicemailType)
			[messageField setText:[messageData objectForKey:MGMIText]];
		else if (type==MGMISMSInType || type==MGMISMSOutType)
			[messageField setText:[[[[messageData objectForKey:MGMIMessages] lastObject] objectForKey:MGMIText] flattenHTML]];
		else
			[messageField setText:[[[messageData objectForKey:MGMIPhoneNumber] areaCode] areaCodeLocation]];
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
	
	[nameField setFrame:CGRectMake(20, 3, frameRect.size.width-86, 20)];
	[dateField setFrame:CGRectMake(frameRect.size.width-64, 3, 60, 20)];
	[messageField setFrame:CGRectMake(20, frameRect.size.height-41, frameRect.size.width-18, 32)];
	[self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
	if (messageData!=nil) {
		if (![[messageData objectForKey:MGMIRead] boolValue]) {
			CGRect frameRect = [[self contentView] bounds];
			MGMPath *path = [MGMPath pathWithRoundedRect:CGRectMake(4, (frameRect.size.height/2)-6.5, 13, 13) cornerRadius:6.5];
			[path fillGradientFrom:[UIColor colorWithRed:0.5215 green:0.6901 blue:0.9607 alpha:1.0] to:[UIColor colorWithRed:0.1255 green:0.3138 blue:0.6589 alpha:1.0]];			
		}
	}
	[super drawRect:rect];
}
@end