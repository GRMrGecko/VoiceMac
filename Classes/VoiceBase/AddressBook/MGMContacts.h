//
//  MGMContacts.h
//  VoiceBase
//
//  Created by Mr. Gecko on 8/18/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@protocol MGMContactsProtocol, MGMContactsOwnerDelegate;
@class MGMUser, MGMLiteConnection;

#define MGMContactsDebug 0

@interface MGMContacts : NSObject {
	id<MGMContactsOwnerDelegate> delegate;
	MGMUser *user;
	MGMLiteConnection *contactsConnection;
	MGMLiteConnection *updateConnection;
	Class contactsClass;
	id<MGMContactsProtocol> contacts;
	BOOL isUpdating;
	BOOL stopingUpdate;
	NSLock *updateLock;
	NSLock *contactsLock;
	int maxResults;
}
+ (id)contactsWithClass:(Class)theClass delegate:(id)theDelegate;
- (id)initWithClass:(Class)theClass delegate:(id)theDelegate;

- (void)stop;

- (void)setMaxResults:(int)theMaxResults;
- (int)maxResults;

- (MGMLiteConnection *)contactsConnection;
- (void)setContactsConnection:(MGMLiteConnection *)theConnection;

- (void)updateContacts;
- (void)contactsError:(NSError *)theError;
- (void)groupsError:(NSError *)theError;

- (NSNumber *)countContactsMatching:(NSString *)theString;
- (NSArray *)contactsMatching:(NSString *)theString page:(int)thePage;
- (NSArray *)contactCompletionsMatching:(NSString *)theString;
- (NSDictionary *)contactWithID:(NSNumber *)theID;
- (NSData *)photoDataForNumber:(NSString *)theNumber;
- (NSString *)cachedPhotoForNumber:(NSString *)theNumber;
- (NSString *)nameForNumber:(NSString *)theNumber;

- (NSArray *)groups;
- (NSDictionary *)groupWithID:(NSNumber *)theID;
- (NSNumber *)membersCountOfGroup:(NSDictionary *)theGroup;
- (NSNumber *)membersCountOfGroupID:(NSNumber *)theGroup;
- (NSArray *)membersOfGroup:(NSDictionary *)theGroup;
- (NSArray *)membersOfGroupID:(NSNumber *)theGroup;
- (NSArray *)groupsOfContact:(NSDictionary *)theContact;
@end