//
//  MGMSoundsPane.m
//  VoiceMac
//
//  Created by Mr. Gecko on 9/7/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMSoundsPane.h"
#import "MGMSIPWavConverter.h"
#import <VoiceBase/VoiceBase.h>
#import <WebKit/WebKit.h>

NSString * const MGMNoAuthor = @"No Author Found";

@implementation MGMSoundsPane
- (id)initWithPreferences:(MGMPreferences *)thePreferences {
	if ((self = [super initWithPreferences:thePreferences])) {
        if (![NSBundle loadNibNamed:@"SoundsPane" owner:self]) {
            NSLog(@"Unable to load Nib for Sounds Preferences");
            [self release];
            self = nil;
        } else {
			themeManager = [MGMThemeManager new];
			sounds = [[themeManager sounds] copy];
			[self reload:nil];
        }
    }
    return self;
}
- (void)dealloc {
	[self stopSound:self];
	[themeManager release];
	[mainView release];
	[sounds release];
	[browserWindow release];
	[super dealloc];
}
+ (void)setUpToolbarItem:(NSToolbarItem *)theItem {
	[theItem setLabel:[self title]];
    [theItem setPaletteLabel:[theItem label]];
    [theItem setImage:[NSImage imageNamed:@"Sounds"]];
}
+ (NSString *)title {
	return @"Sounds";
}
- (NSView *)preferencesView {
	return mainView;
}


