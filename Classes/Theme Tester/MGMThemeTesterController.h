//
//  MGMThemeTesterController.h
//  Voice Mac
//
//  Created by Mr. Gecko on 8/24/10.
//  Copyright 2010 Mr. Gecko's Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView, MGMThemeManager;

@interface MGMThemeTesterController : NSObject {
	NSPipe *errorPipe;
	IBOutlet NSTextView *errorConsole;
	IBOutlet NSWindow *errorConsoleWindow;
	
	MGMThemeManager *themeManager;
	IBOutlet NSWindow *mainWindow;
	IBOutlet WebView *SMSView;
	
	NSMutableArray *messages;
	
	IBOutlet NSTextField *yPhotoField;
	IBOutlet NSTextField *yNumberField;
	IBOutlet NSTextField *tPhotoField;
	IBOutlet NSTextField *tNameField;
	IBOutlet NSTextField *tNumberField;
	IBOutlet NSDatePicker *lastDatePicker;
	IBOutlet NSTextField *IDField;
	IBOutlet NSTextField *messageField;
	IBOutlet NSPopUpButton *variantsButton;
}
- (IBAction)open:(id)sender;
- (IBAction)save:(id)sender;

- (void)buildHTML;

- (IBAction)chooseYPhoto:(id)sender;
- (IBAction)chooseTPhoto:(id)sender;

- (IBAction)rebuild:(id)sender;
- (IBAction)incoming:(id)sender;
- (IBAction)outgoing:(id)sender;
@end