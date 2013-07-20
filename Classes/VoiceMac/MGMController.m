//
//  MGMController.m
//  VoiceMac
//
//  Created by Mr. Gecko on 8/15/10.
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

#import "MGMController.h"
#import "MGMAccountSetup.h"
#import "MGMVoiceUser.h"
#import "MGMSIPUser.h"
#import "MGMSMSManager.h"
#import "MGMSMSMessageView.h"
#import "MGMBadge.h"
#import "MGMMultiSMS.h"
#import "MGMInboxWindow.h"
#import "MGMPhoneFeild.h"
#import "MGMNumberOptions.h"
#import <VoiceBase/VoiceBase.h>
#import <MGMUsers/MGMUsers.h>
#import <GeckoReporter/GeckoReporter.h>
#import <Growl/GrowlApplicationBridge.h>
#import <WebKit/WebKit.h>

NSString * const MGMCopyright = @"Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/";
NSString * const MGMVersion = @"MGMVersion";
NSString * const MGMLaunchCount = @"MGMLaunchCount";

NSString * const MGMMakeDefault = @"MGMMakeDefault";

NSString * const MGMContactsControllersChangedNotification = @"MGMContactsControllersChangedNotification";

NSString * const MGMLoading = @"Loading...";

@implementation MGMController
// MegaEduX was here.
- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setup) name:MGMGRDoneNotification object:nil];
	[MGMReporter sharedReporter];
}
- (void)setup {
	[GrowlApplicationBridge setGrowlDelegate:nil];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:MGMMakeDefault]) {
		NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
		LSSetDefaultHandlerForURLScheme(CFSTR("tel"), (CFStringRef)bundleID);
		LSSetDefaultHandlerForURLScheme(CFSTR("callto"), (CFStringRef)bundleID);
		LSSetDefaultHandlerForURLScheme(CFSTR("telephone"), (CFStringRef)bundleID);
		LSSetDefaultHandlerForURLScheme(CFSTR("phone"), (CFStringRef)bundleID);
		LSSetDefaultHandlerForURLScheme(CFSTR("phonenumber"), (CFStringRef)bundleID);
		LSSetDefaultHandlerForURLScheme(CFSTR("call"), (CFStringRef)bundleID);
		LSSetDefaultHandlerForURLScheme(CFSTR("sms"), (CFStringRef)bundleID);
		
		LSSetDefaultHandlerForURLScheme(CFSTR("vmsound"), (CFStringRef)bundleID);
		LSSetDefaultHandlerForURLScheme(CFSTR("vmtheme"), (CFStringRef)bundleID);
		[defaults removeObjectForKey:MGMMakeDefault];
	}
	
	NSString *appVersion = [[MGMSystemInfo info] applicationVersion];
	if ([defaults objectForKey:MGMVersion]==nil) {
        [defaults setObject:appVersion forKey:MGMVersion];
        [defaults removeObjectForKey:@"actionCall"];
		[defaults removeObjectForKey:@"googleContact"];
		[defaults removeObjectForKey:@"lastPhone"];
		[defaults removeObjectForKey:@"MailSoundPath"];
		[defaults removeObjectForKey:@"MailSoundVariant"];
		[defaults removeObjectForKey:@"NSSplitView Subview Frames SMSSplitView"];
		[defaults removeObjectForKey:@"NSWindow Frame SMSWindow"];
		[defaults removeObjectForKey:@"NSWindow Frame contactsWindow"];
		[defaults removeObjectForKey:@"NSWindow Frame InformationWindow"];
		[defaults removeObjectForKey:@"SMSSoundPath"];
		[defaults removeObjectForKey:@"SMSSoundVariant"];
		[defaults removeObjectForKey:@"SMSThemePath"];
		[defaults removeObjectForKey:@"SMSThemeVariant"];
    }
