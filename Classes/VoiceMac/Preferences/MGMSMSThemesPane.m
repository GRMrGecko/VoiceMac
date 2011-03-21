//
//  MGMSMSThemesPane.m
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

#import "MGMSMSThemesPane.h"
#import <VoiceBase/VoiceBase.h>
#import <WebKit/WebKit.h>

NSString * const MGMTestTYPhoto = @"yPhoto";
NSString * const MGMTestTTPhoto = @"tPhoto";

@implementation MGMSMSThemesPane
- (id)initWithPreferences:(MGMPreferences *)thePreferences {
	if ((self = [super initWithPreferences:thePreferences])) {
        if (![NSBundle loadNibNamed:@"SMSThemesPane" owner:self]) {
            NSLog(@"Unable to load Nib for SMS Themes Preferences");
            [self release];
            self = nil;
        } else {
			themeManager = [MGMThemeManager new];
			testMessages = [NSMutableArray new];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Hey, you got the message?", MGMIText, @"5:56 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No, can you resend it?", MGMIText, @"5:57 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No, all local copies were destroyed, because we don't want this to get out.", MGMIText, @"5:58 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Oh, yea, right, that thing.", MGMIText, @"5:59 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"I can't send you on SMS because your cell phone company spy's on you.", MGMIText, @"6:00 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"True. We can meet in the secret spot.", MGMIText, @"6:00 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"No thanks, I think we should meet at my house.", MGMIText, @"6:01 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Would you like to come for dinner?", MGMIText, @"6:01 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"I'd love, but my girl needs me more.", MGMIText, @"6:02 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Well why not make it a double date? I bring my wife and you bring yours.", MGMIText, @"6:03 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Sure I pick Mucha Pizza. What time should we meet?", MGMIText, @"6:05 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"7PM?", MGMIText, @"6:05 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"That sounds good.", MGMIText, @"6:06 PM", MGMITime, [NSNumber numberWithBool:YES], MGMIYou, nil]];
			[testMessages addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Great, meet you then.", MGMIText, @"6:07 PM", MGMITime, [NSNumber numberWithBool:NO], MGMIYou, nil]];
			testMessageInfo = [NSMutableDictionary new];
			[testMessageInfo setObject:[NSDate dateWithTimeIntervalSince1970:1598915245] forKey:MGMITime];
			[testMessageInfo setObject:@"Noah Jonson" forKey:MGMTInName];
			[testMessageInfo setObject:@"+15555555555" forKey:MGMIPhoneNumber];
			[testMessageInfo setObject:@"+17204325686" forKey:MGMTUserNumber];
			[testMessageInfo setObject:@"673bd22599231d1a9ba78760f2df085a7237b4b3" forKey:MGMIID];
			[SMSView setResourceLoadDelegate:self];
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			NSFont *font = [NSFont fontWithName:[defaults objectForKey:MGMTFontName] size:[defaults integerForKey:MGMTFontSize]];
			[fontPreview setFont:font];
			[fontPreview setStringValue:[NSString stringWithFormat:@"%@ %d", [font fontName], (int)[font pointSize]]];
			
			[headerButton setState:([defaults boolForKey:MGMTShowHeader] ? NSOnState : NSOffState)];
			[footerButton setState:([defaults boolForKey:MGMTShowFooter] ? NSOnState : NSOffState)];
			[iconsButton setState:([defaults boolForKey:MGMTShowIcons] ? NSOnState : NSOffState)];
			[self reload:self];
        }
    }
    return self;
}
- (void)dealloc {
	[themeManager release];
	[testMessages release];
	[testMessageInfo release];
	[mainView release];
	[browserWindow release];
	[super dealloc];
}
+ (void)setUpToolbarItem:(NSToolbarItem *)theItem {
	[theItem setLabel:[self title]];
    [theItem setPaletteLabel:[theItem label]];
    [theItem setImage:[NSImage imageNamed:@"SMSThemes"]];
}
+ (NSString *)title {
	return @"SMS Themes";
}
- (NSView *)preferencesView {
	return mainView;
}

- (IBAction)reload:(id)sender {
	[testMessageInfo setObject:[[themeManager outgoingIconPath] filePath] forKey:MGMTestTYPhoto];
	[testMessageInfo setObject:[[themeManager incomingIconPath] filePath] forKey:MGMTestTTPhoto];
	[self buildHTML];
	themes = [[themeManager themes] copy];
	[themePopUp removeAllItems];
	for (int i=0; i<[themes count]; i++) {
		[themePopUp addItemWithTitle:[[themes objectAtIndex:i] objectForKey:MGMTName]];
		if ([[[themes objectAtIndex:i] objectForKey:MGMTThemePath] isEqual:[themeManager currentThemePath]])
			[themePopUp selectItemAtIndex:i];
	}
	NSDictionary *theme = [themeManager theme];
	NSArray *variants = [theme objectForKey:MGMTVariants];
	[variantPopUp removeAllItems];
	for (int i=0; i<[variants count]; i++) {
		[variantPopUp addItemWithTitle:[[variants objectAtIndex:i] objectForKey:MGMTName]];
		if ([[[variants objectAtIndex:i] objectForKey:MGMTName] isEqual:[[themeManager variant] objectForKey:MGMTName]])
			[variantPopUp selectItemAtIndex:i];
	}
	[authorButton setTitle:[theme objectForKey:MGMTAuthor]];
}
- (void)buildHTML {
	NSMutableArray *messageArray = [NSMutableArray array];
	for (unsigned int i=0; i<[testMessages count]; i++) {
		NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:[testMessages objectAtIndex:i]];
		[message setObject:[[NSNumber numberWithInt:i] stringValue] forKey:MGMIID];
		if ([[message objectForKey:MGMIYou] boolValue]) {
			[message setObject:[testMessageInfo objectForKey:MGMTestTYPhoto] forKey:MGMTPhoto];
			[message setObject:NSFullUserName() forKey:MGMTName];
			[message setObject:[testMessageInfo objectForKey:MGMTUserNumber] forKey:MGMIPhoneNumber];
		} else {
			[message setObject:[testMessageInfo objectForKey:MGMTestTTPhoto] forKey:MGMTPhoto];
			[message setObject:[testMessageInfo objectForKey:MGMTInName] forKey:MGMTName];
			[message setObject:[testMessageInfo objectForKey:MGMIPhoneNumber] forKey:MGMIPhoneNumber];
		}
		[messageArray addObject:message];
	}
	NSString *html = [themeManager buildHTMLWithMessages:messageArray messageInfo:testMessageInfo];
	[[SMSView mainFrame] loadHTMLString:html baseURL:[NSURL fileURLWithPath:[themeManager currentThemeVariantPath]]];
}
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
	[SMSView stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}

