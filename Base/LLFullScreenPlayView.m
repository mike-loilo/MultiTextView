//
//  LLFullScreenPlayView.m
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import "LLFullScreenPlayView.h"
#import "LLClipResource.h"
#import "LLUtility.h"
#import "LLClipItem.h"
#import "LLClip.h"
#import "MultiTextView-Swift.h"

#pragma mark - LLFullScreenPlayViewItem

@interface LLFullScreenPlayViewItem : UIView<UIScrollViewDelegate>
@property (nonatomic, readonly) UIScrollView *scroll;
@property (nonatomic, readonly) UIView *contentView;
@end
@implementation LLFullScreenPlayViewItem {
    LLPlayableResource *_clipResource;
}
- (instancetype)initWithFrame:(CGRect)frame clipItem:(LLClipItem *)clipItem flags:(int)flags {
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

    _contentView = [UIView.alloc initWithFrame:frame];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin;
    [_scroll addSubview:_contentView];
    
    [self setupClipItem:clipItem flags:flags];
    
    return self;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _contentView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale <= scrollView.minimumZoomScale)
        [self viewForZoomingInScrollView:scrollView].center = scrollView.center;
}
- (void)setupClipItem:(LLClipItem *)clipItem flags:(int)flags {
    if (_clipResource)
        [_clipResource.playerLayer removeFromSuperlayer];
    // 省略
    _clipResource = [LLClipResource makeSingleResource:clipItem playerSize:self.bounds.size textAreaNotifier:NULL flags:flags];
    [_contentView.layer addSublayer:_clipResource.playerLayer];
    //TODO:- テキストカード特別対応
    // LLTextHandleViewを画像化する場合はLLClipResource側での処理で良さそうだが、LLTextHandleViewオブジェクトをそのまま保持しておくため、ここでレイアウトする
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { if ([obj isKindOfClass:LLTextHandleView.class]) [obj removeFromSuperview]; }];
    if (!(flags & LL_SRF_NO_TEXT)) {
        performActionOnSubThread(^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [clipItem.clip.richTexts enumerateObjectsUsingBlock:^(__kindof LLRichText * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LLTextHandleView *const textHandleView = [LLTextHandleView.alloc initWithRichText:obj type:LLTextHandleViewTypeNormal];
                textHandleView.movable = NO;
                textHandleView.hiddenBorder = YES;
                performActionOnMainThread(^{
                    // HTMLをちゃんとロードするためにViewをレイアウトする必要があるので注意
                    [self addSubview:textHandleView];
                    dispatch_semaphore_signal(semaphore);
                });
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }];
        }, NULL);
    }
}
- (void)dealloc {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [obj removeFromSuperview]; }];
}
@end

#pragma mark - LLFullScreenPlayView

@implementation LLFullScreenPlayView {
    LLFullScreenPlayViewItem *_preview;
}
- (instancetype)initWithFrame:(CGRect)frame clipItem:(LLClipItem *)clipItem {
    self = [super initWithFrame:frame];
    _preview = [LLFullScreenPlayViewItem.alloc initWithFrame:self.bounds clipItem:clipItem flags:0];
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
- (void)setupClipItem:(LLClipItem *)clipItem flags:(int)flags {
    [_preview setupClipItem:clipItem flags:flags];
}
@end
