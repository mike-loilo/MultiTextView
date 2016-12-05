//
//  LLClipResource.mm
//  MultiTextView
//
//  Created by mike on 2016/12/02.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import "LLClipResource.h"
#import "LLClipItem.h"
#import "LLClip.h"
#import "MultiTextView-Swift.h"
#import <UIKit/UIKit.h>

@implementation LLPlayableResource {
    LLClipResource *_resource;
}
- (id)initWithLayer:(AVPlayerLayer *)layer resource:(LLClipResource *)r {
    self = [super init];
    if (!self) return nil;
    _playerLayer = layer;
    _resource = r;
    return self;
}
@end

@implementation LLClipResource
+ (LLPlayableResource *)makeSingleResource:(LLClipItem *)item playerSize:(CGSize)size textAreaNotifier:(void(^)(NSArray *))textAreaNotifier flags:(int)flags {
    AVPlayerLayer *const playerLayer = [AVPlayerLayer.alloc init];
    playerLayer.frame = (CGRect) { .size = size };
    CAGradientLayer *layer = CAGradientLayer.layer;
    layer.colors = @[(id)[UIColor colorWithRed:238/255. green:130/255. blue:238/255. alpha:1].CGColor /* Violet */,
                     (id)[UIColor colorWithRed:75/255. green:0 blue:130/255. alpha:1].CGColor /* Indigo */,
                     (id)[UIColor colorWithRed:0 green:0 blue:1 alpha:1].CGColor /* Blue */,
                     (id)[UIColor colorWithRed:0 green:1 blue:0 alpha:1].CGColor /* Green */,
                     (id)[UIColor colorWithRed:1 green:1 blue:0 alpha:1].CGColor /* Yellow */,
                     (id)[UIColor colorWithRed:1 green:165/255. blue:0 alpha:1].CGColor /* Orange */,
                     (id)[UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor /* Red */];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1.0, 1.0);
    layer.frame = playerLayer.bounds;
    [playerLayer addSublayer:layer];
    
    if (!(flags & LL_SRF_NO_TEXT)) {
        performActionOnSubThread(^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [item.clip.richTexts enumerateObjectsUsingBlock:^(__kindof LLRichText * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LLTextHandleView *const textHandleView = [LLTextHandleView.alloc initWithRichText:obj type:LLTextHandleViewTypeNormal];
                textHandleView.movable = NO;
                textHandleView.hiddenBorder = YES;
                performActionOnMainThread(^{
                    // HTMLをちゃんとロードするためにViewをレイアウトする必要があるので注意
                    [UIApplication.sharedApplication.keyWindow addSubview:textHandleView];
                    textHandleView.didFinishNavigation = ^(id viewer, WKNavigation *navigation) {
                        LLTextHandleView *const view = (LLTextHandleView *)viewer;
                        // ちゃんと描画しておかないと意図した画像が取得できないので注意
                        [view.superview setNeedsDisplay];
                        UIImage *const image = view.screenCapture;
                        CALayer *const imageLayer = CALayer.layer;
                        imageLayer.frame = view.frame;
                        imageLayer.contents = (id)image.CGImage;
                        [playerLayer addSublayer:imageLayer];
                        [view removeFromSuperview];
                        dispatch_semaphore_signal(semaphore);
                    };
                });
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }];
        }, NULL);
    }
    
    return [LLPlayableResource.alloc initWithLayer:playerLayer resource:[LLClipResource.alloc init]];
}
@end
