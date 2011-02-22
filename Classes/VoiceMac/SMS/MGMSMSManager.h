//
//  MGMSMSManager.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/25/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMController, MGMSplitView, MGMThemeManager, MGMInstance, MGMSMSMessageView;

@interface MGMSMSManager : NSObject {
	MGMController *controller;
	IBOutlet NSWindow *SMSWindow;
	IBOutlet MGMSplitView *splitView;
	IBOutlet NSView *messageView;
	IBOutlet NSTableView *messagesTable;
	NSMutableArray *SMSMessages;
	NSMutableDictionary *lastDates;
	NSTimer *updateTimer;
	
	float rightMax;
	float leftMax;
}
+ (id)managerWithController:(MGMController *)theController;
- (id)initWithController:(MGMController *)theController;

- (NSWindow *)SMSWindow;
- (MGMController *)controller;
- (MGMThemeManager *)themeManager;
- (NSMutableArray *)SMSMessages;

- (IBAction)showWindow:(id)sender;

- (void)reloadData;
- (void)closeSMSMessage:(MGMSMSMessageView *)theMessage;

- (void)checkSMSMessagesForInstance:(MGMInstance *)theInstance;
- (void)messageWithNumber:(NSString *)theNumber instance:(MGMInstance *)theInstance;
- (void)messageWithData:(NSDictionary *)theData instance:(MGMInstance *)theInstance;
- (NSString *)currentPhoneNumber;
- (void)windowDidBecomeKey:(NSNotification *)notification;
@end