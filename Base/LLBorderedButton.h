//
//  LLBorderedButton.h
//  LoiloPad
//
//  Created by Kiyotaka Sasaya on 10/7/14.
//
//

#import <UIKit/UIKit.h>

@interface LLBorderedButton : UIButton
- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)setBorderWidth:(CGFloat)width;
- (void)setCornerRadius:(CGFloat)cornerRadius;

- (void)setWhiteStyle;
- (void)setLabelStyle;

+ (instancetype)whiteButtonWithFrame:(CGRect)frame;
@end
