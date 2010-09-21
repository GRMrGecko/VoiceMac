//
//  MGMMultiSMS.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/30/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMInstance, MGMController, MGMSMSTextView;

@interface MGMMultiSMS : NSObject {
	MGMInstance *instance;
	MGMController *controller;
	IBOutlet NSWindow *SMSWindow;
	IBOutlet NSPopUpButton *groupsPopUp;
	IBOutlet NSTokenField *additionalField;
	IBOutlet MGMSMSTextView *SMSTextView;
	IBOutlet NSButton *sendButton;
	IBOutlet NSButton *cancelButton;
	
	BOOL sendingMessage;
}
+ (id)SMSWithInstance:(MGMInstance *)theInstance controller:(MGMController *)theController;
- (id)initWithInstance:(MGMInstance *)theInstance controller:(MGMController *)theController;

- (MGMInstance *)instance;
- (MGMController *)controller;
- (NSWindow *)SMSWindow;

- (IBAction)sendMessage:(id)sender;
- (IBAction)cancel:(id)sender;
@end