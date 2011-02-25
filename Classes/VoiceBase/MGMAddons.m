//
//  NSAddons.m
//  VoiceBase
//
//  Created by Mr. Gecko on 3/4/09.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import "MGMAddons.h"
#import "MGMInbox.h"
#import "MGMXML.h"

@implementation NSString (MGMAddons)
+ (NSString *)stringWithSeconds:(int)theSeconds {
	int time = theSeconds;
	int seconds = time%60;
	time = time/60;
	int minutes = time%60;
	time = time/60;
	int hours = time%24;
    int days = time/24;
	NSString *string;
	if (days!=0) {
		string = [NSString stringWithFormat:@"%d:%02d:%02d:%02d", days, hours, minutes, seconds];
	} else if (hours!=0) {
		string = [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
	} else {
		string = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
	}
	return string;
}

- (NSString *)flattenHTML {
	NSString *xml = [NSString stringWithFormat:@"<d>%@</d>", self];
	MGMXMLElement *xmlElement = [[[MGMXMLElement alloc] initWithXMLString:xml error:nil] autorelease];
	return [xmlElement stringValue];
}
- (NSString *)replace:(NSString *)targetString with:(NSString *)replaceString {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSMutableString *temp = [NSMutableString new];
	NSRange replaceRange = NSMakeRange(0, [self length]);
	NSRange rangeInOriginalString = replaceRange;
	int replaced = 0;
	
	while (1) {
		NSRange rangeToCopy;
		NSRange foundRange = [self rangeOfString:targetString options:0 range:rangeInOriginalString];
		if (foundRange.length == 0) break;
		rangeToCopy = NSMakeRange(rangeInOriginalString.location, foundRange.location - rangeInOriginalString.location);	
		[temp appendString:[self substringWithRange:rangeToCopy]];
		[temp appendString:replaceString];
		rangeInOriginalString.length -= NSMaxRange(foundRange) -
		rangeInOriginalString.location;
		rangeInOriginalString.location = NSMaxRange(foundRange);
		replaced++;
		if (replaced % 100 == 0) {
			[pool drain];
			pool = [NSAutoreleasePool new];
		}
	}
	if (rangeInOriginalString.length > 0) [temp appendString:[self substringWithRange:rangeInOriginalString]];
	[pool drain];
	
	return [temp autorelease];
}
- (BOOL)containsString:(NSString *)string {
	return ([[self lowercaseString] rangeOfString:[string lowercaseString]].location!=NSNotFound);
}

- (NSString *)javascriptEscape {
	NSString *escaped = [self replace:@"\\" with:@"\\\\"];
	escaped = [escaped replace:@"'" with:@"\\'"];
	escaped = [escaped replace:@"\n" with:@"<br />"];
	escaped = [escaped replace:@"\r" with:@""];
	return escaped;
}

- (NSString *)filePath {
	/*NSString *path = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	if (![path hasPrefix:@"file:///"]) {
		path = [NSString stringWithFormat:@"file://%@", path];
	}
	return [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];*/
	return [[NSURL fileURLWithPath:self] absoluteString];
}

- (NSString *)littersToNumbers {
	NSMutableString *outString = [NSMutableString string];
	for (int i=0; i<[self length]; i++) {
		unichar character = [self characterAtIndex:i];
		switch (character) {
			case 'a'...'c':
			case 'A'...'C':
				character = '2';
				break;
			case 'd'...'f':
			case 'D'...'F':
				character = '3';
				break;
			case 'g'...'i':
			case 'G'...'I':
				character = '4';
				break;
			case 'j'...'l':
			case 'J'...'L':
				character = '5';
				break;
			case 'm'...'o':
			case 'M'...'O':
				character = '6';
				break;
			case 'p'...'s':
			case 'P'...'S':
				character = '7';
				break;
			case 't'...'v':
			case 'T'...'V':
				character = '8';
				break;
			case 'w'...'z':
			case 'W'...'Z':
				character = '9';
				break;
			case '0'...'9':
				break;
			default:
				character = '\0';
				break;
		}
		if (character!='\0')
			CFStringAppendCharacters((CFMutableStringRef)outString, &character, 1);
	}
	return outString;
}
- (NSString *)removePhoneWhiteSpace {
	NSString *number = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	number = [number replace:@" " with:@""];
	number = [number replace:@"-" with:@""];
	number = [number replace:@")" with:@""];
	number = [number replace:@"(" with:@""];
	number = [number replace:@"+1" with:@"1"];
	number = [number replace:@"+" with:@"011"];
	number = [number replace:@"." with:@""];
	return number;
}
- (BOOL)isPhone {
	if ([self rangeOfString:@"@"].location!=NSNotFound)
		return YES;
	NSString *number = [self removePhoneWhiteSpace];
	if ([number length]<1)
		return NO;
	return [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[number characterAtIndex:0]];
}
- (BOOL)isPhoneComplete {
	if ([self rangeOfString:@"@"].location!=NSNotFound)
		return YES;
	NSString *number = [self removePhoneWhiteSpace];
	if ([number length]<1 || ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[number characterAtIndex:0]])
		return NO;
	if ([number hasPrefix:@"011"])
		return YES;
	if ([number length]==11 && [number hasPrefix:@"1"])
		return YES;
	else if ([number length]==10 || [number length]==7)
		return YES;
	return NO;
}
- (NSString *)phoneFormatWithAreaCode:(NSString *)theAreaCode {
	if ([self rangeOfString:@"@"].location!=NSNotFound)
		return self;
	NSString *number = [[self removePhoneWhiteSpace] littersToNumbers];
	if (![number hasPrefix:@"011"]) {
		int length = [number length];
		if (length==11 && [number hasPrefix:@"1"])
			number = [NSString stringWithFormat:@"+%@", number];
		else if (length<=7)
			number = [NSString stringWithFormat:@"+1%@%@", theAreaCode, number];
		else if (length<=10)
			number = [NSString stringWithFormat:@"+1%@", number];
	}
	return number;
}
- (NSString *)phoneFormatAreaCode:(NSString *)theAreaCode {
	if ([self rangeOfString:@"@"].location!=NSNotFound)
		return self;
	NSString *number = [[self removePhoneWhiteSpace] littersToNumbers];
	if (![number hasPrefix:@"011"]) {
		int length = [number length];
		if (length==11 && [number hasPrefix:@"1"])
			number = [NSString stringWithFormat:@"+%@", number];
		else
			number = [NSString stringWithFormat:@"+1%@%@", theAreaCode, number];
	}
	return number;
}
- (NSString *)phoneFormat {
	if ([self rangeOfString:@"@"].location!=NSNotFound)
		return self;
	NSString *number = [[self removePhoneWhiteSpace] littersToNumbers];
	if (![number hasPrefix:@"011"]) {
		if ([number hasPrefix:@"1"])
			number = [NSString stringWithFormat:@"+%@", number];
		else
			number = [NSString stringWithFormat:@"+1%@", number];
	}
	return number;
}
- (NSString *)readableNumber {
	NSString *number = [[self removePhoneWhiteSpace] littersToNumbers];
	if (![number hasPrefix:@"011"]) {
		if ([number length]==10) {
			NSString *areaCode = [number substringToIndex:3];
			number = [number substringFromIndex:3];
			NSString *firstNumbers = [number substringToIndex:3];
			number = [number substringFromIndex:3];
			number = [NSString stringWithFormat:@"(%@) %@-%@", areaCode, firstNumbers, number];
		} else if ([number length]==11 && [number hasPrefix:@"1"]) {
			number = [number substringFromIndex:1];
			NSString *areaCode = [number substringToIndex:3];
			number = [number substringFromIndex:3];
			NSString *firstNumbers = [number substringToIndex:3];
			number = [number substringFromIndex:3];
			if ([areaCode isEqual:@"800"])
				number = [NSString stringWithFormat:@"1 (%@) %@-%@", areaCode, firstNumbers, number];
			else
				number = [NSString stringWithFormat:@"(%@) %@-%@", areaCode, firstNumbers, number];
		} else if ([number length]>=7 && [number length]<=10) {
			NSString *firstNumbers = [number substringToIndex:3];
			number = [number substringFromIndex:3];
			number = [NSString stringWithFormat:@"%@-%@", firstNumbers, number];
		}
	} else {
		number = [number substringFromIndex:3];
		number = [@"+" stringByAppendingString:number];
	}
	return number;
}
- (NSString *)areaCode {
	NSString *areaCode = [[self removePhoneWhiteSpace] littersToNumbers];
	if (![areaCode hasPrefix:@"011"]) {
		if ([areaCode length]>7) {
			if ([areaCode hasPrefix:@"1"])
				areaCode = [areaCode substringFromIndex:1];
			areaCode = [areaCode substringToIndex:3];
		}
		return areaCode;
	}
	return nil;
}
- (NSString *)areaCodeLocation {
	switch ([self intValue]) {
		case 200:
			return @"Service access code";
			break;
		case 201:
			return @"New Jersey - NorthEast";
			break;
		case 202:
			return @"District Of Columbia";
			break;
		case 203:
			return @"Connecticut";
			break;
		case 204:
			return @"Manitoba";
			break;
		case 205:
			return @"Alabama - Birmingham/Central Alabama";
			break;
		case 206:
			return @"Washington - Seattle";
			break;
		case 207:
			return @"Maine";
			break;
		case 208:
			return @"Idaho";
			break;
		case 209:
			return @"California - Central";
			break;
		case 210:
			return @"Texas - San Antonio";
			break;
		case 211:
			return @"Coin Phone Refunds";
			break;
		case 212:
			return @"New York - Manhattan";
			break;
		case 213:
			return @"California - Los Angeles";
			break;
		case 214:
			return @"Texas - Dallas";
			break;
		case 215:
			return @"Pennsylvania - SouthEast";
			break;
		case 216:
			return @"Ohio - Cleveland";
			break;
		case 217:
			return @"Illinois - South Central";
			break;
		case 218:
			return @"Minnesota - Northern";
			break;
		case 219:
			return @"Indiana - Northern";
			break;
		case 224:
			return @"Illinois overlay deferred";
			break;
		case 225:
			return @"Louisiana";
			break;
		case 228:
			return @"Mississippi";
			break;
		case 229:
			return @"Georgia - (split from 912)";
			break;
		case 231:
			return @"Michigan";
			break;
		case 234:
			return @"Ohio (overlay 330)";
			break;
		case 240:
			return @"Maryland";
			break;
		case 242:
			return @"Bahamas-Carib";
			break;
		case 246:
			return @"Barbados-Carib";
			break;
		case 248:
			return @"Michigan - Oakland Cty";
			break;
		case 250:
			return @"British Columbia";
			break;
		case 252:
			return @"North Carolina";
			break;
		case 253:
			return @"Washington - Tacoma";
			break;
		case 254:
			return @"Texas - Ft. Worth";
			break;
		case 256:
			return @"Alabama - Huntsville/North Alabama";
			break;
		case 262:
			return @"Wisconsin";
			break;
		case 264:
			return @"Anguilla";
			break;
		case 267:
			return @"Pennsylvania (overlay 215)";
			break;
		case 268:
			return @"Antigua/Barbuda-Carib";
			break;
		case 270:
			return @"Kentucky";
			break;
		case 278:
			return @"Michigan overlay suspended";
			break;
		case 281:
			return @"Texas - Houston";
			break;
		case 284:
			return @"British V.I.-Carib";
			break;
		case 300:
			return @"Service Access Code";
			break;
		case 301:
			return @"Maryland - Southern&Western";
			break;
		case 302:
			return @"Delaware";
			break;
		case 303:
			return @"Colorado - Northern&Western";
			break;
		case 304:
			return @"West Virginia";
			break;
		case 305:
			return @"Florida - SouthEast";
			break;
		case 306:
			return @"Saskatchewan";
			break;
		case 307:
			return @"Wyoming";
			break;
		case 308:
			return @"Nebraska - Western";
			break;
		case 309:
			return @"Illinois - West Central";
			break;
		case 310:
			return @"California - Los Angeles";
			break;
		case 311:
			return @"Reserved Special Function";
			break;
		case 312:
			return @"Illinois - Chicago";
			break;
		case 313:
			return @"Michigan - Eastern";
			break;
		case 314:
			return @"Missouri - Eastern";
			break;
		case 315:
			return @"New York - North Central";
			break;
		case 316:
			return @"Kansas - Southern";
			break;
		case 317:
			return @"Indiana - Central";
			break;
		case 318:
			return @"Louisiana - Western";
			break;
		case 319:
			return @"Iowa - Eastern";
			break;
		case 320:
			return @"Minnesota";
			break;
		case 321:
			return @"Florida Space Coast (Melbourne)";
			break;
		case 323:
			return @"California - Los Angeles";
			break;
		case 325:
			return @"Texas - San Angelo";
			break;
		case 330:
			return @"Ohio - Eastern";
			break;
		case 331:
			return @"Illinois overlay deferred";
			break;
		case 334:
			return @"Alabama - Montgomery/Mobile/Lower Alabama";
			break;
		case 336:
			return @"North Carolina";
			break;
		case 337:
			return @"Louisiana";
			break;
		case 339:
			return @"Massachusetts";
			break;
		case 340:
			return @"US Virgin Islands";
			break;
		case 341:
			return @"California";
			break;
		case 345:
			return @"Cayman Islands";
			break;
		case 347:
			return @"New York - NYC-not Mnhtn (split from 718)";
			break;
		case 351:
			return @"Massachusetts";
			break;
		case 352:
			return @"Florida - North";
			break;
		case 360:
			return @"Washington - Western";
			break;
		case 361:
			return @"Texas - (split from 512)";
			break;
		case 369:
			return @"California - (split from 707)";
			break;
		case 385:
			return @"Utah";
			break;
		case 400:
			return @"Service Access Code";
			break;
		case 401:
			return @"Rhode Island";
			break;
		case 402:
			return @"Nebraska - Eastern";
			break;
		case 403:
			return @"Alberta , Southern";
			break;
		case 404:
			return @"Georgia - Metro Atlanta";
			break;
		case 405:
			return @"Oklahoma- Southern&Western";
			break;
		case 406:
			return @"Montana";
			break;
		case 407:
			return @"Florida - Greater Orlando";
			break;
		case 408:
			return @"California - Central Coastal";
			break;
		case 409:
			return @"Texas - SouthEast";
			break;
		case 410:
			return @"Maryland - Eastern";
			break;
		case 411:
			return @"Directory Services";
			break;
		case 412:
			return @"Pennsylvania - Pittsburgh";
			break;
		case 413:
			return @"Massachusetts - Western";
			break;
		case 414:
			return @"Wisconsin - Eastern";
			break;
		case 415:
			return @"California - San Francisco";
			break;
		case 416:
			return @"Ontario - City of Toronto";
			break;
		case 417:
			return @"Missouri - SouthWest";
			break;
		case 418:
			return @"Quebec - NorthEast";
			break;
		case 419:
			return @"Ohio - NorthWest";
			break;
		case 423:
			return @"Tennessee - Eastern";
			break;
		case 424:
			return @"California (overlay 310)";
			break;
		case 425:
			return @"Washington - Seattle east suburbs";
			break;
		case 435:
			return @"Utah";
			break;
		case 440:
			return @"Ohio - Northeast";
			break;
		case 441:
			return @"Bermuda-Carib";
			break;
		case 442:
			return @"California";
			break;
		case 443:
			return @"Maryland";
			break;
		case 445:
			return @"Pennsylvania";
			break;
		case 450:
			return @"Quebec";
			break;
		case 456:
			return @"Inbound International";
			break;
		case 464:
			return @"Illinois overlay deferred";
			break;
		case 469:
			return @"Texas";
			break;
		case 473:
			return @"Grenada-Carib";
			break;
		case 475:
			return @"Connecticut - (overlay 203)";
			break;
		case 478:
			return @"Georgia";
			break;
		case 480:
			return @"Arizona - Phoenix. East Valley";
			break;
		case 484:
			return @"Pennsylvania (overlay 610)";
			break;
		case 500:
			return @"Personal Communication Svcs";
			break;
		case 501:
			return @"Arkansas";
			break;
		case 502:
			return @"Kentucky - Western";
			break;
		case 503:
			return @"Oregon - Portland tri-metro";
			break;
		case 504:
			return @"Louisiana - Eastern";
			break;
		case 505:
			return @"New Mexico";
			break;
		case 506:
			return @"New Brunswick";
			break;
		case 507:
			return @"Minnesota - Southern";
			break;
		case 508:
			return @"Massachusetts - Eastern";
			break;
		case 509:
			return @"Washington - Eastern";
			break;
		case 510:
			return @"California - East Bay Area";
			break;
		case 512:
			return @"Texas - Southern";
			break;
		case 513:
			return @"Ohio - SouthWest";
			break;
		case 514:
			return @"Quebec - Southern";
			break;
		case 515:
			return @"Iowa - Central";
			break;
		case 516:
			return @"New York - Nassau County LI";
			break;
		case 517:
			return @"Michigan - Central";
			break;
		case 518:
			return @"New York - NorthEast";
			break;
		case 519:
			return @"Ontario - SouthWest";
			break;
		case 520:
			return @"Arizona";
			break;
		case 530:
			return @"California - Northern";
			break;
		case 540:
			return @"Virginia";
			break;
		case 541:
			return @"Oregon";
			break;
		case 555:
			return @"Not Available";
			break;
		case 559:
			return @"California - Central";
			break;
		case 561:
			return @"Florida - Greater Palm Beach";
			break;
		case 562:
			return @"California - Los Angeles";
			break;
		case 564:
			return @"Washington - (overlay 360)";
			break;
		case 567:
			return @"Ohio";
			break;
		case 570:
			return @"Pennsylvania - (split 717)";
			break;
		case 571:
			return @"Virginia";
			break;
		case 573:
			return @"Missouri";
			break;
		case 580:
			return @"Oklahoma";
			break;
		case 586:
			return @"Michigan overlay suspended";
			break;
		case 600:
			return @"Canada/Services";
			break;
		case 601:
			return @"Mississippi";
			break;
		case 602:
			return @"Arizona";
			break;
		case 603:
			return @"New Hampshire";
			break;
		case 604:
			return @"British Columbia";
			break;
		case 605:
			return @"South Dakota";
			break;
		case 606:
			return @"Kentucky - Eastern";
			break;
		case 607:
			return @"New York - South Central";
			break;
		case 608:
			return @"Wisconsin - SouthWest";
			break;
		case 609:
			return @"New Jersey - Southern";
			break;
		case 610:
			return @"Pennsylvania";
			break;
		case 611:
			return @"Repair Service";
			break;
		case 612:
			return @"Minnesota - Minneapolis";
			break;
		case 613:
			return @"Ontario - SouthEast";
			break;
		case 614:
			return @"Ohio - Columbus Area";
			break;
		case 615:
			return @"Tennessee - Middle/Western";
			break;
		case 616:
			return @"Michigan - Western";
			break;
		case 617:
			return @"Massachusetts - Eastern";
			break;
		case 618:
			return @"Illinois - Southern";
			break;
		case 619:
			return @"California - San Diego, S.Cal";
			break;
		case 620:
			return @"Kansas";
			break;
		case 623:
			return @"Arizona - Phoenix. West Valley";
			break;
		case 626:
			return @"California - Pas./San Gabr.Vly";
			break;
		case 627:
			return @"California - (split from 707)";
			break;
		case 628:
			return @"California";
			break;
		case 630:
			return @"Illinois - Chicago suburbs";
			break;
		case 631:
			return @"New York - Suffolk County LI";
			break;
		case 636:
			return @"Missouri";
			break;
		case 641:
			return @"Iowa";
			break;
		case 646:
			return @"New York - Manhattan (split from 212)";
			break;
		case 647:
			return @"Ontario";
			break;
		case 649:
			return @"Turks & Caicos";
			break;
		case 650:
			return @"California - West Bay Area";
			break;
		case 651:
			return @"Minnesota - St. Paul ";
			break;
		case 657:
			return @"California";
			break;
		case 660:
			return @"Missouri";
			break;
		case 661:
			return @"California - (split from 805)";
			break;
		case 662:
			return @"Mississippi";
			break;
		case 664:
			return @"Montserrat-Carib";
			break;
		case 669:
			return @"California";
			break;
		case 670:
			return @"CNMI-Mariana Islands";
			break;
		case 671:
			return @"Guam";
			break;
		case 678:
			return @"Georgia";
			break;
		case 679:
			return @"Michigan overlay suspended";
			break;
		case 682:
			return @"Texas";
			break;
		case 700:
			return @"Service Varies by LD Carrier";
			break;
		case 701:
			return @"North Dakota";
			break;
		case 702:
			return @"Nevada - Clark County";
			break;
		case 703:
			return @"Virginia - Northern & Western";
			break;
		case 704:
			return @"North Carolina - Western";
			break;
		case 705:
			return @"Ontario - Northern";
			break;
		case 706:
			return @"Georgia - Northern";
			break;
		case 707:
			return @"California - North Coastal";
			break;
		case 708:
			return @"Illinois - NorthEast";
			break;
		case 709:
			return @"Newfndlnd, Labradr";
			break;
		case 710:
			return @"Gov Emer Telecom Svc";
			break;
		case 711:
			return @"Special Function";
			break;
		case 712:
			return @"Iowa - Western";
			break;
		case 713:
			return @"Texas - Houston Area";
			break;
		case 714:
			return @"California - Orange County";
			break;
		case 715:
			return @"Wisconsin - Northern";
			break;
		case 716:
			return @"New York - Western";
			break;
		case 717:
			return @"Pennsylvania - East Central";
			break;
		case 718:
			return @"New York - NYC except Mnhtn";
			break;
		case 719:
			return @"Colorado - SouthEast";
			break;
		case 720:
			return @"Colorado";
			break;
		case 724:
			return @"Pennsylvania - Western";
			break;
		case 727:
			return @"Florida Greater St Petersburg";
			break;
		case 731:
			return @"Tennessee";
			break;
		case 732:
			return @"New Jersey - Central";
			break;
		case 734:
			return @"Michigan - Ann Arbor/Ypsilanti";
			break;
		case 737:
			return @"Texas";
			break;
		case 740:
			return @"Ohio - SouthEast";
			break;
		case 747:
			return @"California";
			break;
		case 752:
			return @"California";
			break;
		case 757:
			return @"Virginia";
			break;
		case 758:
			return @"St. Lucia-Carib";
			break;
		case 760:
			return @"California - San Diego";
			break;
		case 763:
			return @"Minnesota - Minneapolis Suburbs";
			break;
		case 764:
			return @"California";
			break;
		case 765:
			return @"Indiana - Outside Indianapolis";
			break;
		case 767:
			return @"Dominica";
			break;
		case 770:
			return @"Georgia";
			break;
		case 773:
			return @"Illinois - Chicago";
			break;
		case 774:
			return @"Massachusetts";
			break;
		case 775:
			return @"Nevada";
			break;
		case 778:
			return @"British Columbia";
			break;
		case 780:
			return @"Alberta, Edmonton & North";
			break;
		case 781:
			return @"Massachusetts";
			break;
		case 784:
			return @"St. Vincent/Grenadines";
			break;
		case 785:
			return @"Kansas - Northern";
			break;
		case 786:
			return @"Florida - Overlay the 305 area";
			break;
		case 787:
			return @"Puerto Rico-Carib";
			break;
		case 800:
			return @"Toll-Free Calling";
			break;
		case 801:
			return @"Utah";
			break;
		case 802:
			return @"Vermont";
			break;
		case 803:
			return @"South Carolina";
			break;
		case 804:
			return @"Virginia - SouthEast";
			break;
		case 805:
			return @"California - SouthCentral";
			break;
		case 806:
			return @"Texas - North Panhandle";
			break;
		case 807:
			return @"Ontario - NorthWest";
			break;
		case 808:
			return @"Hawaii";
			break;
		case 809:
			return @"Caribbean Islands";
			break;
		case 810:
			return @"Michigan - Northern";
			break;
		case 811:
			return @"Special Function";
			break;
		case 812:
			return @"Indiana - Southern";
			break;
		case 813:
			return @"Florida - Tampa area";
			break;
		case 814:
			return @"Pennsylvania - West Central";
			break;
		case 815:
			return @"Illinois - Northern";
			break;
		case 816:
			return @"Missouri - NorthWest";
			break;
		case 817:
			return @"Texas - North Central";
			break;
		case 818:
			return @"California - SF Valley, LA area";
			break;
		case 819:
			return @"Quebec - Eastern";
			break;
		case 822:
			return @"Future Toll-Free Svc.";
			break;
		case 828:
			return @"North Carolina";
			break;
		case 830:
			return @"Texas -South, near San Antonio";
			break;
		case 831:
			return @"California, Central Coastal";
			break;
		case 832:
			return @"Texas, Houston area";
			break;
		case 833:
			return @"Future Toll-Free Svc.";
			break;
		case 835:
			return @"Pennsylvania";
			break;
		case 843:
			return @"South Carolina";
			break;
		case 844:
			return @"Future Toll-Free Svc.";
			break;
		case 845:
			return @"New York";
			break;
		case 847:
			return @"Illinois - Chicago suburbs";
			break;
		case 850:
			return @"Florida panhandle";
			break;
		case 855:
			return @"Toll-Free Svc.";
			break;
		case 856:
			return @"New Jersey - Southern";
			break;
		case 857:
			return @"Massachusetts";
			break;
		case 858:
			return @"California - (split from 619)";
			break;
		case 859:
			return @"Kentucky";
			break;
		case 860:
			return @"Connecticut";
			break;
		case 863:
			return @"Florida - South Central";
			break;
		case 864:
			return @"South Carolina";
			break;
		case 865:
			return @"Tennessee";
			break;
		case 866:
			return @"Toll-Free Svc.";
			break;
		case 867:
			return @"Yukon/N.W.Territories";
			break;
		case 868:
			return @"Trinidad and Tobago-Carib";
			break;
		case 869:
			return @"St.Kitts and Nevis-Carib";
			break;
		case 870:
			return @"Arkansas";
			break;
		case 872:
			return @"Illinois overlay deferred";
			break;
		case 876:
			return @"Jamaica";
			break;
		case 877:
			return @"Toll-Free Calling";
			break;
		case 878:
			return @"Pennsylvania";
			break;
		case 880:
			return @"Paid 800 Service";
			break;
		case 881:
			return @"Paid 888 Service";
			break;
		case 882:
			return @"Paid 877 Service";
			break;
		case 888:
			return @"Toll-Free Calling";
			break;
		case 900:
			return @"Value Added Info Svc Code";
			break;
		case 901:
			return @"Tennessee - Western";
			break;
		case 902:
			return @"Prince Edward Island, Nova Scotia ";
			break;
		case 903:
			return @"Texas - NorthEast";
			break;
		case 904:
			return @"Florida - Northeast";
			break;
		case 905:
			return @"Greater Toronto Area, except Toronto";
			break;
		case 906:
			return @"Michigan - Upper North";
			break;
		case 907:
			return @"Alaska";
			break;
		case 908:
			return @"New Jersey - Central";
			break;
		case 909:
			return @"California - Riverside&S.Bern";
			break;
		case 910:
			return @"North Carolina";
			break;
		case 911:
			return @"Emergency Services";
			break;
		case 912:
			return @"Georgia - Southern";
			break;
		case 913:
			return @"Kansas - Northern";
			break;
		case 914:
			return @"New York - Southern";
			break;
		case 915:
			return @"Texas - Western";
			break;
		case 916:
			return @"California - Sacramento";
			break;
		case 917:
			return @"New York City";
			break;
		case 918:
			return @"Oklahoma - NorthEast";
			break;
		case 919:
			return @"North Carolina - Eastern";
			break;
		case 920:
			return @"Wisconsin";
			break;
		case 925:
			return @"California - S.F.Bay area";
			break;
		case 931:
			return @"Tennessee";
			break;
		case 935:
			return @"California - (split from 619)";
			break;
		case 936:
			return @"Texas - (split from 409)";
			break;
		case 937:
			return @"Ohio - Dayton, SW Ohio";
			break;
		case 939:
			return @"Puerto Rico";
			break;
		case 940:
			return @"Texas - Ft. Worth";
			break;
		case 941:
			return @"Florida - Cape Coral area";
			break;
		case 947:
			return @"Michigan overlay suspended";
			break;
		case 949:
			return @"California - Orange County";
			break;
		case 951:
			return @"California";
			break;
		case 952:
			return @"Minnesota - Minneapolis Suburbs";
			break;
		case 954:
			return @"Florida - Greater Ft Lauderdale";
			break;
		case 956:
			return @"Texas - Laredo/Brownsville";
			break;
		case 959:
			return @"Connecticut - (overlay 860)";
			break;
		case 970:
			return @"Colorado";
			break;
		case 971:
			return @"Oregon";
			break;
		case 972:
			return @"Texas - Dallas";
			break;
		case 973:
			return @"New Jersey - Northern";
			break;
		case 978:
			return @"Massachusetts";
			break;
		case 979:
			return @"Texas";
			break;
		case 980:
			return @"North Carolina";
			break;
		case 985:
			return @"Louisiana";
			break;
		case 989:
			return @"Michigan";
			break;
	}
	return @"No Location Found";
}

