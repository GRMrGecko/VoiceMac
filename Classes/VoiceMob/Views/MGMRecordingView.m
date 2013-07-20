//
//  MGMRecordingView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 10/14/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMRecordingView.h"
#import "MGMSIPRecordings.h"

@implementation MGMRecordingView
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
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[nameField release];
	[dateField release];
	[recording release];
	[super dealloc];
}

- (void)setRecording:(NSDictionary *)theRecording {
	[recording release];
	recording = [theRecording retain];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
    CGRect frameRect = [[self contentView] bounds];
	
	if (recording!=nil) {
		[nameField setText:[recording objectForKey:MGMRName]];
		NSDate *today = [NSDate dateWithTimeIntervalSinceNow:-86400];
		if ([[recording objectForKey:MGMRDate] earlierDate:today]==today) {
			NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
			[formatter setDateFormat:@"h:mm a"];
			[dateField setText:[formatter stringFromDate:[recording objectForKey:MGMRDate]]];
		} else {
			NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
			[formatter setDateFormat:@"M/d/yy"];
			[dateField setText:[formatter stringFromDate:[recording objectForKey:MGMRDate]]];
		}
	}
	
	[nameField setFrame:CGRectMake(8, (frameRect.size.height-20)/2, frameRect.size.width-74, 20)];
	[dateField setFrame:CGRectMake(frameRect.size.width-64, (frameRect.size.height-20)/2, 60, 20)];
}
@end