//
//  LLClipTextInputViewController.h
//  MultiTextView
//
//  Created by mike on 2016/11/04.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import <UIKit/UIKit.h>

struct TextFontSize
{
    __unsafe_unretained NSString *name;
    CGFloat fontSize;
};
@interface LLClipTextSizePickerViewController : UIViewController
- (id)initWithFontSize:(CGFloat)fontSize callback:(void (^)(struct TextFontSize textFontSize))callback;
@end