#if MGMSIPENABLED
	if (![[defaults objectForKey:MGMVersion] isEqual:@"0.3"]) {
		[defaults setObject:appVersion forKey:MGMVersion];
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		NSArray *users = [MGMUser users];
		for (int i=0; i<[users count]; i++) {
			MGMUser *user = [MGMUser userWithID:[users objectAtIndex:i]];
			if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
				if ([user settingForKey:MGMSIPAccountRegistrar]==nil || [[user settingForKey:MGMSIPAccountRegistrar] isEqual:@""])
					[user setSetting:[user settingForKey:MGMSIPAccountDomain] forKey:MGMSIPAccountRegistrar];
			}
		}
		[pool drain];
	}
#endif
	if (![[defaults objectForKey:MGMVersion] isEqual:appVersion]) {
		[defaults setObject:appVersion forKey:MGMVersion];
	}
	[self registerDefaults];
	if ([defaults integerForKey:MGMLaunchCount]!=5) {
		[defaults setInteger:[defaults integerForKey:MGMLaunchCount]+1 forKey:MGMLaunchCount];
		if ([defaults integerForKey:MGMLaunchCount]==5) {
			NSAlert *alert = [[NSAlert new] autorelease];
			[alert setMessageText:@"Donations"];
			[alert setInformativeText:@"Thank you for using VoiceMac. VoiceMac is donation supported software. If you like using it, please consider giving a donation to help with development."];
			[alert addButtonWithTitle:@"Yes"];
			[alert addButtonWithTitle:@"No"];
			int result = [alert runModal];
			if (result==1000)
				[self donate:self];
		}
	}
	
	NSFileManager *manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:[MGMUser cachePath]])
		[manager removeItemAtPath:[MGMUser cachePath]];
	quitting = NO;
	currentContactsController = -1;
	preferences = [MGMPreferences new];
    [preferences addPreferencesPaneClassName:@"MGMAccountsPane"];
    [preferences addPreferencesPaneClassName:@"MGMSoundsPane"];
    [preferences addPreferencesPaneClassName:@"MGMSMSThemesPane"];
#if MGMSIPENABLED
	[preferences addPreferencesPaneClassName:@"MGMSIPPane"];
	
	[[MGMSIP sharedSIP] setDelegate:self];
#endif
	about = [MGMAbout new];
	taskManager = [[MGMTaskManager managerWithDelegate:self] retain];
	connectionManager = [MGMURLConnectionManager new];
	
	themeManager = [MGMThemeManager new];
	SMSManager = [[MGMSMSManager managerWithController:self] retain];
	badge = [MGMBadge new];
	badgeValues = [NSMutableDictionary new];
	
	contactsControllers = [NSMutableArray new];
	NSArray *lastUsers = [MGMUser lastUsers];
	for (int i=0; i<[lastUsers count]; i++) {
		MGMUser *user = [MGMUser userWithID:[lastUsers objectAtIndex:i]];
		if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
			[contactsControllers addObject:[MGMVoiceUser voiceUser:user controller:self]];
		}
#if MGMSIPENABLED
		else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
			if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
			[contactsControllers addObject:[MGMSIPUser SIPUser:user controller:self]];
		}
#endif
	}
	multipleSMS = [NSMutableArray new];
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(userStarted:) name:MGMUserStartNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(userDone:) name:MGMUserDoneNotification object:nil];
	if ([contactsControllers count]==0) {
		if ([[MGMUser userNames] count]==0)
			[[MGMAccountSetup new] showSetupWindow:self]; // This is not a leak, it'll auto release it self when done.
		else
			[self preferences:self];
	} else {
		BOOL windows = NO;
		for (int i=0; i<[contactsControllers count]; i++) {
			if ([[(MGMUser *)[[contactsControllers objectAtIndex:i] user] settingForKey:MGMContactsWindowOpen] boolValue])
				windows = YES;
		}
		if (!windows)
			[contactsControllers makeObjectsPerformSelector:@selector(showContactsWindow)];
	}
	
	[[RLMap mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"map" ofType:@"html"]]]];
	
	NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
	[em setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
	
	[notificationCenter addObserver:self selector:@selector(updateWindowMenu) name:MGMContactsControllersChangedNotification object:nil];
	[notificationCenter postNotificationName:MGMContactsControllersChangedNotification object:self];
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[contactsControllers release];
	[multipleSMS release];
	[preferences release];
	[taskManager release];
	[connectionManager release];
	[themeManager release];
	[SMSManager release];
	[badge release];
	[badgeValues release];
	[about release];
	[RLWindow release];
	[super dealloc];
}

