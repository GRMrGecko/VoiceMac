//
//  MGMContacts.h
//  VoiceBase
//
//  Created by Mr. Gecko on 8/18/10.
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

- (void)setDelegate:(id)theDelegate;
- (id<MGMContactsOwnerDelegate>)delegate;

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