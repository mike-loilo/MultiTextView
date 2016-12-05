//
//  LLClip.h
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - LLRichText

@interface LLRichText : NSObject<NSCopying>
- (id)initWithJson:(id)json;
@property (nonatomic) NSString *text;
@property (nonatomic) NSInteger zIndex;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;
@property (nonatomic, readonly) id serialize;
@end

#pragma mark - LLClip

@interface LLClip : NSObject

@property (nonatomic) NSMutableArray<__kindof LLRichText *> *richTexts;
- (id)initWithSavedData:(NSDictionary *)data documentId:(UInt64)documentId atIndex:(NSUInteger)index;
- (NSMutableDictionary *)serialize:(BOOL)updateAuthor;
- (void)serialize:(NSMutableDictionary *)data updateAuthor:(BOOL)updateAuthor;

@end
