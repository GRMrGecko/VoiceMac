//
//  MGMThemeManager.m
//  VoiceBase
//
//  Created by Mr. Gecko on 8/23/10.
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

#import "MGMThemeManager.h"
#import "MGMInbox.h"
#import "MGMAddons.h"
#import "MGMSound.h"
#import <MGMUsers/MGMUsers.h>

NSString * const MGMTThemeChangedNotification = @"MGMTThemeChangedNotification";
NSString * const MGMTUpdatedSMSThemeNotification = @"MGMTUpdatedSMSThemeNotification";

NSString * const MGMTThemeFolder = @"SMS Themes";
NSString * const MGMTDefaultTheme = @"default.vmt";
NSString * const MGMTCurrentThemeName = @"MGMTCurrentThemeName";
NSString * const MGMTCurrentThemePath = @"MGMTCurrentThemePath";
NSString * const MGMTCurrentThemeVariant = @"MGMTCurrentThemeVariant";
NSString * const MGMTShowHeader = @"MGMTShowHeader";
NSString * const MGMTShowFooter = @"MGMTShowFooter";
NSString * const MGMTInfoPlist = @"Info.plist";

NSString * const MGMTPResource = @"%RESOURCE%";
NSString * const MGMTPThemes = @"%THEMES%";
NSString * const MGMTPSounds = @"%SOUNDS%";

NSString * const MGMTThemePath = @"themePath";
NSString * const MGMTVariantFolder = @"variantFolder";
NSString * const MGMTVariants = @"variants";
NSString * const MGMTSounds = @"sounds";
NSString * const MGMTName = @"name";
NSString * const MGMTFolder = @"folder";
NSString * const MGMTFile = @"file";
NSString * const MGMTRebuild = @"rebuild";
NSString * const MGMTIncomingIcon = @"incomingIcon";
NSString * const MGMTOutgoingIcon = @"outgoingIcon";
NSString * const MGMTDate = @"date";
NSString * const MGMTAuthor = @"author";
NSString * const MGMTSite = @"site";

NSString * const MGMTThemeHeaderName = @"themeHeader.html";
NSString * const MGMTThemeFooterName = @"themeFooter.html";
NSString * const MGMTHeaderName = @"header.html";
NSString * const MGMTFooterName = @"footer.html";
NSString * const MGMTIncomingFolder = @"incoming";
NSString * const MGMTOutgoingFolder = @"outgoing";

NSString * const MGMTContentName = @"content.html";
NSString * const MGMTContextName = @"context.html";
NSString * const MGMTNextContentName = @"nextContent.html";
NSString * const MGMTNextContextName = @"nextContext.html";

NSString * const MGMTUserNumber = @"userNumber";
NSString * const MGMTInName = @"inName";
NSString * const MGMTPhoto = @"photo";

NSString * const MGMTRHeader = @"%HEADER%";
NSString * const MGMTRFooter = @"%FOOTER%";
NSString * const MGMTRResource = @"%RESOURCE%";
NSString * const MGMTRTheme = @"%THEME%";
NSString * const MGMTRThemes = @"%THEMES%";
NSString * const MGMTRUserName = @"%USERNAME%";
NSString * const MGMTRUserNumber = @"%USERNUMBER%";
NSString * const MGMTRInName = @"%INNAME%";
NSString * const MGMTRInNumber = @"%INNUMBER%";
NSString * const MGMTRLastDate = @"%LASTDATE%";
NSString * const MGMTRText = @"%TEXT%";
NSString * const MGMTRPhoto = @"%PHOTO%";
NSString * const MGMTRTime = @"%TIME%";
NSString * const MGMTRID = @"%ID%";
NSString * const MGMTRMessageID = @"%MESSAGEID%";
NSString * const MGMTRName = @"%NAME%";
NSString * const MGMTRNumber = @"%NUMBER%";

NSString * const MGMTSoundChangedNotification = @"MGMTSoundChangedNotification";

NSString * const MGMTCallSoundsFolder = @"CallSounds";
NSString * const MGMTSoundsFolder = @"Sounds";
NSString * const MGMTSDefaultPath = @"/default.vms";
NSString * const MGMTSDefaultSMSMessageName = @"bass.mp3";
NSString * const MGMTSDefaultVoicemailName = @"bells.mp3";
NSString * const MGMTSDefaultSIPRingtoneName = @"ringtone.mp3";
NSString * const MGMTNoSound = @"NoSound";
NSString * const MGMTSFolderName = @"soundFolderName";
NSString * const MGMTSPath = @"soundPath";
NSString * const MGMTSName = @"soundName";
NSString * const MGMTSSMSMessage = @"SMSMessage";
NSString * const MGMTSVoicemail = @"Voicemail";
NSString * const MGMTSSIPRingtone = @"SIPRingtone";
NSString * const MGMTSSIPHoldMusic = @"SIPHoldMusic";
NSString * const MGMTSSIPConnected = @"SIPConnected";
NSString * const MGMTSSIPDisconnected = @"SIPDisconnected";
NSString * const MGMTSSIPSound1 = @"SIPSound1";
NSString * const MGMTSSIPSound2 = @"SIPSound2";
NSString * const MGMTSSIPSound3 = @"SIPSound3";
NSString * const MGMTSSIPSound4 = @"SIPSound4";
NSString * const MGMTSSIPSound5 = @"SIPSound5";

