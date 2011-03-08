//
//  MGMSMSMessageView.m
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

#import "MGMSMSMessageView.h"
#import "MGMSMSManager.h"
#import "MGMSMSView.h"
#import "MGMSMSTextView.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>
#import <Growl/GrowlApplicationBridge.h>
#import <WebKit/WebKit.h>

@implementation MGMSMSMessageView
+ (id)viewWithManager:(MGMSMSManager *)theManager messages:(NSArray *)theMessages messageInfo:(NSDictionary *)theMessageInfo instance:(MGMInstance *)theInstance {
	return [[[self alloc] initWithManager:theManager messages:theMessages messageInfo:theMessageInfo instance:theInstance] autorelease];
}
- (id)initWithManager:(MGMSMSManager *)theManager messages:(NSArray *)theMessages messageInfo:(NSDictionary *)theMessageInfo instance:(MGMInstance *)theInstance {
	if ((self = [super init])) {
		if (![NSBundle loadNibNamed:@"SMSMessageView" owner:self]) {
			NSLog(@"Error: Unable to load SMS Message View.");
			[self release];
			self = nil;
		} else {
			manager = theManager;
			instance = theInstance;
			messages = [theMessages mutableCopy];
			messageInfo = [theMessageInfo mutableCopy];
			BOOL read = [[messageInfo objectForKey:MGMIRead] boolValue];
			sendingMessage = NO;
			
			marking = NO;
			
			[SMSView setResourceLoadDelegate:self];
			view = [[MGMSMSView viewWithMessageView:self] retain];
			[view setRead:read];
			[self buildHTML];
			if (!read)
				[self sendNotifications];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedTheme:) name:MGMTUpdatedSMSThemeNotification object:[manager themeManager]];
		}
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[SMSSplitView release];
	[messages release];
	[messageInfo release];
	[super dealloc];
}

- (void)setRead:(BOOL)isRead {
	[messageInfo setObject:[NSNumber numberWithBool:isRead] forKey:MGMIRead];
	[view setRead:isRead];
}

- (MGMSMSManager *)manager {
	return manager;
}
- (MGMInstance *)instance {
	return instance;
}
- (MGMSplitView *)SMSSplitView {
	return SMSSplitView;
}
- (WebView *)SMSView {
	return SMSView;
}
- (MGMSMSTextView *)SMSTextField {
	return SMSTextView;
}
- (MGMSMSView *)view {
	return view;
}

- (NSArray *)messages {
	return messages;
}
- (NSMutableDictionary *)messageInfo {
	return messageInfo;
}

- (void)sendNotifications {
	for (unsigned int i=[messages count]-1; i>=0; i--) {
		if (![[[messages objectAtIndex:i] objectForKey:MGMIYou] boolValue]) {
			[GrowlApplicationBridge notifyWithTitle:[NSString stringWithFormat:@"SMS from %@", [messageInfo objectForKey:MGMTInName]] description:[[[messages objectAtIndex:i] objectForKey:MGMIText] flattenHTML] notificationName:@"SMS" iconData:[[instance contacts] photoDataForNumber:[messageInfo objectForKey:MGMIPhoneNumber]] priority:0 isSticky:NO clickContext:nil];
			break;
		}
	}
}

- (BOOL)updateWithMessages:(NSArray *)theMessages messageInfo:(NSDictionary *)theMessageInfo {
	BOOL newIncomingMessages = NO;
	if (![[theMessageInfo objectForKey:MGMITime] isEqual:[messageInfo objectForKey:MGMITime]]) {
		[messageInfo release];
		messageInfo = [theMessageInfo mutableCopy];
		[self setRead:[[messageInfo objectForKey:MGMIRead] boolValue]];
		
		BOOL rebuild = [[[[manager themeManager] variant] objectForKey:MGMTRebuild] boolValue];
		BOOL newMessages = NO;
		for (unsigned int i=[messages count]; i<[theMessages count]; i++) {
			newMessages = YES;
			[messages addObject:[theMessages objectAtIndex:i]];
			if (![[[theMessages objectAtIndex:i] objectForKey:MGMIYou] boolValue])
				newIncomingMessages = YES;
			if (!rebuild)
				[self addMessage:[messages lastObject]];
		}
		
		if (newMessages && rebuild)
			[self buildHTML];
		if (newIncomingMessages)
			[self sendNotifications];
	}
	return newIncomingMessages;
}

- (void)updatedTheme:(NSNotification *)theNotification {
	[self buildHTML];
}

