//
//  MGMThemeManager.h
//  VoiceBase
//
//  Created by Mr. Gecko on 8/23/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#define MGMThemeManagerDebug 0

@class MGMSound;

extern NSString * const MGMTThemeChangedNotification;
extern NSString * const MGMTUpdatedSMSThemeNotification;

extern NSString * const MGMTCurrentThemeName;
extern NSString * const MGMTCurrentThemePath;
extern NSString * const MGMTCurrentThemeVariant;
extern NSString * const MGMTShowHeader;
extern NSString * const MGMTShowFooter;
extern NSString * const MGMTInfoPlist;

extern NSString * const MGMTThemePath;
extern NSString * const MGMTVariantFolder;
extern NSString * const MGMTVariants;
extern NSString * const MGMTSounds;
extern NSString * const MGMTName;
extern NSString * const MGMTFolder;
extern NSString * const MGMTFile;
extern NSString * const MGMTRebuild;
extern NSString * const MGMTIncomingIcon;
extern NSString * const MGMTOutgoingIcon;
extern NSString * const MGMTDate;
extern NSString * const MGMTAuthor;
extern NSString * const MGMTSite;

extern NSString * const MGMTUserNumber;
extern NSString * const MGMTInName;
extern NSString * const MGMTInNumber;
extern NSString * const MGMTPhoto;

extern NSString * const MGMTSoundChangedNotification;

extern NSString * const MGMTCallSoundsFolder;
extern NSString * const MGMTSoundsFolder;
extern NSString * const MGMTSDefaultPath;
extern NSString * const MGMTSDefaultSMSMessageName;
extern NSString * const MGMTSDefaultVoicemailName;
extern NSString * const MGMTNoSound;
extern NSString * const MGMTSFolderName;
extern NSString * const MGMTSPath;
extern NSString * const MGMTSName;
extern NSString * const MGMTSSMSMessage;
extern NSString * const MGMTSVoicemail;
extern NSString * const MGMTSSIPRingtone;
extern NSString * const MGMTSSIPHoldMusic;
extern NSString * const MGMTSSIPConnected;
extern NSString * const MGMTSSIPDisconnected;
extern NSString * const MGMTSSIPSound1;
extern NSString * const MGMTSSIPSound2;
extern NSString * const MGMTSSIPSound3;
extern NSString * const MGMTSSIPSound4;
extern NSString * const MGMTSSIPSound5;

extern NSString * const MGMTThemeExt;
extern NSString * const MGMTSoundExt;
extern NSString * const MGMAiffExt;
extern NSString * const MGMAifExt;
extern NSString * const MGMMP3Ext;
extern NSString * const MGMWavExt;
extern NSString * const MGMAuExt;
extern NSString * const MGMM4AExt;
extern NSString * const MGMCAFExt;

@interface MGMThemeManager : NSObject {
	NSMutableDictionary *currentTheme;
	BOOL shouldPostNotification;
}
- (void)registerDefaults;
- (NSString *)soundsFolderPath;
- (NSDictionary *)sounds;
- (NSString *)currentSoundPath:(NSString *)theSoundName;
- (NSString *)nameOfSound:(NSString *)theSoundName;
- (BOOL)setSound:(NSString *)theSoundName withPath:(NSString *)thePath;
- (MGMSound *)playSound:(NSString *)theSoundName;

- (NSString *)themesFolderPath;
- (BOOL)setupCurrentTheme;
- (NSString *)currentThemePath;
- (NSString *)currentThemeVariantPath;

- (NSArray *)themes;
- (NSDictionary *)theme;
- (BOOL)setTheme:(NSDictionary *)theTheme;
- (NSDictionary *)variant;
- (void)setVariant:(NSString *)theVariant;

- (BOOL)hasCustomIncomingIcon;
- (NSString *)incomingIconPath;
- (NSString *)outgoingIconPath;

- (NSString *)replace:(NSString *)theHTML messageInfo:(NSDictionary *)theMessageInfo;
- (NSString *)replace:(NSString *)theHTML message:(NSDictionary *)theMessage;
- (NSString *)buildHTMLWithMessages:(NSArray *)theMessages messageInfo:(NSDictionary *)theMessageInfo;
@end