//
//  NSObject+observers.m
//  fan
//
//  Created by mike on 2014/01/31.
//  Copyright (c) 2014年 mike. All rights reserved.
//

#import "NSObject+observers.h"

@implementation NSObject (observers)

- (NSArray *)observances
{
    return [(__bridge id)(self.observationInfo) valueForKey:@"_observances"];
}

- (NSArray *)observers
{
    __block NSMutableArray *__observers = @[].mutableCopy;
    [self.observances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [__observers addObject:[obj valueForKey:@"_observer"]];
    }];
    return __observers;
}

- (BOOL)observedByObserver:(NSObject *)observer keyPath:(NSString *)keyPath
{
    __block BOOL observed = NO;
    [self.observances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj valueForKey:@"_observer"] isEqual:observer]
            && [[obj valueForKeyPath:@"_property._keyPath"] isEqualToString:keyPath]) {
            observed = YES;
            *stop = YES;
        }
    }];
    return observed;
}

- (BOOL)tryRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    if ([self observedByObserver:observer keyPath:keyPath]) {
        [self removeObserver:observer forKeyPath:keyPath];
        return YES;
    }
    else {
        return NO;
    }
}

@end