NSString * const MGMTThemeExt = @"vmt";
NSString * const MGMTSoundExt = @"vms";
NSString * const MGMAiffExt = @"aiff";
NSString * const MGMAifExt = @"aif";
NSString * const MGMMP3Ext = @"mp3";
NSString * const MGMWavExt = @"wav";
NSString * const MGMAuExt = @"au";
NSString * const MGMM4AExt = @"m4a";
NSString * const MGMCAFExt = @"caf";

@implementation MGMThemeManager
- (id)init {
	if ((self = [super init])) {
		shouldPostNotification = NO;
		[self registerDefaults];
		if (![self setupCurrentTheme]) {
			[self release];
			self = nil;
		} else {
			shouldPostNotification = YES;
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:MGMTThemeChangedNotification object:nil];
		}
		[self setSound:MGMTSSMSMessage withPath:nil];
		[self setSound:MGMTSVoicemail withPath:nil];
	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[currentTheme release];
	[super dealloc];
}

- (void)registerDefaults {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults setObject:MGMTDefaultTheme forKey:MGMTCurrentThemeName];
	[defaults setObject:MGMTPResource forKey:MGMTCurrentThemePath];
	[defaults setObject:[NSNumber numberWithInt:0] forKey:MGMTCurrentThemeVariant];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:MGMTShowHeader];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:MGMTShowFooter];
	[defaults setObject:[MGMTPResource stringByAppendingString:MGMTSDefaultPath] forKey:[MGMTSPath stringByAppendingString:MGMTSSMSMessage]];
	[defaults setObject:MGMTSDefaultSMSMessageName forKey:[MGMTSName stringByAppendingString:MGMTSSMSMessage]];
	[defaults setObject:[MGMTPResource stringByAppendingString:MGMTSDefaultPath] forKey:[MGMTSPath stringByAppendingString:MGMTSVoicemail]];
	[defaults setObject:MGMTSDefaultVoicemailName forKey:[MGMTSName stringByAppendingString:MGMTSVoicemail]];
	[defaults setObject:[MGMTPResource stringByAppendingString:MGMTSDefaultPath] forKey:[MGMTSPath stringByAppendingString:MGMTSSIPRingtone]];
	[defaults setObject:MGMTSDefaultSIPRingtoneName forKey:[MGMTSName stringByAppendingString:MGMTSSIPRingtone]];
	[defaults setObject:MGMTNoSound forKey:[MGMTSPath stringByAppendingString:MGMTSSIPHoldMusic]];
	[defaults setObject:MGMTNoSound forKey:[MGMTSPath stringByAppendingString:MGMTSSIPConnected]];
	[defaults setObject:MGMTNoSound forKey:[MGMTSPath stringByAppendingString:MGMTSSIPDisconnected]];
	[defaults setObject:MGMTNoSound forKey:[MGMTSPath stringByAppendingString:MGMTSSIPSound1]];
	[defaults setObject:MGMTNoSound forKey:[MGMTSPath stringByAppendingString:MGMTSSIPSound2]];
	[defaults setObject:MGMTNoSound forKey:[MGMTSPath stringByAppendingString:MGMTSSIPSound3]];
	[defaults setObject:MGMTNoSound forKey:[MGMTSPath stringByAppendingString:MGMTSSIPSound4]];
	[defaults setObject:MGMTNoSound forKey:[MGMTSPath stringByAppendingString:MGMTSSIPSound5]];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}
