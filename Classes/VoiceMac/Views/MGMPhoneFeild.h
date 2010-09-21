//
//  MGMPhoneFeild.h
//  VoiceMac
//
//  Created by Mr. Gecko on 7/15/10.
//  Copyright (c) 2010 Mr. Gecko's Media (James Coleman). All rights reserved. http://mrgeckosmedia.com/
//

#import <Cocoa/Cocoa.h>

@protocol MGMPhoneFieldDelegate <NSObject>
- (void)filterContacts;
@end


@interface MGMPhoneField : NSTextField {
	IBOutlet id<MGMPhoneFieldDelegate> phoneDelegate;
}
- (void)setPhoneDelegate:(id)thePhoneDelegate;
- (id<MGMPhoneFieldDelegate>)phoneDelegate;
@end

@interface MGMPhoneFieldCell : NSTextFieldCell {
	NSButtonCell *clearButton;
}
- (NSButtonCell *)clearButton;
- (NSRect)clearButtonRectForBounds:(NSRect)bounds;
- (NSRect)textRectForBounds:(NSRect)bounds includeButtons:(BOOL)buttons;
@end

@interface MGMPhoneFieldView : NSTextView {
	IBOutlet id<MGMPhoneFieldDelegate> phoneDelegate;
}
- (void)setPhoneDelegate:(id)thePhoneDelegate;
- (id<MGMPhoneFieldDelegate>)phoneDelegate;
@end