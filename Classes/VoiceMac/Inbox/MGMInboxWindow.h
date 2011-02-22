//
//  MGMInboxWindow.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/3/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMInstance, MGMSplitView;

@interface MGMInboxWindow : NSObject {
	MGMInstance *instance;
	IBOutlet NSWindow *inboxWindow;
	IBOutlet MGMSplitView *splitView;
	IBOutlet NSOutlineView *sidebarView;
	IBOutlet NSTableView *inboxTable;
	IBOutlet NSButton *nextButton;
	IBOutlet NSButton *previousButton;
	IBOutlet NSTextField *pageField;
	IBOutlet NSProgressIndicator *progress;
	int progressStartCount;
	
	int currentInbox;
	int maxResults;
	unsigned int start;
	int resultsCount;
	
	float rightMax;
	float leftMax;
	NSMutableArray *currentData;
	NSDate *lastDate;
}
+ (id)windowWithInstance:(MGMInstance *)theInstance;
- (id)initWithInstance:(MGMInstance *)theInstance;
- (NSWindow *)inboxWindow;
- (IBAction)showWindow:(id)sender;
- (void)closeWindow;

- (void)startProgress;
- (void)stopProgress;

- (void)checkVoicemail;

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;

- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;

- (void)loadInbox;
- (int)currentInbox;
- (void)setCurrentData:(NSArray *)theData;
- (NSDictionary *)selectedItem;
- (NSString *)currentPhoneNumber;
- (NSURL *)audioURL;
- (IBAction)spam:(id)sender;
- (IBAction)markRead:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)undelete:(id)sender;
@end

@interface MGMInboxTableView : NSTableView {
	IBOutlet MGMInboxWindow *inboxWindow;
}

@end