- (NSString *)soundsFolderPath {
	NSString *supportPath = [[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMTSoundsFolder];
	NSFileManager *manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:supportPath])
		[manager createDirectoryAtPath:supportPath withAttributes:nil];
	return supportPath;
}
- (NSDictionary *)sounds {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSMutableDictionary *sounds = [NSMutableDictionary dictionary];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC
	NSMutableArray *systemSounds = [NSMutableArray array];
	NSMutableArray *userSounds = [NSMutableArray array];
#endif
	NSMutableArray *unknownSounds = [NSMutableArray array];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC
	NSString *systemSoundsPath = @"/System/Library/Sounds/";
	NSString *userSoundsPath = [@"~/Library/Sounds/" stringByExpandingTildeInPath];
#endif
	NSArray *allowedExtensions = [NSArray arrayWithObjects:MGMAiffExt, MGMAifExt, MGMMP3Ext, MGMWavExt, MGMAuExt, MGMM4AExt, MGMCAFExt, nil];
	NSArray *checkPaths = [NSArray arrayWithObjects:[self soundsFolderPath], [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MGMTSoundsFolder]
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC
						   , systemSoundsPath, userSoundsPath
#endif
						   , nil];
	for (int i=0; i<[checkPaths count]; i++) {
		NSDirectoryEnumerator *soundFolders = [manager enumeratorAtPath:[checkPaths objectAtIndex:i]];
		NSString *soundName = nil;
		while ((soundName = [soundFolders nextObject])) {
			NSString *path = [[[checkPaths objectAtIndex:i] stringByAppendingPathComponent:soundName] stringByResolvingSymlinksInPath];
			if ([[[soundName pathExtension] lowercaseString] isEqual:MGMTSoundExt]) {
				if (![manager fileExistsAtPath:[path stringByAppendingPathComponent:MGMTInfoPlist]])
					continue;
				NSMutableDictionary *soundsInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:MGMTInfoPlist]];
				NSMutableArray *thisSounds = [NSMutableArray array];
				for (int s=0; s<[[soundsInfo objectForKey:MGMTSounds] count]; s++) {
					NSDictionary *soundInfo = [[soundsInfo objectForKey:MGMTSounds] objectAtIndex:s];
					NSString *soundPath = [path stringByAppendingPathComponent:[soundInfo objectForKey:MGMTFile]];
					if (![allowedExtensions containsObject:[[soundPath pathExtension] lowercaseString]] || ![manager fileExistsAtPath:soundPath] || ![manager isReadableFileAtPath:soundPath])
						continue;
					NSMutableDictionary *sound = [NSMutableDictionary dictionary];
					if ([soundInfo objectForKey:MGMTName]!=nil)
						[sound setObject:[soundInfo objectForKey:MGMTName] forKey:MGMTSName];
					else
						[sound setObject:[[soundPath lastPathComponent] stringByDeletingPathExtension] forKey:MGMTSName];
					[sound setObject:soundPath forKey:MGMTSPath];
					[thisSounds addObject:sound];
				}
				if ([thisSounds count]>0) {
					if ([soundsInfo objectForKey:MGMTName]!=nil)
						[sounds setObject:thisSounds forKey:[soundsInfo objectForKey:MGMTName]];
					else
						[sounds setObject:thisSounds forKey:[soundName stringByDeletingPathExtension]];
				}
			} else if ([allowedExtensions containsObject:[[soundName pathExtension] lowercaseString]] && ![[[[soundName stringByDeletingLastPathComponent] pathExtension] lowercaseString] isEqual:MGMTSoundExt]) {
				NSMutableDictionary *sound = [NSMutableDictionary dictionary];
				[sound setObject:[soundName stringByDeletingPathExtension] forKey:MGMTSName];
				[sound setObject:path forKey:MGMTSPath];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC
				if ([[checkPaths objectAtIndex:i] isEqual:systemSoundsPath] && ![systemSounds containsObject:sound])
					[systemSounds addObject:sound];
				else if ([[checkPaths objectAtIndex:i] isEqual:userSoundsPath] && ![userSounds containsObject:sound])
					[userSounds addObject:sound];
				else if (![[checkPaths objectAtIndex:i] isEqual:systemSoundsPath] && ![[checkPaths objectAtIndex:i] isEqual:userSoundsPath] && ![unknownSounds containsObject:sound])
					[unknownSounds addObject:sound];
#else
				if (![unknownSounds containsObject:sound])
					[unknownSounds addObject:sound];
#endif
			}
		}
	}
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC
	if ([systemSounds count]>0)
		[sounds setObject:systemSounds forKey:@"System Sounds"];
	if ([userSounds count]>0)
		[sounds setObject:userSounds forKey:@"User Sounds"];
	if ([unknownSounds count]>1)
