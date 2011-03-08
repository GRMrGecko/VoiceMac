//
//  MGMContacts.m
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

#import "MGMContacts.h"
#import "MGMContactsProtocol.h"
#import "MGMAddressBook.h"
#import "MGMGoogleContacts.h"
#import "MGMInstance.h"
#import "MGMAddons.h"
#import <MGMUsers/MGMUsers.h>

NSString * const MGMCContactsDB = @"contacts.db";
NSString * const MGMCUpdateDB = @"update.db";

NSString * const MGMCWordSA = @"%@*";
NSString * const MGMCWordSSA = @" %@*";
NSString * const MGMCWordS = @" %@";
NSString * const MGMCQoute = @"\"";
NSString * const MGMCNum = @"%%%@%%";
NSString * const MGMCNEAR = @"NEAR";
NSString * const MGMCAND = @"AND";
NSString * const MGMCOR = @"OR";
NSString * const MGMCNOT = @"NOT";

NSString * const MGMCCNumber = @"%@ (%@)";

NSString * const MGMTiffExt = @"tif";

const int MGMCMaxResults = 10;

@interface MGMContacts (MGMPrivate)
- (void)updated;
@end

@implementation MGMContacts
+ (id)contactsWithClass:(Class)theClass delegate:(id)theDelegate {
	return [[[self alloc] initWithClass:theClass delegate:theDelegate] autorelease];
}
- (id)initWithClass:(Class)theClass delegate:(id)theDelegate {
	if ((self = [super init])) {
		maxResults = MGMCMaxResults;
		delegate = theDelegate;
		user = [delegate user];
		contactsLock = [NSLock new];
		isUpdating = NO;
		stopingUpdate = NO;
		updateLock = [NSLock new];
		if (theClass==NULL) {
			[self release];
			self = nil;
		} else {
			contacts = [[theClass alloc] initWithDelegate:delegate];
			if (contacts==nil) {
				[self release];
				self = nil;
			} else {
				if ([[NSFileManager defaultManager] fileExistsAtPath:[[user supportPath] stringByAppendingPathComponent:MGMCContactsDB]]) {
					[self setContactsConnection:[MGMLiteConnection connectionWithPath:[[user supportPath] stringByAppendingPathComponent:MGMCContactsDB]]];
				}
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdated:) name:MGMUserUpdatedNotification object:nil];
			}
		}

	}
	return self;
}
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[updateLock lock];
	[updateLock unlock];
	[updateLock release];
	[contactsLock lock];
	[contactsLock unlock];
	[contactsLock release];
	[contactsConnection release];
	[updateConnection release];
	[contacts release];
	[super dealloc];
}

- (void)setDelegate:(id)theDelegate {
	delegate = theDelegate;
}
- (id<MGMContactsOwnerDelegate>)delegate {
	return delegate;
}

- (void)stop {
	if (isUpdating) {
		stopingUpdate = YES;
		[contacts stop];
		[updateLock lock];
		[updateLock unlock];
		[updateConnection release];
		updateConnection = nil;
		isUpdating = NO;
		stopingUpdate = NO;
	}
}

- (void)userUpdated:(NSNotification *)theNotification {
	MGMUser *theUser = [theNotification object];
	if ([theUser isEqual:user] && (![[theUser settingForKey:MGMSContactsSourceKey] isEqual:NSStringFromClass([contacts class])] || ([contacts isKindOfClass:[MGMGoogleContacts class]] && ![[[(MGMGoogleContacts *)contacts user] settingForKey:MGMUserID] isEqual:[theUser settingForKey:MGMCGoogleContactsUser]]))) {
		if (stopingUpdate) return;
		[self stop];
		[contacts release];
		contacts = [[NSClassFromString([theUser settingForKey:MGMSContactsSourceKey]) alloc] initWithDelegate:delegate];
		[self updateContacts];
	}
}

- (void)setMaxResults:(int)theMaxResults {
	maxResults = theMaxResults;
}
- (int)maxResults {
	return maxResults;
}

- (MGMLiteConnection *)contactsConnection {
	return contactsConnection;
}
- (void)setContactsConnection:(MGMLiteConnection *)theConnection {
	[contactsLock lock];
	[contactsConnection release];
	contactsConnection = [theConnection retain];
	[contactsLock unlock];
}

- (void)updateContacts {
	if (isUpdating)
		return;
	isUpdating = YES;
	[updateLock lock];
	NSFileManager *manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:[[user supportPath] stringByAppendingPathComponent:MGMCUpdateDB]])
		[manager removeItemAtPath:[[user supportPath] stringByAppendingPathComponent:MGMCUpdateDB]];
	updateConnection = [[MGMLiteConnection connectionWithPath:[[user supportPath] stringByAppendingPathComponent:MGMCUpdateDB]] retain];
	if (updateConnection==nil) {
		[self contactsError:nil];
	}