- (void)buildHTML {
	NSString *yPhotoPath = [[instance contacts] cachedPhotoForNumber:[messageInfo objectForKey:MGMTUserNumber]];
	if (yPhotoPath==nil)
		yPhotoPath = [[[manager themeManager] outgoingIconPath] filePath];
	NSString *tPhotoPath = [[instance contacts] cachedPhotoForNumber:[messageInfo objectForKey:MGMIPhoneNumber]];
	if (tPhotoPath==nil)
		tPhotoPath = [[[manager themeManager] incomingIconPath] filePath];
	NSMutableArray *messageArray = [NSMutableArray array];
	for (unsigned int i=0; i<[messages count]; i++) {
		NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:[messages objectAtIndex:i]];
		[message setObject:[[NSNumber numberWithInt:i] stringValue] forKey:MGMIID];
		if ([[message objectForKey:MGMIYou] boolValue]) {
			[message setObject:yPhotoPath forKey:MGMTPhoto];
			[message setObject:NSFullUserName() forKey:MGMTName];
			[message setObject:[messageInfo objectForKey:MGMTUserNumber] forKey:MGMIPhoneNumber];
		} else {
			[message setObject:tPhotoPath forKey:MGMTPhoto];
			[message setObject:[messageInfo objectForKey:MGMTInName] forKey:MGMTName];
			[message setObject:[messageInfo objectForKey:MGMIPhoneNumber] forKey:MGMIPhoneNumber];
		}
		[messageArray addObject:message];
	}
	NSString *html = [[manager themeManager] buildHTMLWithMessages:messageArray messageInfo:messageInfo];
	[[SMSView mainFrame] loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[manager themeManager] currentThemeVariantPath]]];
}
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
	if (marking) return;
	[SMSView stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}
- (void)addMessage:(NSDictionary *)theMessage {
	NSString *yPhotoPath = [[instance contacts] cachedPhotoForNumber:[messageInfo objectForKey:MGMTUserNumber]];
	if (yPhotoPath==nil)
		yPhotoPath = [[[manager themeManager] outgoingIconPath] filePath];
	NSString *tPhotoPath = [[instance contacts] cachedPhotoForNumber:[messageInfo objectForKey:MGMIPhoneNumber]];
	if (tPhotoPath==nil)
		tPhotoPath = [[[manager themeManager] incomingIconPath] filePath];
	NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:theMessage];
	[message setObject:[[NSNumber numberWithInt:[messages count]-1] stringValue] forKey:MGMIID];
	int type = 1;
	if ([[message objectForKey:MGMIYou] boolValue]) {
		type = (([[message objectForKey:MGMIID] intValue]==0 || ![[[messages objectAtIndex:[[message objectForKey:MGMIID] intValue]-1] objectForKey:MGMIYou] boolValue]) ? 1 : 2);
		[message setObject:yPhotoPath forKey:MGMTPhoto];
		[message setObject:NSFullUserName() forKey:MGMTName];
		[message setObject:[messageInfo objectForKey:MGMTUserNumber] forKey:MGMIPhoneNumber];
	} else {
		type = (([[message objectForKey:MGMIID] intValue]==0 || [[[messages objectAtIndex:[[message objectForKey:MGMIID] intValue]-1] objectForKey:MGMIYou] boolValue]) ? 3 : 4);
		[message setObject:tPhotoPath forKey:MGMTPhoto];
		[message setObject:[messageInfo objectForKey:MGMTInName] forKey:MGMTName];
		[message setObject:[messageInfo objectForKey:MGMIPhoneNumber] forKey:MGMIPhoneNumber];
	}
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateFormat:[[[manager themeManager] variant] objectForKey:MGMTDate]];
	[SMSView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"newMessage('%@', '%@', '%@', %@, '%@', '%@', '%@', %d);", [[message objectForKey:MGMIText] javascriptEscape], [[message objectForKey:MGMTPhoto] javascriptEscape], [[message objectForKey:MGMITime] javascriptEscape], [message objectForKey:MGMIID], [[message objectForKey:MGMTName] javascriptEscape], [[[message objectForKey:MGMIPhoneNumber] readableNumber] javascriptEscape], [formatter stringFromDate:[messageInfo objectForKey:MGMITime]], type]];
	[SMSView stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}

