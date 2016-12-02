//
//  LLClipItem.h
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LLClip;

@interface LLClipItem : NSObject

@property (nonatomic, readonly) LLClip *clip;
- (NSDictionary *)serialize:(BOOL)updateAuthor positionOffset:(CGPoint)positionOffset;
- (id)initWithSavedData:(NSDictionary *)data documentId:(UInt64)documentId atIndex:(NSUInteger)index;

@end
