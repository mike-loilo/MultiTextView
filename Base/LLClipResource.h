//
//  LLClipResource.h
//  MultiTextView
//
//  Created by mike on 2016/12/02.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LLPlayableResource : NSObject
@property (nonatomic, readonly) AVPlayerLayer *playerLayer;
@end

@class LLClipItem;

enum SingleResourceFlag {
    LL_SRF_NO_DRAWN_IMAGE = 1,
    LL_SRF_NO_KEN_BURNS = 2,
    LL_SRF_NO_TEXT = 4,
    LL_SRF_APPLY_INOUT = 8,
    LL_SRF_IGNORE_BGM = 0x10,
    LL_SRF_NO_VIDEO = 0x20,
    LL_SRF_NO_ANNOTATION_LAYER = 0x40,
    LL_SRF_NO_AUDIO = 0x80,
    LL_SRF_NO_NARRATION = 0x0100,
};

@interface LLClipResource : NSObject
+ (LLPlayableResource *)makeSingleResource:(LLClipItem *)item playerSize:(CGSize)size textAreaNotifier:(void(^)(NSArray *))textAreaNotifier flags:(int)flags;
@end