- (void)setMenuForPopUp:(NSPopUpButton *)thePopUp authorButton:(NSButton *)theAuthorButton withCurrentPath:(NSString *)thePath {
	NSArray *soundsKeys = [sounds allKeys];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSMenu *soundsMenu = [[NSMenu new] autorelease];
	NSMenuItem *noSound = [[NSMenuItem new] autorelease];
	[noSound setTitle:@"No Sound"];
	[noSound setTag:-1];
	[noSound setTarget:self];
	[noSound setAction:@selector(selectSound:)];
	[noSound setRepresentedObject:thePopUp];
	[soundsMenu addItem:noSound];
	[soundsMenu addItem:[NSMenuItem separatorItem]];
	NSString *currentMenuName = nil;
	for (int i=0; i<[soundsKeys count]; i++) {
		NSMenuItem *menuItem = [[NSMenuItem new] autorelease];
		[menuItem setTitle:[soundsKeys objectAtIndex:i]];
		[menuItem setTag:i];
		NSMenu *menu = [[NSMenu new] autorelease];
		for (int s=0; s<[[sounds objectForKey:[soundsKeys objectAtIndex:i]] count]; s++) {
			NSMenuItem *menuItem = [[NSMenuItem new] autorelease];
			[menuItem setTitle:[[[sounds objectForKey:[soundsKeys objectAtIndex:i]] objectAtIndex:s] objectForKey:MGMTSName]];
			[menuItem setTag:s];
			[menuItem setTarget:self];
			[menuItem setAction:@selector(selectSound:)];
			[menuItem setRepresentedObject:thePopUp];
			if ([[[[sounds objectForKey:[soundsKeys objectAtIndex:i]] objectAtIndex:s] objectForKey:MGMTSPath] isEqual:thePath]) {
				currentMenuName = [[[sounds objectForKey:[soundsKeys objectAtIndex:i]] objectAtIndex:s] objectForKey:MGMTSName];
				
				BOOL author = NO;
				if ([manager fileExistsAtPath:[[thePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:MGMTInfoPlist]]) {
					NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[[thePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:MGMTInfoPlist]];
					if ([info objectForKey:MGMTAuthor]!=nil) {
						[theAuthorButton setTitle:[info objectForKey:MGMTAuthor]];
						author = YES;
					}
				}
				if (!author)
					[theAuthorButton setTitle:MGMNoAuthor];
				[theAuthorButton setEnabled:author];
			}
			[menu addItem:menuItem];
		}
		[menuItem setSubmenu:menu];
		[soundsMenu addItem:menuItem];
	}
	if (currentMenuName!=nil) {
		[soundsMenu addItem:[NSMenuItem separatorItem]];
		NSMenuItem *selected = [[NSMenuItem new] autorelease];
		[selected setTitle:currentMenuName];
		[soundsMenu addItem:selected];
	}
	[thePopUp setMenu:soundsMenu];
	if (currentMenuName!=nil)
		[thePopUp selectItem:[thePopUp lastItem]];
	else {
		[theAuthorButton setTitle:MGMNoAuthor];
		[theAuthorButton setEnabled:NO];
		[thePopUp selectItemAtIndex:0];
	}
}
- (void)reload:(NSString *)theSound {
	if (theSound==nil || [theSound isEqual:MGMTSSMSMessage])
		[self setMenuForPopUp:SMSMessagePopUp authorButton:SMSMessageAuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSMSMessage]];
	if (theSound==nil || [theSound isEqual:MGMTSVoicemail])
		[self setMenuForPopUp:voicemailPopUp authorButton:voicemailAuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSVoicemail]];
	if (theSound==nil || [theSound isEqual:MGMTSSIPRingtone])
		[self setMenuForPopUp:SIPRingtonePopUp authorButton:SIPRingtoneAuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSIPRingtone]];
	if (theSound==nil || [theSound isEqual:MGMTSSIPHoldMusic])
		[self setMenuForPopUp:SIPHoldMusicPopUp authorButton:SIPHoldMusicAuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSIPHoldMusic]];
	if (theSound==nil || [theSound isEqual:MGMTSSIPConnected])
		[self setMenuForPopUp:SIPConnectedPopUp authorButton:SIPConnectedAuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSIPConnected]];
	if (theSound==nil || [theSound isEqual:MGMTSSIPDisconnected])
		[self setMenuForPopUp:SIPDisconnectedPopUp authorButton:SIPDisconnectedAuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSIPDisconnected]];
	if (theSound==nil || [theSound isEqual:MGMTSSIPSound1])
		[self setMenuForPopUp:SIPSound1PopUp authorButton:SIPSound1AuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSIPSound1]];
	if (theSound==nil || [theSound isEqual:MGMTSSIPSound2])
		[self setMenuForPopUp:SIPSound2PopUp authorButton:SIPSound2AuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSIPSound2]];
	if (theSound==nil || [theSound isEqual:MGMTSSIPSound3])
		[self setMenuForPopUp:SIPSound3PopUp authorButton:SIPSound3AuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSIPSound3]];
	if (theSound==nil || [theSound isEqual:MGMTSSIPSound4])
		[self setMenuForPopUp:SIPSound4PopUp authorButton:SIPSound4AuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSIPSound4]];
	if (theSound==nil || [theSound isEqual:MGMTSSIPSound5])
		[self setMenuForPopUp:SIPSound5PopUp authorButton:SIPSound5AuthorButton withCurrentPath:[themeManager currentSoundPath:MGMTSSIPSound5]];
}
- (IBAction)selectSound:(id)sender {
	NSString *soundName = nil;
	if ([sender representedObject]==SMSMessagePopUp)
		soundName = MGMTSSMSMessage;
	else if ([sender representedObject]==voicemailPopUp)
		soundName = MGMTSVoicemail;
	else if ([sender representedObject]==SIPRingtonePopUp)
		soundName = MGMTSSIPRingtone;
	else if ([sender representedObject]==SIPHoldMusicPopUp)
		soundName = MGMTSSIPHoldMusic;
	else if ([sender representedObject]==SIPConnectedPopUp)
		soundName = MGMTSSIPConnected;
	else if ([sender representedObject]==SIPDisconnectedPopUp)
		soundName = MGMTSSIPDisconnected;
	else if ([sender representedObject]==SIPSound1PopUp)
		soundName = MGMTSSIPSound1;
	else if ([sender representedObject]==SIPSound2PopUp)
		soundName = MGMTSSIPSound2;
	else if ([sender representedObject]==SIPSound3PopUp)
		soundName = MGMTSSIPSound3;
	else if ([sender representedObject]==SIPSound4PopUp)
		soundName = MGMTSSIPSound4;
	else if ([sender representedObject]==SIPSound5PopUp)
		soundName = MGMTSSIPSound5;
	if (soundName==nil) return;
	if ([sender tag]==-1) {
		[themeManager setSound:soundName withPath:MGMTNoSound];
		if ([soundName isEqual:MGMTSSIPHoldMusic] || [soundName isEqual:MGMTSSIPSound1] || [soundName isEqual:MGMTSSIPSound2] || [soundName isEqual:MGMTSSIPSound3] || [soundName isEqual:MGMTSSIPSound4] || [soundName isEqual:MGMTSSIPSound5]) {
			NSFileManager<NSFileManagerProtocol> *manager = [NSFileManager defaultManager];
			NSString *finalPath = [[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MGMTCallSoundsFolder] stringByAppendingPathComponent:soundName] stringByAppendingPathExtension:MGMWavExt];
			if ([manager fileExistsAtPath:finalPath]) {
				if ([manager respondsToSelector:@selector(removeFileAtPath:)])
					[manager removeFileAtPath:finalPath handler:nil];
				else
					[manager removeItemAtPath:finalPath error:nil];
			}		
		}
	} else {
		NSMenuItem *soundsMenuItem = nil;
		NSArray *items = [[sender representedObject] itemArray];
		for (int i=0; i<[items count]; i++) {
			if ([[items objectAtIndex:i] submenu]==[sender menu]) {
				soundsMenuItem = [items objectAtIndex:i];
				break;
			}
		}
		if (soundsMenuItem==nil)
			return;
 		NSDictionary *sound = [[sounds objectForKey:[[sounds allKeys] objectAtIndex:[soundsMenuItem tag]]] objectAtIndex:[sender tag]];
		if (sound!=nil) {
			if (![themeManager setSound:soundName withPath:[sound objectForKey:MGMTSPath]]) {
				NSBeep();
			} else {
				[soundPlayer stop];
				[soundPlayer release];
				soundPlayer = nil;
				soundPlayer = [themeManager playSound:soundName];
				[soundPlayer setDelegate:self];
			}
			if ([soundName isEqual:MGMTSSIPHoldMusic] || [soundName isEqual:MGMTSSIPSound1] || [soundName isEqual:MGMTSSIPSound2] || [soundName isEqual:MGMTSSIPSound3] || [soundName isEqual:MGMTSSIPSound4] || [soundName isEqual:MGMTSSIPSound5])
				[[MGMSIPWavConverter alloc] initWithSoundName:soundName fileConverting:[sound objectForKey:MGMTSPath]];
		}
	}
	[self reload:soundName];
}
- (void)soundDidFinishPlaying:(MGMSound *)theSound {
	[soundPlayer release];
	soundPlayer = nil;
}
- (IBAction)stopSound:(id)sender {
	[soundPlayer stop];
	[soundPlayer release];
	soundPlayer = nil;
}

