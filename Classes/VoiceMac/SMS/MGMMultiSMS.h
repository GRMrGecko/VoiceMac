//
//  MGMMultiSMS.h
//  VoiceMac
//
//  Created by Mr. Gecko on 8/30/10.
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