//
//  MGMMiddleView.h
//  VoiceMob
//
//  Created by Mr. Gecko on 10/11/10.
//  Copyright (c) 2011 Mr. Gecko's Media (James Coleman). http://mrgeckosmedia.com/
//

#import <UIKit/UIKit.h>

extern NSString * const MGMMTitle;
extern NSString * const MGMMImage;
extern NSString * const MGMMTarget;
extern NSString * const MGMMAction;
extern NSString * const MGMMHighlighted;
extern NSString * const MGMMRect;

@class MGMMiddleView;

@interface MGMMiddleViewButton : NSObject {
	NSString *title;
	NSString *image;
	id target;
	SEL action;
	BOOL highlighted;
	CGRect rect;
}
+ (id)buttonWithTitle:(NSString *)theTitle image:(NSString *)theImage target:(id)theTarget action:(SEL)theAction;
- (id)initWithTitle:(NSString *)theTitle image:(NSString *)theImage target:(id)theTarget action:(SEL)theAction;
- (void)setTitle:(NSString *)theTitle;
- (NSString *)title;
- (void)setImage:(NSString *)theImage;
- (NSString *)image;
- (void)setTarget:(id)theTarget;
- (id)target;
- (void)setAction:(SEL)theAction;
- (SEL)action;
- (void)setHighlighted:(BOOL)isHighlighted;
- (BOOL)highlighted;
- (void)setRect:(CGRect)theRect;
- (CGRect)rect;
@end

@protocol MGMMiddleViewDelegate <NSObject>
- (void)middleViewDidCancel:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex;
- (void)middleViewDidSelect:(MGMMiddleView *)theMiddleView atIndex:(int)theIndex;
@end

@interface MGMMiddleView : UIView {
	IBOutlet id<MGMMiddleViewDelegate> delegate;
	NSMutableArray *buttons;
	CGPoint touchStartPoint;
	int touchStartIndex;
}
- (void)setDelegate:(id)theDelegate;
- (id<MGMMiddleViewDelegate>)delegate;

- (void)addButtonWithTitle:(NSString *)theTitle imageName:(NSString *)theImage target:(id)theTarget action:(SEL)theAction;
- (void)setButtons:(NSArray *)theButtons;
- (NSArray *)buttons;

- (void)updateButtonRects;

- (void)setHighlighted:(BOOL)isHighlighted forButtonAtIndex:(int)theIndex;
@end