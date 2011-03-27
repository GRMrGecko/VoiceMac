//
//  MGMAddressBookProtocol.m
//  VoiceBase
//
//  Created by Mr. Gecko on 8/17/10.
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
const float MGMABPhotoSizePX = 60.0;
#else
const float MGMABPhotoSizePX = 64.0;
#endif