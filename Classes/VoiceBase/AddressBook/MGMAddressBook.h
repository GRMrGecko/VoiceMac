//
//  MGMAddressBook.h
//  VoiceBase
//
//  Created by Mr. Gecko on 8/17/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <AddressBook/ABAddressBook.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@protocol MGMContactsDelegate, MGMContactsOwnerDelegate;

@class ABAddressBook;

@interface MGMAddressBook : NSObject {
	id<MGMContactsOwnerDelegate> delegate;
#if TARGET_OS_IPHONE
	ABAddressBookRef addressBook;
#else
	ABAddressBook *addressBook;
#endif
	BOOL shouldStop;
	BOOL gettingContacts;
	BOOL gettingGroups;
	id<MGMContactsDelegate> contactsSender;
	id<MGMContactsDelegate> groupsSender;
}
- (id)initWithDelegate:(id)theDelegate;

#if !TARGET_OS_IPHONE
+ (NSData *)userPhotoData;
#endif

- (void)getContacts:(id)sender;
- (void)getGroups:(id)sender;
@end