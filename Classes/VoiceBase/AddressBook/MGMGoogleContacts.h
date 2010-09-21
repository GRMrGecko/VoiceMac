//
//  MGMGoogleContacts.h
//  VoiceBase
//
//  Created by Mr. Gecko on 8/17/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@class MGMUser, MGMURLConnectionManager;
@protocol MGMContactsDelegate, MGMContactsOwnerDelegate;

extern NSString * const MGMGCAuthenticationURL;
extern NSString * const MGMGCAuthenticationBody;
extern NSString * const MGMGCUseragent;

@interface MGMGoogleContacts : NSObject {
	id<MGMContactsOwnerDelegate> delegate;
	MGMUser *user;
	MGMURLConnectionManager *connectionManager;
	BOOL isAuthenticating;
	NSString *authenticationString;
	NSMutableArray *afterAuthentication;
	NSMutableArray *contacts;
	NSArray *contactEntries;
	unsigned int contactsIndex;
	NSData *contactPhoto;
	BOOL shouldStop;
	BOOL gettingContacts;
	BOOL gettingGroups;
	id<MGMContactsDelegate> contactsSender;
	id<MGMContactsDelegate> groupsSender;
	NSTimer *releaseTimer;
}
- (id)initWithDelegate:(id)theDelegate;
+ (NSDictionary *)dictionaryWithData:(NSData *)theData;
- (MGMUser *)user;
- (void)getContacts:(id)sender;
- (void)parseContact;
- (void)continueContacts;
- (void)getGroups:(id)sender;
@end