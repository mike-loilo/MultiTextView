//
//  LLClipTextInputViewController.h
//  MultiTextView
//
//  Created by mike on 2016/11/04.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - LLClipTextSizePickerViewController

struct TextFontSize
{
    __unsafe_unretained NSString *name;
    CGFloat fontSize;
};
@interface LLClipTextSizePickerViewController : UIViewController
- (id)initWithFontSize:(CGFloat)fontSize callback:(void (^)(struct TextFontSize textFontSize))callback;
@end

#pragma mark - LLClipTextColorPickerViewController

@interface LLClipTextColorPickerViewController : UIViewController
- (id)initWithColor:(UIColor *)color callback:(void (^)(UIColor *color))callback;
@end