#endif
		[sounds setObject:unknownSounds forKey:@"Unknown"];
	return sounds;
}
- (NSString *)nameOfSound:(NSString *)theSoundName {
	NSString *path = [self currentSoundPath:theSoundName];
	if ([path isEqual:MGMTNoSound])
		return @"No Sound";
	NSString *file = [path lastPathComponent];
	NSString *name = [file stringByDeletingPathExtension];
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:MGMTInfoPlist]]) {
		NSDictionary *soundsInfo = [NSDictionary dictionaryWithContentsOfFile:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:MGMTInfoPlist]];
		for (int s=0; s<[[soundsInfo objectForKey:MGMTSounds] count]; s++) {
			NSDictionary *soundInfo = [[soundsInfo objectForKey:MGMTSounds] objectAtIndex:s];
			if ([[soundInfo objectForKey:MGMTFile] isEqual:file]) {
				if ([soundInfo objectForKey:MGMTName]!=nil)
					name = [soundInfo objectForKey:MGMTName];
				break;
			}
		}
	}
	return name;
}
- (NSString *)currentSoundPath:(NSString *)theSoundName {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [defaults objectForKey:[MGMTSPath stringByAppendingString:theSoundName]];
	if ([path isEqual:MGMTNoSound])
		return path;
	path = [path replace:MGMTPResource with:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MGMTSoundsFolder]];
	path = [path replace:MGMTPSounds with:[self soundsFolderPath]];
	path = [path stringByAppendingPathComponent:[defaults objectForKey:[MGMTSName stringByAppendingString:theSoundName]]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[defaults setObject:MGMTNoSound forKey:[MGMTSPath stringByAppendingString:theSoundName]];
		path = MGMTNoSound;
	}
	return path;
}
- (BOOL)setSound:(NSString *)theSoundName withPath:(NSString *)thePath {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSFileManager *manager = [NSFileManager defaultManager];
	if (thePath==nil) {
		if ([[self currentSoundPath:theSoundName] isEqual:MGMTNoSound])
			return YES;
		if (![manager fileExistsAtPath:[self currentSoundPath:theSoundName]]) {
			NSString *path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MGMTSoundsFolder] stringByAppendingPathComponent:MGMTSDefaultPath];
			if ([theSoundName isEqual:MGMTSSMSMessage])
				path = [path stringByAppendingPathComponent:MGMTSDefaultSMSMessageName];
			else if ([theSoundName isEqual:MGMTSVoicemail])
				path = [path stringByAppendingPathComponent:MGMTSDefaultVoicemailName];
			else if ([theSoundName isEqual:MGMTSSIPRingtone])
				path = [path stringByAppendingPathComponent:MGMTSDefaultSIPRingtoneName];
			else
				path = MGMTNoSound;
			return [self setSound:theSoundName withPath:path];
		}
	} else {
		if ([thePath isEqual:MGMTNoSound]) {
			[defaults setObject:thePath forKey:[MGMTSPath stringByAppendingString:theSoundName]];
			return YES;
		}
		NSArray *allowedExtensions = [NSArray arrayWithObjects:MGMAiffExt, MGMAifExt, MGMMP3Ext, MGMWavExt, MGMAuExt, MGMM4AExt, nil];
		if (![allowedExtensions containsObject:[[thePath pathExtension] lowercaseString]])
			return NO;
		if (![manager fileExistsAtPath:thePath] || ![manager isReadableFileAtPath:thePath])
			return NO;
		[defaults setObject:[thePath lastPathComponent] forKey:[MGMTSName stringByAppendingString:theSoundName]];
		thePath = [thePath stringByDeletingLastPathComponent];
		if ([thePath containsString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MGMTSoundsFolder]])
			thePath = [thePath replace:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MGMTSoundsFolder] with:MGMTPResource];
		else if ([thePath containsString:[self soundsFolderPath]])
			thePath = [thePath replace:[self soundsFolderPath] with:MGMTPSounds];
		[defaults setObject:thePath forKey:[MGMTSPath stringByAppendingString:theSoundName]];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMTSoundChangedNotification object:theSoundName];
	return YES;
}
- (MGMSound *)playSound:(NSString *)theSoundName {
	MGMSound *sound = nil;
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *path = [self currentSoundPath:theSoundName];
	if ([manager fileExistsAtPath:path]) {
		sound = [[MGMSound alloc] initWithContentsOfFile:path];
		[sound setDelegate:self];
		[sound performSelectorOnMainThread:@selector(play) withObject:nil waitUntilDone:NO];
	}
	return sound;
}
- (void)soundDidFinishPlaying:(MGMSound *)theSound {
	[theSound release];
}

