//
//  MGMKeychainItem.h
//  MGMUsers
//
//  Created by Mr. Gecko on 4/14/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>
#import <Security/Security.h>

@interface MGMKeychainItem : NSObject {
@private
    SecKeychainItemRef keychainItem;
	int error;
}
+ (id)itemWithRef:(SecKeychainItemRef)theItem;
- (id)initWithRef:(SecKeychainItemRef)theItem;
- (SecKeychainItemRef)keychainItem;
- (SecItemClass)kind;
- (NSString *)kindString;
- (BOOL)isInternetItem;
- (BOOL)isGenericItem;
- (BOOL)isAppleShareItem;
- (BOOL)isCertificate;
- (int)error;
- (NSData *)data;
- (void)setData:(NSData *)theData;
- (NSString *)string;
- (void)setString:(NSString *)theString;
- (void)setData:(NSData *)theData forAttribute:(int)theAttribute;
- (void)setBool:(BOOL)theBool forAttribute:(int)theAttribute;
- (NSData *)attributeData:(int)theAttribute;
- (void)setString:(NSString *)theString forAttribute:(int)theAttribute;
- (NSString *)attributeString:(int)theAttribute;
- (void)setCreationDate:(NSCalendarDate *)theDate;
- (NSCalendarDate *)creationDate;
- (void)setModifiedDate:(NSCalendarDate *)theDate;
- (NSCalendarDate *)modifiedDate;
- (void)setDescription:(NSString *)theDescription;
- (NSString *)description;
- (void)setComment:(NSString *)theComment;
- (NSString *)comment;
- (void)setCreator:(NSString *)theCreator;
- (NSString *)creator;
- (void)setType:(NSString *)theType;
- (NSString *)type;
- (void)setName:(NSString *)theName;
- (NSString *)name;
- (void)setVisible:(BOOL)isVisible;
- (BOOL)isVisible;
- (void)setPasswordValid:(BOOL)isPasswordValid;
- (BOOL)isPasswordValid;
- (void)setHasCustomIcon:(BOOL)hasCustomIcon;
- (BOOL)hasCustomIcon;
- (void)setAccount:(NSString *)theAccount;
- (NSString *)account;
- (void)setService:(NSString *)theService;
- (NSString *)service;
- (void)setAttribute:(NSString *)theAttribute;
- (NSString *)attribute;
- (void)setSecurityDomain:(NSString *)theSecurityDomain;
- (NSString *)securityDomain;
- (void)setServer:(NSString *)theServer;
- (NSString *)server;
- (void)setAuthenticationType:(SecAuthenticationType)theAuthenticationType;
- (SecAuthenticationType)authenticationType;
- (NSString*)authenticationTypeString;
- (void)setPort:(UInt16)thePort;
- (UInt16)port;
- (void)setVolume:(NSString *)theVolume;
- (NSString *)volume;
- (void)setAddress:(NSString *)theAddress;
- (NSString *)address;
- (void)setSignature:(SecAFPServerSignature *)theSignature;
- (SecAFPServerSignature *)signature;
- (void)setProtocol:(SecProtocolType)theProtocol;
- (SecProtocolType)protocol;
- (NSString *)protocolString;
- (void)setCertificateType:(CSSM_CERT_TYPE)theCertificateType;
- (CSSM_CERT_TYPE)certificateType;
- (void)setCertificateEncoding:(CSSM_CERT_ENCODING)theCertificateEncoding;
- (CSSM_CERT_ENCODING)certificateEncoding;
- (void)setCRLType:(CSSM_CRL_TYPE)theCRLType;
- (CSSM_CRL_TYPE)CRLType;
- (NSString*)CRLTypeString;
- (void)setCRLEncoding:(CSSM_CRL_ENCODING)theCRLEncoding;
- (CSSM_CRL_ENCODING)CRLEncoding;
- (NSString*)CRLEncodingString;
- (void)setAlias:(BOOL)isAlias;
- (BOOL)isAlias;
- (void)remove;
@end