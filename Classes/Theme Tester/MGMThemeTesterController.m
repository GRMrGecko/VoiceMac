//
//  MGMThemeTesterController.m
//  Voice Mac
//
//  Created by Mr. Gecko on 8/24/10.
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

#import "MGMThemeTesterController.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>
#import <WebKit/WebKit.h>

@implementation MGMThemeTesterController
- (void)awakeFromNib {
	errorPipe = [NSPipe new];
	dup2([[errorPipe fileHandleForWriting] fileDescriptor], fileno(stderr));
	
	NSFileHandle *pipeHandle = [errorPipe fileHandleForReading];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorHandle:) name:NSFileHandleReadCompletionNotification object:pipeHandle];
	[pipeHandle readInBackgroundAndNotify];
	
	[SMSView setResourceLoadDelegate:self];
	messages = [NSMutableArray new];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Hey, you got the message?", MGMIText, @"5:56 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No, can you resend it?", MGMIText, @"5:57 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No, all local copies were destroyed, because we don't want this to get out.", MGMIText, @"5:58 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Oh, yea, right, that thing.", MGMIText, @"5:59 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"I can't send you on SMS because your cell phone company spy's on you.", MGMIText, @"6:00 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"True. We can meet in the secret spot.", MGMIText, @"6:00 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No thanks, I think we should meet at my house.", MGMIText, @"6:01 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Would you like to come for dinner?", MGMIText, @"6:01 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"I'd love, but my girl needs me more.", MGMIText, @"6:02 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Well why not make it a double date? I bring my wife and you bring yours.", MGMIText, @"6:03 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Sure I pick Mucha Pizza. What time should we meet?", MGMIText, @"6:05 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"7PM?", MGMIText, @"6:05 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"That sounds good.", MGMIText, @"6:06 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
	[messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Great, meet you then.", MGMIText, @"6:07 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
	[[SMSView mainFrame] loadHTMLString:@"<div style=\"text-align: center; font-size: 14pt; font-weight: bold;\">Please open a theme to preview it.</div>" baseURL:nil];
	[mainWindow makeKeyAndOrderFront:self];
}
- (IBAction)open:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setResolvesAliases:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setAllowedFileTypes:[NSArray arrayWithObject:@"vmt"]];
	[panel setTreatsFilePackagesAsDirectories:NO];
	int returnCode = [panel runModal];
	if (returnCode==NSOKButton) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[[[panel URL] path] stringByDeletingLastPathComponent] forKey:MGMTCurrentThemePath];
		[defaults setObject:[[[panel URL] path] lastPathComponent] forKey:MGMTCurrentThemeName];
		[defaults setObject:[NSNumber numberWithInt:0] forKey:MGMTCurrentThemeVariant];
		if (themeManager!=nil) [themeManager release];
		NSLog(@"Loading Theme Manager");
		themeManager = [MGMThemeManager new];
		if (themeManager!=nil) {
			NSArray *variants = [[themeManager theme] objectForKey:MGMTVariants];
			[variantsButton removeAllItems];
			for (int i=0; i<[variants count]; i++) {
				[variantsButton addItemWithTitle:[[variants objectAtIndex:i] objectForKey:MGMTName]];
			}
			[self buildHTML];
		} else {
			NSAlert *alert = [[NSAlert new] autorelease];
			[alert setMessageText:@"Error loading theme"];
			[alert setInformativeText:@"For some reason, the Theme Manager was unable to load the theme. For more information, view the console."];
			[alert runModal];
		}
	}
}
- (IBAction)save:(id)sender {
	NSSavePanel *panel = [NSSavePanel savePanel];
	int returnCode = [panel runModal];
	if (returnCode==NSOKButton) {
		[[[[SMSView mainFrame] dataSource] data] writeToURL:[panel URL] atomically:YES];
	}
}

- (void)buildHTML {
	NSLog(@"Building HTML");
	NSMutableDictionary *messageInfo = [NSMutableDictionary dictionary];
	[messageInfo setObject:[lastDatePicker dateValue] forKey:MGMITime];
	[messageInfo setObject:[tNameField stringValue] forKey:MGMTInName];
	[messageInfo setObject:[tNumberField stringValue] forKey:MGMIPhoneNumber];
	[messageInfo setObject:[yNumberField stringValue] forKey:MGMTUserNumber];
	[messageInfo setObject:[IDField stringValue] forKey:MGMIID];
	NSString *yPhotoPath = nil;
	if ([[yPhotoField stringValue] isEqual:@""])
		yPhotoPath = [[themeManager outgoingIconPath] filePath];
	else
		yPhotoPath = [[yPhotoField stringValue] filePath];
	NSString *tPhotoPath = nil;
	if ([[tPhotoField stringValue] isEqual:@""])
		tPhotoPath = [[themeManager incomingIconPath] filePath];
	else
		tPhotoPath = [[tPhotoField stringValue] filePath];
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
	NSString *html = [themeManager buildHTMLWithMessages:messageArray messageInfo:messageInfo];
	[[SMSView mainFrame] loadHTMLString:html baseURL:[NSURL fileURLWithPath:[themeManager currentThemeVariantPath]]];
}
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
	[SMSView stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}