- (NSString *)themesFolderPath {
	NSString *supportPath = [[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMTThemeFolder];
	NSFileManager *manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:supportPath])
		[manager createDirectoryAtPath:supportPath withAttributes:nil];
	return supportPath;
}
- (NSString *)currentThemePath {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [defaults objectForKey:MGMTCurrentThemePath];
	path = [path replace:MGMTPResource with:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MGMTThemeFolder]];
	path = [path replace:MGMTPThemes with:[self themesFolderPath]];
	return [path stringByAppendingPathComponent:[defaults objectForKey:MGMTCurrentThemeName]];
}
- (NSString *)currentThemeVariantPath {
	return [[currentTheme objectForKey:MGMTThemePath] stringByAppendingPathComponent:[currentTheme objectForKey:MGMTVariantFolder]];
}
- (BOOL)setupCurrentTheme {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
#if MGMThemeManagerDebug
	NSLog(@"%@ Path: %@", self, [defaults objectForKey:MGMTCurrentThemePath]);
	NSLog(@"%@ Name: %@", self, [defaults objectForKey:MGMTCurrentThemeName]);
#endif
	NSFileManager *manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:[[self currentThemePath] stringByAppendingPathComponent:MGMTInfoPlist]]) {
		if ([[defaults objectForKey:MGMTCurrentThemePath] isEqual:MGMTPResource]) {
			NSLog(@"Error: Theme not found in resource!");
			return NO;
		}
		[defaults setObject:MGMTDefaultTheme forKey:MGMTCurrentThemeName];
		[defaults setObject:MGMTPResource forKey:MGMTCurrentThemePath];
		[defaults setInteger:0 forKey:MGMTCurrentThemeVariant];
		return [self setupCurrentTheme];
	}
	NSMutableDictionary *theme = [NSMutableDictionary dictionaryWithContentsOfFile:[[self currentThemePath] stringByAppendingPathComponent:MGMTInfoPlist]];
	[theme setObject:[self currentThemePath] forKey:MGMTThemePath];
#if MGMThemeManagerDebug
	NSLog(@"%@ Theme Path %@", self, [theme objectForKey:MGMTThemePath]);
#endif
	[defaults synchronize];
	return [self setTheme:theme];
}

- (void)themeChanged:(NSNotification *)theNotification {
	if ([theNotification object]==self) return;
	shouldPostNotification = NO;
	[self setupCurrentTheme];
	shouldPostNotification = YES;
}

- (NSArray *)themes {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSMutableArray *themes = [NSMutableArray array];
	NSArray *checkPaths = [NSArray arrayWithObjects:[self themesFolderPath], [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MGMTThemeFolder], nil];
	for (int i=0; i<[checkPaths count]; i++) {
		NSDirectoryEnumerator *themeFolders = [manager enumeratorAtPath:[checkPaths objectAtIndex:i]];
		NSString *themeFolder = nil;
		while ((themeFolder = [themeFolders nextObject])) {
			if ([[[themeFolder pathExtension] lowercaseString] isEqual:MGMTThemeExt]) {
				NSString *folder = [[[checkPaths objectAtIndex:i] stringByAppendingPathComponent:themeFolder] stringByResolvingSymlinksInPath];
				if (![manager fileExistsAtPath:[folder stringByAppendingPathComponent:MGMTInfoPlist]])
					continue;
				NSMutableDictionary *theme = [NSMutableDictionary dictionaryWithContentsOfFile:[folder stringByAppendingPathComponent:MGMTInfoPlist]];
				if ([[theme objectForKey:MGMTVariants] count]>=1) {
					[theme setObject:folder forKey:MGMTThemePath];
					[themes addObject:theme];
				}
			}
		}
	}
	return themes;
}
- (NSDictionary *)theme {
	return currentTheme;
}
- (BOOL)setTheme:(NSDictionary *)theTheme {
	BOOL isNew = ![[theTheme objectForKey:MGMTThemePath] isEqual:[self currentThemePath]];
	[currentTheme release];
	currentTheme = [theTheme mutableCopy];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (isNew) {
		if ([[currentTheme objectForKey:MGMTThemePath] containsString:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MGMTThemeFolder]])
			[defaults setObject:MGMTPResource forKey:MGMTCurrentThemePath];
		else if ([[currentTheme objectForKey:MGMTThemePath] containsString:[self themesFolderPath]])
			[defaults setObject:MGMTPThemes forKey:MGMTCurrentThemePath];
		else
			[defaults setObject:[[currentTheme objectForKey:MGMTThemePath] stringByDeletingLastPathComponent] forKey:MGMTCurrentThemePath];
		[defaults setObject:[[currentTheme objectForKey:MGMTThemePath] lastPathComponent] forKey:MGMTCurrentThemeName];
#if MGMThemeManagerDebug
		NSLog(@"%@ Path: %@", self, [defaults objectForKey:MGMTCurrentThemePath]);
		NSLog(@"%@ Name: %@", self, [defaults objectForKey:MGMTCurrentThemeName]);
#endif
	}
	if ([[currentTheme objectForKey:MGMTVariants] count]<=0) {
		if ([[defaults objectForKey:MGMTCurrentThemePath] isEqual:MGMTPResource]) {
			NSLog(@"Error: No varients in the resource!");
			return NO;
		}
		NSLog(@"Error: No variants! Trying to go to default.");
		[defaults setObject:MGMTDefaultTheme forKey:MGMTCurrentThemeName];
		[defaults setObject:MGMTPResource forKey:MGMTCurrentThemePath];
		[defaults setInteger:0 forKey:MGMTCurrentThemeVariant];
		return [self setupCurrentTheme];
	} else if ([defaults integerForKey:MGMTCurrentThemeVariant]<[[currentTheme objectForKey:MGMTVariants] count]) {
		NSString *varriant = [[[currentTheme objectForKey:MGMTVariants] objectAtIndex:[defaults integerForKey:MGMTCurrentThemeVariant]] objectForKey:MGMTFolder];
		if (![manager fileExistsAtPath:[[currentTheme objectForKey:MGMTThemePath] stringByAppendingPathComponent:varriant]]) {
			NSLog(@"Error: Varient Folder Is Missing!");
			return NO;
		}
		[currentTheme setObject:varriant forKey:MGMTVariantFolder];
#if MGMThemeManagerDebug
		NSLog(@"%@ Variant Folder is %@", self, [currentTheme objectForKey:MGMTVariantFolder]);	
#endif
	} else {
		NSLog(@"Error: What? We are over the varient count? Reverting to varient 0");
		[defaults setInteger:0 forKey:MGMTCurrentThemeVariant];
		return [self setupCurrentTheme];
	}
	[defaults synchronize];
	if (shouldPostNotification)
		[[NSNotificationCenter defaultCenter] postNotificationName:MGMTThemeChangedNotification object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMTUpdatedSMSThemeNotification object:self];
	return YES;
}
- (NSDictionary *)variant {
	return [[currentTheme objectForKey:MGMTVariants] objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:MGMTCurrentThemeVariant]];
}
- (void)setVariant:(NSString *)theVariant {
	NSArray *variants = [currentTheme objectForKey:MGMTVariants];
	for (int i=0; i<[variants count]; i++) {
		if ([[[variants objectAtIndex:i] objectForKey:MGMTName] isEqual:theVariant]) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			NSFileManager *manager = [NSFileManager defaultManager];
			NSString *varriant = [[variants objectAtIndex:i] objectForKey:MGMTFolder];
			if (![manager fileExistsAtPath:[[currentTheme objectForKey:MGMTThemePath] stringByAppendingPathComponent:varriant]]) {
				NSLog(@"Error: Varient Folder Is Missing!");
				return;
			}
			[currentTheme setObject:varriant forKey:MGMTVariantFolder];
			[defaults setInteger:i forKey:MGMTCurrentThemeVariant];
			break;
		}
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMTThemeChangedNotification object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMTUpdatedSMSThemeNotification object:self];
}