- (void)registerDefaults {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSNumber numberWithInt:1] forKey:MGMLaunchCount];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (BOOL)isQuitting {
	return quitting;
}
- (NSArray *)contactsControllers {
	return contactsControllers;
}
- (MGMPreferences *)preferences {
	return preferences;
}
- (MGMThemeManager *)themeManager {
	return themeManager;
}
- (MGMSMSManager *)SMSManager {
	return SMSManager;
}
- (MGMBadge *)badge {
	return badge;
}
- (void)setBadge:(int)theBadge forInstance:(MGMInstance *)theInstance {
	if (quitting) return;
	if (![theInstance isLoggedIn]) return;
	if (theBadge==0)
		[badgeValues removeObjectForKey:[theInstance userNumber]];
	else
		[badgeValues setObject:[NSNumber numberWithInt:theBadge] forKey:[theInstance userNumber]];
	NSArray *valueKeys = [badgeValues allKeys];
	int value = 0;
	for (int i=0; i<[valueKeys count]; i++)
		value += [[badgeValues objectForKey:[valueKeys objectAtIndex:i]] intValue];
	if (value==0)
		[badge setLabel:nil];
	else
		[badge setLabel:[[NSNumber numberWithInt:value] stringValue]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	SEL menuSelector = [menuItem action];
	if (menuSelector==@selector(showInbox:) || menuSelector==@selector(call:)) {
		return (currentContactsController!=-1);
	} else if (menuSelector==@selector(sms:)) {
		return (currentContactsController!=-1 && [[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(sms:)]);
	} else if (menuSelector==@selector(inboxSpam:)) {
		if (currentContactsController!=-1 && [[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)] && [[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] selectedItem]!=nil) {
			if ([[[[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] selectedItem] objectForKey:MGMISpam] boolValue])
				[menuItem setTitle:@"Unreport for Spam"];
			else
				[menuItem setTitle:@"Report for Spam"];
			return YES;
		} else
			return NO;
	} else if (menuSelector==@selector(inboxMarkRead:)) {
		if (currentContactsController!=-1 && [[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)] && [[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] selectedItem]!=nil) {
			if ([[[[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] selectedItem] objectForKey:MGMIRead] boolValue])
				[menuItem setTitle:@"Mark Unread"];
			else
				[menuItem setTitle:@"Mark Read"];
			return YES;
		} else
			return NO;
	} else if (menuSelector==@selector(refreshInbox:)) {
		return (currentContactsController!=-1 && [[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)] && [[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] inboxWindow]!=nil && [[NSApplication sharedApplication] keyWindow]==[[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] inboxWindow]);
	} else if (menuSelector==@selector(inboxDelete:)) {
		return (currentContactsController!=-1 && [[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)] && [[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] selectedItem]!=nil);
	} else if (menuSelector==@selector(inboxUndelete:)) {
		return (currentContactsController!=-1 && [[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)] && [[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] selectedItem]!=nil && [[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] currentInbox]==3);
	} else if (menuSelector==@selector(saveAudio:)) {
		return (currentContactsController!=-1 && [[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)] && [[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] audioURL]!=nil);
	}
	return YES;
}
- (void)updateWindowMenu {
	if (quitting) return;
	int splitterIndex = 0;
	for (int i=0; i<[windowMenu numberOfItems]; i++) {
		if (splitterIndex!=0) {
			if ([[windowMenu itemAtIndex:i] isSeparatorItem])
				break;
			[windowMenu removeItemAtIndex:i];
			i--;
		}
		if ([[[windowMenu itemAtIndex:i] title] isEqual:@"users"])
			splitterIndex = i;
	}
	for (int i=[contactsControllers count]-1; i>=0; i--) {
		NSMenuItem *item = [[NSMenuItem new] autorelease];
		[item setTitle:[[contactsControllers objectAtIndex:i] menuTitle]];
		if (currentContactsController==i)
			[item setState:NSOnState];
		if (i<10)
			[item setKeyEquivalent:[[NSNumber numberWithInt:i+1] stringValue]];
		[item setTag:i];
		[item setTarget:self];
		[item setAction:@selector(showUserWindow:)];
		[windowMenu insertItem:item atIndex:splitterIndex+1];
	}
}
- (IBAction)showUserWindow:(id)sender {
	if (quitting) return;
	MGMContactsController *contactsController = [contactsControllers objectAtIndex:[sender tag]];
	[contactsController showContactsWindow];
}

- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
	NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
	NSString *scheme = [[url scheme] lowercaseString];
	NSString *data = [url resourceSpecifier];
	/*NSString *queryData = [url query];
	NSDictionary *query;
	if (queryData) {
		NSMutableArray *dataArr = [NSMutableArray arrayWithArray:[data componentsSeparatedByString:@"?"]];
		[dataArr removeLastObject];
		data = [dataArr componentsJoinedByString:@"?"];
		NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
		NSArray *parameters = [queryData componentsSeparatedByString:@"&"];
		for (int i=0; i<[parameters count]; i++) {
			NSArray *info = [[parameters objectAtIndex:i] componentsSeparatedByString:@"="];
			[dataDic setObject:[[[info subarrayWithRange:NSMakeRange(1, [info count]-1)] componentsJoinedByString:@"="] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[[info objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
		query = [NSDictionary dictionaryWithDictionary:dataDic];
	}*/
	if ([data hasPrefix:@"//"])
		data = [data substringFromIndex:2];
	if ([scheme isEqualToString:@"tel"] || [scheme isEqualToString:@"callto"] || [scheme isEqualToString:@"telephone"] || [scheme isEqualToString:@"phone"] || [scheme isEqualToString:@"phonenumber"]) {
		if (currentContactsController==-1)
			return;
		MGMContactsController *contactsController = [contactsControllers objectAtIndex:currentContactsController];
		NSString *phoneNumber = [data phoneFormatWithAreaCode:[contactsController areaCode]];
		[[MGMNumberOptions alloc] initWithContactsController:contactsController controller:self number:phoneNumber]; // This is not a leak as I release it within it self. I just don't want to keep track of it in here.
	} else if ([scheme isEqualToString:@"call"]) {
		if (currentContactsController==-1)
			return;
		MGMContactsController *contactsController = [contactsControllers objectAtIndex:currentContactsController];
		NSString *phoneNumber = [data phoneFormatWithAreaCode:[contactsController areaCode]];
		[contactsController showContactsWindow];
		[[contactsController phoneField] setStringValue:[phoneNumber readableNumber]];
		[self call:self];
	} else if ([scheme isEqualToString:@"sms"]) {
		if (currentContactsController==-1)
			return;
		MGMContactsController *contactsController = [contactsControllers objectAtIndex:currentContactsController];
		if (![contactsController respondsToSelector:@selector(sms:)]) return;
		NSString *phoneNumber = [data phoneFormatWithAreaCode:[contactsController areaCode]];
		[contactsController showContactsWindow];
		[[contactsController phoneField] setStringValue:[phoneNumber readableNumber]];
		[self sms:self];
	} else if ([scheme isEqualToString:@"vmtheme"]) {
		[taskManager addTask:nil withURL:[NSURL URLWithString:[@"http://" stringByAppendingString:data]] cookieStorage:nil];
	} else if ([scheme isEqualToString:@"vmsound"]) {
		[taskManager addTask:nil withURL:[NSURL URLWithString:[@"http://" stringByAppendingString:data]] cookieStorage:nil];
	}
}
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
	[taskManager application:sender openFiles:filenames];
	NSFileManager *manager = [NSFileManager defaultManager];
	for (int i=0; i<[filenames count]; i++) {
		if ([[[[filenames objectAtIndex:i] pathExtension] lowercaseString] isEqualToString:MGMVMTExt])
			[manager moveItemAtPath:[filenames objectAtIndex:i] toPath:[[themeManager themesFolderPath] stringByAppendingPathComponent:[[filenames objectAtIndex:i] lastPathComponent]]];
		else if ([[[[filenames objectAtIndex:i] pathExtension] lowercaseString] isEqualToString:MGMVMSExt])
			[manager moveItemAtPath:[filenames objectAtIndex:i] toPath:[[themeManager soundsFolderPath] stringByAppendingPathComponent:[[filenames objectAtIndex:i] lastPathComponent]]];
	}
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
	if (!flag && currentContactsController!=-1)
		[[contactsControllers objectAtIndex:currentContactsController] showContactsWindow];
	return YES;
}

