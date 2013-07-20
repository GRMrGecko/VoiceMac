//
//  MGMContactView.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/29/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMContactView.h"
#import <VoiceBase/VoiceBase.h>

@implementation MGMContactView
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[[self contentView] addSubview:photoView];
		nameField = [[UILabel alloc] initWithFrame:CGRectZero];
		[nameField setBackgroundColor:[UIColor clearColor]];
		[nameField setFont:[UIFont boldSystemFontOfSize:18.0]];
		[[self contentView] addSubview:nameField];
		phoneField = [[UILabel alloc] initWithFrame:CGRectZero];
		[phoneField setBackgroundColor:[UIColor clearColor]];
		[phoneField setFont:[UIFont systemFontOfSize:15.0]];
		[[self contentView] addSubview:phoneField];
		photoLock = [NSLock new];
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[photoView release];
	[nameField release];
	[phoneField release];
	[contact release];
	[photoLock release];
	[number release];
	[super dealloc];
}

- (void)setThemeManager:(MGMThemeManager *)theThemeManager {
	themeManager = theThemeManager;
}
- (void)setContacts:(MGMContacts *)theContacts {
	contacts = theContacts;
}
- (void)setContact:(NSDictionary *)theContact {
	[contact release];
	contact = [theContact retain];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
    CGRect frameRect = [[self contentView] bounds];
	
	if (contact!=nil) {
		if (![number isEqual:[contact objectForKey:MGMCNumber]]) {
			[number release];
			number = [[contact objectForKey:MGMCNumber] retain];
			[photoView setImage:nil];
			[NSThread detachNewThreadSelector:@selector(getPhotoForNumber:) toTarget:self withObject:number];
		}
		if ([[contact objectForKey:MGMCName] isEqual:@""])
			[nameField setText:[contact objectForKey:MGMCCompany]];
		else
			[nameField setText:[contact objectForKey:MGMCName]];
		if ([[contact objectForKey:MGMCLabel] isEqual:@""])
			[phoneField setText:[[contact objectForKey:MGMCNumber] readableNumber]];
		else
			[phoneField setText:[NSString stringWithFormat:@"%@ %@", [[contact objectForKey:MGMCNumber] readableNumber], [contact objectForKey:MGMCLabel]]];
	}
	
	[photoView setFrame:CGRectMake(0, 0, frameRect.size.height, frameRect.size.height)];
	[nameField setFrame:CGRectMake(frameRect.size.height+8, 10, frameRect.size.width-(frameRect.size.height+12), 20)];
	[phoneField setFrame:CGRectMake(frameRect.size.height+8, frameRect.size.height-27, frameRect.size.width-(frameRect.size.height+12), 20)];
}

- (void)getPhotoForNumber:(NSString *)theNumber {
	photoWaiting++;
	[photoLock lock];
	photoWaiting--;
	if (photoWaiting>=1) {
		[photoLock unlock];
		return;
	}
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSData *photo = [contacts photoDataForNumber:number];
	if (photoWaiting>=1) {
		[pool release];
		[photoLock unlock];
		return;
	}
	if (photo==nil || [photo isKindOfClass:[NSNull class]])
		[photoView setImage:[[[UIImage alloc] initWithContentsOfFile:[themeManager incomingIconPath]] autorelease]];
	else
		[photoView setImage:[[[UIImage alloc] initWithData:photo] autorelease]];
	[pool release];
	[photoLock unlock];
}
@end