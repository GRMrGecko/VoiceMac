//
//  MGMAddressBook.m
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

#import "MGMAddressBook.h"
#import "MGMContactsProtocol.h"
#import "MGMAddons.h"
#if TARGET_OS_IPHONE
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABGroup.h>
#import <AddressBook/ABMultiValue.h>
#else
#import <AddressBook/AddressBook.h>
#endif

@implementation MGMAddressBook
- (id)initWithDelegate:(id)theDelegate {
	if ((self = [super init])) {
		delegate = theDelegate;
		shouldStop = NO;
		gettingContacts = NO;
		gettingGroups = NO;
#if TARGET_OS_IPHONE
		addressBook = ABAddressBookCreate();
#else
		addressBook = [[ABAddressBook sharedAddressBook] retain];
#endif
	}
	return self;
}
- (void)dealloc {
#if TARGET_OS_IPHONE
	if (addressBook!=NULL)
		CFRelease(addressBook);
#else
	[addressBook release];
#endif
	[super dealloc];
}

#if !TARGET_OS_IPHONE
+ (NSData *)userPhotoData {
	return [[[ABAddressBook sharedAddressBook] me] imageData];
}
#endif

- (void)stop {
	shouldStop = YES;
	while (gettingContacts)
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	while (gettingGroups)
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	shouldStop = NO;
}

- (void)getContacts:(id)sender {
	if (gettingContacts) {
		NSDictionary *info = [NSDictionary dictionaryWithObject:contactsSender forKey:MGMCRecallSender];
		NSError *error = [NSError errorWithDomain:MGMCRecallError code:1 userInfo:info];
		if ([sender respondsToSelector:@selector(contactsError:)]) [sender contactsError:error];
		return;
	}
	gettingContacts = YES;
	contactsSender = sender;
	[NSThread detachNewThreadSelector:@selector(contactsBackground) toTarget:self withObject:nil];
}
- (void)contactsBackground {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
#if TARGET_OS_IPHONE
	NSArray *people = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
	for (unsigned int i=0; i<[people count]; i++) {
		if (shouldStop) break;
		ABRecordRef person = [people objectAtIndex:i];
		NSString *name = @"";
		NSString *firstName = [(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) autorelease];
		if (firstName!=nil)
			name = firstName;
		NSString *lastName = [(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) autorelease];
		if ([name isEqualToString:@""] && lastName!=nil)
			name = lastName;
		else if (lastName!=nil)
			name = [name stringByAppendingFormat:@" %@", lastName];
		NSString *company = [(NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty) autorelease];
		if (company==nil)
			company = @"";
		ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
		int phonesCount = ABMultiValueGetCount(phones);
		NSData *image = [(NSData *)ABPersonCopyImageData(person) autorelease];
		if (phonesCount>0) {
			if (image!=nil)
				image = [image resizeTo:MGMABPhotoSize];
		}
		for (int p=0; p<phonesCount; p++) {
			if (shouldStop) break;
			NSMutableDictionary *contact = [NSMutableDictionary dictionary];
			[contact setObject:name forKey:MGMCName];
			[contact setObject:company forKey:MGMCCompany];
			CFStringRef phoneNumber = ABMultiValueCopyValueAtIndex(phones, p);
			if (delegate!=nil)
				[contact setObject:[(NSString *)phoneNumber phoneFormatWithAreaCode:[delegate areaCode]] forKey:MGMCNumber];
			else
				[contact setObject:[(NSString *)phoneNumber phoneFormat] forKey:MGMCNumber];
			CFRelease(phoneNumber);
			NSString *label = [(NSString *)ABMultiValueCopyLabelAtIndex(phones, p) autorelease];
			NSRange range = [label rangeOfString:@"<"];
			if (range.location!=NSNotFound) {
				NSString *string = [label substringFromIndex:range.location+range.length];
				range = [string rangeOfString:@">"];
				if (range.location==NSNotFound) {
					NSLog(@"failed 0007");
				} else {
					label = [string substringWithRange:NSMakeRange(0, range.location)];
				}
			}
			[contact setObject:[label capitalizedString] forKey:MGMCLabel];
			if (image!=nil)
				[contact setObject:image forKey:MGMCPhoto];
			if ([contactsSender respondsToSelector:@selector(gotContact:)]) [contactsSender gotContact:contact];
		}
		CFRelease(phones);
	}
#else
	NSArray *people = [addressBook people];
	for (unsigned int i=0; i<[people count]; i++) {
		if (shouldStop) break;
		ABPerson *person = [people objectAtIndex:i];
		if ([person valueForProperty:kABPhoneProperty]!=nil) {
			NSString *name = @"";
			if ([person valueForProperty:kABFirstNameProperty])
				name = [person valueForProperty:kABFirstNameProperty];
			if ([name isEqualToString:@""] && [person valueForProperty:kABLastNameProperty]!=nil)
				name = [person valueForProperty:kABLastNameProperty];
			else if ([person valueForProperty:kABLastNameProperty]!=nil)
				name = [name stringByAppendingFormat:@" %@", [person valueForProperty:kABLastNameProperty]];
			NSString *company = @"";
			if ([person valueForProperty:kABOrganizationProperty]!=nil)
				company = [person valueForProperty:kABOrganizationProperty];
			ABMultiValue *phones = [person valueForProperty:kABPhoneProperty];
			NSData *image = [person imageData];
			if ([phones count]>0) {
				if (image!=nil)
					image = [image resizeTo:MGMABPhotoSize];
			}
			for (int p=0; p<[phones count]; p++) {
				if (shouldStop) break;
				NSMutableDictionary *contact = [NSMutableDictionary dictionary];
				[contact setObject:name forKey:MGMCName];
				[contact setObject:company forKey:MGMCCompany];
				if (delegate!=nil)
					[contact setObject:[[phones valueAtIndex:p] phoneFormatWithAreaCode:[delegate areaCode]] forKey:MGMCNumber];
				else
					[contact setObject:[[phones valueAtIndex:p] phoneFormat] forKey:MGMCNumber];
				NSString *label = [phones labelAtIndex:p];
				NSRange range = [label rangeOfString:@"<"];
				if (range.location!=NSNotFound) {
					NSString *string = [label substringFromIndex:range.location+range.length];
					range = [string rangeOfString:@">"];
					if (range.location==NSNotFound) {
						NSLog(@"failed 0007");
					} else {
						label = [string substringWithRange:NSMakeRange(0, range.location)];
					}
				}
				[contact setObject:[label capitalizedString] forKey:MGMCLabel];
				if (image!=nil)
					[contact setObject:image forKey:MGMCPhoto];
				if ([contactsSender respondsToSelector:@selector(gotContact:)]) [contactsSender gotContact:contact];
			}
		}
	}
#endif
	if (!shouldStop)
		if ([contactsSender respondsToSelector:@selector(doneGettingContacts)]) [contactsSender doneGettingContacts];
	gettingContacts = NO;
	[pool drain];
}

