//
//  MGMSMSMessageView.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/25/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMSMSManager, MGMInstance, MGMSplitView, WebView, MGMSMSTextView, MGMSMSView;

@interface MGMSMSMessageView : NSObject {
	MGMSMSManager *manager;
	MGMInstance *instance;
	IBOutlet MGMSplitView *SMSSplitView;
	IBOutlet WebView *SMSView;
	IBOutlet MGMSMSTextView *SMSTextView;
	MGMSMSView *view;
	
	NSMutableArray *messages;
	NSMutableDictionary *messageInfo;
	BOOL sendingMessage;
	
	BOOL marking;
	
	float bottomMax;
}
+ (id)viewWithManager:(MGMSMSManager *)theManager messages:(NSArray *)theMessages messageInfo:(NSDictionary *)theMessageInfo instance:(MGMInstance *)theInstance;
- (id)initWithManager:(MGMSMSManager *)theManager messages:(NSArray *)theMessages messageInfo:(NSDictionary *)theMessageInfo instance:(MGMInstance *)theInstance;

- (MGMSMSManager *)manager;
- (MGMInstance *)instance;
- (MGMSplitView *)SMSSplitView;
- (WebView *)SMSView;
- (MGMSMSTextView *)SMSTextField;
- (MGMSMSView *)view;

- (NSArray *)messages;
- (NSMutableDictionary *)messageInfo;

- (void)sendNotifications;

- (BOOL)updateWithMessages:(NSArray *)theMessages messageInfo:(NSDictionary *)theMessageInfo;

- (void)buildHTML;
- (void)addMessage:(NSDictionary *)theMessage;

- (IBAction)sendMessage:(id)sender;
- (IBAction)close:(id)sender;
- (BOOL)shouldClose;
@end