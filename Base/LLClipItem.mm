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

@end
