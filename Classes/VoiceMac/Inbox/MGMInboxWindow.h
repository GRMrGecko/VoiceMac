//
//  MGMInboxWindow.h
//  VoiceMac
//
//  Created by Mr. Gecko on 9/3/10.
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