- (BOOL)hasCustomIncomingIcon {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSDictionary *variant = [[currentTheme objectForKey:MGMTVariants] objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:MGMTCurrentThemeVariant]];
	NSString *photoPath = nil;
	if (variant!=nil) {
		if ([variant objectForKey:MGMTIncomingIcon]!=nil && ![[variant objectForKey:MGMTIncomingIcon] isEqual:@""] && [manager fileExistsAtPath:[[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTIncomingIcon]]]) {
			photoPath = [[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTIncomingIcon]];
		} else if ([variant objectForKey:MGMTOutgoingIcon]!=nil && ![[variant objectForKey:MGMTOutgoingIcon] isEqual:@""] && [manager fileExistsAtPath:[[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTOutgoingIcon]]]) {
			photoPath = [[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTOutgoingIcon]];
		}
	}
	return (photoPath!=nil);
}
- (NSString *)incomingIconPath {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSDictionary *variant = [[currentTheme objectForKey:MGMTVariants] objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:MGMTCurrentThemeVariant]];
	NSString *photoPath = nil;
	if (variant!=nil) {
		if ([variant objectForKey:MGMTIncomingIcon]!=nil && ![[variant objectForKey:MGMTIncomingIcon] isEqual:@""] && [manager fileExistsAtPath:[[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTIncomingIcon]]]) {
			photoPath = [[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTIncomingIcon]];
		} else if ([variant objectForKey:MGMTOutgoingIcon]!=nil && ![[variant objectForKey:MGMTOutgoingIcon] isEqual:@""] && [manager fileExistsAtPath:[[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTOutgoingIcon]]]) {
			photoPath = [[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTOutgoingIcon]];
		}
	}
	if (photoPath==nil)
		photoPath = [[NSBundle mainBundle] pathForResource:@"blankicon" ofType:@"png"];
	return photoPath;
}
- (NSString *)outgoingIconPath {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSDictionary *variant = [[currentTheme objectForKey:MGMTVariants] objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:MGMTCurrentThemeVariant]];
	NSString *photoPath = nil;
	if (variant!=nil) {
		if ([variant objectForKey:MGMTOutgoingIcon]!=nil && ![[variant objectForKey:MGMTOutgoingIcon] isEqual:@""] && [manager fileExistsAtPath:[[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTOutgoingIcon]]]) {
			photoPath = [[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTOutgoingIcon]];
		} else if ([variant objectForKey:MGMTIncomingIcon]!=nil && ![[variant objectForKey:MGMTIncomingIcon] isEqual:@""] && [manager fileExistsAtPath:[[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTIncomingIcon]]]) {
			photoPath = [[self currentThemeVariantPath] stringByAppendingPathComponent:[variant objectForKey:MGMTIncomingIcon]];
		}
	}
	if (photoPath==nil)
		photoPath = [[NSBundle mainBundle] pathForResource:@"blankicon" ofType:@"png"];
	return photoPath;
}

