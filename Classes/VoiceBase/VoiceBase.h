/*
 *  VoiceBase.h
 *  VoiceBase
 *
 *  Created by Mr. Gecko on 8/15/10.
 *  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
 *
 */

#if TARGET_OS_IPHONE
#import <MGMAddons.h>
#import <MGMInstance.h>
#import <MGMInbox.h>
#import <MGMContactsProtocol.h>
#import <MGMContacts.h>
#import <MGMAddressBook.h>
#import <MGMGoogleContacts.h>
#import <MGMSound.h>
#import <MGMThemeManager.h>
#import <MGMXML.h>

//MGMSIP Stuff
#import <MGMSIP.h>
#import <MGMSIPAccount.h>
#import <MGMSIPCall.h>
#import <MGMSIPURL.h>
#else
#import <VoiceBase/MGMAddons.h>
#import <VoiceBase/MGMInstance.h>
#import <VoiceBase/MGMInbox.h>
#import <VoiceBase/MGMContactsProtocol.h>
#import <VoiceBase/MGMContacts.h>
#import <VoiceBase/MGMAddressBook.h>
#import <VoiceBase/MGMGoogleContacts.h>
#import <VoiceBase/MGMSound.h>
#import <VoiceBase/MGMThemeManager.h>
#import <VoiceBase/MGMXML.h>

//MGMSIP Stuff
#import <VoiceBase/MGMSIP.h>
#import <VoiceBase/MGMSIPAccount.h>
#import <VoiceBase/MGMSIPCall.h>
#import <VoiceBase/MGMSIPURL.h>
#endif