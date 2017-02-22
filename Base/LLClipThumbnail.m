//
//  LLClipThumbnail.m
//  MultiTextView
//
//  Created by mike on 2017/02/22.
//  Copyright © 2017年 loilo. All rights reserved.
//

#import "LLClipThumbnail.h"
#import "LLClip.h"
#import "LLUtility.h"
#import "UIView+Snapshot.h"
#import "MultiTextView-Swift.h"

@implementation LLClipThumbnail
+ (void)create:(LLClip *)clip size:(CGSize)size ignoreLayerType:(ClipThumbnailIgnoreLayerType)ignoreLayerType callback:(void (^)(UIImage *, ClipThumbnailIgnoreLayerType ignoreLayerType_))callback
{
    performActionOnMainThread(^{
        //TODO:- テキストカード特別対応
        // 本来、LLRichTextはベースのサイズが変わったら座標やフォントサイズを変換する必要があるので注意
        // とりあえず、ベースのサイズでレイアウトしてしまって、リサイズした画像にする
        // サイズが異なる他のリソースに重ねるときは、画像化してしまってから処理した方が手間が少なそうだが、手描きや添削レイヤーみたいに指定したサイズでコンバートする処理を実装してしまえば、それでも良さそう。
        UIView *const richTextsView = [UIView.alloc initWithFrame:(CGRect) { .size = UIScreen.landscapeSize }];
        // LLTextHandleViewの都合上、実際に表示されるビューにレイアウトされないとレンダリングされないので、画像化するまでは透過状態にしておく
        richTextsView.alpha = 0;
        [UIApplication.sharedApplication.keyWindow addSubview:richTextsView];
        performActionOnSubThread(^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [clip.richTexts enumerateObjectsUsingBlock:^(__kindof LLRichText * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LLTextHandleView *const textHandleView = [LLTextHandleView.alloc initWithRichText:obj type:LLTextHandleViewTypeNormal];
                textHandleView.movable = NO;
                textHandleView.hiddenBorder = YES;
                performActionOnMainThread(^{
                    [richTextsView addSubview:textHandleView];
                    textHandleView.didFinishNavigation = ^(id viewer, WKNavigation *navigation) {
                        dispatch_semaphore_signal(semaphore);
                    };
                });
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }];
        }, ^{
#warning 本当は、アスペクト比を変えずにsizeに収まるようにリサイズする
            richTextsView.alpha = 1;
            UIImage *const image = richTextsView.snapshot;
            [richTextsView removeFromSuperview];
            if (callback) callback(image, ignoreLayerType);
        });
    });
}
@end
