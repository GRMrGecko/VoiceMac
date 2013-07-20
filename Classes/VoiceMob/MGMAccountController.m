//
//  MGMAccountController.m
//  VoiceMob
//
//  Created by Mr. Gecko on 9/27/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import "MGMAccountController.h"
#import "MGMController.h"
#import "MGMAccounts.h"
#import "MGMGContactUser.h"
#import "MGMVoiceUser.h"
#import "MGMSIPUser.h"
#import "MGMPhotoSelector.h"
#import "MGMVMAddons.h"
#import "MGMAccountSetup.h"
#import "MGMConverter.h"
#import <MGMUsers/MGMUsers.h>
#import <VoiceBase/VoiceBase.h>

NSString * const MGMLastContactsController = @"MGMLastContactsController";

NSString * const MGMAccountsTitle = @"Accounts";
NSString * const MGMBackTitle = @"Back";
NSString * const MGMLogInOut = @"MGMLogInOut";
NSString * const MGMLogin = @"Login";
NSString * const MGMLogout = @"Logout";

@implementation MGMAccountController
- (id)initWithController:(MGMController *)theController {
	if ((self = [super init])) {
		controller = theController;
		
		[self registerDefaults];
		
		contactsControllers = [NSMutableArray new];
		NSArray *lastUsers = [MGMUser lastUsers];
		for (int i=0; i<[lastUsers count]; i++) {
			MGMUser *user = [MGMUser userWithID:[lastUsers objectAtIndex:i]];
			if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
				[contactsControllers addObject:[MGMVoiceUser voiceUser:user accountController:self]];
			}
#if MGMSIPENABLED
			else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
				if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
				[contactsControllers addObject:[MGMSIPUser SIPUser:user accountController:self]];
			}
#endif
		}
		currentContactsController = [[NSUserDefaults standardUserDefaults] integerForKey:MGMLastContactsController];
		badgeValues = [NSMutableDictionary new];
		
		accounts = [[MGMAccounts alloc] initWithAccountController:self];
		shouldRefreshSounds = NO;
		
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(userStarted:) name:MGMUserStartNotification object:nil];
		[notificationCenter addObserver:self selector:@selector(userDone:) name:MGMUserDoneNotification object:nil];		
	}
	return self;
}
- (void)dealloc {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self releaseView];
	[contactsControllers release];
	[badgeValues release];
	[accounts release];
	[accountsItems release];
	[accountItems release];
	[settingsItems release];
	[super dealloc];
}

- (void)registerDefaults {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSNumber numberWithInt:-1] forKey:MGMLastContactsController];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (MGMController *)controller {
	return controller;
}
- (NSArray *)contactsControllers {
	return contactsControllers;
}
- (id<MGMAccountProtocol>)contactControllerWithUser:(MGMUser *)theUser {
	for (int i=0; i<[contactsControllers count]; i++) {
		if ([[[contactsControllers objectAtIndex:i] user] isEqual:theUser])
			return [contactsControllers objectAtIndex:i];
	}
	return nil;
}
- (NSDictionary *)badgeValues {
	return badgeValues;
}
- (int)badgeValueForInstance:(MGMInstance *)theInstance {
	return [[badgeValues objectForKey:[theInstance userNumber]] intValue];
}
- (void)setBadge:(int)theBadge forInstance:(MGMInstance *)theInstance {
	if (![theInstance isLoggedIn]) return;
	if (theBadge==0)
		[badgeValues removeObjectForKey:[theInstance userNumber]];
	else
		[badgeValues setObject:[NSNumber numberWithInt:theBadge] forKey:[theInstance userNumber]];
	NSArray *valueKeys = [badgeValues allKeys];
	int value = 0;
	for (int i=0; i<[valueKeys count]; i++)
		value += [[badgeValues objectForKey:[valueKeys objectAtIndex:i]] intValue];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:value];
	if (currentContactsController==-1)
		[(UITableView *)[accounts view] reloadData];
}
- (UIView *)view {
	if (view==nil) {
		if (![[NSBundle mainBundle] loadNibNamed:[[UIDevice currentDevice] appendDeviceSuffixToString:@"AccountController"] owner:self options:nil]) {
			NSLog(@"Unable to load Account Controller");
		} else {
			accountsItems = [[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings:)] autorelease], [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease], [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAccount:)] autorelease], nil] retain];
			accountItems = [[toolbar items] copy];
			settingsItems = [[NSArray arrayWithObjects:[[[UIBarButtonItem alloc] initWithTitle:MGMBackTitle style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)] autorelease], nil] retain];
			
			if ([contactsControllers count]==0 || currentContactsController==-1) {
				[self setItems:accountsItems animated:NO];
				CGRect viewFrame = [[accounts view] frame];
				viewFrame.size = [contentView frame].size;
				[[accounts view] setFrame:viewFrame];
				[contentView addSubview:[accounts view]];
				[self setTitle:MGMAccountsTitle];
			} else {
				id<MGMAccountProtocol> contactsController = [contactsControllers objectAtIndex:currentContactsController];
				[self setItems:accountItems animated:NO];
				CGRect viewFrame = [[contactsController view] frame];
				viewFrame.size = [contentView frame].size;
				[[contactsController view] setFrame:viewFrame];
				[contentView addSubview:[contactsController view]];
				
				[self setTitle:[contactsController title]];
			}
		}
	}
	return view;
}
- (void)releaseView {
#if releaseDebug
	NSLog(@"%s Releasing", __PRETTY_FUNCTION__);
#endif
	if (currentContactsController!=-1)
		[[contactsControllers objectAtIndex:currentContactsController] releaseView];
	[accounts releaseView];
	[view release];
	view = nil;
	[toolbar release];
	toolbar = nil;
	[phoneButton release];
	phoneButton = nil;
	[contentView release];
	contentView = nil;
	[accountsItems release];
	accountsItems = nil;
	[accountItems release];
	accountItems = nil;
	[settingsItems release];
	settingsItems = nil;
}
- (UIToolbar *)toolbar {
	return toolbar;
}
- (void)setItems:(NSArray *)theItems animated:(BOOL)isAnimated {
	if ([toolbar items]!=theItems)
		[toolbar setItems:theItems animated:isAnimated];
}
- (NSArray *)accountsItems {
	return accountsItems;
}
- (NSArray *)accountItems {
	return accountItems;
}

