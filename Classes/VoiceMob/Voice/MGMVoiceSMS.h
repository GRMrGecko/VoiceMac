//
//  MGMVoiceSMS.h
//  VoiceMob
//
//  Created by Mr. Gecko on 9/30/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

@class MGMVoiceUser, MGMSMSTextView, MGMInstance;

@interface MGMVoiceSMS : NSObject <UIWebViewDelegate> {
	MGMVoiceUser *voiceUser;
	
	NSArray *messageItems;
	
	NSMutableArray *SMSMessages;
	int currentSMSMessage;
	NSDate *lastDate;
	NSTimer *updateTimer;
	BOOL sendingMessage;
	BOOL marking;
	
	IBOutlet UITableView *messagesTable;
	IBOutlet UIView *messageView;
	IBOutlet UIWebView *SMSView;
	CGRect SMSViewStartFrame;
	IBOutlet UIView *SMSBottomView;
	IBOutlet MGMSMSTextView *SMSTextView;
	IBOutlet UILabel *SMSTextCountField;
	IBOutlet UIButton *SMSSendButton;
}
+ (id)tabWithVoiceUser:(MGMVoiceUser *)theVoiceUser;
- (id)initWithVoiceUser:(MGMVoiceUser *)theVoiceUser;

- (MGMVoiceUser *)voiceUser;

- (UIView *)view;
- (void)releaseView;

- (void)checkSMSMessages;
- (void)messageWithNumber:(NSString *)theNumber instance:(MGMInstance *)theInstance;
- (void)messageWithData:(NSDictionary *)theData instance:(MGMInstance *)theInstance;

- (IBAction)showMessages:(id)sender;

- (void)setMessage:(int)theMessage read:(BOOL)isRead;

- (BOOL)updateMessage:(int)theMessage messageInfo:(NSDictionary *)theMessageInfo;

- (void)textViewDidChange:(UITextView *)textView;

- (void)buildHTML;
- (void)addMessage:(NSDictionary *)theMessage withInfo:(NSMutableDictionary *)theMessageInfo;

- (IBAction)sendMessage:(id)sender;

- (BOOL)shouldClose;
@end