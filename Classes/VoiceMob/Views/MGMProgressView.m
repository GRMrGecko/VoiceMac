//
//  MGMLoginProcessView.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/19/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMProgressView.h"

@implementation MGMProgressView
- (id)initWithFrame:(CGRect)frameRect {
	if (self = [super initWithFrame:frameRect]) {
		[self setBackgroundColor:[UIColor clearColor]];
		progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[progress setFrame:CGRectMake((frameRect.size.width-37)/2, (frameRect.size.height-37)/2, 37, 37)];
		[self addSubview:progress];
		pleaseWaitField = [[UILabel alloc] initWithFrame:CGRectMake(17, (((frameRect.size.height-37)/2)+34)+8, frameRect.size.width-34, 21)];
		[pleaseWaitField setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		[pleaseWaitField setTextAlignment:UITextAlignmentCenter];
		[pleaseWaitField setBackgroundColor:[UIColor clearColor]];
		[pleaseWaitField setText:@"Please Wait..."];
		[self addSubview:pleaseWaitField];
		progressField = [[UILabel alloc] initWithFrame:CGRectMake(17, ((frameRect.size.height-37)/2)-30, frameRect.size.width-34, 21)];
		[progressField setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		[progressField setTextAlignment:UITextAlignmentCenter];
		[progressField setBackgroundColor:[UIColor clearColor]];
		[progressField setText:@"Progress"];
		[self addSubview:progressField];
	}
	return self;
}
- (void)dealloc {
	if (progress)
		[progress release];
	if (pleaseWaitField!=nil)
		[pleaseWaitField release];
	if (progressField!=nil)
		[progressField release];
	[super dealloc];
}
- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect frameRect = [self frame];
	[progress setFrame:CGRectMake((frameRect.size.width-37)/2, (frameRect.size.height-37)/2, 37, 37)];
	[pleaseWaitField setFrame:CGRectMake(17, ((frameRect.size.height-37)/2)-37, frameRect.size.width-37, 21)];
	[progressField setFrame:CGRectMake(17, (((frameRect.size.height-37)/2)+37)+12, frameRect.size.width-37, 21)];
}
- (void)startProgess {
	[progress startAnimating];
}
- (void)stopProgess {
	[progress stopAnimating];
}
- (void)setProgressTitle:(NSString *)theTitle {
	[progressField setText:theTitle];
}
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(context, [self bounds]);
	
	CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] CGColor]);
	CGContextBeginPath(context);
	CGContextAddRect(context, rect);
	CGContextClosePath(context);
	CGContextFillPath(context);
}
- (BOOL)canBecomeFirstResponder {
	return YES;
}
@end