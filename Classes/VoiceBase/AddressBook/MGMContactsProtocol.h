//
//  MGMAddressBookProtocol.h
//  VoiceBase
//
//  Created by Mr. Gecko on 8/17/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <Foundation/Foundation.h>
#else
#import <Cocoa/Cocoa.h>
#endif

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

extern const int MGMABPhotoSize;

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