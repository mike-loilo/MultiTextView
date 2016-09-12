//
//  LLClipViewController.m
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import "LLClipViewController.h"
#import "MultiTextView-Swift.h"

@implementation LLClipViewController
{
    __weak IBOutlet UIButton *_textButton;
    __weak IBOutlet UIButton *_closeButton;
    void (^_closeCallback)();
    
    LLClipMultiTextInputViewController *_multiTextInputViewController;
}

- (id)initWithCloseCallback:(void (^)())closeCallback {
    self = [super init];
    _closeCallback = closeCallback;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.75];
        _textButton.tintColor = [UIColor colorWithRed:0.25 green:0.6 blue:1 alpha:1];
    }
    else {
        self.view.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.75];
        _textButton.tintColor = [UIColor colorWithRed:0.5 green:0.8 blue:1 alpha:1];
    }
    _closeButton.tintColor = _textButton.tintColor;
}

- (void)dealloc { NSLog(@"%s", __FUNCTION__); }

- (BOOL)prefersStatusBarHidden { return true; }

- (IBAction)textButtonDidTap:(id)sender {
    NSLog(@"##### TEXT");
    if (_multiTextInputViewController)
        [_multiTextInputViewController dismissViewControllerAnimated:NO completion:NULL];
    
    __weak typeof(self) __self = self;
    _multiTextInputViewController = [LLClipMultiTextInputViewController.alloc initWithCloseCallback:^{
        typeof(self) self = __self;
        if (!self) return;
        _multiTextInputViewController = nil;
    }];
    [self presentViewController:_multiTextInputViewController animated:YES completion:NULL];
}

- (IBAction)closeButtonDidTap:(id)sender {
    __weak typeof(self) __self = self;
    [self dismissViewControllerAnimated:YES completion:^{
        typeof(self) self = __self;
        if (!self) return;
        if (self->_closeCallback) self->_closeCallback();
    }];
}

@end
