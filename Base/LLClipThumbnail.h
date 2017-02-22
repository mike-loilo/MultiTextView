//
//  LLClipThumbnail.h
//  MultiTextView
//
//  Created by mike on 2017/02/22.
//  Copyright © 2017年 loilo. All rights reserved.
//

#import <UIKit/UIKit.h>

/** サムネイル作成時に無視するレイヤー */
typedef NS_OPTIONS(NSUInteger, ClipThumbnailIgnoreLayerType) {
    CTILT_NONE = 0x01,
    CTILT_TEXT = 0x02,  // テキスト
    CTILT_EXTENSION = 0x04, // 手描き
    CTILT_ANNOTATION = 0x08,    // 添削
};

@class LLClip;

@interface LLClipThumbnail : NSObject
+ (void)create:(LLClip *)clip size:(CGSize)size ignoreLayerType:(ClipThumbnailIgnoreLayerType)ignoreLayerType callback:(void (^)(UIImage *, ClipThumbnailIgnoreLayerType ignoreLayerType))callback;
@end