#if MGMContactsDebug
	NSLog(@"Getting Contacts");
	[updateConnection setLogQuery:YES];
#endif
	[updateConnection query:@"CREATE VIRTUAL TABLE contacts USING fts3(name, company, number, label, photo)"];
	[updateConnection query:@"CREATE TABLE groups (docid INTEGER PRIMARY KEY AUTOINCREMENT, name)"];
	[updateConnection query:@"CREATE TABLE groupMembers (docid INTEGER PRIMARY KEY AUTOINCREMENT, groupid INTEGER, contactid INTEGER)"];
	[updateLock unlock];
	[contacts getContacts:self];
}
- (void)gotContact:(NSDictionary *)theContact {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[updateLock lock];
	if (updateConnection!=nil) {
		[updateConnection query:@"INSERT INTO contacts (name, company, number, label, photo) VALUES (%@, %@, %@, %@, %@)", [theContact objectForKey:MGMCName], [theContact objectForKey:MGMCCompany], [theContact objectForKey:MGMCNumber], [theContact objectForKey:MGMCLabel], [theContact objectForKey:MGMCPhoto]];
#if MGMContactsDebug
		if ([updateConnection errorID]!=0)
			NSLog(@"%@ %@", [updateConnection errorMessage], theContact);
#endif
	}
	[updateLock unlock];
	[pool drain];
}
- (void)doneGettingContacts {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[contacts getGroups:self];
#if MGMContactsDebug
	NSLog(@"Finished Adding Contacts");
#endif
	[pool drain];
}
- (void)contactsError:(NSError *)theError {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSLog(@"MGMContacts Error: %@", theError);
	isUpdating = NO;
	[pool drain];
}

- (void)gotGroup:(NSString *)theName withMembers:(NSArray *)theMembers {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[updateLock lock];
	if (updateConnection!=nil) {
		[updateConnection query:@"INSERT INTO groups (name) VALUES (%@)", theName];
		long long int groupID = [updateConnection insertId];
		for (unsigned int i=0; i<[theMembers count]; i++) {
			NSDictionary *result = [[updateConnection query:@"SELECT docid, * FROM contacts WHERE number = %@", [theMembers objectAtIndex:i]] nextRow];
			if (result!=nil)
				[updateConnection query:@"INSERT INTO groupMembers (groupid, contactid) VALUES (%qi, %@)", groupID, [result objectForKey:MGMCDocID]];
		}
	}
	[updateLock unlock];
	[pool drain];
}
- (void)doneGettingGroups {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self updated];
#if MGMContactsDebug
	NSLog(@"Finished Adding Groups");
#endif
	[pool drain];
}
- (void)groupsError:(NSError *)theError {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSLog(@"MGMContacts Group Error: %@", theError);
	[self updated];
	[pool drain];
}
- (void)updated {
	[updateLock lock];
	[self setContactsConnection:nil];
	NSFileManager *manager = [NSFileManager defaultManager];
	if ([manager fileExistsAtPath:[[user supportPath] stringByAppendingPathComponent:MGMCContactsDB]])
		[manager removeItemAtPath:[[user supportPath] stringByAppendingPathComponent:MGMCContactsDB]];
	[manager moveItemAtPath:[[user supportPath] stringByAppendingPathComponent:MGMCUpdateDB] toPath:[[user supportPath] stringByAppendingPathComponent:MGMCContactsDB]];
	[self setContactsConnection:[MGMLiteConnection connectionWithPath:[[user supportPath] stringByAppendingPathComponent:MGMCContactsDB]]];
	[updateLock unlock];
	isUpdating = NO;
	if (delegate!=nil && [delegate respondsToSelector:@selector(updatedContacts)]) [delegate updatedContacts];
}

