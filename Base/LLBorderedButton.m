//
//  LLBorderedButton.m
//  LoiloPad
//
//  Created by Kiyotaka Sasaya on 10/7/14.
//
//

#import "LLBorderedButton.h"
#import "MultiTextView-Swift.h"
#import <QuartzCore/CALayer.h>

@implementation LLBorderedButton
{
    // cornerRadiusが設定されている場合、カーブしている部分で背景色が滲んでしまう
    // そのため、背景色用のレイヤーを使って、そのレイヤーでハイライトも実現する
    CALayer *_backgroundLayer;
    UIColor *_backgroundColor;
}

- (instancetype)_init
{
    self.layer.borderWidth = 1 * UIScreen.scaleToStandard;
    self.layer.cornerRadius = 5 * UIScreen.scaleToStandard;
    self.layer.shadowRadius = 0;
    self.layer.shadowColor = nil;
    
    _backgroundLayer = CALayer.new;
    _backgroundLayer.cornerRadius = self.layer.cornerRadius;
    _backgroundLayer.frame = CGRectInset(self.layer.bounds, self.layer.borderWidth * 0.5, self.layer.borderWidth * 0.5);
    _backgroundLayer.shadowRadius = self.layer.shadowRadius;
    _backgroundLayer.shadowColor = self.layer.shadowColor;
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
    
    self.tintColor = UIColor.blueColor;
    self.backgroundColor = UIColor.whiteColor;
    return self;
}

- (instancetype)init
{
    return super.init._init;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame]._init;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder]._init;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _backgroundLayer.frame = CGRectInset(self.layer.bounds, self.layer.borderWidth * 0.5, self.layer.borderWidth * 0.5);
    [CATransaction commit];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _backgroundLayer.backgroundColor = (highlighted ? self.tintColor : _backgroundColor).CGColor;
    [super setHighlighted:highlighted];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setTitleColor:tintColor forState:UIControlStateNormal];
    self.layer.borderColor = tintColor.CGColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    _backgroundLayer.backgroundColor = backgroundColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)width
{
    self.layer.borderWidth = width;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _backgroundLayer.frame = CGRectInset(self.layer.bounds, self.layer.borderWidth * 0.5, self.layer.borderWidth * 0.5);
    [CATransaction commit];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    _backgroundLayer.cornerRadius = cornerRadius * MIN(CGRectGetWidth(self.layer.bounds) / CGRectGetWidth(_backgroundLayer.bounds), CGRectGetHeight(self.layer.bounds) / CGRectGetHeight(_backgroundLayer.bounds));
}

- (void)setWhiteStyle
{
    self.userInteractionEnabled = YES;
    self.borderWidth = 2 * UIScreen.scaleToStandard;
    self.cornerRadius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) * 0.45;
    self.backgroundColor = [UIColor colorWithRed:46/255. green:100/255. blue:124/255. alpha:0.75];
    self.tintColor = UIColor.whiteColor;
    [self setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
}

- (void)setLabelStyle
{
    self.userInteractionEnabled = NO;
    self.borderWidth = 0;
    self.cornerRadius = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) * 0.3;
    self.backgroundColor = UIColor.whiteColor;
    [self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
}

+ (instancetype)whiteButtonWithFrame:(CGRect)frame
{
    LLBorderedButton *button = [LLBorderedButton.alloc initWithFrame:frame];
    [button setWhiteStyle];
    return button;
}

@end