- (IBAction)authorSite:(id)sender {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *path = nil;
	if (sender==SMSMessageAuthorButton)
		path = [themeManager currentSoundPath:MGMTSSMSMessage];
	else if (sender==voicemailAuthorButton)
		path = [themeManager currentSoundPath:MGMTSVoicemail];
	else if (sender==SIPRingtoneAuthorButton)
		path = [themeManager currentSoundPath:MGMTSSIPRingtone];
	else if (sender==SIPHoldMusicAuthorButton)
		path = [themeManager currentSoundPath:MGMTSSIPHoldMusic];
	else if (sender==SIPConnectedAuthorButton)
		path = [themeManager currentSoundPath:MGMTSSIPConnected];
	else if (sender==SIPDisconnectedAuthorButton)
		path = [themeManager currentSoundPath:MGMTSSIPDisconnected];
	else if (sender==SIPSound1AuthorButton)
		path = [themeManager currentSoundPath:MGMTSSIPSound1];
	else if (sender==SIPSound2AuthorButton)
		path = [themeManager currentSoundPath:MGMTSSIPSound2];
	else if (sender==SIPSound3AuthorButton)
		path = [themeManager currentSoundPath:MGMTSSIPSound3];
	else if (sender==SIPSound4AuthorButton)
		path = [themeManager currentSoundPath:MGMTSSIPSound4];
	else if (sender==SIPSound5AuthorButton)
		path = [themeManager currentSoundPath:MGMTSSIPSound5];
	if ([manager fileExistsAtPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:MGMTInfoPlist]]) {
		NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:MGMTInfoPlist]];
		if ([info objectForKey:MGMTSite]!=nil)
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[info objectForKey:MGMTSite]]];
	}
}
- (IBAction)showBrowser:(id)sender {
	[[browser mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mrgeckosmedia.com/voicemac/sounds/"]]];
	[browserWindow makeKeyAndOrderFront:self];
}
@end