- (IBAction)sendMessage:(id)sender {
	if ([[SMSTextView string] isEqual:@""])
		return;
	sendingMessage = YES;
	[SMSTextView setEditable:NO];
	[[instance inbox] sendMessage:[SMSTextView string] phoneNumbers:[NSArray arrayWithObject:[messageInfo objectForKey:MGMIPhoneNumber]] smsID:[messageInfo objectForKey:MGMIID] delegate:self];
}
- (void)message:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	sendingMessage = NO;
	[SMSTextView setEditable:YES];
	[[manager SMSWindow] makeFirstResponder:SMSTextView];
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert setMessageText:@"Error sending a SMS Message"];
	[theAlert setInformativeText:[theError localizedDescription]];
	[theAlert runModal];
}
- (void)messageDidFinish:(MGMDelegateInfo *)theInfo instance:(MGMInstance *)theInstance {
	sendingMessage = NO;
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateFormat:@"h:mm a"];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[SMSTextView string], MGMIText, [formatter stringFromDate:[NSDate date]], MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil];
	[messages addObject:message];
	[messageInfo setObject:[NSDate date] forKey:MGMITime];
	if ([[[[manager themeManager] variant] objectForKey:MGMTRebuild] boolValue]) {
		[self buildHTML];
	} else {
		[self addMessage:message];
	}
	[SMSTextView setString:@""];
	[SMSTextView setEditable:YES];
	[SMSTextView count];
	NSRect frame = [SMSSplitView frame];
	NSView *top = [[SMSSplitView subviews] objectAtIndex:0];
    NSRect topFrame = [top frame];
	NSView *bottom = [[SMSSplitView subviews] objectAtIndex:1];
    NSRect bottomFrame = [bottom frame];
	bottomFrame.size.height = 33.0;
	topFrame.size.height = frame.size.height-(bottomFrame.size.height+[SMSSplitView dividerThickness]);
	[top setFrame:topFrame];
	[bottom setFrame:bottomFrame];
	[[manager SMSWindow] makeFirstResponder:SMSTextView];
	[self setRead:YES];
}

- (IBAction)close:(id)sender {
	if (sendingMessage) {
		NSAlert *theAlert = [[NSAlert new] autorelease];
		[theAlert setMessageText:@"Sending a SMS Message"];
		[theAlert setInformativeText:@"Your SMS Message is currently being sent, please wait for it to be sent."];
		[theAlert runModal];
	} else if (marking) {
		
	} else if (![[messageInfo objectForKey:MGMIRead] boolValue]) {
		marking = YES;
		[[instance inbox] markEntries:[NSArray arrayWithObject:[messageInfo objectForKey:MGMIID]] read:YES delegate:self];
	} else {
		[manager closeSMSMessage:self];
	}
}
- (BOOL)shouldClose {
	return (!sendingMessage);
}
- (void)mark:(MGMDelegateInfo *)theInfo didFailWithError:(NSError *)theError instance:(MGMInstance *)theInstance {
	marking = NO;
	NSAlert *theAlert = [[NSAlert new] autorelease];
	[theAlert setMessageText:@"Error marking as read"];
	[theAlert setInformativeText:[theError localizedDescription]];
	[theAlert runModal];
}
- (void)markDidFinish:(MGMDelegateInfo *)theInfo instance:(MGMInstance *)theInstance {
	marking = NO;
	[messageInfo setObject:[NSNumber numberWithBool:YES] forKey:MGMIRead];
	[self close:self];
}

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset {
    bottomMax = [[[sender subviews] objectAtIndex:1] frame].size.height;
	return 50.0;
}
- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset{
	bottomMax = [[[sender subviews] objectAtIndex:1] frame].size.height;
	return proposedMax - 33.0;
}
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    NSRect newFrame = [sender frame];
    if (newFrame.size.height == oldSize.height) {
		[sender adjustSubviews];
		return;
    }
	
	NSView *top = [[sender subviews] objectAtIndex:0];
    NSRect topFrame = [top frame];
	NSView *bottom = [[sender subviews] objectAtIndex:1];
    NSRect bottomFrame = [bottom frame];
	if (bottomMax==0.0)
		[self splitView:sender constrainMinCoordinate:0.0 ofSubviewAt:0];
	
	if (topFrame.size.height<50.0) {
		bottomMax = newFrame.size.height-(50.0+[sender dividerThickness]);
		bottomFrame.size.width = bottomMax;
	}
	
	if (bottomMax<33.0)
		bottomMax = 33.0;
	
	if (bottomFrame.size.height < bottomMax || bottomFrame.size.height > bottomMax) {
		bottomFrame.size.height = bottomMax;
	}
	topFrame.size.height = newFrame.size.height-(bottomFrame.size.height+[sender dividerThickness]);
	[top setFrame:topFrame];
	[bottom setFrame:bottomFrame];
}
@end