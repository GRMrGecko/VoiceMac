//
//  MGMAddressBookProtocol.h
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

#import <Foundation/Foundation.h>

extern NSString * const MGMCRecallError;
extern NSString * const MGMCRecallSender;

extern NSString * const MGMCName;
extern NSString * const MGMCCompany;
extern NSString * const MGMCNumber;
extern NSString * const MGMCLabel;
extern NSString * const MGMCPhoto;
extern NSString * const MGMCDocID;
extern NSString * const MGMCGroupID;
extern NSString * const MGMCContactID;

extern NSString * const MGMCGoogleContactsUser;

extern const float MGMABPhotoSizePX;
#if TARGET_OS_IPHONE
#define MGMABPhotoSize CGSizeMake(MGMABPhotoSizePX, MGMABPhotoSizePX)
#else
#define MGMABPhotoSize NSMakeSize(MGMABPhotoSizePX, MGMABPhotoSizePX)
#endif

@class MGMUser;

@protocol MGMContactsProtocol <NSObject>
- (id)initWithUser:(MGMUser *)theUser;
- (void)stop;
- (void)getContacts:(id)sender;
- (void)getGroups:(id)sender;
@end

@protocol MGMContactsDelegate <NSObject>
- (void)gotContact:(NSDictionary *)theContact;
- (void)doneGettingContacts;
- (void)contactsError:(NSError *)theError;
- (void)gotGroup:(NSString *)theName withMembers:(NSArray *)theMembers;
- (void)doneGettingGroups;
- (void)groupsError:(NSError *)theError;
@end

@protocol MGMContactsOwnerDelegate <NSObject>
- (MGMUser *)user;
- (NSString *)areaCode;
- (NSString *)userNumber;
- (void)updatedContacts;
@end