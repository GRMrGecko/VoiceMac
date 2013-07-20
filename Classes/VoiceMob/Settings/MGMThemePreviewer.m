//
//  MGMThemePreviewer.m
//  VoiceMob
//
//  Created by Mr. Gecko on 11/6/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMThemePreviewer.h"
#import <VoiceBase/VoiceBase.h>

NSString * const MGMTestTYPhoto = @"yPhoto";
NSString * const MGMTestTTPhoto = @"tPhoto";

@implementation MGMThemePreviewer
- (id)initWithSetting:(MGMSetting *)theSetting {
	if ((self = [super initWithSetting:theSetting])) {
		themeManager = [MGMThemeManager new];
		testMessages = [NSMutableArray new];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Hey, you got the message?", MGMIText, @"5:56 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No, can you resend it?", MGMIText, @"5:57 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No, all local copies were destroyed, because we don't want this to get out.", MGMIText, @"5:58 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Oh, yea, right, that thing.", MGMIText, @"5:59 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"I can't send you on SMS because your cell phone company spy's on you.", MGMIText, @"6:00 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"True. We can meet in the secret spot.", MGMIText, @"6:00 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No thanks, I think we should meet at my house.", MGMIText, @"6:01 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Would you like to come for dinner?", MGMIText, @"6:01 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"I'd love, but my girl needs me more.", MGMIText, @"6:02 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Well why not make it a double date? I bring my wife and you bring yours.", MGMIText, @"6:03 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Sure I pick Mucha Pizza. What time should we meet?", MGMIText, @"6:05 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"7PM?", MGMIText, @"6:05 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"That sounds good.", MGMIText, @"6:06 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
		[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Great, meet you then.", MGMIText, @"6:07 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
		testMessageInfo = [NSMutableDictionary new];
		[testMessageInfo setObject:[NSDate dateWithTimeIntervalSince1970:1598915245] forKey:MGMITime];
		[testMessageInfo setObject:@"Noah Jonson" forKey:MGMTInName];
		[testMessageInfo setObject:@"+15555555555" forKey:MGMIPhoneNumber];
		[testMessageInfo setObject:@"+17204325686" forKey:MGMTUserNumber];
		[testMessageInfo setObject:@"673bd22599231d1a9ba78760f2df085a7237b4b3" forKey:MGMIID];
		[testMessageInfo setObject:[[themeManager outgoingIconPath] filePath] forKey:MGMTestTYPhoto];
		[testMessageInfo setObject:[[themeManager incomingIconPath] filePath] forKey:MGMTestTTPhoto];
	}
	return self;
}
- (void)dealloc {
	[self releaseView];
	[themeManager release];
	[testMessages release];
	[testMessageInfo release];
	[super dealloc];
}

- (UIView *)view {
	if (SMSView==nil) {
		SMSView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 418)];
		[SMSView setDelegate:self];
		
		NSMutableArray *messageArray = [NSMutableArray array];
		for (unsigned int i=0; i<[testMessages count]; i++) {
			NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:[testMessages objectAtIndex:i]];
			[message setObject:[[NSNumber numberWithInt:i] stringValue] forKey:MGMIID];
			if ([[message objectForKey:MGMIYou] boolValue]) {
				[message setObject:[testMessageInfo objectForKey:MGMTestTYPhoto] forKey:MGMTPhoto];
				[message setObject:NSFullUserName() forKey:MGMTName];
				[message setObject:[testMessageInfo objectForKey:MGMTUserNumber] forKey:MGMIPhoneNumber];
			} else {
				[message setObject:[testMessageInfo objectForKey:MGMTestTTPhoto] forKey:MGMTPhoto];
				[message setObject:[testMessageInfo objectForKey:MGMTInName] forKey:MGMTName];
				[message setObject:[testMessageInfo objectForKey:MGMIPhoneNumber] forKey:MGMIPhoneNumber];
			}
			[messageArray addObject:message];
		}
		NSString *html = [themeManager buildHTMLWithMessages:messageArray messageInfo:testMessageInfo];
		[SMSView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[themeManager currentThemeVariantPath]]];
	}
	return SMSView;
}
- (void)releaseView {
	[SMSView release];
	SMSView = nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[SMSView stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}
@end