- (IBAction)about:(id)sender {
	[about show];
}
- (IBAction)showTaskManager:(id)sender {
	[taskManager showTaskManager:sender];
}

- (IBAction)showInbox:(id)sender {
	if (currentContactsController==-1 || ![[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)]) {
		NSBeep();
		return;
	}
	[[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] showWindow:sender];
}
- (IBAction)refreshInbox:(id)sender {
	if (currentContactsController==-1 || ![[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)]) {
		NSBeep();
		return;
	}
	[[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] loadInbox];
}
- (IBAction)inboxSpam:(id)sender {
	if (currentContactsController==-1 || ![[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)]) {
		NSBeep();
		return;
	}
	[[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] spam:sender];
}
- (IBAction)inboxMarkRead:(id)sender {
	if (currentContactsController==-1 || ![[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)]) {
		NSBeep();
		return;
	}
	[[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] markRead:sender];
}
- (IBAction)inboxDelete:(id)sender {
	if (currentContactsController==-1 || ![[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)]) {
		NSBeep();
		return;
	}
	[[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] delete:sender];
}
- (IBAction)inboxUndelete:(id)sender {
	if (currentContactsController==-1 || ![[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)]) {
		NSBeep();
		return;
	}
	[[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] undelete:sender];
}

- (void)userStarted:(NSNotification *)theNotification {
	MGMUser *user = [theNotification object];
	if ([[user settingForKey:MGMSAccountType] isEqual:MGMSGoogleVoice]) {
		[contactsControllers addObject:[MGMVoiceUser voiceUser:user controller:self]];
	}
#if MGMSIPENABLED
	else if ([[user settingForKey:MGMSAccountType] isEqual:MGMSSIP]) {
		if (![[MGMSIP sharedSIP] isStarted]) [[MGMSIP sharedSIP] start];
		[contactsControllers addObject:[MGMSIPUser SIPUser:user controller:self]];
	}
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:MGMContactsControllersChangedNotification object:self];
}
- (void)contactsControllerBecameCurrent:(MGMContactsController *)theContactsController {
	if (quitting) return;
	if ([contactsControllers containsObject:theContactsController])
		currentContactsController = [contactsControllers indexOfObject:theContactsController];
	else
		currentContactsController = [contactsControllers count];
	[self updateWindowMenu];
}
- (void)userDone:(NSNotification *)theNotification {
	for (int i=0; i<[contactsControllers count]; i++) {
		if ([[contactsControllers objectAtIndex:i] isKindOfClass:[MGMVoiceUser class]]) {
			MGMVoiceUser *voiceUser = [contactsControllers objectAtIndex:i];
			if ([[voiceUser user] isEqual:[theNotification object]]) {
				for (unsigned int i=0; i<[multipleSMS count]; i++) {
					if ([[multipleSMS objectAtIndex:i] instance]==[voiceUser instance]) {
						[[[multipleSMS objectAtIndex:i] SMSWindow] close];
						i--;
					}
				}
				for (unsigned int i=0; i<[[SMSManager SMSMessages] count]; i++) {
					if ([[[SMSManager SMSMessages] objectAtIndex:i] instance]==[voiceUser instance]) {
						[SMSManager closeSMSMessage:[[SMSManager SMSMessages] objectAtIndex:i]];
						i--;
					}
				}
				[self setBadge:0 forInstance:[voiceUser instance]];
				
				currentContactsController = -1;
				[contactsControllers removeObject:voiceUser];
				[[NSNotificationCenter defaultCenter] postNotificationName:MGMContactsControllersChangedNotification object:self];
				break;
			}
		}
#if MGMSIPENABLED
		else if ([[contactsControllers objectAtIndex:i] isKindOfClass:[MGMSIPUser class]]) {
			MGMSIPUser *SIPUser = [contactsControllers objectAtIndex:i];
			if ([[SIPUser user] isEqual:[theNotification object]]) {
				currentContactsController = -1;
				[contactsControllers removeObject:SIPUser];
				[[NSNotificationCenter defaultCenter] postNotificationName:MGMContactsControllersChangedNotification object:self];
			}
		}
#endif
	}
}
- (NSString *)currentPhoneNumber {
	NSString *phoneNumber = nil;
	if ([[NSApplication sharedApplication] mainWindow]==[SMSManager SMSWindow])
		phoneNumber = [SMSManager currentPhoneNumber];
	if (phoneNumber==nil && currentContactsController!=-1)
		phoneNumber = [[contactsControllers objectAtIndex:currentContactsController] currentPhoneNumber];
	return phoneNumber;
}

