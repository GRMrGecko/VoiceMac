//
//  MGMKeychainItem.h
//  MGMUsers
//
//  Created by Mr. Gecko on 4/14/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Foundation/Foundation.h>
#import <MGMUsers/MGMKeychain.h>
#import <Security/Security.h>


#if TARGET_OS_IPHONE
typedef enum {
	kSecCreationDateItemAttr,
	kSecModDateItemAttr,
	kSecDescriptionItemAttr,
	kSecCommentItemAttr,
	kSecCreatorItemAttr,
	kSecTypeItemAttr,
	kSecLabelItemAttr,
	kSecInvisibleItemAttr,
	kSecNegativeItemAttr,
	kSecAccountItemAttr,
	kSecServiceItemAttr,
	kSecGenericItemAttr,
	kSecSecurityDomainItemAttr,
	kSecServerItemAttr,
	kSecAuthenticationTypeItemAttr,
	kSecPortItemAttr,
	kSecProtocolItemAttr,
	kSecCertificateType,
	kSecCertificateEncoding
} SecItemAttributes;

typedef enum {
	kSecAuthenticationTypeNTLM,
	kSecAuthenticationTypeMSN,
	kSecAuthenticationTypeDPA,
	kSecAuthenticationTypeRPA,
	kSecAuthenticationTypeHTTPBasic,
	kSecAuthenticationTypeHTTPDigest,
	kSecAuthenticationTypeHTMLForm,
	kSecAuthenticationTypeDefault
} SecAuthenticationType;

typedef enum {
	kSecProtocolTypeFTP,
	kSecProtocolTypeFTPAccount,
	kSecProtocolTypeHTTP,
	kSecProtocolTypeIRC,
	kSecProtocolTypeNNTP,
	kSecProtocolTypePOP3,
	kSecProtocolTypeSMTP,
	kSecProtocolTypeSOCKS,
	kSecProtocolTypeIMAP,
	kSecProtocolTypeLDAP,
	kSecProtocolTypeAppleTalk,
	kSecProtocolTypeAFP,
	kSecProtocolTypeTelnet,
	kSecProtocolTypeSSH,
	kSecProtocolTypeFTPS,
	kSecProtocolTypeHTTPS,
	kSecProtocolTypeHTTPProxy,
	kSecProtocolTypeHTTPSProxy,
	kSecProtocolTypeFTPProxy,
	kSecProtocolTypeSMB,
	kSecProtocolTypeRTSP,
	kSecProtocolTypeRTSPProxy,
	kSecProtocolTypeDAAP,
	kSecProtocolTypeEPPC,
	kSecProtocolTypeIPP,
	kSecProtocolTypeNNTPS,
	kSecProtocolTypeLDAPS,
	kSecProtocolTypeTelnetS,
	kSecProtocolTypeIMAPS,
	kSecProtocolTypeIRCS,
	kSecProtocolTypePOP3S
} SecProtocolType;


// From OS X cssmtype.h
typedef enum {
    CSSM_CERT_UNKNOWN = 0x00,
    CSSM_CERT_X_509v1 = 0x01,
    CSSM_CERT_X_509v2 = 0x02,
    CSSM_CERT_X_509v3 = 0x03
} CSSM_CERT_TYPE;
typedef enum {
    CSSM_CERT_ENCODING_UNKNOWN = 0x00,
    CSSM_CERT_ENCODING_CUSTOM = 0x01,
    CSSM_CERT_ENCODING_BER = 0x02,
    CSSM_CERT_ENCODING_DER = 0x03
} CSSM_CERT_ENCODING;
#endif

@interface MGMKeychainItem : NSObject {
@private
#if TARGET_OS_IPHONE
	NSMutableDictionary *keychainItem;
	SecItemClass itemClass;
#else
    SecKeychainItemRef keychainItem;
#endif
	int error;
}
#if TARGET_OS_IPHONE
+ (id)itemWithDictionary:(NSDictionary *)theKeychainItem itemClass:(SecItemClass)theClass;
- (id)initWithDictionary:(NSDictionary *)theKeychainItem itemClass:(SecItemClass)theClass;
- (NSDictionary *)keychainItem;
#else
+ (id)itemWithRef:(SecKeychainItemRef)theItem;
- (id)initWithRef:(SecKeychainItemRef)theItem;
- (SecKeychainItemRef)keychainItem;
#endif
#if TARGET_OS_IPHONE
- (NSString *)attributeKey:(SecItemAttributes)theAttribute;
#endif
- (SecItemClass)kind;
- (NSString *)kindString;
- (BOOL)isInternetItem;
- (BOOL)isGenericItem;
#if !TARGET_OS_IPHONE
- (BOOL)isAppleShareItem;
#endif
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
- (void)setCreationDate:(NSDate *)theDate;
- (NSDate *)creationDate;
- (void)setModifiedDate:(NSDate *)theDate;
- (NSDate *)modifiedDate;
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
#if !TARGET_OS_IPHONE
- (void)setHasCustomIcon:(BOOL)hasCustomIcon;
- (BOOL)hasCustomIcon;
#endif
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
- (NSString *)authenticationTypeString;
- (void)setPort:(UInt16)thePort;
- (UInt16)port;
#if !TARGET_OS_IPHONE
- (void)setVolume:(NSString *)theVolume;
- (NSString *)volume;
- (void)setAddress:(NSString *)theAddress;
- (NSString *)address;
- (void)setSignature:(SecAFPServerSignature *)theSignature;
- (SecAFPServerSignature *)signature;
#endif
- (void)setProtocol:(SecProtocolType)theProtocol;
- (SecProtocolType)protocol;
- (NSString *)protocolString;
- (void)setCertificateType:(CSSM_CERT_TYPE)theCertificateType;
- (CSSM_CERT_TYPE)certificateType;
- (void)setCertificateEncoding:(CSSM_CERT_ENCODING)theCertificateEncoding;
- (CSSM_CERT_ENCODING)certificateEncoding;
#if !TARGET_OS_IPHONE
- (void)setCRLType:(CSSM_CRL_TYPE)theCRLType;
- (CSSM_CRL_TYPE)CRLType;
- (NSString *)CRLTypeString;
- (void)setCRLEncoding:(CSSM_CRL_ENCODING)theCRLEncoding;
- (CSSM_CRL_ENCODING)CRLEncoding;
- (NSString *)CRLEncodingString;
- (void)setAlias:(BOOL)isAlias;
- (BOOL)isAlias;
#endif
- (void)remove;
@end