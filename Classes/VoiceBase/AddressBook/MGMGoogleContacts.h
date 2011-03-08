//
//  MGMGoogleContacts.h
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

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

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
+ (NSDictionary *)dictionaryWithString:(NSString *)theString;
- (MGMUser *)user;
- (void)getContacts:(id)sender;
- (void)parseContact;
- (void)continueContacts;
- (void)getGroups:(id)sender;
@end