- (IBAction)preferences:(id)sender {
	[preferences showPreferences];
}

- (IBAction)sendMultipleSMS:(id)sender {
	if (currentContactsController==-1 || ![[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(instance)]) {
		NSBeep();
		return;
	}
	[multipleSMS addObject:[MGMMultiSMS SMSWithInstance:[[contactsControllers objectAtIndex:currentContactsController] instance] controller:self]];
}
- (void)removeMultiSMS:(MGMMultiSMS *)theMultiSMS {
	[multipleSMS removeObject:theMultiSMS];
}

- (IBAction)saveAudio:(id)sender {
	if (currentContactsController==-1 || ![[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(inboxWindow)] || [[[contactsControllers objectAtIndex:currentContactsController] inboxWindow] audioURL]==nil) {
		NSBeep();
		return;
	}
	MGMVoiceUser *voiceUser = [contactsControllers objectAtIndex:currentContactsController];
	NSURL *audioURL = [[voiceUser inboxWindow] audioURL];
	NSDictionary *data = [[voiceUser inboxWindow] selectedItem];
	[taskManager saveURL:audioURL withName:[NSString stringWithFormat:@"%@ (%@)", [[voiceUser contacts] nameForNumber:[data objectForKey:MGMIPhoneNumber]], [[data objectForKey:MGMIPhoneNumber] readableNumber]] cookieStorage:[[voiceUser instance] cookieStorage]];
}

- (IBAction)call:(id)sender {
	NSString *phoneNumber = [self currentPhoneNumber];
	if (phoneNumber==nil || currentContactsController==-1) {
		NSBeep();
		return;
	}
	MGMContactsController *contactsController = [contactsControllers objectAtIndex:currentContactsController];
	[contactsController showContactsWindow];
	[[contactsController phoneField] setStringValue:[phoneNumber readableNumber]];
	[contactsController call:sender];
}
- (IBAction)sms:(id)sender {
	NSString *phoneNumber = [self currentPhoneNumber];
	if (phoneNumber==nil || currentContactsController==-1 || ![[contactsControllers objectAtIndex:currentContactsController] respondsToSelector:@selector(sms:)]) {
		NSBeep();
		return;
	}
	MGMVoiceUser *voiceUser = [contactsControllers objectAtIndex:currentContactsController];
	[voiceUser showContactsWindow];
	[[voiceUser phoneField] setStringValue:[phoneNumber readableNumber]];
	[voiceUser sms:sender];
}

- (IBAction)reverseLookup:(id)sender {
	NSString *phoneNumber = [self currentPhoneNumber];
	if (phoneNumber==nil) {
		NSBeep();
		return;
	}
	MGMWhitePagesHandler *handler = [MGMWhitePagesHandler reverseLookup:phoneNumber delegate:self];
	[connectionManager addHandler:handler];
	[RLName setStringValue:MGMLoading];
	[RLAddress setStringValue:MGMLoading];
	[RLCityState setStringValue:MGMLoading];
	[RLZipCode setStringValue:MGMLoading];
	[RLPhoneNumber setStringValue:MGMLoading];
	[RLWindow orderFront:self];
}
- (void)reverseLookup:(MGMWhitePagesHandler *)theHandler didFailWithError:(NSError *)theError {
	NSAlert *alert = [[NSAlert new] autorelease];
	[alert setMessageText:@"Reverse Lookup Failed"];
	[alert setInformativeText:[theError localizedDescription]];
	[alert runModal];
}
- (void)reverseLookupDidFindInfo:(MGMWhitePagesHandler *)theHandler {
	if ([theHandler name]!=nil) {
		[RLName setStringValue:[theHandler name]];
	} else {
		[RLName setStringValue:@""];
	}
	if ([theHandler address]!=nil) {
		[RLAddress setStringValue:[theHandler address]];
	} else {
		[RLAddress setStringValue:@""];
	}
	if ([theHandler location]!=nil) {
		[RLCityState setStringValue:[theHandler location]];
	} else {
		[RLCityState setStringValue:@""];
	}
	if ([theHandler zip]!=nil) {
		[RLZipCode setStringValue:[theHandler zip]];
	} else {
		[RLZipCode setStringValue:@""];
	}
	if ([theHandler phoneNumber]!=nil) {
		[RLPhoneNumber setStringValue:[[theHandler phoneNumber] readableNumber]];
	} else {
		[RLPhoneNumber setStringValue:@""];
	}
	
	int zoom = 0;
	NSString *address = nil;
	if ([theHandler address]!=nil) {
		address = [NSString stringWithFormat:@"%@, %@", [theHandler address], [theHandler zip]];
		zoom = 15;
	} else if ([theHandler zip]!=nil) {
		address = [theHandler zip];
		zoom = 13;
	} else if ([theHandler location]!=nil) {
		address = [theHandler location];
		zoom = 13;
	} else if ([theHandler latitude]!=nil && [theHandler longitude]!=nil) {
		address = [NSString stringWithFormat:@"%@, %@", [theHandler latitude], [theHandler longitude]];
		zoom = 13;
	}
	if (address!=nil)
		[RLMap stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showAddress('%@', %d);", [address javascriptEscape], zoom]];
}

- (IBAction)openSource:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://opensource.mrgeckosmedia.com/VoiceBase/Mac/Mob"]];
}
- (IBAction)donate:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7693931"]];
}
- (IBAction)viewTOS:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.google.com/googlevoice/legal-notices.html"]];
}
- (IBAction)rates:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.google.com/support/voice/bin/answer.py?answer=141925"]];
}
- (IBAction)billing:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.google.com/voice/#billing"]];
}

