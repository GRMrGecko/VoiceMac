//
//  MGMNumberOptions.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/6/10.
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
#import "MGMContactsController.h"

@class MGMController, MGMURLConnectionManager;

@interface MGMContactsController (MGMSMS)
- (IBAction)sms:(id)sender;
@end

@interface MGMNumberOptions : NSObject {
	MGMContactsController *contactsController;
	MGMController *controller;
	MGMURLConnectionManager *connectionManager;
	IBOutlet NSWindow *optionsWindow;
	IBOutlet NSTextField *phoneField;
	IBOutlet NSTextField *nameField;
	IBOutlet NSPopUpButton *accountPopUp;
	IBOutlet NSButton *smsButton;
	IBOutlet NSButton *callButton;
	IBOutlet NSButton *cancelButton;
}
- (id)initWithContactsController:(MGMContactsController *)theContactsController controller:(MGMController *)theController number:(NSString *)theNumber;

- (void)updateAccounts;
- (IBAction)setAccount:(id)sender;

- (IBAction)call:(id)sender;
- (IBAction)sms:(id)sender;
- (IBAction)cancel:(id)sender;
@end