- (IBAction)changeTheme:(id)sender {
	NSDictionary *theme = [themes objectAtIndex:[themePopUp indexOfSelectedItem]];
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MGMTCurrentThemeVariant];
	[themeManager setTheme:theme];
	[self reload:self];
}
- (IBAction)changeVariant:(id)sender {
	[themeManager setVariant:[variantPopUp titleOfSelectedItem]];
	[self reload:self];
}
- (IBAction)authorSite:(id)sender {
	if ([[themeManager theme] objectForKey:MGMTSite]!=nil)
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[themeManager theme] objectForKey:MGMTSite]]];
}
- (IBAction)selectFont:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	
    NSFontPanel *fontPanel = [fontManager fontPanel:YES];
    [fontPanel setDelegate:self];
	[fontPanel setPanelFont:[NSFont fontWithName:[defaults objectForKey:MGMTFontName] size:[defaults integerForKey:MGMTFontSize]] isMultiple:NO];
	[fontPanel makeKeyAndOrderFront:self];
}
- (void)changeFont:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSFont *font = [sender convertFont:[NSFont fontWithName:[defaults objectForKey:MGMTFontName] size:[defaults integerForKey:MGMTFontSize]]];
	[defaults setObject:[font fontName] forKey:MGMTFontName];
	[defaults setInteger:(int)[font pointSize] forKey:MGMTFontSize];
	[fontPreview setFont:font];
	[fontPreview setStringValue:[NSString stringWithFormat:@"%@ %d", [font fontName], (int)[font pointSize]]];
}
- (void)windowWillClose:(NSNotification *)notification {
	[self reload:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMTUpdatedSMSThemeNotification object:self];
}
- (void)windowDidResignKey:(NSNotification *)notification {
	[[notification object] close];
}
- (IBAction)header:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:([headerButton state]==NSOnState) forKey:MGMTShowHeader];
	[self reload:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMTUpdatedSMSThemeNotification object:self];
}
- (IBAction)footer:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:([footerButton state]==NSOnState) forKey:MGMTShowFooter];
	[self reload:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMTUpdatedSMSThemeNotification object:self];
}
- (IBAction)icons:(id)sender {
	[[NSUserDefaults standardUserDefaults] setBool:([iconsButton state]==NSOnState) forKey:MGMTShowIcons];
	[self reload:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMTUpdatedSMSThemeNotification object:self];
}

- (IBAction)showBrowser:(id)sender {
	[[browser mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mrgeckosmedia.com/voicemac/themes/"]]];
	[browserWindow makeKeyAndOrderFront:self];
}
@end