- (NSString *)addPercentEscapes {
	NSString *result = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]|"), kCFStringEncodingUTF8);
	
	if (escapedString) {
		result = [NSString stringWithString:(NSString *)escapedString];
		CFRelease(escapedString);
	}
	return result;
}

#if !TARGET_OS_IPHONE
- (NSString *)truncateForWidth:(double)theWidth attributes:(NSDictionary *)theAttributes {
	NSString *endString = @"…";
	NSString *truncatedString = self;
	int truncatedStringLength = [self length];
	
	if (truncatedStringLength>2 && [truncatedString sizeWithAttributes:theAttributes].width>theWidth) {
		double targetWidth = theWidth - [endString sizeWithAttributes:theAttributes].width;
		NSCharacterSet *whiteSpaceCharacters = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		while ([truncatedString sizeWithAttributes:theAttributes].width > targetWidth && truncatedStringLength) {
			truncatedStringLength--;
			while ([whiteSpaceCharacters characterIsMember:[truncatedString characterAtIndex:truncatedStringLength-1]])
				truncatedStringLength--;
			truncatedString = [truncatedString substringToIndex:truncatedStringLength];
		}
		truncatedString = [truncatedString stringByAppendingString:endString];
	}
	
	return truncatedString;
}
#endif

NSComparisonResult dateSort(NSDictionary *info1, NSDictionary *info2, void *context) {
	NSComparisonResult result = [[info1 objectForKey:MGMITime] compare:[info2 objectForKey:MGMITime]];
	if (result==NSOrderedAscending) {
		result = NSOrderedDescending;
	} else if (result==NSOrderedDescending) {
		result = NSOrderedAscending;
	}
	return result;
}