- (BOOL)isCurrent:(id)theUser {
	return ([contactsControllers indexOfObject:theUser]==currentContactsController);
}
- (void)setTitle:(NSString *)theTitle {
	[phoneButton setTitle:theTitle forState:UIControlStateNormal];
}

- (IBAction)addAccount:(id)sender {
	[controller showAccountSetup];
}

- (IBAction)showAccounts:(id)sender {
	id contactsController = nil;
	if (currentContactsController!=-1) {
		contactsController = [contactsControllers objectAtIndex:currentContactsController];
		currentContactsController = -1;
		[[NSUserDefaults standardUserDefaults] setInteger:currentContactsController forKey:MGMLastContactsController];
	}
	[self setItems:accountsItems animated:YES];
	[self setTitle:MGMAccountsTitle];
	CGRect outViewFrame = [[contactsController view] frame];
	CGRect inViewFrame = [[accounts view] frame];
	inViewFrame.size = outViewFrame.size;
	inViewFrame.origin.x = -inViewFrame.size.width;
	[[accounts view] setFrame:inViewFrame];
	[contentView addSubview:[accounts view]];
	[UIView beginAnimations:nil context:contactsController];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(contactsControllerAnimationDidStop:finished:contactsController:)];
	[[accounts view] setFrame:outViewFrame];
	outViewFrame.origin.x = +outViewFrame.size.width;
	[[contactsController view] setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (IBAction)showSettings:(id)sender {
	settings = [[MGMSettings alloc] initWithDisplayView:contentView delegate:self];
	if (currentContactsController==-1) {
		NSMutableDictionary *settingsDic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"settings.plist"]] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
		NSMutableArray *allSettings = [[[settingsDic objectForKey:MGMSObjectsKey] objectAtIndex:0] objectForKey:MGMSObjectsKey];
		
		NSMutableArray *soundSections = [[[allSettings objectAtIndex:0] objectForKey:MGMSObjectsKey] objectForKey:MGMSObjectsKey];
		NSDictionary *sounds = [[controller themeManager] sounds];
		NSArray *rebuild = [NSArray arrayWithObjects:MGMTSSMSMessage, MGMTSVoicemail, MGMTSSIPRingtone, MGMTSSIPHoldMusic, MGMTSSIPConnected, MGMTSSIPDisconnected, MGMTSSIPSound1, MGMTSSIPSound2, MGMTSSIPSound3, MGMTSSIPSound4, MGMTSSIPSound5, nil];
		for (int i=0; i<[rebuild count]; i++) {
			[[[soundSections objectAtIndex:[self soundSectionForKey:[rebuild objectAtIndex:i]]] objectForKey:MGMSObjectsKey] replaceObjectAtIndex:[self soundSettingRowForKey:[rebuild objectAtIndex:i]] withObject:[self soundMenuWithSounds:sounds key:[rebuild objectAtIndex:i]]];
		}
		
		NSMutableArray *themesArray = [[[[[allSettings objectAtIndex:1] objectForKey:MGMSObjectsKey] objectForKey:MGMSObjectsKey] objectAtIndex:0] objectForKey:MGMSObjectsKey];
		NSMutableArray *themesValue = [NSMutableArray array];
		NSArray *themes = [[controller themeManager] themes];
		for (int i=0; i<[themes count]; i++) {
			[themesValue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[themes objectAtIndex:i] objectForKey:MGMTName], MGMSTitleKey, [[[themes objectAtIndex:i] objectForKey:MGMTThemePath] lastPathComponent], MGMSValueKey, nil]];
		}
		[[themesArray objectAtIndex:0] setObject:themesValue forKey:MGMSValueKey];
		NSDictionary *theme = [[controller themeManager] theme];
		[[themesArray objectAtIndex:2] setObject:[theme objectForKey:MGMTAuthor] forKey:MGMSValueKey];
		[[themesArray objectAtIndex:2] setObject:[theme objectForKey:MGMTSite] forKey:MGMSExtraKey];
		NSArray *fonts = [UIFont familyNames];
		fonts = [fonts sortedArrayUsingSelector:@selector(compare:)];
		NSMutableArray *fontsValue = [NSMutableArray array];
		for (int i=0; i<[fonts count]; i++) {
			NSString *font = [fonts objectAtIndex:i];
			NSArray *fontNames = [UIFont fontNamesForFamilyName:font];
			for (int i=0; i<[fontNames count]; i++) {
				NSString *fontName = [fontNames objectAtIndex:i];
				NSArray *fontComponents = [fontName componentsSeparatedByString:@"-"];
				NSString *name = font;
				if ([fontComponents count]>=2)
					name = [NSString stringWithFormat:@"%@ - %@", name, [fontComponents objectAtIndex:1]];
				[fontsValue addObject:[NSDictionary dictionaryWithObjectsAndKeys:name, MGMSTitleKey, fontName, MGMSValueKey, nil]];
			}
		}
		[[themesArray objectAtIndex:6] setObject:fontsValue forKey:MGMSValueKey];
		NSArray *variants = [theme objectForKey:MGMTVariants];
		NSMutableArray *varientsValue = [NSMutableArray array];
		for (int i=0; i<[variants count]; i++) {
			[varientsValue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[variants objectAtIndex:i] objectForKey:MGMTName], MGMSTitleKey, [NSNumber numberWithInt:i], MGMSValueKey, nil]];
		}
		[[themesArray objectAtIndex:1] setObject:varientsValue forKey:MGMSValueKey];
		
		NSMutableArray *sipSections = [[[allSettings objectAtIndex:2] objectForKey:MGMSObjectsKey] objectForKey:MGMSObjectsKey];
		NSArray *codecs = [[[MGMSIP sharedSIP] codecs] allKeys];
		codecs = [codecs sortedArrayUsingSelector:@selector(compare:)];
		NSMutableArray *codecsValue = [NSMutableArray array];
		for (int i=0; i<[codecs count]; i++) {
			NSString *codec = [codecs objectAtIndex:i];
			[codecsValue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:codec, MGMSTitleKey, codec, MGMSValueKey, nil]];
		}
		[[[[sipSections objectAtIndex:4] objectForKey:MGMSObjectsKey] objectAtIndex:2] setObject:codecsValue forKey:MGMSValueKey];
		
		if (![[[NSUserDefaults standardUserDefaults] objectForKey:MGMSIPBackground] isEqual:MGMSIPBCustom])
			[[[[[[[[[sipSections objectAtIndex:1] objectForKey:MGMSObjectsKey] objectAtIndex:0] objectForKey:MGMSObjectsKey] objectForKey:MGMSObjectsKey] objectAtIndex:0] objectForKey:MGMSObjectsKey] objectAtIndex:1] setObject:[NSNumber numberWithInt:MGMSOCheckMark] forKey:MGMSOptionsKey];
		
		[settings setSections:[MGMSettingSections sectionsWithDictionary:settingsDic target:[NSUserDefaults standardUserDefaults] getter:@selector(objectForKey:) setter:@selector(setObject:forKey:)]];
	} else {
		NSString *settingsFile = nil;
		id<MGMAccountProtocol> account = [contactsControllers objectAtIndex:currentContactsController];
		if ([account isKindOfClass:[MGMVoiceUser class]])
			settingsFile = @"voicesettings.plist";
		else if ([account isKindOfClass:[MGMSIPUser class]])
			settingsFile = @"sipsettings.plist";
		else if ([account isKindOfClass:[MGMGContactUser class]])
			settingsFile = @"gcontactsettings.plist";
		NSMutableDictionary *settingsDic = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:settingsFile]] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
		
		NSMutableArray *objects = [settingsDic objectForKey:MGMSObjectsKey];
		for (int i=0; i<[objects count]; i++) {
			if ([[[[[objects objectAtIndex:i] objectForKey:MGMSObjectsKey] objectAtIndex:0] objectForKey:MGMSKeyKey] isEqual:MGMSContactsSourceKey]) {
				NSMutableDictionary *contacts = [[[objects objectAtIndex:i] objectForKey:MGMSObjectsKey] objectAtIndex:0];
				[contacts removeObjectForKey:MGMSKeyKey];
				NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithObject:MGMSContactsSourceKey forKey:MGMSKeyKey];
				if ([[[account user] settingForKey:MGMSContactsSourceKey] isEqual:NSStringFromClass([MGMAddressBook class])])
					[extra setObject:[[account user] settingForKey:MGMSContactsSourceKey] forKey:MGMSValueKey];
				else
					[extra setObject:[[account user] settingForKey:MGMCGoogleContactsUser] forKey:MGMSValueKey];
				[contacts setValue:extra forKey:MGMSExtraKey];
				
				NSMutableArray *contactSources = [NSMutableArray array];
				[contactSources addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([MGMAddressBook class]), MGMSValueKey, @"Address Book", MGMSTitleKey, nil]];
				NSArray *users = [MGMUser users];
				for (int i=0; i<[users count]; i++) {
					MGMUser *gcUser = [MGMUser userWithID:[users objectAtIndex:i]];
					if ([[gcUser settingForKey:MGMSAccountType] isEqual:MGMSGoogleContacts]) {
						NSMutableDictionary *contactSource = [NSMutableDictionary dictionary];
						[contactSource setObject:[gcUser settingForKey:MGMUserName] forKey:MGMSTitleKey];
						[contactSource setObject:[gcUser settingForKey:MGMUserID] forKey:MGMSValueKey];
						[contactSources addObject:contactSource];
					}
				}
				[contacts setObject:contactSources forKey:MGMSValueKey];
			} else if ([[[[[objects objectAtIndex:i] objectForKey:MGMSObjectsKey] objectAtIndex:0] objectForKey:MGMSKeyKey] isEqual:MGMLogInOut]) {
				NSMutableDictionary *logInOut = [[[objects objectAtIndex:i] objectForKey:MGMSObjectsKey] objectAtIndex:0];
				if ([[account user] isStarted]) {
					[logInOut setObject:MGMLogout forKey:MGMSTitleKey];
				} else {
					[logInOut setObject:MGMLogin forKey:MGMSTitleKey];
				}
			}
		}
		
		[settings setSections:[MGMSettingSections sectionsWithDictionary:settingsDic target:[account user] getter:@selector(settingForKey:) setter:@selector(setSetting:forKey:)]];
	}
	[self setItems:nil animated:YES];
	[self setTitle:[settings title]];
	
	CGRect outViewFrame = [((currentContactsController==-1 || ![(MGMUser *)[[contactsControllers objectAtIndex:currentContactsController] user] isStarted]) ? [accounts view] : [[contactsControllers objectAtIndex:currentContactsController] view]) frame];
	CGRect inViewFrame = [[settings view] frame];
	inViewFrame.size = outViewFrame.size;
	inViewFrame.origin.x = +inViewFrame.size.width;
	[[settings view] setFrame:inViewFrame];
	[contentView addSubview:[settings view]];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showSettingsAnimationDidStop:finished:context:)];
	[[settings view] setFrame:outViewFrame];
	outViewFrame.origin.x = -outViewFrame.size.width;
	[((currentContactsController==-1 || ![(MGMUser *)[[contactsControllers objectAtIndex:currentContactsController] user] isStarted]) ? [accounts view] : [[contactsControllers objectAtIndex:currentContactsController] view]) setFrame:outViewFrame];
	[UIView commitAnimations];
}
- (NSString *)soundTitleForKey:(NSString *)theKey {
	if ([theKey isEqual:MGMTSSMSMessage])
		return @"SMS Message";
	if ([theKey isEqual:MGMTSVoicemail])
		return @"Voicemail";
	if ([theKey isEqual:MGMTSSIPRingtone])
		return @"Ringtone";
	if ([theKey isEqual:MGMTSSIPHoldMusic])
		return @"Hold Music";
	if ([theKey isEqual:MGMTSSIPConnected])
		return @"Connected";
	if ([theKey isEqual:MGMTSSIPDisconnected])
		return @"Disconnected";
	if ([theKey isEqual:MGMTSSIPSound1])
		return @"Sound 1";
	if ([theKey isEqual:MGMTSSIPSound2])
		return @"Sound 2";
	if ([theKey isEqual:MGMTSSIPSound3])
		return @"Sound 3";
	if ([theKey isEqual:MGMTSSIPSound4])
		return @"Sound 4";
	if ([theKey isEqual:MGMTSSIPSound5])
		return @"Sound 5";
	return nil;
}
- (int)soundSectionForKey:(NSString *)theKey {
	if ([theKey isEqual:MGMTSSMSMessage] || [theKey isEqual:MGMTSVoicemail])
		return 0;
	if ([theKey isEqual:MGMTSSIPRingtone] || [theKey isEqual:MGMTSSIPHoldMusic])
		return 1;
	if ([theKey isEqual:MGMTSSIPConnected] || [theKey isEqual:MGMTSSIPDisconnected])
		return 2;
	if ([theKey isEqual:MGMTSSIPSound1] || [theKey isEqual:MGMTSSIPSound2] || [theKey isEqual:MGMTSSIPSound3] || [theKey isEqual:MGMTSSIPSound4] || [theKey isEqual:MGMTSSIPSound5])
		return 3;
	return 0;
}
- (int)soundSettingRowForKey:(NSString *)theKey {
	if ([theKey isEqual:MGMTSSMSMessage])
		return 0;
	if ([theKey isEqual:MGMTSVoicemail])
		return 1;
	if ([theKey isEqual:MGMTSSIPRingtone])
		return 0;
	if ([theKey isEqual:MGMTSSIPHoldMusic])
		return 1;
	if ([theKey isEqual:MGMTSSIPConnected])
		return 0;
	if ([theKey isEqual:MGMTSSIPDisconnected])
		return 1;
	if ([theKey isEqual:MGMTSSIPSound1])
		return 0;
	if ([theKey isEqual:MGMTSSIPSound2])
		return 1;
	if ([theKey isEqual:MGMTSSIPSound3])
		return 2;
	if ([theKey isEqual:MGMTSSIPSound4])
		return 3;
	if ([theKey isEqual:MGMTSSIPSound5])
		return 4;
	return 0;
}
- (NSDictionary *)soundMenuWithSounds:(NSDictionary *)theSounds key:(NSString *)key {
	NSMutableDictionary *mainMenu = [NSMutableDictionary dictionary];
	[mainMenu setObject:[self soundTitleForKey:key] forKey:MGMSTitleKey];
	[mainMenu setObject:[NSNumber numberWithInt:MGMSTitleType] forKey:MGMSTypeKey];
	NSString *soundPath = [[controller themeManager] currentSoundPath:key];
	if ([soundPath isEqual:MGMTNoSound])
		[mainMenu setObject:@"No Sound" forKey:MGMSValueKey];
	NSArray *soundKeys = [theSounds allKeys];
	NSMutableArray *soundsArray = [NSMutableArray array];
	for (int i=0; i<[soundKeys count]; i++) {
		NSArray *sounds = [theSounds objectForKey:[soundKeys objectAtIndex:i]];
		NSMutableDictionary *sound = [NSMutableDictionary dictionary];
		NSMutableDictionary *soundExtra = [NSMutableDictionary dictionary];
		[sound setObject:[soundKeys objectAtIndex:i] forKey:MGMSTitleKey];
		[soundExtra setObject:[[[sounds objectAtIndex:0] objectForKey:MGMTSPath] stringByDeletingLastPathComponent] forKey:MGMTSPath];
		[sound setObject:[NSNumber numberWithInt:MGMSMultiType] forKey:MGMSTypeKey];
		BOOL isCurrent = [[soundPath stringByDeletingLastPathComponent] isEqual:[soundExtra objectForKey:MGMTSPath]];
		if (isCurrent)
			[sound setObject:[MGMTSName stringByAppendingString:key] forKey:MGMSKeyKey];
		else
			[soundExtra setObject:[MGMTSName stringByAppendingString:key] forKey:MGMSKeyKey];
		[sound setObject:soundExtra forKey:MGMSExtraKey];
		if ([[soundKeys objectAtIndex:i] isEqual:@"Unknown"] || [[soundKeys objectAtIndex:i] isEqual:@"User Sounds"])
			[sound setObject:[NSNumber numberWithInt:8] forKey:MGMSOptionsKey];
		else if (![[soundKeys objectAtIndex:i] isEqual:@"System Sounds"] && ![[soundKeys objectAtIndex:i] isEqual:@"VoiceMob"])
			[sound setObject:[NSNumber numberWithInt:4] forKey:MGMSOptionsKey];
		NSMutableArray *soundArray = [NSMutableArray array];
		for (int s=0; s<[sounds count]; s++) {
			if (isCurrent && [[[sounds objectAtIndex:s] objectForKey:MGMTSPath] isEqual:soundPath])
				[mainMenu setObject:[[sounds objectAtIndex:s] objectForKey:MGMTSName] forKey:MGMSValueKey];
			NSMutableDictionary *soundDic = [NSMutableDictionary dictionary];
			[soundDic setObject:[[sounds objectAtIndex:s] objectForKey:MGMTSName] forKey:MGMSTitleKey];
			[soundDic setObject:[[[sounds objectAtIndex:s] objectForKey:MGMTSPath] lastPathComponent] forKey:MGMSValueKey];
			[soundArray addObject:soundDic];
		}
		[sound setObject:soundArray forKey:MGMSValueKey];
		[soundsArray addObject:sound];
	}
	NSDictionary *soundDicionary = [NSDictionary dictionaryWithObject:soundsArray forKey:MGMSObjectsKey];
	NSMutableDictionary *noSoundDic = [NSMutableDictionary dictionary];
	[noSoundDic setObject:@"No Sound" forKey:MGMSTitleKey];
	[noSoundDic setObject:MGMTNoSound forKey:MGMSExtraKey];
	[noSoundDic setObject:[MGMTSName stringByAppendingString:key] forKey:MGMSKeyKey];
	[noSoundDic setObject:[NSNumber numberWithInt:MGMSNullType] forKey:MGMSTypeKey];
	if ([soundPath isEqual:MGMTNoSound])
		[noSoundDic setObject:[NSNumber numberWithInt:MGMSOCheckMark] forKey:MGMSOptionsKey];
	NSDictionary *noSoundDicDicionary = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:noSoundDic] forKey:MGMSObjectsKey];
	NSArray *soundObject = [NSArray arrayWithObjects:soundDicionary, noSoundDicDicionary, nil];
	[mainMenu setObject:[NSDictionary dictionaryWithObjectsAndKeys:[self soundTitleForKey:key], MGMSTitleKey, soundObject, MGMSObjectsKey, nil] forKey:MGMSObjectsKey];
	return mainMenu;
}
- (IBAction)goBack:(id)sender {
	[soundPlayer stop];
	[soundPlayer release];
	soundPlayer = nil;
	if (![settings goBack]) {
		BOOL account = (currentContactsController!=-1 && [(MGMUser *)[[contactsControllers objectAtIndex:currentContactsController] user] isStarted]);
		if (!account)
			[[accountsItems objectAtIndex:0] setEnabled:NO];
		else
			[[accountItems objectAtIndex:0] setEnabled:NO];
		[self setItems:(!account ? accountsItems : accountItems) animated:YES];
		if (!account)
			[self setTitle:MGMAccountsTitle];
		else
			[self setTitle:[[contactsControllers objectAtIndex:currentContactsController] title]];
		CGRect outViewFrame = [[settings view] frame];
		CGRect inViewFrame = [(!account ? [accounts view] : [[contactsControllers objectAtIndex:currentContactsController] view]) frame];
		inViewFrame.size = outViewFrame.size;
		inViewFrame.origin.x = -inViewFrame.size.width;
		[(!account ? [accounts view] : [[contactsControllers objectAtIndex:currentContactsController] view]) setFrame:inViewFrame];
		[contentView addSubview:(!account ? [accounts view] : [[contactsControllers objectAtIndex:currentContactsController] view])];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideSettingsAnimationDidStop:finished:context:)];
		[(!account ? [accounts view] : [[contactsControllers objectAtIndex:currentContactsController] view]) setFrame:outViewFrame];
		outViewFrame.origin.x = +outViewFrame.size.width;
		[[settings view] setFrame:outViewFrame];
		[UIView commitAnimations];
	}
}
- (void)settingsWillTransition {
	[[settingsItems objectAtIndex:0] setEnabled:NO];
}
- (void)settingsDidTransition {
	if ([settings parentTitle]!=nil)
		[[settingsItems objectAtIndex:0] setTitle:[settings parentTitle]];
	else
		[[settingsItems objectAtIndex:0] setTitle:MGMBackTitle];
	[[settingsItems objectAtIndex:0] setEnabled:YES];
	if (shouldRefreshSounds) {
		shouldRefreshSounds = NO;
		NSArray *rebuild = [NSArray arrayWithObjects:MGMTSSMSMessage, MGMTSVoicemail, MGMTSSIPRingtone, MGMTSSIPHoldMusic, MGMTSSIPConnected, MGMTSSIPDisconnected, MGMTSSIPSound1, MGMTSSIPSound2, MGMTSSIPSound3, MGMTSSIPSound4, MGMTSSIPSound5, nil];
		MGMSettingSections *sections = [[settings sections] parent];
		NSDictionary *sounds = [[controller themeManager] sounds];
		for (int i=0; i<[rebuild count]; i++) {
			NSDictionary *setting = [self soundMenuWithSounds:sounds key:[rebuild objectAtIndex:i]];
			MGMSettingSections *settingSections = [MGMSettingSections sectionsWithDictionary:[setting objectForKey:MGMSObjectsKey] target:[NSUserDefaults standardUserDefaults] getter:@selector(objectForKey:) setter:@selector(setObject:forKey:)];
			if ([settings sections]==[(MGMSettings *)[[[sections sectionAtIndex:[self soundSectionForKey:[rebuild objectAtIndex:i]]] settings] objectAtIndex:[self soundSettingRowForKey:[rebuild objectAtIndex:i]]] sections]) {
				[(MGMSetting *)[[[sections sectionAtIndex:[self soundSectionForKey:[rebuild objectAtIndex:i]]] settings] objectAtIndex:[self soundSettingRowForKey:[rebuild objectAtIndex:i]]] setValue:[setting objectForKey:MGMSValueKey]];
				[[settings sections] setSections:[settingSections sections]];
			} else {
				[(MGMSetting *)[[[sections sectionAtIndex:[self soundSectionForKey:[rebuild objectAtIndex:i]]] settings] objectAtIndex:[self soundSettingRowForKey:[rebuild objectAtIndex:i]]] setSections:settingSections];
			}
		}
		[(UITableView *)[settings view] reloadData];
	}
	[self setTitle:[settings title]];
}
- (void)setting:(MGMSetting *)theSetting changedToValue:(id)theValue forKey:(NSString *)theKey {
	if ([theKey isEqual:MGMTCurrentThemeName] || [theKey isEqual:@"MGMTDownloader"]) {
		if ([theKey isEqual:MGMTCurrentThemeName]) {
			int index = 0;
			for (int i=0; i<[[theSetting value] count]; i++) {
				if ([[[[theSetting value] objectAtIndex:i] objectForKey:MGMSValueKey] isEqual:theValue]) {
					index = i;
					break;
				}
			}
			[[controller themeManager] setTheme:[[[controller themeManager] themes] objectAtIndex:index]];
		}
		NSArray *themesArray = [[[settings sections] sectionAtIndex:0] settings];
		NSMutableArray *themesValue = [NSMutableArray array];
		NSArray *themes = [[controller themeManager] themes];
		for (int i=0; i<[themes count]; i++) {
			[themesValue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[themes objectAtIndex:i] objectForKey:MGMTName], MGMSTitleKey, [[[themes objectAtIndex:i] objectForKey:MGMTThemePath] lastPathComponent], MGMSValueKey, nil]];
		}
		[(MGMSetting *)[themesArray objectAtIndex:0] setValue:themesValue];
		NSDictionary *theme = [[controller themeManager] theme];
		[(MGMSetting *)[themesArray objectAtIndex:2] setValue:[theme objectForKey:MGMTAuthor]];
		NSArray *variants = [theme objectForKey:MGMTVariants];
		NSMutableArray *varientsValue = [NSMutableArray array];
		for (int i=0; i<[variants count]; i++) {
			[varientsValue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[variants objectAtIndex:i] objectForKey:MGMTName], MGMSTitleKey, [NSNumber numberWithInt:i], MGMSValueKey, nil]];
		}
		[(MGMSetting *)[themesArray objectAtIndex:1] setValue:varientsValue];
	} else if ([theKey isEqual:MGMTCurrentThemeName] || [theKey isEqual:@"MGMSDownloader"]) {
		NSArray *rebuild = [NSArray arrayWithObjects:MGMTSSMSMessage, MGMTSVoicemail, MGMTSSIPRingtone, MGMTSSIPHoldMusic, MGMTSSIPConnected, MGMTSSIPDisconnected, MGMTSSIPSound1, MGMTSSIPSound2, MGMTSSIPSound3, MGMTSSIPSound4, MGMTSSIPSound5, nil];
		NSDictionary *sounds = [[controller themeManager] sounds];
		for (int i=0; i<[rebuild count]; i++) {
			NSDictionary *setting = [self soundMenuWithSounds:sounds key:[rebuild objectAtIndex:i]];
			MGMSettingSections *settingSections = [MGMSettingSections sectionsWithDictionary:[setting objectForKey:MGMSObjectsKey] target:[NSUserDefaults standardUserDefaults] getter:@selector(objectForKey:) setter:@selector(setObject:forKey:)];
			[(MGMSetting *)[[[[settings sections] sectionAtIndex:[self soundSectionForKey:[rebuild objectAtIndex:i]]] settings] objectAtIndex:[self soundSettingRowForKey:[rebuild objectAtIndex:i]]] setSections:settingSections];
		}
	} else if ([theKey hasPrefix:MGMTSName] || ([[theSetting extra] isKindOfClass:[NSDictionary class]] && [[[theSetting extra] objectForKey:MGMSKeyKey] hasPrefix:MGMTSName])) {
		NSString *key = nil;
		if (theKey!=nil)
			key = theKey;
		else
			key = [[theSetting extra] objectForKey:MGMSKeyKey];
		NSString *path = [[[theSetting extra] objectForKey:MGMTSPath] stringByAppendingPathComponent:theValue];
		NSString *soundName = [key substringFromIndex:[MGMTSName length]];
		[[controller themeManager] setSound:soundName withPath:path];
		[soundPlayer stop];
		[soundPlayer release];
		soundPlayer = nil;
		soundPlayer = [[controller themeManager] playSound:soundName];
		[soundPlayer setDelegate:self];
#if MGMSIPENABLED
		if ([soundName isEqual:MGMTSSIPHoldMusic] || [soundName isEqual:MGMTSSIPSound1] || [soundName isEqual:MGMTSSIPSound2] || [soundName isEqual:MGMTSSIPSound3] || [soundName isEqual:MGMTSSIPSound4] || [soundName isEqual:MGMTSSIPSound5])
			[[MGMConverter alloc] initWithSound:soundName file:path];
#endif
		NSDictionary *soundDic = [self soundMenuWithSounds:[[controller themeManager] sounds] key:soundName];
		[(MGMSetting *)[[[[[settings sections] parent] sectionAtIndex:[self soundSectionForKey:soundName]] settings] objectAtIndex:[self soundSettingRowForKey:soundName]] setValue:[soundDic objectForKey:MGMSValueKey]];
		MGMSettingSections *sections = [MGMSettingSections sectionsWithDictionary:[soundDic objectForKey:MGMSObjectsKey] target:[NSUserDefaults standardUserDefaults] getter:@selector(objectForKey:) setter:@selector(setObject:forKey:)];
		[[settings sections] setSections:[sections sections]];
	} else if ([[theSetting extra] isKindOfClass:[NSDictionary class]] && [[[theSetting extra] objectForKey:MGMSKeyKey] isEqual:MGMSContactsSourceKey]) {
		if ([theValue isEqual:NSStringFromClass([MGMAddressBook class])]) {
			NSString *key = MGMSContactsSourceKey;
			NSMethodSignature *signature = [[theSetting target] methodSignatureForSelector:[theSetting action]];
			if (signature!=nil) {
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
				[invocation setSelector:[theSetting action]];
				[invocation setArgument:&theValue atIndex:2];
				[invocation setArgument:&key atIndex:3];
				[invocation invokeWithTarget:[theSetting target]];
			}
		} else {
			NSString *key = MGMSContactsSourceKey;
			NSString *value = NSStringFromClass([MGMGoogleContacts class]);
			NSMethodSignature *signature = [[theSetting target] methodSignatureForSelector:[theSetting action]];
			if (signature!=nil) {
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
				[invocation setSelector:[theSetting action]];
				[invocation setArgument:&value atIndex:2];
				[invocation setArgument:&key atIndex:3];
				[invocation invokeWithTarget:[theSetting target]];
			}
			key = MGMCGoogleContactsUser;
			signature = [[theSetting target] methodSignatureForSelector:[theSetting action]];
			if (signature!=nil) {
				NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
				[invocation setSelector:[theSetting action]];
				[invocation setArgument:&theValue atIndex:2];
				[invocation setArgument:&key atIndex:3];
				[invocation invokeWithTarget:[theSetting target]];
			}
		}
	} else if ([[theSetting extra] isKindOfClass:[NSDictionary class]] && [[[theSetting extra] objectForKey:MGMSExtraKey] isEqual:@"MGMCustom"]) {
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:MGMSIPBackground] isEqual:MGMSIPBCustom])
			[[[[[settings sections] sectionAtIndex:0] settings] objectAtIndex:1] setOptions:0];
		else
			[[[[[settings sections] sectionAtIndex:0] settings] objectAtIndex:1] setOptions:MGMSOCheckMark];
	}
}
- (void)soundDidFinishPlaying:(MGMSound *)theSound {
	[soundPlayer release];
	soundPlayer = nil;
}
- (void)didSelectSetting:(MGMSetting *)theSetting {
	if ([[theSetting key] isEqual:@"MGMTAuthor"]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[theSetting extra]]];
	} else if ([[theSetting extra] isEqual:MGMTNoSound]) {
		NSString *soundName = [[theSetting key] substringFromIndex:[MGMTSName length]];
		[[controller themeManager] setSound:soundName withPath:MGMTNoSound];
		NSDictionary *soundDic = [self soundMenuWithSounds:[[controller themeManager] sounds] key:soundName];
		[(MGMSetting *)[[[[[settings sections] parent] sectionAtIndex:[self soundSectionForKey:soundName]] settings] objectAtIndex:[self soundSettingRowForKey:soundName]] setValue:[soundDic objectForKey:MGMSValueKey]];
		MGMSettingSections *sections = [MGMSettingSections sectionsWithDictionary:[soundDic objectForKey:MGMSObjectsKey] target:[NSUserDefaults standardUserDefaults] getter:@selector(objectForKey:) setter:@selector(setObject:forKey:)];
		[[settings sections] setSections:[sections sections]];
		[self goBack:self];
	} else if ([[theSetting extra] isEqual:@"MGMDefault"]) {
		[theSetting setOptions:MGMSOCheckMark];
		[[NSUserDefaults standardUserDefaults] setObject:MGMSIPBDefault forKey:MGMSIPBackground];
		[[NSFileManager defaultManager] removeItemAtPath:[[MGMUser applicationSupportPath] stringByAppendingPathComponent:MGMPSBackground]];
		[self goBack:self];
	} else if ([[theSetting key] isEqual:MGMLogInOut]) {
		id<MGMAccountProtocol> account = [[[contactsControllers objectAtIndex:currentContactsController] retain] autorelease];
		MGMUser *user = [account user];
		[contactsControllers removeObjectAtIndex:currentContactsController];
		if ([user isStarted]) {
			[user done];
			[theSetting setTitle:MGMLogin];
			id contactsController = nil;
			if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
				contactsController = [MGMVoiceUser voiceUser:user accountController:self];
				[contactsControllers addObject:contactsController];
			} else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleContacts]) {
				contactsController = [MGMGContactUser gContactUser:user accountController:self];
				[contactsControllers addObject:contactsController];
			}
