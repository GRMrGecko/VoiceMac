//
//  MGMTaskView.h
//  YouView
//
//  Created by Mr. Gecko on 4/16/09.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMURLConnectionManager, MGMTaskManager;

@interface MGMTaskView : NSObject <NSSoundDelegate> {
	MGMTaskManager *manager;
	IBOutlet NSView *mainView;
	IBOutlet NSImageView *icon;
	IBOutlet NSTextField *name;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *info;
	IBOutlet NSButton *stop;
	IBOutlet NSButton *restart;
	NSMutableDictionary *taskInfo;
	NSHTTPCookieStorage *cookieStorage;
	
	MGMURLConnectionManager *connectionManager;
	
	int startTime;
	int bytesReceivedSec;
	int bytesReceived;
	NSTimer *secCheckTimer;
	NSString *receivedSec;
    int receivedContentLength;
    int expectedContentLength;
	
	BOOL working;
	BOOL stopped;
}
+ (id)taskViewWithTask:(NSDictionary *)theTask manager:(MGMTaskManager *)theManager cookieStorage:(NSHTTPCookieStorage *)theCookieStorage;
- (id)initWithTask:(NSDictionary *)theTask manager:(MGMTaskManager *)theManager cookieStorage:(NSHTTPCookieStorage *)theCookieStorage;
- (void)setName;
- (NSString *)VMTaskPath;
- (BOOL)working;
- (NSView *)view;
- (NSString *)bytesToString:(double)bytes;
- (NSString *)secsToString:(int)secs;
- (IBAction)stop:(id)sender;
- (IBAction)reveal:(id)sender;
- (IBAction)restart:(id)sender;
- (void)saveInfo;
@end