- (BOOL)isIPAddress {
	NSArray *components = [self componentsSeparatedByString:@"."];
	if ([components count]!=4)
		return NO;
	NSCharacterSet *characterSet = [NSCharacterSet decimalDigitCharacterSet];
	for (int i=0; i<[components count]; i++) {
		NSString *component = [components objectAtIndex:i];
		if ([component length]>3)
			return NO;
		for (int c=0; c<[component length]; c++) {
			if (![characterSet characterIsMember:[component characterAtIndex:c]])
				return NO;
		}
		if ([component intValue]>255)
			return NO;
	}
	return YES;
}

#if MGMSIPENABLED
+ (NSString *)stringWithPJString:(pj_str_t)pjString {
	return [[[NSString alloc] initWithBytes:pjString.ptr length:pjString.slen encoding:NSUTF8StringEncoding] autorelease];
}
- (pj_str_t)PJString {
	return pj_str((char *)[self UTF8String]);
}
#endif
@end

@implementation NSData (MGMAddons)

- (NSData *)resizeTo:(
#if TARGET_OS_IPHONE
	CGSize
#else
	NSSize
#endif
	)theSize {
#if TARGET_OS_IPHONE
	UIImage *image = [[UIImage alloc] initWithData:self];
#else
	NSImage *image = [[NSImage alloc] initWithData:self];
#endif
	if (image==nil)
		return self;
	if (image!=nil) {
#if TARGET_OS_IPHONE
		CGSize size = [image size];
#else
		NSSize size = [image size];
#endif
		float scaleFactor = 0.0;
		float scaledWidth = theSize.width;
		float scaledHeight = theSize.height;
		
		if (
#if TARGET_OS_IPHONE
		!CGSizeEqualToSize(size, theSize)
#else
		!NSEqualSizes(size, theSize)
#endif
		) {
			float widthFactor = theSize.width / size.width;
			float heightFactor = theSize.height / size.height;
			
			if (widthFactor < heightFactor)
				scaleFactor = widthFactor;
			else
				scaleFactor = heightFactor;
			
			scaledWidth = size.width * scaleFactor;
			scaledHeight = size.height * scaleFactor;
		}
		NSData *scaledData = self;
#if TARGET_OS_IPHONE
		CGSize newSize = CGSizeMake(scaledWidth, scaledHeight);
		if (!CGSizeEqualToSize(newSize, CGSizeZero)) {
			NSAutoreleasePool *pool = [NSAutoreleasePool new];
			UIGraphicsBeginImageContext(newSize);
			[image drawInRect:CGRectMake(0, 0, scaledWidth, scaledHeight)];
			UIImage *newImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
			UIGraphicsEndImageContext();
			[pool drain];
			scaledData = UIImagePNGRepresentation(newImage);
			[newImage release];
		}
#else
		NSSize newSize = NSMakeSize(scaledWidth, scaledHeight);
		if (!NSEqualSizes(newSize, NSZeroSize)) {
			NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
			if (newImage==nil || NSEqualSizes([newImage size], NSZeroSize))
				return self;
			[newImage lockFocus];
			NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
			[graphicsContext setImageInterpolation:NSImageInterpolationHigh];
			[graphicsContext setShouldAntialias:YES];
			[image drawInRect:NSMakeRect(0, 0, scaledWidth, scaledHeight) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
			[newImage unlockFocus];
			NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[newImage TIFFRepresentation]];
			scaledData = [imageRep representationUsingType:NSPNGFileType properties:nil];
			[newImage release];
		}
#endif
		[image release];
		return scaledData;
	}
	return nil;
}
@end