#if MGMSIPENABLED
			else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
				if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
				contactsController = [MGMSIPUser SIPUser:user accountController:self];
				[contactsControllers addObject:contactsController];
			}
#endif
		} else {
			[user start];
			[theSetting setTitle:MGMLogout];
		}
		currentContactsController = [contactsControllers count]-1;
		[(UITableView *)[settings view] reloadData];
	}
}
- (void)settingDeleted:(MGMSetting *)theSetting {
	NSString *key = [theSetting key];
	if (key==nil)
		key = [[theSetting extra] objectForKey:MGMSKeyKey];
	NSString *path = [[theSetting extra] objectForKey:MGMTSPath];
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	
	NSArray *rebuild = [NSArray arrayWithObjects:MGMTSSMSMessage, MGMTSVoicemail, MGMTSSIPRingtone, MGMTSSIPHoldMusic, MGMTSSIPConnected, MGMTSSIPDisconnected, MGMTSSIPSound1, MGMTSSIPSound2, MGMTSSIPSound3, MGMTSSIPSound4, MGMTSSIPSound5, nil];
	MGMSettingSections *sections = [[settings sections] parent];
	NSDictionary *sounds = [[controller themeManager] sounds];
	for (int i=0; i<[rebuild count]; i++) {
		NSDictionary *setting = [self soundMenuWithSounds:sounds key:[rebuild objectAtIndex:i]];
		MGMSettingSections *settingSections = [MGMSettingSections sectionsWithDictionary:[setting objectForKey:MGMSObjectsKey] target:[NSUserDefaults standardUserDefaults] getter:@selector(objectForKey:) setter:@selector(setObject:forKey:)];
		if ([[MGMTSName stringByAppendingString:[rebuild objectAtIndex:i]] isEqual:key]) {
			NSString *soundName = [[theSetting key] substringFromIndex:[MGMTSName length]];
			[(MGMSetting *)[[[[[settings sections] parent] sectionAtIndex:[self soundSectionForKey:soundName]] settings] objectAtIndex:[self soundSettingRowForKey:soundName]] setValue:[setting objectForKey:MGMSValueKey]];
			[[settings sections] setSections:[settingSections sections]];
		} else {
			[(MGMSetting *)[[[sections sectionAtIndex:[self soundSectionForKey:[rebuild objectAtIndex:i]]] settings] objectAtIndex:[self soundSettingRowForKey:[rebuild objectAtIndex:i]]] setSections:settingSections];
		}
	}
}
- (void)settingDeleted:(MGMSetting *)theSetting value:(id)theValue {
	if ([[theSetting key] isEqual:MGMTCurrentThemeName]) {
		int index = 0;
		for (int i=0; i<[[theSetting value] count]; i++) {
			if ([[[[theSetting value] objectAtIndex:i] objectForKey:MGMSValueKey] isEqual:theValue]) {
				index = i;
				break;
			}
		}
		NSString *path = [[[[controller themeManager] themes] objectAtIndex:index] objectForKey:MGMTThemePath];
		if ([path rangeOfString:[[NSBundle mainBundle] resourcePath]].location!=NSNotFound) {
			UIAlertView *alert = [[UIAlertView new] autorelease];
			[alert setTitle:@"Error Deleting"];
			[alert setMessage:@"You cannot delete a built in theme."];
			[alert addButtonWithTitle:MGMOkButtonTitle];
			[alert show];
		} else if ([([[theSetting extra] isKindOfClass:[NSDictionary class]] ? [[theSetting extra] objectForKey:MGMSValueKey] : [theSetting extra]) isEqual:theValue]) {
			UIAlertView *alert = [[UIAlertView new] autorelease];
			[alert setTitle:@"Error Deleting"];
			[alert setMessage:@"You cannot delete the current theme."];
			[alert addButtonWithTitle:MGMOkButtonTitle];
			[alert show];
		} else {
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
			NSMutableArray *themesValue = [NSMutableArray array];
			NSArray *themes = [[controller themeManager] themes];
			for (int i=0; i<[themes count]; i++) {
				[themesValue addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[themes objectAtIndex:i] objectForKey:MGMTName], MGMSTitleKey, [[[themes objectAtIndex:i] objectForKey:MGMTThemePath] lastPathComponent], MGMSValueKey, nil]];
			}
			[theSetting setValue:themesValue];
		}
	} else {
		NSString *key = [theSetting key];
		if (key==nil)
			key = [[theSetting extra] objectForKey:MGMSKeyKey];
		NSString *path = [[[theSetting extra] objectForKey:MGMTSPath] stringByAppendingPathComponent:theValue];
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		if ([[theSetting value] count]==1) {
			[self goBack:self];
			shouldRefreshSounds = YES;
		} else {
			NSArray *rebuild = [NSArray arrayWithObjects:MGMTSSMSMessage, MGMTSVoicemail, MGMTSSIPRingtone, MGMTSSIPHoldMusic, MGMTSSIPConnected, MGMTSSIPDisconnected, MGMTSSIPSound1, MGMTSSIPSound2, MGMTSSIPSound3, MGMTSSIPSound4, MGMTSSIPSound5, nil];
			MGMSettingSections *sections = [[settings sections] parent];
			NSDictionary *sounds = [[controller themeManager] sounds];
			for (int i=0; i<[rebuild count]; i++) {
				NSDictionary *setting = [self soundMenuWithSounds:sounds key:[rebuild objectAtIndex:i]];
				MGMSettingSections *settingSections = [MGMSettingSections sectionsWithDictionary:[setting objectForKey:MGMSObjectsKey] target:[NSUserDefaults standardUserDefaults] getter:@selector(objectForKey:) setter:@selector(setObject:forKey:)];
				if ([[MGMTSName stringByAppendingString:[rebuild objectAtIndex:i]] isEqual:key]) {
					NSString *soundName = [[theSetting key] substringFromIndex:[MGMTSName length]];
					[(MGMSetting *)[[[[[settings sections] parent] sectionAtIndex:[self soundSectionForKey:soundName]] settings] objectAtIndex:[self soundSettingRowForKey:soundName]] setValue:[setting objectForKey:MGMSValueKey]];
					[theSetting setValue:[[[[settingSections sectionAtIndex:0] settings] objectAtIndex:[[[[settings sections] sectionAtIndex:0] settings] indexOfObject:theSetting]] value]];
				} else {
					[(MGMSetting *)[[[sections sectionAtIndex:[self soundSectionForKey:[rebuild objectAtIndex:i]]] settings] objectAtIndex:[self soundSettingRowForKey:[rebuild objectAtIndex:i]]] setSections:settingSections];
				}
			}
		}
	}
}
- (void)showSettingsAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([settings parentTitle]!=nil)
		[[settingsItems objectAtIndex:0] setTitle:[settings parentTitle]];
	else
		[[settingsItems objectAtIndex:0] setTitle:MGMBackTitle];
	[self setItems:settingsItems animated:YES];
	[((currentContactsController==-1 || ![(MGMUser *)[[contactsControllers objectAtIndex:currentContactsController] user] isStarted]) ? [accounts view] : [[contactsControllers objectAtIndex:currentContactsController] view]) removeFromSuperview];
	[((currentContactsController==-1 || ![(MGMUser *)[[contactsControllers objectAtIndex:currentContactsController] user] isStarted]) ? accounts : [contactsControllers objectAtIndex:currentContactsController]) releaseView];
}
- (void)hideSettingsAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[[settings view] removeFromSuperview];
	[settings release];
	settings = nil;
	if (currentContactsController==-1 || ![(MGMUser *)[[contactsControllers objectAtIndex:currentContactsController] user] isStarted]) {
		if (currentContactsController!=-1) {
			[contactsControllers removeObjectAtIndex:currentContactsController];
			currentContactsController = -1;
			[[NSUserDefaults standardUserDefaults] setInteger:currentContactsController forKey:MGMLastContactsController];
		}
		[[NSUserDefaults standardUserDefaults] synchronize];
		[[accountsItems objectAtIndex:0] setEnabled:YES];
	} else {
		[[accountItems objectAtIndex:0] setEnabled:YES];
	}
}

