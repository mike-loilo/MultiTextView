//
//  LLFullScreenPlayView.h
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLClipItem;

@interface LLFullScreenPlayView : UIScrollView

- (instancetype)initWithFrame:(CGRect)frame clipItem:(LLClipItem *)clipItem;
@property (nonatomic, readonly) UIView *currentPageContentView;
- (void)setupClipItem:(LLClipItem *)clipItem flags:(int)flags;

@end
