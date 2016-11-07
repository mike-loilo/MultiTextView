//
//  LLClipTextInputViewController.m
//  MultiTextView
//
//  Created by mike on 2016/11/04.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import "LLClipTextInputViewController.h"
#import "MultiTextView-Swift.h"

static UIColor *TEXT_COLORS[] =
{
    [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1],
    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1],
    [UIColor colorWithRed:0.81960785 green:0.18039216 blue:0.12156863 alpha:1],
    [UIColor colorWithRed:0.8980392 green:0.5137255 blue:0.22352941 alpha:1],
    [UIColor colorWithRed:1.0 green:0.9019608 blue:0.0 alpha:1],
    [UIColor colorWithRed:0.9529412 green:0.7529412 blue:3.137255e-2 alpha:1],
    [UIColor colorWithRed:0.6431373 green:0.77254903 blue:0.1254902 alpha:1],
    [UIColor colorWithRed:3.529412e-2 green:0.6392157 blue:9.411765e-2 alpha:1],
    [UIColor colorWithRed:0.43137255 green:0.7176471 blue:0.85882354 alpha:1],
    [UIColor colorWithRed:0.0 green:0.47843137 blue:0.7176471 alpha:1],
    [UIColor colorWithRed:1.0 green:0.62352943 blue:0.6745098 alpha:1],
    [UIColor colorWithRed:0.80784315 green:0.34117648 blue:0.60784316 alpha:1],
    [UIColor colorWithRed:0.98039216 green:0.89411765 blue:0.83137256 alpha:1],
    [UIColor colorWithRed:0.4392157 green:0.25490198 blue:0.10980392 alpha:1],
    [UIColor colorWithRed:0.6666667 green:0.6666667 blue:0.6666667 alpha:1],
};
static const int TEXT_COLORS_COUNT = sizeof TEXT_COLORS / sizeof(UIColor *);

static struct TextFontSize TEXT_SIZE[5] = { { NSLocalizedString(@"266", nil) /* 極小 */, 15 }, { NSLocalizedString(@"036", nil) /* 小 */, 30 }, { NSLocalizedString(@"037", nil) /* 中 */, 40 }, { NSLocalizedString(@"038", nil) /* 大 */, 50 }, { NSLocalizedString(@"039", nil) /* 特大 */, 80 } };
static const int TEXT_SIZE_COUNT = sizeof TEXT_SIZE / sizeof(struct TextFontSize);

#pragma mark - LLClipTextSizePickerViewController

/** テキストサイズの選択ビュー */
@interface LLClipTextSizePickerViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
@end
@implementation LLClipTextSizePickerViewController
{
    CGFloat _fontSize;
    __strong void (^_callback)(TextFontSize);
    
    __weak UIPickerView *_picker;
}
- (id)initWithFontSize:(CGFloat)fontSize callback:(void (^)(struct TextFontSize textFontSize))callback;
{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    _fontSize = fontSize;
    _callback = callback;
    return self;
}
- (void)loadView
{
    UIPickerView *picker = [UIPickerView.alloc initWithFrame:CGRectMake(0, 0, 70, 200)];
    _picker = picker;
    self.view = picker;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _picker.showsSelectionIndicator = YES;
    _picker.delegate = self;
    _picker.dataSource = self;
    
    NSInteger sel = 0;
    for (; sel < TEXT_SIZE_COUNT; ++sel) {
        if (_fontSize * 10 == (NSInteger)round(TEXT_SIZE[sel].fontSize * 10)) break;
    }
    sel = MIN(sel, TEXT_SIZE_COUNT - 1);
    [_picker selectRow:sel inComponent:0 animated:NO];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return TEXT_SIZE_COUNT;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return TEXT_SIZE[row].name;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_callback) _callback(TEXT_SIZE[row]);
}
@end

#pragma mark - LLClipTextColorPickerViewController

/** テキストカラーの選択ビュー */
@interface LLClipTextColorPickerViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
- (id)initWithColor:(UIColor *)color callback:(void (^)(UIColor *color))callback;
@end
@implementation LLClipTextColorPickerViewController
{
    UIColor *_color;
    __strong void (^_callback)(UIColor *);
    
    __weak UIPickerView *_picker;
}
- (id)initWithColor:(UIColor *)color callback:(void (^)(UIColor *color))callback
{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    _color = color;
    _callback = callback;
    return self;
}
- (void)loadView
{
    UIPickerView *picker = [UIPickerView.alloc initWithFrame:CGRectMake(0, 0, 70, 200)];
    _picker = picker;
    self.view = picker;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _picker.showsSelectionIndicator = YES;
    _picker.delegate = self;
    _picker.dataSource = self;
    
    NSInteger sel = 0;
    for (; sel < TEXT_COLORS_COUNT; ++sel) {
        if ([_color maybeEqual:TEXT_COLORS[sel]]) break;
    }
    sel = MIN(sel, TEXT_COLORS_COUNT - 1);
    [_picker selectRow:sel inComponent:0 animated:NO];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return TEXT_COLORS_COUNT;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
{
    if (!view)
        view = [UIView.alloc initWithFrame:CGRectMake(0, 0, 40, 20)];
    view.backgroundColor = TEXT_COLORS[row];
    return view;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_callback) _callback(TEXT_COLORS[row]);
}
@end