- (NSNumber *)countContactsMatching:(NSString *)theString {
	if (contactsConnection==nil)
		return [NSNumber numberWithInt:0];
	[contactsLock lock];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSString *string = [theString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	MGMLiteResult *result;
	if (theString==nil || [string isEqual:@""]) {
		result = [contactsConnection query:@"SELECT COUNT(docid) AS count FROM contacts"];
	} else {
		if ([string isPhone]) {
			NSString *search = [NSString stringWithFormat:MGMCNum, [[string removePhoneWhiteSpace] littersToNumbers]];
			result = [contactsConnection query:@"SELECT COUNT(docid) AS count FROM contacts WHERE number LIKE %@", search];
		} else {
			NSArray *words = [string componentsSeparatedByString:@" "];
			NSMutableString *search = [NSMutableString string];
			BOOL quote = NO;
			for (int i=0; i<[words count]; i++) {
				NSString *word = [words objectAtIndex:i];
				if (quote) {
					quote = ![word hasSuffix:MGMCQoute];
					if (i==0)
						[search appendString:word];
					else
						[search appendFormat:MGMCWordS, word];
				} else {
					quote = [word hasPrefix:MGMCQoute];
					if (quote) {
						i--;
						continue;
					}
					if (i==0)
						[search appendFormat:MGMCWordSA, word];
					else {
						if ([word hasPrefix:MGMCNEAR] || [word isEqual:MGMCAND] || [word isEqual:MGMCOR] || [word isEqual:MGMCNOT]) {
							[search appendFormat:MGMCWordS, word];
						} else {
							[search appendFormat:MGMCWordSSA, word];
						}
					}
				}
			}
			result = [contactsConnection query:@"SELECT COUNT(docid) AS count FROM contacts WHERE contacts MATCH %@", search];
		}
	}
	NSNumber *count = [[[result nextRow] objectForKey:@"count"] copy];
	[contactsLock unlock];
	[pool drain];
	return [count autorelease];
}
- (NSArray *)contactsMatching:(NSString *)theString page:(int)thePage {
	if (contactsConnection==nil)
		return nil;
	[contactsLock lock];
	NSMutableArray *contactsArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSString *string = [theString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	MGMLiteResult *result;
	if (thePage==0) thePage = 1;
	long long int page = (thePage*maxResults)-maxResults;
	if (theString==nil || [string isEqual:@""]) {
		result = [contactsConnection query:@"SELECT docid, * FROM contacts ORDER BY company, name LIMIT %qi, %d", page, maxResults];
	} else {
		if ([string isPhone]) {
			NSString *search = [NSString stringWithFormat:MGMCNum, [[string removePhoneWhiteSpace] littersToNumbers]];
			result = [contactsConnection query:@"SELECT docid, * FROM contacts WHERE number LIKE %@ ORDER BY company, name LIMIT %qi, %d", search, page, maxResults];
		} else {
			NSArray *words = [string componentsSeparatedByString:@" "];
			NSMutableString *search = [NSMutableString string];
			BOOL quote = NO;
			for (int i=0; i<[words count]; i++) {
				NSString *word = [words objectAtIndex:i];
				if (quote) {
					quote = ![word hasSuffix:MGMCQoute];
					if (i==0)
						[search appendString:word];
					else
						[search appendFormat:MGMCWordS, word];
				} else {
					quote = [word hasPrefix:MGMCQoute];
					if (quote) {
						i--;
						continue;
					}
					if (i==0)
						[search appendFormat:MGMCWordSA, word];
					else {
						if ([word hasPrefix:MGMCNEAR] || [word isEqual:MGMCAND] || [word isEqual:MGMCOR] || [word isEqual:MGMCNOT]) {
							[search appendFormat:MGMCWordS, word];
						} else {
							[search appendFormat:MGMCWordSSA, word];
						}
					}
				}
			}
			result = [contactsConnection query:@"SELECT docid, *, offsets(contacts) AS offset FROM contacts WHERE contacts MATCH %@ ORDER BY offset LIMIT %qi, %d", search, page, maxResults];
		}
	}
	NSDictionary *contact = nil;
	while ((contact=[result nextRow])!=nil) {
		[contactsArray addObject:contact];
	}
	[contactsLock unlock];
	[pool drain];
	return contactsArray;
}
- (NSArray *)contactCompletionsMatching:(NSString *)theString {
	if (contactsConnection==nil)
		return nil;
	[contactsLock lock];
	NSMutableArray *completions = [NSMutableArray array];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSString *string = [theString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if (theString==nil || [string isEqual:@""]) {
		[pool drain];
		return completions;
	} else {
		if ([string isPhone]) {
			for (int i=0; i<2; i++) {
				NSString *search = [NSString stringWithFormat:@"%@%%", (i==0 ? [string phoneFormat] : [string phoneFormatAreaCode:[delegate areaCode]])];
				MGMLiteResult *result = [contactsConnection query:@"SELECT docid, * FROM contacts WHERE number LIKE %@ ORDER BY company, name LIMIT %d", search, maxResults];
				
				NSDictionary *contact = nil;
				while ((contact=[result nextRow])!=nil) {
					NSString *completion = nil;
					NSString *number = [contact objectForKey:MGMCNumber];
					if (i==0) {
						if (![string hasPrefix:@"+1"] && ![string hasPrefix:@"011"]) {
							if ([number hasPrefix:@"+1"])
								number = [number substringFromIndex:2];
						}
					} else {
						number = [number substringFromIndex:5];
					}
					if ([contact objectForKey:MGMCName]!=nil && ![[contact objectForKey:MGMCName] isEqual:@""]) {
						completion = [NSString stringWithFormat:MGMCCNumber, number, [contact objectForKey:MGMCName]];
					} else if ([contact objectForKey:MGMCCompany]!=nil && ![[contact objectForKey:MGMCCompany] isEqual:@""]) {
						completion = [NSString stringWithFormat:MGMCCNumber, number, [contact objectForKey:MGMCCompany]];
					} else {
						completion = number;
					}
					[completions addObject:completion];
				}
			}
		} else {
			NSArray *words = [string componentsSeparatedByString:@" "];
			NSMutableString *search = [NSMutableString string];
			for (int i=0; i<[words count]; i++) {
				NSString *word = [words objectAtIndex:i];
				if (i==0)
					[search appendFormat:MGMCWordSA, word];
				else {
					[search appendFormat:MGMCWordSSA, word];
				}
			}
			MGMLiteResult *result = [contactsConnection query:@"SELECT docid, *, offsets(contacts) AS offset FROM contacts WHERE contacts MATCH %@ ORDER BY offset LIMIT %d", search, maxResults];
			
			NSDictionary *contact = nil;
			while ((contact=[result nextRow])!=nil) {
				NSString *completion = nil;
				if (([contact objectForKey:MGMCName]!=nil && ![[contact objectForKey:MGMCName] isEqual:@""]) || ([contact objectForKey:MGMCCompany]!=nil && ![[contact objectForKey:MGMCCompany] isEqual:@""])) {
					NSArray *words = [string componentsSeparatedByString:@" "];
					NSString *name = nil;
					if ([contact objectForKey:MGMCName]!=nil && ![[contact objectForKey:MGMCName] isEqual:@""])
						name = [contact objectForKey:MGMCName];
					else
						name = [contact objectForKey:MGMCCompany];
					if (![name hasPrefix:[words objectAtIndex:0]]) {
						NSMutableArray *nameArray = [NSMutableArray arrayWithArray:[name componentsSeparatedByString:@" "]];
						for (int i=0; i<[nameArray count]; i++) {
							if ([[nameArray objectAtIndex:i] hasPrefix:[words objectAtIndex:0]]) {
								name = [nameArray objectAtIndex:i];
								[nameArray removeObjectAtIndex:i];
								break;
							}
						}
						for (int i=0; i<[nameArray count]; i++) {
							name = [name stringByAppendingFormat:MGMCWordS, [nameArray objectAtIndex:i]];
						}
					}
					completion = [NSString stringWithFormat:@"%@ <%@>", name, [[contact objectForKey:MGMCNumber] readableNumber]];
				} else {
					completion = [[contact objectForKey:MGMCNumber] readableNumber];
				}
				[completions addObject:completion];
			}
		}
	}
	[contactsLock unlock];
	[pool drain];
	return completions;
}
- (NSDictionary *)contactWithID:(NSNumber *)theID {
	if (contactsConnection==nil)
		return nil;
	return [[contactsConnection query:@"SELECT docid, * FROM contacts WHERE docid = %@", theID] nextRow];
}
- (NSData *)photoDataForNumber:(NSString *)theNumber {
	NSDictionary *contact = [[contactsConnection query:@"SELECT photo FROM contacts WHERE number = %@ AND photo NOT NULL", theNumber] nextRow];
	if (contact!=nil)
		return [contact objectForKey:MGMCPhoto];
	return nil;
}
- (NSString *)cachedPhotoForNumber:(NSString *)theNumber {
	NSFileManager *manager = [NSFileManager defaultManager];
#if !TARGET_OS_IPHONE
	if ([delegate respondsToSelector:@selector(userNumber)] && [[delegate userNumber] isEqual:theNumber]) {
		if (![manager fileExistsAtPath:[[MGMUser cachePath] stringByAppendingPathComponent:[theNumber stringByAppendingPathExtension:MGMTiffExt]]]) {
			NSData *photo = [MGMAddressBook userPhotoData];
			if (photo!=nil) {
				[photo writeToFile:[[MGMUser cachePath] stringByAppendingPathComponent:[theNumber stringByAppendingPathExtension:MGMTiffExt]] atomically:YES];
				return [[MGMUser cachePath] stringByAppendingPathComponent:[theNumber stringByAppendingPathExtension:MGMTiffExt]];
			}
		} else {
			return [[MGMUser cachePath] stringByAppendingPathComponent:[theNumber stringByAppendingPathExtension:MGMTiffExt]];
		}
	}
#endif
	if (![manager fileExistsAtPath:[[MGMUser cachePath] stringByAppendingPathComponent:[theNumber stringByAppendingPathExtension:MGMTiffExt]]]) {
		NSData *photo = [self photoDataForNumber:theNumber];
		if (photo!=nil) {
			[photo writeToFile:[[MGMUser cachePath] stringByAppendingPathComponent:[theNumber stringByAppendingPathExtension:MGMTiffExt]] atomically:YES];
			return [[MGMUser cachePath] stringByAppendingPathComponent:[theNumber stringByAppendingPathExtension:MGMTiffExt]];
		}
	} else {
		return [[MGMUser cachePath] stringByAppendingPathComponent:[theNumber stringByAppendingPathExtension:MGMTiffExt]];
	}
	return nil;
}
- (NSString *)nameForNumber:(NSString *)theNumber {
	NSDictionary *contact = [[contactsConnection query:@"SELECT name, company FROM contacts WHERE number = %@ AND (name != '' OR company != '')", theNumber] nextRow];
	if (contact!=nil) {
		if (![[contact objectForKey:MGMCName] isEqual:@""])
			return [contact objectForKey:MGMCName];
		else if (![[contact objectForKey:MGMCCompany] isEqual:@""])
			return [contact objectForKey:MGMCCompany];
	}
	if ([theNumber isPhoneComplete])
		return [theNumber readableNumber];
	return theNumber;
}

- (NSArray *)groups {
	if (contactsConnection==nil)
		return nil;
	[contactsLock lock];
	NSMutableArray *groupsArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	MGMLiteResult *result = [contactsConnection query:@"SELECT * FROM groups ORDER BY name"];
	NSDictionary *group = nil;
	while ((group=[result nextRow])!=nil) {
		[groupsArray addObject:group];
	}
	[contactsLock unlock];
	[pool drain];
	return groupsArray;
}
- (NSDictionary *)groupWithID:(NSNumber *)theID {
	if (contactsConnection==nil)
		return nil;
	return [[contactsConnection query:@"SELECT * FROM groups WHERE docid = %@", theID] nextRow];
}
- (NSNumber *)membersCountOfGroup:(NSDictionary *)theGroup {
	return [self membersCountOfGroupID:[theGroup objectForKey:MGMCDocID]];
}
- (NSNumber *)membersCountOfGroupID:(NSNumber *)theGroup {
	if (contactsConnection==nil)
		return nil;
	[contactsLock lock];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	MGMLiteResult *result = [contactsConnection query:@"SELECT COUNT(docid) AS count FROM groupMembers WHERE groupid = %@", theGroup];
	NSNumber *count = [[[result nextRow] objectForKey:@"count"] copy];
	[contactsLock unlock];
	[pool drain];
	return [count autorelease];
}
- (NSArray *)membersOfGroup:(NSDictionary *)theGroup {
	return [self membersOfGroupID:[theGroup objectForKey:MGMCDocID]];
}
- (NSArray *)membersOfGroupID:(NSNumber *)theGroup {
	if (contactsConnection==nil)
		return nil;
	[contactsLock lock];
	NSMutableArray *memebersArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	MGMLiteResult *result = [contactsConnection query:@"SELECT * FROM groupMembers WHERE groupid = %@", theGroup];
	NSDictionary *member = nil;
	while ((member=[result nextRow])!=nil) {
		NSDictionary *contact = [self contactWithID:[member objectForKey:MGMCContactID]];
		if (contact!=nil)
			[memebersArray addObject:contact];
	}
	[contactsLock unlock];
	[pool drain];
	return memebersArray;
}
- (NSArray *)groupsOfContact:(NSDictionary *)theContact {
	if (contactsConnection==nil)
		return nil;
	[contactsLock lock];
	NSMutableArray *groupsArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	MGMLiteResult *result = [contactsConnection query:@"SELECT * FROM groupMembers WHERE contactid = %@", [theContact objectForKey:MGMCDocID]];
	NSDictionary *groupMember = nil;
	while ((groupMember=[result nextRow])!=nil) {
		NSDictionary *group = [self groupWithID:[groupMember objectForKey:MGMCGroupID]];
		if (group!=nil)
			[groupsArray addObject:group];
	}
	[contactsLock unlock];
	[pool drain];
	return groupsArray;
}
@end