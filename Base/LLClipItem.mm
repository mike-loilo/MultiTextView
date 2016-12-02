//
//  LLClipItem.mm
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import "LLClipItem.h"
#import "LLClip.h"

@implementation LLClipItem

- (id)init
{
    self = super.init;
    if (!self) return nil;
    _clip = [LLClip.alloc init];
    return self;
}
- (NSDictionary *)serialize:(BOOL)updateAuthor positionOffset:(CGPoint)positionOffset
{
    return [_clip serialize:updateAuthor];
}
- (id)initWithSavedData:(NSDictionary *)data documentId:(UInt64)documentId atIndex:(NSUInteger)index
{
    self = super.init;
    _clip = [LLClip.alloc initWithSavedData:data documentId:documentId atIndex:index];
    return self;
}

@end
