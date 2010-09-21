//
//  MGMGoogleContacts.m
//  VoiceBase
//
//  Created by Mr. Gecko on 8/17/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMGoogleContacts.h"
#import "MGMContactsProtocol.h"
#import "MGMInstance.h"
#import "MGMAddons.h"
#import <MGMUsers/MGMUsers.h>

NSString * const MGMGCAuthenticationURL = @"https://www.google.com/accounts/ClientLogin";
NSString * const MGMGCAuthenticationBody = @"Email=%@&Passwd=%@&source=MrGeckosMedia-VoiceBase-0.1&service=cp&accountType=HOSTED_OR_GOOGLE";
NSString * const MGMGCUseragent = @"VoiceBase/0.1";

NSString * const MGMGCContactsURL = @"https://www.google.com/m8/feeds/contacts/default/full?max-results=10000";
NSString * const MGMGCGroupsURL = @"https://www.google.com/m8/feeds/groups/default/full?max-results=10000";
NSString * const MGMGCAuthorization = @"Authorization";

const BOOL MGMGoogleContactsInvisible = YES;

@implementation MGMGoogleContacts
- (id)initWithDelegate:(id)theDelegate {
	if (self = [super init]) {
		gettingContacts = NO;
		delegate = theDelegate;
		user = [[MGMUser userWithID:[[delegate user] settingForKey:MGMCGoogleContactsUser]] retain];
		if (user==nil)
			user = [[delegate user] retain];
		NSString *username = [user settingForKey:MGMUserName];
		if (![username containsString:@"@"])
			username = [username stringByAppendingString:@"@gmail.com"];
		NSURLCredential *credentials = [NSURLCredential credentialWithUser:username password:[user password] persistence:NSURLCredentialPersistenceForSession];
		connectionManager = [[MGMURLConnectionManager managerWithCookieStorage:[user cookieStorage]] retain];
		[connectionManager setCredentials:credentials];
		[connectionManager setCustomUseragent:MGMGCUseragent];
		isAuthenticating = YES;
		afterAuthentication = [NSMutableArray new];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMGCAuthenticationURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
		[request setHTTPMethod:MGMPostMethod];
		[request setValue:MGMURLForm forHTTPHeaderField:MGMContentType];
		[request setHTTPBody:[[NSString stringWithFormat:MGMGCAuthenticationBody, [username addPercentEscapes], [[user password] addPercentEscapes]] dataUsingEncoding:NSUTF8StringEncoding]];
		[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(authentication:didFailWithError:) didFinish:@selector(authenticationDidFinish:) invisible:MGMGoogleContactsInvisible object:nil];
	}
	return self;
}
- (void)dealloc {
	if (user!=nil)
		[user release];
	if (connectionManager!=nil) {
		[connectionManager cancelAll];
		[connectionManager release];
	}
	if (authenticationString!=nil)
		[authenticationString release];
	if (afterAuthentication!=nil)
		[afterAuthentication release];
	if (releaseTimer!=nil)
		[releaseTimer fire];
	if (contactEntries!=nil)
		[contactEntries release];
	if (contactPhoto!=nil)
		[contactPhoto release];
	[super dealloc];
}
- (void)authentication:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	NSLog(@"MGMGoogleContacts Error: %@", theError);
}
+ (NSDictionary *)dictionaryWithData:(NSData *)theData {
	NSString *string = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
	NSArray *values = [string componentsSeparatedByString:@"\n"];
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	for (int i=0; i<[values count]; i++) {
		if (![[values objectAtIndex:i] isEqual:@""]) {
			NSMutableArray *info = [NSMutableArray arrayWithArray:[[values objectAtIndex:i] componentsSeparatedByString:@"="]];
			NSString *key = [info objectAtIndex:0];
			[info removeObjectAtIndex:0];
			NSString *value = [info componentsJoinedByString:@"="];
			[dictionary setObject:value forKey:key];
		}
	}
	[string release];
	return dictionary;
}
- (void)authenticationDidFinish:(NSDictionary *)theInfo {
	NSDictionary *info = [MGMGoogleContacts dictionaryWithData:[theInfo objectForKey:MGMConnectionData]];
	if (authenticationString!=nil) [authenticationString release];
	authenticationString = [[NSString stringWithFormat:@"GoogleLogin auth=%@", [info objectForKey:@"Auth"]] retain];
	isAuthenticating = NO;
	while ([afterAuthentication count]!=0) {
		[[afterAuthentication objectAtIndex:0] invoke];
		[afterAuthentication removeObjectAtIndex:0];
	}
}
- (MGMUser *)user {
	return user;
}


