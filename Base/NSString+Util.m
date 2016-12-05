//
//  NSString+Util.m
//  LoiloPad
//
//  Created by mike on 2015/07/17.
//
//

#import "NSString+Util.h"

#pragma mark - NSString (isDecimalDigit)

@implementation NSString (isDecimalDigit)
- (BOOL)isDecimalDigit
{
    return [NSCharacterSet.decimalDigitCharacterSet isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:self]];
}
@end

#pragma mark - NSString (isMeaningful)

@implementation NSString (isMeaningful)
- (BOOL)isMeaningful
{
    return self && 0 < [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length;
}
@end

#pragma mark - NSString (unsignedValues)

@implementation NSString (unsignedValues)
- (UInt64)unsignedLongLongValue
{
    return strtoull([self UTF8String], NULL, 0);
}
@end

#pragma mark - NSString (withoutNewline)

@implementation NSString (withoutNewline)
- (NSString *)withoutNewline
{
    // 改行無しの文字列にする
    NSMutableString *withoutNewline = @"".mutableCopy;
    [self enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [withoutNewline appendString:line];
    }];
    return withoutNewline;
}
@end

#pragma mark - NSString (GraphemeLength)

@implementation NSString (GraphemeLength)
- (NSUInteger)graphemeLength
{
    NSString *withoutNewline = self.withoutNewline;
    __block NSUInteger length = 0;
    [self.withoutNewline enumerateSubstringsInRange:NSMakeRange(0, withoutNewline.length)
                                       options:NSStringEnumerationByComposedCharacterSequences
                                    usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                        length++;
                                    }];
    return length;
}
@end

#pragma mark - NSString (escapedString)

@implementation NSString (escapedString)
- (NSString *)escapedString
{
    if (!self.isMeaningful) return self;
    NSString *const validName = [[NSRegularExpression regularExpressionWithPattern:@"[\\r\\n\\t]+" options:0 error:nil] stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@" "];
    NSRegularExpression *const regex = [NSRegularExpression regularExpressionWithPattern:@"[\\r\\n\\t\\\\/:;\\?\\*<>\"\\|]+" options:0 error:nil];
    return [regex stringByReplacingMatchesInString:validName options:0 range:NSMakeRange(0, validName.length) withTemplate:@""];
}
@end
