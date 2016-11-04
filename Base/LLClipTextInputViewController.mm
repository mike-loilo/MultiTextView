//
//  LLClipTextInputViewController.m
//  MultiTextView
//
//  Created by mike on 2016/11/04.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import "LLClipTextInputViewController.h"

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
