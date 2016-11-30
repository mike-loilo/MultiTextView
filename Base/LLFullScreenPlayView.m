//
//  LLFullScreenPlayView.m
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import "LLFullScreenPlayView.h"

#pragma mark - MTContentView

@interface MTContentView : UIView
@end
@implementation MTContentView
+ (Class)layerClass {
    return CAGradientLayer.class;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    CAGradientLayer *layer = (CAGradientLayer *)self.layer;
    layer.colors = @[(id)[UIColor colorWithRed:238/255. green:130/255. blue:238/255. alpha:1].CGColor /* Violet */,
                     (id)[UIColor colorWithRed:75/255. green:0 blue:130/255. alpha:1].CGColor /* Indigo */,
                     (id)[UIColor colorWithRed:0 green:0 blue:1 alpha:1].CGColor /* Blue */,
                     (id)[UIColor colorWithRed:0 green:1 blue:0 alpha:1].CGColor /* Green */,
                     (id)[UIColor colorWithRed:1 green:1 blue:0 alpha:1].CGColor /* Yellow */,
                     (id)[UIColor colorWithRed:1 green:165/255. blue:0 alpha:1].CGColor /* Orange */,
                     (id)[UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor /* Red */];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1.0, 1.0);
    return self;
}
@end

#pragma mark - LLFullScreenPlayViewItem

@interface LLFullScreenPlayViewItem : UIView<UIScrollViewDelegate>
@property (nonatomic, readonly) UIScrollView *scroll;
@property (nonatomic, readonly) MTContentView *contentView;
@end
@implementation LLFullScreenPlayViewItem
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _scroll = [UIScrollView.alloc initWithFrame:frame];
    _scroll.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin;
    _scroll.maximumZoomScale = 20;
    _scroll.bounces = NO;
    _scroll.delegate = self;
    _scroll.contentSize = frame.size;
    _scroll.scrollsToTop = NO;
    [self addSubview:_scroll];

    _contentView = [MTContentView.alloc initWithFrame:frame];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin;
    [_scroll addSubview:_contentView];
    
    return self;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _contentView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale <= scrollView.minimumZoomScale)
        [self viewForZoomingInScrollView:scrollView].center = scrollView.center;
}
@end

#pragma mark - LLFullScreenPlayView

@implementation LLFullScreenPlayView
{
    LLFullScreenPlayViewItem *_preview;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _preview = [LLFullScreenPlayViewItem.alloc initWithFrame:frame];
    _preview.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:_preview];
    self.contentSize = frame.size;
    return self;
}
- (UIView *)currentPageContentView {
    return _preview;
}
- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _preview.scroll.userInteractionEnabled = super.scrollEnabled = scrollEnabled;
}
@end
