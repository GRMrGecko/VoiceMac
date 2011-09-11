//
//  MGMSMSMessageView.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/25/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//
//  Permission to use, copy, modify, and/or distribute this software for any purpose
//  with or without fee is hereby granted, provided that the above copyright notice
//  and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
//  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT,
//  OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
//  DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
//  ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
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
	BOOL markingForMessage;
	
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