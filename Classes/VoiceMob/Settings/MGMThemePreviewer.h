//
//  MGMThemePreviewer.h
//  VoiceMob
//
//  Created by Mr. Gecko on 11/6/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>
#import <MGMUsers/MGMUsers.h>

@class MGMThemeManager;

@interface MGMThemePreviewer : MGMSettingView <UIWebViewDelegate> {
	MGMThemeManager *themeManager;
	UIWebView *SMSView;
	NSMutableArray *testMessages;
	NSMutableDictionary *testMessageInfo;
}

@end