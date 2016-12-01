//
//  LLClip.mm
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import "LLClip.h"

static id nn(id obj) { return NSNull.null == obj ? nil : obj; }
static id _nn(id obj) { return obj ?: NSNull.null; }

#pragma mark - LLRichText

@implementation LLRichText
- (id)initWithJson:(id)json
{
    self = [super init];
    
    _text = nn(json[@"text"]);
    _zIndex = [nn(json[@"zindex"]) integerValue];
    _origin = CGPointZero;
    if (id originValue = nn(json[@"origin"]))
        _origin = CGPointMake([originValue[@"x"] floatValue], [originValue[@"y"] floatValue]);
    if (id sizeValue = nn(json[@"size"]))
        _size = CGSizeMake([sizeValue[@"width"] floatValue], [sizeValue[@"height"] floatValue]);
    
    return self;
}
- (BOOL)isEqual:(id)object
{
    if ([super isEqual:object]) return YES;
    return [object isKindOfClass:self.class]
    && [self.text isEqualToString:[(LLRichText *)object text]]
    && self.zIndex == [(LLRichText *)object zIndex]
    && CGPointEqualToPoint(self.origin, [(LLRichText *)object origin])
    && CGSizeEqualToSize(self.size, [(LLRichText *)object size]);
}
- (NSString *)description { return self.debugDescription; }
- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p; frame = {%@, %@}; zIndex = %ld; text = %@>",
            NSStringFromClass(self.class),
            self,
            NSStringFromCGPoint(_origin),
            NSStringFromCGSize(_size),
            _zIndex,
            _text];
}
- (id)serialize
{
    return @{@"text": _nn(_text),
             @"zindex": @(_zIndex),
             @"origin": @{@"x": @(_origin.x), @"y": @(_origin.y)},
             @"size": @{@"width": @(_size.width), @"height": @(_size.height)}};
}
@end

#pragma mark - LLClip

@implementation LLClip

- (id)init
{
    self = [super init];
    if (!self) return nil;
    _richTexts = @[].mutableCopy;
    return self;
}

@end