- (IBAction)chooseYPhoto:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setResolvesAliases:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"png", @"jpg", @"tif", @"jpeg", @"tiff", nil]];
	[panel setTreatsFilePackagesAsDirectories:NO];
	int returnCode = [panel runModal];
	if (returnCode==NSOKButton) {
		[yPhotoField setStringValue:[[panel URL] path]];
	}
}
- (IBAction)chooseTPhoto:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setResolvesAliases:YES];
	[panel setAllowsMultipleSelection:NO];
	[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"png", @"jpg", @"tif", @"jpeg", @"tiff", nil]];
	[panel setTreatsFilePackagesAsDirectories:NO];
	int returnCode = [panel runModal];
	if (returnCode==NSOKButton) {
		[tPhotoField setStringValue:[[panel URL] path]];
	}
}

- (IBAction)rebuild:(id)sender {
	if (themeManager!=nil) {
		[themeManager setVariant:[variantsButton titleOfSelectedItem]];
		[self buildHTML];
	}
}
- (void)addMessage:(NSDictionary *)theMessage {
	NSMutableDictionary *messageInfo = [NSMutableDictionary dictionary];
	[messageInfo setObject:[lastDatePicker dateValue] forKey:MGMITime];
	[messageInfo setObject:[tNameField stringValue] forKey:MGMTInName];
	[messageInfo setObject:[tNumberField stringValue] forKey:MGMIPhoneNumber];
	[messageInfo setObject:[yNumberField stringValue] forKey:MGMTUserNumber];
	NSString *yPhotoPath = nil;
	if ([[yPhotoField stringValue] isEqual:@""])
		yPhotoPath = [[themeManager outgoingIconPath] filePath];
	else
		yPhotoPath = [[yPhotoField stringValue] filePath];
	NSString *tPhotoPath = nil;
	if ([[tPhotoField stringValue] isEqual:@""])
		tPhotoPath = [[themeManager incomingIconPath] filePath];
	else
		tPhotoPath = [[tPhotoField stringValue] filePath];
	NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:theMessage];
	[message setObject:[[NSNumber numberWithInt:[messages count]-1] stringValue] forKey:MGMIID];
	int type = 1;
	if ([[message objectForKey:MGMIYou] boolValue]) {
		type = ([[[messages objectAtIndex:[[message objectForKey:MGMIID] intValue]-1] objectForKey:MGMIYou] boolValue] ? 2 : 1);
		NSLog(@"Adding Outgoing %@", (type==1 ? @"Content" : @"Next Content"));
		[message setObject:yPhotoPath forKey:MGMTPhoto];
		[message setObject:NSFullUserName() forKey:MGMTName];
		[message setObject:[messageInfo objectForKey:MGMTUserNumber] forKey:MGMIPhoneNumber];
	} else {
		type = ([[[messages objectAtIndex:[[message objectForKey:MGMIID] intValue]-1] objectForKey:MGMIYou] boolValue] ? 3 : 4);
		NSLog(@"Adding Incoming %@", (type==3 ? @"Content" : @"Next Content"));
		[message setObject:tPhotoPath forKey:MGMTPhoto];
		[message setObject:[messageInfo objectForKey:MGMTInName] forKey:MGMTName];
		[message setObject:[messageInfo objectForKey:MGMIPhoneNumber] forKey:MGMIPhoneNumber];
	}
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateFormat:[[themeManager variant] objectForKey:MGMTDate]];
	[SMSView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"newMessage('%@', '%@', '%@', %@, '%@', '%@', '%@', %d);", [[message objectForKey:MGMIText] javascriptEscape], [[message objectForKey:MGMTPhoto] javascriptEscape], [[message objectForKey:MGMITime] javascriptEscape], [message objectForKey:MGMIID], [[message objectForKey:MGMTName] javascriptEscape], [[[message objectForKey:MGMIPhoneNumber] readableNumber] javascriptEscape], [formatter stringFromDate:[messageInfo objectForKey:MGMITime]], type]];
	[SMSView stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}
- (IBAction)incoming:(id)sender {
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateFormat:@"h:mm a"];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[messageField stringValue], MGMIText, [formatter stringFromDate:[lastDatePicker dateValue]], MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil];
	[messages addObject:message];
	if ([[[themeManager variant] objectForKey:MGMTRebuild] boolValue]) {
		[self buildHTML];
	} else {
		[self addMessage:message];
	}
}
- (IBAction)outgoing:(id)sender {
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateFormat:@"h:mm a"];
	NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[messageField stringValue], MGMIText, [formatter stringFromDate:[lastDatePicker dateValue]], MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil];
	[messages addObject:message];
	if ([[[themeManager variant] objectForKey:MGMTRebuild] boolValue]) {
		[self buildHTML];
	} else {
		[self addMessage:message];
	}
}

- (void)errorHandle:(NSNotification *)theNotification {
	[[theNotification object] readInBackgroundAndNotify];
	NSString *string = [[NSString alloc] initWithData:[[theNotification userInfo] objectForKey:NSFileHandleNotificationDataItem] encoding:NSUTF8StringEncoding];
	[errorConsole insertText:string];
	[string release];
}
@end