- (void)stop {
	shouldStop = YES;
	[connectionManager cancelAll];
	if (gettingContacts || gettingGroups)
		[connectionManager cancelAll];
	shouldStop = NO;
}
- (void)getContacts:(id)sender {
	if (isAuthenticating) {
		SEL selector = @selector(getContacts:);
		NSMethodSignature *signature = [self methodSignatureForSelector:selector];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:selector];
			[invocation setTarget:self];
			[invocation setArgument:&sender atIndex:2];
			[afterAuthentication addObject:invocation];
		}
		return;
	}
	if (gettingContacts) {
		NSDictionary *info = [NSDictionary dictionaryWithObject:contactsSender forKey:MGMCRecallSender];
		NSError *error = [NSError errorWithDomain:MGMCRecallError code:1 userInfo:info];
		if ([sender respondsToSelector:@selector(contactsError:)]) [sender contactsError:error];
		return;
	}
	gettingContacts = YES;
	contactsSender = sender;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMGCContactsURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
	[request setValue:authenticationString forHTTPHeaderField:MGMGCAuthorization];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(contacts:didFailWithError:) didFinish:@selector(contactsDidFinish:) invisible:MGMGoogleContactsInvisible object:nil];
}
- (void)contacts:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	gettingContacts = NO;
	NSLog(@"MGMGoogleContacts Error: %@", theError);
	if ([contactsSender respondsToSelector:@selector(contactsError:)]) [contactsSender contactsError:theError];
}
- (void)contactsDidFinish:(NSDictionary *)theInfo {
	if (releaseTimer!=nil) {
		[releaseTimer invalidate];
		[releaseTimer release];
		releaseTimer = nil;
	}
	if (contacts!=nil) [contacts release];
	contacts = [NSMutableArray new];
	NSXMLElement *XML = [[[[NSXMLDocument alloc] initWithData:[theInfo objectForKey:MGMConnectionData] options:NSXMLDocumentTidyXML error:nil] autorelease] rootElement];
	contactEntries = [[XML elementsForName:@"entry"] retain];
	contactsIndex=0;
	[self continueContacts];
}
- (void)photo:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	NSLog(@"MGMGoogleContacts Photo Error: %@", theError);
	[self parseContact];
	contactsIndex++;
	[self continueContacts];
}
- (void)photoDidFinish:(NSDictionary *)theInfo {
	contactPhoto = [[theInfo objectForKey:MGMConnectionData] retain];
	[self parseContact];
	contactsIndex++;
	[self continueContacts];
}
- (void)parseContact {
	if (shouldStop) return;
	NSXMLElement *entry = [contactEntries objectAtIndex:contactsIndex];
	NSArray *titles = [entry elementsForName:@"title"];
	NSString *name = @"";
	if ([titles count]!=0)
		name = [[titles objectAtIndex:0] stringValue];
	NSArray *organizations = [entry elementsForName:@"gd:organization"];
	NSString *company = @"";
	if ([organizations count]!=0) {
		NSArray *organizationName = [[organizations objectAtIndex:0] elementsForName:@"gd:orgName"];
		if ([organizationName count]!=0)
			company = [[organizationName objectAtIndex:0] stringValue];
	}
	NSArray *phones = [entry elementsForName:@"gd:phoneNumber"];
	NSData *image = nil;
	if ([phones count]>0) {
		if (contactPhoto!=nil) {
			image = [contactPhoto resizeTo:NSMakeSize(MGMABPhotoSize, MGMABPhotoSize)];
			[contactPhoto release];
			contactPhoto = nil;
		}
	}
	for (int p=0; p<[phones count]; p++) {
		if (shouldStop) break;
		NSXMLElement *phone = [phones objectAtIndex:p];
		NSMutableDictionary *contact = [NSMutableDictionary dictionary];
		[contact setObject:name forKey:MGMCName];
		[contact setObject:company forKey:MGMCCompany];
		if (delegate!=nil)
			[contact setObject:[[phone stringValue] phoneFormatWithAreaCode:[delegate areaCode]] forKey:MGMCNumber];
		else
			[contact setObject:[[phone stringValue] phoneFormat] forKey:MGMCNumber];
		NSString *label = @"";
		NSXMLNode *labelXML = [phone attributeForName:@"label"];
		if (labelXML==nil) {
			NSXMLNode *rel = [phone attributeForName:@"rel"];
			if (rel!=nil) {
				NSString *string = [rel stringValue];
				NSRange range = [string rangeOfString:@"#"];
				if (range.location!=NSNotFound) {
					label = [string substringFromIndex:range.location+range.length];
				}
			}
		} else {
			label = [labelXML stringValue];
		}
		[contact setObject:[label capitalizedString] forKey:MGMCLabel];
		[contacts addObject:[[contact copy] autorelease]];
		if (image!=nil)
			[contact setObject:image forKey:MGMCPhoto];
		if ([contactsSender respondsToSelector:@selector(gotContact:)]) [contactsSender gotContact:contact];
	}
}
- (void)continueContacts {
	for (; contactsIndex<[contactEntries count]; contactsIndex++) {
		if (shouldStop) break;
		NSXMLElement *entry = [contactEntries objectAtIndex:contactsIndex];
		NSArray *phones = [entry elementsForName:@"gd:phoneNumber"];
		if ([phones count]!=0) {
			NSArray *links = [entry elementsForName:@"link"];
			BOOL loadingPhoto = NO;
			for (int i=0; i<[links count]; i++) {
				NSXMLNode *rel = [[links objectAtIndex:i] attributeForName:@"rel"];
				if (rel!=nil) {
					if ([[rel stringValue] containsString:@"#photo"]) {
						NSString *url = [[[links objectAtIndex:i] attributeForName:@"href"] stringValue];
						NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
						[request setValue:authenticationString forHTTPHeaderField:MGMGCAuthorization];
						[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(photo:didFailWithError:) didFinish:@selector(photoDidFinish:) invisible:YES object:nil];
						loadingPhoto = YES;
						break;
					}
				}
			}
			if (!loadingPhoto)
				[self parseContact];
			else
				break;
		}
	}
	if (contactsIndex>=[contactEntries count]) {
		releaseTimer = [[NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(releaseContacts) userInfo:nil repeats:NO] retain];
		if ([contactsSender respondsToSelector:@selector(doneGettingContacts)]) [contactsSender doneGettingContacts];
		[contactEntries release];
		contactEntries = nil;
		contactsSender = nil;
		gettingContacts = NO;
	}
}
- (void)releaseContacts {
	if (releaseTimer!=nil) {
		[releaseTimer invalidate];
		[releaseTimer release];
		releaseTimer = nil;
	}
	if (contacts!=nil) {
		[contacts release];
		contacts = nil;
	}
}