- (void)SIPStopped {
	if (quitting)
		[[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	NSApplicationTerminateReply response = [taskManager applicationShouldTerminate:sender];
	
#if MGMSIPENABLED
	if (response==NSTerminateNow) {
		for (int i=0; i<[contactsControllers count]; i++) {
			if ([[contactsControllers objectAtIndex:i] isKindOfClass:[MGMSIPUser class]]) {
				MGMSIPUser *SIPUser = [contactsControllers objectAtIndex:i];
				if ([[SIPUser calls] count]!=0) {
					NSAlert *alert = [[NSAlert new] autorelease];
					[alert setMessageText:@"Calls in Progress"];
					[alert setInformativeText:@"You appear to have calls in progress, are you sure you want to quit?"];
					[alert addButtonWithTitle:@"Yes"];
					[alert addButtonWithTitle:@"No"];
					int result = [alert runModal];
					if (result==1001)
						response = NSTerminateCancel;
					break;
				}
			}
		}
	}
#endif
	if (response==NSTerminateNow) {
		while ([[SMSManager SMSMessages] count]>=1) {
			[SMSManager closeSMSMessage:[[SMSManager SMSMessages] lastObject]];
		}
		
		quitting = YES;
		[contactsControllers removeAllObjects];
	}
#if MGMSIPENABLED
	if (response==NSTerminateNow) {
		if ([[MGMSIP sharedSIP] isStarted]) {
			[[MGMSIP sharedSIP] stop];
			response = NSTerminateLater;
		}
	}
#endif
	return response;
}
@end