//
//  MGMAddressBookProtocol.m
//  VoiceBase
//
//  Created by Mr. Gecko on 8/17/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMContactsProtocol.h"

NSString * const MGMCRecallError = @"com.MrGeckosMedia.MGMContacts.AlreadyCalled";
NSString * const MGMCRecallSender = @"sender";

NSString * const MGMCName = @"name";
NSString * const MGMCCompany = @"company";
NSString * const MGMCNumber = @"number";
NSString * const MGMCLabel = @"label";
NSString * const MGMCPhoto = @"photo";
NSString * const MGMCDocID = @"docid";
NSString * const MGMCGroupID = @"groupid";
NSString * const MGMCContactID = @"contactid";

NSString * const MGMCGoogleContactsUser = @"MGMCGoogleContactsUser";

#if TARGET_OS_IPHONE
const float MGMABPhotoSizePX = 120.0;
#else
const float MGMABPhotoSizePX = 64.0;
#endif