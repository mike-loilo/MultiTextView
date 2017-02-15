//
//  LLClipViewController.h
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLClipItem;

@interface LLClipViewController : UIViewController

- (id)initWithClipItem:(LLClipItem *)clipItem closeCallback:(void (^)(UIImage *screenshot))closeCallback;

@end
