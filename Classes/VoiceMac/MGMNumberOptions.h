//
//  MGMNumberOptions.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/6/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>
#import "MGMContactsController.h"

@class MGMController, MGMWhitePages;

@interface MGMContactsController (MGMSMS)
- (IBAction)sms:(id)sender;
@end

@interface MGMNumberOptions : NSObject {
	MGMContactsController *contactsController;
	MGMController *controller;
	MGMWhitePages *whitePages;
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