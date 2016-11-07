//
//  LLButton.m
//  LoiloPad
//
//  Created by Kiyotaka Sasaya on 12/02/09.
//  Copyright (c) 2012年 LoiLo inc. All rights reserved.
//

#import "LLButton.h"

@implementation LLButton

- (id)init_
{
    [self setBackgroundImage:[[UIImage imageNamed:@"button_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 30)] forState:UIControlStateNormal];
    [self setBackgroundImage:[[UIImage imageNamed:@"button_pushed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 30)]forState:UIControlStateHighlighted];
    [self setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    if (7 <= UIDevice.currentDevice.systemVersion.doubleValue)
        self.tintColor = UIColor.whiteColor;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder].init_;
}

- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame].init_;
}

@end

@implementation LLButtonWithEdgeInsets

- (void)setupForState:(UIControlState)state
{
    UIImage *img = [[self backgroundImageForState:state] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 30)];
    [self setBackgroundImage:img forState:state];
}

- (id)init_
{
    [self setupForState:UIControlStateNormal];
    [self setupForState:UIControlStateHighlighted];
    [self setupForState:UIControlStateSelected];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder].init_;
}

- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame].init_;
}

@end