- (void)getGroups:(id)sender {
	if (isAuthenticating) {
		SEL selector = @selector(getGroups:);
		NSMethodSignature *signature = [self methodSignatureForSelector:selector];
		if (signature!=nil) {
			NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
			[invocation setSelector:selector];
			[invocation setTarget:self];
			[invocation setArgument:&sender atIndex:2];
			[afterAuthentication addObject:invocation];
		}
		return;
	}
	if (gettingGroups) {
		NSDictionary *info = [NSDictionary dictionaryWithObject:groupsSender forKey:MGMCRecallSender];
		NSError *error = [NSError errorWithDomain:MGMCRecallError code:1 userInfo:info];
		if ([sender respondsToSelector:@selector(groupsError:)]) [sender groupsError:error];
		return;
	}
	if ([sender respondsToSelector:@selector(groupsError:)]) [sender groupsError:nil];
	return;
	gettingGroups = YES;
	groupsSender = sender;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:MGMGCGroupsURL]];
	[request setValue:authenticationString forHTTPHeaderField:MGMGCAuthorization];
	[connectionManager connectionWithRequest:request delegate:self didFailWithError:@selector(groups:didFailWithError:) didFinish:@selector(groupsDidFinish:) invisible:MGMGoogleContactsInvisible object:nil];
}
- (void)groups:(NSDictionary *)theInfo didFailWithError:(NSError *)theError {
	gettingGroups = NO;
	NSLog(@"MGMGoogleContacts Error: %@", theError);
}
- (void)groupsDidFinish:(NSDictionary *)theInfo {
	NSXMLElement *XML = [[[[NSXMLDocument alloc] initWithData:[theInfo objectForKey:MGMConnectionData] options:NSXMLDocumentTidyXML error:nil] autorelease] rootElement];
	NSLog(@"%@", XML);
	gettingGroups = NO;
}
@end