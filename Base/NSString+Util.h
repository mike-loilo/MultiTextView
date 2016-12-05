//
//  NSString+Util.h
//  LoiloPad
//
//  Created by mike on 2015/07/17.
//
//

#import <Foundation/Foundation.h>

#pragma mark - NSString (isDecimalDigit)

@interface NSString (isDecimalDigit)
- (BOOL)isDecimalDigit;
@end

#pragma mark - NSString (isMeaningful)

@interface NSString (isMeaningful)
- (BOOL)isMeaningful;
@end


#pragma mark - NSString (unsignedValues)

@interface NSString (unsignedValues)
@property (nonatomic, readonly) UInt64 unsignedLongLongValue;
@end

#pragma mark - NSString (withoutNewline)

@interface NSString (withoutNewline)
/** 改行無しの文字列 */
- (NSString *)withoutNewline;
@end

#pragma mark - NSString (GraphemeLength)

@interface NSString (GraphemeLength)
/** 見た目通りの文字数（一部を除き、絵文字も一文字としてカウントする） */
- (NSUInteger)graphemeLength;
@end

#pragma mark - NSString (escapedString)

@interface NSString (escapedString)
/** 禁則文字をエスケープした文字列 */
- (NSString *)escapedString;
@end