- (void)getGroups:(id)sender {
	if (gettingGroups) {
		NSDictionary *info = [NSDictionary dictionaryWithObject:groupsSender forKey:MGMCRecallSender];
		NSError *error = [NSError errorWithDomain:MGMCRecallError code:1 userInfo:info];
		if ([sender respondsToSelector:@selector(groupsError:)]) [sender groupsError:error];
		return;
	}
	gettingGroups = YES;
	groupsSender = sender;
	[NSThread detachNewThreadSelector:@selector(groupsBackground:) toTarget:self withObject:sender];
}
- (void)groupsBackground:(id<MGMContactsDelegate>)sender {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
#if TARGET_OS_IPHONE
	NSArray *abGroups = [(NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook) autorelease];
	for (unsigned int i=0; i<[abGroups count]; i++) {
		if (shouldStop) break;
		ABRecordRef abGroup = [abGroups objectAtIndex:i];
		NSString *name = [(NSString *)ABRecordCopyValue(abGroup, kABGroupNameProperty) autorelease];
		NSArray *people = [(NSArray *)ABGroupCopyArrayOfAllMembers(abGroup) autorelease];
		NSMutableArray *groupMembers = [NSMutableArray array];
		for (unsigned int p=0; p<[people count]; p++) {
			if (shouldStop) break;
			ABRecordRef person = [people objectAtIndex:i];
			ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
			if (phones!=NULL) {
				if (shouldStop) break;
				int phonesCount = ABMultiValueGetCount(phones);
				for (int p=0; p<phonesCount; p++) {
					if (delegate!=nil)
						[groupMembers addObject:[[(NSString *)ABMultiValueCopyValueAtIndex(phones, p) autorelease] phoneFormatWithAreaCode:[delegate areaCode]]];
					else
						[groupMembers addObject:[[(NSString *)ABMultiValueCopyValueAtIndex(phones, p) autorelease] phoneFormat]];
				}
				CFRelease(phones);
			}
		}
		if (!shouldStop)
			if ([groupsSender respondsToSelector:@selector(gotGroup:withMembers:)]) [groupsSender gotGroup:name withMembers:groupMembers];
	}
#else
	NSArray *abGroups = [addressBook groups];
	for (unsigned int i=0; i<[abGroups count]; i++) {
		if (shouldStop) break;
		ABGroup *abGroup = [abGroups objectAtIndex:i];
		NSString *name = [abGroup valueForProperty:kABGroupNameProperty];
		NSArray *people = [abGroup members];
		NSMutableArray *groupMembers = [NSMutableArray array];
		for (unsigned int p=0; p<[people count]; p++) {
			if (shouldStop) break;
			ABPerson *person = [people objectAtIndex:p];
			if ([person valueForProperty:kABPhoneProperty]!=nil) {
				ABMultiValue *phones = [person valueForProperty:kABPhoneProperty];
				for (int p=0; p<[phones count]; p++) {
					if (shouldStop) break;
					if (delegate!=nil)
						[groupMembers addObject:[[phones valueAtIndex:p] phoneFormatWithAreaCode:[delegate areaCode]]];
					else
						[groupMembers addObject:[[phones valueAtIndex:p] phoneFormat]];
				}
			}
		}
		if (!shouldStop)
			if ([groupsSender respondsToSelector:@selector(gotGroup:withMembers:)]) [groupsSender gotGroup:name withMembers:groupMembers];
	}
#endif
	if (!shouldStop)
		if ([groupsSender respondsToSelector:@selector(doneGettingGroups)]) [groupsSender doneGettingGroups];
	gettingGroups = NO;
	[pool drain];
}
@end