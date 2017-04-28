//
//  NSObject+observers.h
//  fan
//
//  Created by mike on 2014/01/31.
//  Copyright (c) 2014年 mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (observers)

/* オブジェクトを監視しているオブザーバーのリスト */
@property (nonatomic, readonly) NSArray *observers;

/* 指定したオブザーバーに、指定したキーで監視されているかどうか */
- (BOOL)observedByObserver:(NSObject *)observer keyPath:(NSString *)keyPath;

/* 指定したオブザーバーに、指定したキーで監視されているなら除外する */
- (BOOL)tryRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