- (void)userStarted:(NSNotification *)theNotification {
	MGMUser *user = [theNotification object];
	if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
		[contactsControllers addObject:[MGMVoiceUser voiceUser:user accountController:self]];
	}
#if MGMSIPENABLED
	else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
		if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
		[contactsControllers addObject:[MGMSIPUser SIPUser:user accountController:self]];
	}
#endif
}
- (void)userDone:(NSNotification *)theNotification {
	for (int i=0; i<[contactsControllers count]; i++) {
		id<MGMAccountProtocol> account = [contactsControllers objectAtIndex:i];
		if ([[account user] isEqual:[theNotification object]]) {
			if (currentContactsController==i) {
				currentContactsController = -1;
				[[NSUserDefaults standardUserDefaults] setInteger:currentContactsController forKey:MGMLastContactsController];
			} else {
				[contactsControllers removeObject:account];
			}
			break;
		}
	}
}

- (void)showUser:(MGMUser *)theUser {
	id contactsController = nil;
	for (int i=0; i<[contactsControllers count]; i++) {
		if ([[[contactsControllers objectAtIndex:i] user] isEqual:theUser]) {
			contactsController = [contactsControllers objectAtIndex:i];
			break;
		}
	}
	if (contactsController==nil) {
		if ([[theUser settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
			contactsController = [MGMVoiceUser voiceUser:theUser accountController:self];
			[contactsControllers addObject:contactsController];
		} else if ([[theUser settingForKey:MGMSAccountType] isEqual:MGMSGoogleContacts]) {
			contactsController = [MGMGContactUser gContactUser:theUser accountController:self];
			[contactsControllers addObject:contactsController];
		}
#if MGMSIPENABLED
		else if ([[theUser settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
			NSLog(@"Hello");
			if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
			contactsController = [MGMSIPUser SIPUser:theUser accountController:self];
			[contactsControllers addObject:contactsController];
		}
#endif
	}
	if (contactsController==nil)
		return;
	currentContactsController = [contactsControllers indexOfObject:contactsController];
	if (![theUser isStarted]) {
		[self showSettings:self];
	} else if ([contactsController view]!=nil) {
		[[NSUserDefaults standardUserDefaults] setInteger:currentContactsController forKey:MGMLastContactsController];
		
		[self setItems:nil animated:YES];
		[self setTitle:[contactsController title]];
		
		CGRect outViewFrame = [[accounts view] frame];
		CGRect inViewFrame = [[contactsController view] frame];
		inViewFrame.size = outViewFrame.size;
		inViewFrame.origin.x = +inViewFrame.size.width;
		[[contactsController view] setFrame:inViewFrame];
		[contentView addSubview:[contactsController view]];
		[UIView beginAnimations:nil context:accounts];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(contactsControllerAnimationDidStop:finished:contactsController:)];
		[[contactsController view] setFrame:outViewFrame];
		outViewFrame.origin.x = -outViewFrame.size.width;
		[[accounts view] setFrame:outViewFrame];
		[UIView commitAnimations];
	}
}
- (void)contactsControllerAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished contactsController:(id<MGMAccountProtocol>)theContactsController {
	[[theContactsController view] removeFromSuperview];
	[theContactsController releaseView];
	if ([theContactsController isKindOfClass:[MGMAccounts class]]) {
		[self setItems:accountItems animated:YES];
	}
}

- (IBAction)phone:(id)sender {
	if (currentContactsController!=-1) {
		id contactsController = [contactsControllers objectAtIndex:currentContactsController];
		if (![[phoneButton titleForState:UIControlStateNormal] isEqual:[contactsController title]] && [[phoneButton titleForState:UIControlStateNormal] isPhone])
			[contactsController showOptionsForNumber:[[phoneButton titleForState:UIControlStateNormal] phoneFormatWithAreaCode:[contactsController areaCode]]];
	}
}
@end