- (NSString *)replace:(NSString *)theHTML messageInfo:(NSDictionary *)theMessageInfo {
	NSString *HTML = [theHTML replace:MGMTRResource with:[[[NSBundle mainBundle] resourcePath] filePath]];
	HTML = [HTML replace:MGMTRTheme with:[[self currentThemeVariantPath] filePath]];
	HTML = [HTML replace:MGMTRThemes with:[[currentTheme objectForKey:MGMTThemePath] filePath]];
	HTML = [HTML replace:MGMTRUserName with:NSFullUserName()];
	HTML = [HTML replace:MGMTRUserNumber with:[[theMessageInfo objectForKey:MGMTUserNumber] readableNumber]];
	HTML = [HTML replace:MGMTRInName with:[theMessageInfo objectForKey:MGMTInName]];
	HTML = [HTML replace:MGMTRInNumber with:[[theMessageInfo objectForKey:MGMIPhoneNumber] readableNumber]];
	NSDateFormatter *formatter = [[NSDateFormatter new] autorelease];
	[formatter setDateFormat:[[self variant] objectForKey:MGMTDate]];
	HTML = [HTML replace:MGMTRLastDate with:[formatter stringFromDate:[theMessageInfo objectForKey:MGMITime]]];
	HTML = [HTML replace:MGMTRID with:[theMessageInfo objectForKey:MGMIID]];
	return HTML;
}
- (NSString *)replace:(NSString *)theHTML message:(NSDictionary *)theMessage {
	NSString *HTML = [theHTML replace:MGMTRText with:[theMessage objectForKey:MGMIText]];
	HTML = [HTML replace:MGMTRPhoto with:[theMessage objectForKey:MGMTPhoto]];
	HTML = [HTML replace:MGMTRTime with:[theMessage objectForKey:MGMITime]];
	HTML = [HTML replace:MGMTRMessageID with:[theMessage objectForKey:MGMIID]];
	HTML = [HTML replace:MGMTRName with:[theMessage objectForKey:MGMTName]];
	HTML = [HTML replace:MGMTRNumber with:[[theMessage objectForKey:MGMIPhoneNumber] readableNumber]];
	return HTML;
}
- (NSString *)buildHTMLWithMessages:(NSArray *)theMessages messageInfo:(NSDictionary *)theMessageInfo {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *variantPath = [self currentThemeVariantPath];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSMutableString *html = [NSMutableString string];
	if ([manager fileExistsAtPath:[variantPath stringByAppendingPathComponent:MGMTThemeHeaderName]]) {
#if MGMThemeManagerDebug
		NSLog(@"Loading Theme Header");
#endif
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		NSString *themeHeader = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[variantPath stringByAppendingPathComponent:MGMTThemeHeaderName]] encoding:NSUTF8StringEncoding] autorelease];
		NSMutableString *header = [NSMutableString new];
		if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContextName]]) {
#if MGMThemeManagerDebug
			NSLog(@"Adding Incoming Context");
#endif
			[header appendString:[[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContextName]] encoding:NSUTF8StringEncoding] autorelease]];
		}
		if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContextName]]) {
#if MGMThemeManagerDebug
			NSLog(@"Adding Incoming Next Context");
#endif
			[header appendString:[[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContextName]] encoding:NSUTF8StringEncoding] autorelease]];
		}
		if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContextName]]) {
#if MGMThemeManagerDebug
			NSLog(@"Adding Outgoing Context");
#endif
			[header appendString:[[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContextName]] encoding:NSUTF8StringEncoding] autorelease]];
		}
		if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContextName]]) {
#if MGMThemeManagerDebug
			NSLog(@"Adding Outgoing Next Context");
#endif
			[header appendString:[[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContextName]] encoding:NSUTF8StringEncoding] autorelease]];
		}
		if ([defaults boolForKey:MGMTShowHeader]) {
			if ([manager fileExistsAtPath:[variantPath stringByAppendingPathComponent:MGMTHeaderName]]) {
#if MGMThemeManagerDebug
				NSLog(@"Adding Header");
#endif
				NSString *headerHTML = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[variantPath stringByAppendingPathComponent:MGMTHeaderName]] encoding:NSUTF8StringEncoding];
				[header appendString:[self replace:headerHTML messageInfo:theMessageInfo]];
				[headerHTML release];
			}
		}
		themeHeader = [themeHeader replace:MGMTRHeader with:header];
		themeHeader = [self replace:themeHeader messageInfo:theMessageInfo];
		[header release];
		[html appendString:themeHeader];
		[pool drain];
	}
	NSDictionary *lastMessage = nil;
	for (unsigned int i=0; i<[theMessages count]; i++) {
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		NSDictionary *message = [theMessages objectAtIndex:i];
		NSString *messageHTML = nil;
		if ([[message objectForKey:MGMIYou] boolValue]) {
			if (lastMessage==nil || ![[lastMessage objectForKey:MGMIYou] boolValue]) {
#if MGMThemeManagerDebug
				NSLog(@"Adding Message for Outgoing Content");
#endif
				if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContentName]]) {
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Outgoing Next Content doesn't exist, using Incoming Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Outgoing Next Content doesn't exist, using Outgoing Next Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Outgoing Next Content doesn't exist, using Incoming Next Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else {
					NSLog(@"Error: No HTML FOUND!");
					[pool drain];
					return nil;
				}
			} else {
#if MGMThemeManagerDebug
				NSLog(@"Adding Message for Outgoing Next Content");
#endif
				if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContentName]]) {
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Outgoing Next Content doesn't exist, using Incoming Next Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Outgoing Next Content doesn't exist, using Outgoing Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Outgoing Next Content doesn't exist, using Incoming Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else {
					NSLog(@"Error: No HTML FOUND!");
					[pool drain];
					return nil;
				}
			}
		} else {
			if (lastMessage==nil || [[lastMessage objectForKey:MGMIYou] boolValue]) {
#if MGMThemeManagerDebug
				NSLog(@"Adding Message for Incoming Content");
#endif
				if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContentName]]) {
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Incoming Content doesn't exist, using Outgoing Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Incoming Content doesn't exist, using Incoming Next Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Incoming Content doesn't exist, using Outgoing Next Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else {
					NSLog(@"Error: No HTML FOUND!");
					[pool drain];
					return nil;
				}
			} else {
#if MGMThemeManagerDebug
				NSLog(@"Adding Message for Incoming Next Content");
#endif
				if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContentName]]) {
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTNextContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Incoming Next Content doesn't exist, using Outgoing Next Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTNextContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Incoming Next Content doesn't exist, using Incoming Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTIncomingFolder] stringByAppendingPathComponent:MGMTContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else if ([manager fileExistsAtPath:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContentName]]) {
#if MGMThemeManagerDebug
					NSLog(@"Incoming Next Content doesn't exist, using Outgoing Content.");
#endif
					messageHTML = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[variantPath stringByAppendingPathComponent:MGMTOutgoingFolder] stringByAppendingPathComponent:MGMTContentName]] encoding:NSUTF8StringEncoding] autorelease];
				} else {
					NSLog(@"Error: No HTML FOUND!");
					[pool drain];
					return nil;
				}
			}
		}
		messageHTML = [self replace:messageHTML messageInfo:theMessageInfo];
		messageHTML = [self replace:messageHTML message:message];
		[html appendString:messageHTML];
		lastMessage = message;
		[pool drain];
	}
	if ([manager fileExistsAtPath:[variantPath stringByAppendingPathComponent:MGMTThemeFooterName]]) {
#if MGMThemeManagerDebug
		NSLog(@"Loading Theme Footer");
#endif
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		NSString *themeFooter = [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[variantPath stringByAppendingPathComponent:MGMTThemeFooterName]] encoding:NSUTF8StringEncoding] autorelease];
		NSMutableString *footer = [NSMutableString new];
		if ([defaults boolForKey:MGMTShowFooter]) {
			if ([manager fileExistsAtPath:[variantPath stringByAppendingPathComponent:MGMTFooterName]]) {
#if MGMThemeManagerDebug
				NSLog(@"Adding Footer");
#endif
				NSString *footerHTML = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[variantPath stringByAppendingPathComponent:MGMTFooterName]] encoding:NSUTF8StringEncoding];
				[footer appendString:[self replace:footerHTML messageInfo:theMessageInfo]];
				[footerHTML release];
			}
		}
		themeFooter = [themeFooter replace:MGMTRFooter with:footer];
		themeFooter = [self replace:themeFooter messageInfo:theMessageInfo];
		[footer release];
		[html appendString:themeFooter];
		[pool drain];
	}
	return html;
}
@end