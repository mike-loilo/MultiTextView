//
//  LLClipViewController.m
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

#import "LLClipViewController.h"
#import "LLClip.h"
#import "LLClipItem.h"
#import "LLFullScreenPlayView.h"
#import "MultiTextView-Swift.h"

@implementation LLClipViewController
{
    __weak IBOutlet UIView *_topController;
    __weak IBOutlet UIButton *_textButton;
    __weak IBOutlet UIButton *_closeButton;
    
    __weak LLClipItem *_clipItem;
    void (^_closeCallback)();

    LLFullScreenPlayView *_playView;
    
    LLClipMultiTextInputViewController *_multiTextInputViewController;
}

- (id)initWithClipItem:(LLClipItem *)clipItem closeCallback:(void (^)())closeCallback {
    self = [super init];
    _clipItem = clipItem;
    _closeCallback = closeCallback;
    
    _playView = [LLFullScreenPlayView.alloc initWithFrame:self.view.bounds];
    _playView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleHeight
    | UIViewAutoresizingFlexibleBottomMargin;
    _playView.backgroundColor = UIColor.lightGrayColor;
    [self.view insertSubview:_playView belowSubview:_topController];
    
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
    if (_multiTextInputViewController)
        [_multiTextInputViewController dismissViewControllerAnimated:NO completion:NULL];
    
    [self presentTextInputViewControllerAnimated:YES completion:NULL];
}

- (IBAction)closeButtonDidTap:(id)sender {
    __weak typeof(self) __self = self;
    [self dismissViewControllerAnimated:YES completion:^{
        typeof(self) self = __self;
        if (!self) return;
        if (self->_closeCallback) self->_closeCallback();
    }];
}

/** テキスト入力ビューの作成 */
- (void)setupTextInputViewController
{
    __weak typeof(self) __self = self;
    _multiTextInputViewController = [LLClipMultiTextInputViewController.alloc initWithClipItem:_clipItem playView:_playView changeBGColorBlock:^(UIColor * _Nullable color) {
        typeof(self) self = __self;
        if (!self) return;
        
        NSLog(@"----- CHANGE : %@", color);
    } addClipBlock:^(LLClipItem * _Nullable item) {
        typeof(self) self = __self;
        if (!self) return;
        
        NSLog(@"+++++ ADD : %@", item);
    } closeCallback:^{
        typeof(self) self = __self;
        if (!self) return;
        
        [self dismissTextInputViewController];
    }];
    [self addChildViewController:_multiTextInputViewController];
    // viewをロードするために便宜上追加しておく
    [self.view addSubview:_multiTextInputViewController.view];
}

/** テキスト入力ビューの表示 */
- (void)presentTextInputViewControllerAnimated:(BOOL)animated completion:(void (^)())completion
{
    [self setupTextInputViewController];
    
    _playView.scrollEnabled = NO;
    [self dismissControllerAnimated:animated option:LLDismissControllerOptionAll completion:^{
        _multiTextInputViewController.controllerParent = self.view;
        [_multiTextInputViewController.view.superview insertSubview:_multiTextInputViewController.view atIndex:0];
        
        if (completion) completion();
    }];
}

/** テキスト入力ビューの非表示 */
- (void)dismissTextInputViewController
{
    _playView.scrollEnabled = YES;
    [_multiTextInputViewController.view removeFromSuperview];
    [_multiTextInputViewController removeFromParentViewController];
    _multiTextInputViewController = nil;
    
    [self presentController:LLDismissControllerOptionAll completion:NULL];
}

/** コントローラを非表示にするときのオプション */
typedef NS_ENUM(NSUInteger, LLDismissControllerOption) {
    LLDismissControllerOptionAll,   // 全て
    LLDismissControllerOptionWithoutReorder,    // 下のサムネイルを除く
    LLDismissControllerOptionWithoutPlayPauseButtonAndSeekbar,    // 再生ボタンとシークバーを除く
};
/** コントローラの非表示（別のコントローラを表示する時用） */
- (void)dismissControllerAnimated:(BOOL)animated option:(LLDismissControllerOption)option completion:(void (^)())completion
{
    _topController.frame = (CGRect) {
        .size = _topController.frame.size
    };
    _topController.alpha = 1;
    [UIView animateWithDuration:animated ? 0.25 : 0
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         _topController.frame = (CGRect) {
                             .origin.x = CGRectGetMinX(_topController.frame),
                             .origin.y = - CGRectGetHeight(_topController.frame),
                             .size = _topController.frame.size
                         };
                         _topController.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if (completion) completion();
                     }];
}

/** コントローラの表示（別のコントローラを表示していた時用） */
- (void)presentController:(LLDismissControllerOption)option completion:(void (^)())completion
{
    _topController.frame = (CGRect) {
        .origin.x = CGRectGetMinX(_topController.frame),
        .origin.y = - CGRectGetHeight(_topController.frame),
        .size = _topController.frame.size
    };
    _topController.alpha = 0;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         _topController.frame = (CGRect) {
                             .origin.x = CGRectGetMinX(_topController.frame),
                             .origin.y = 0,
                             .size = _topController.frame.size
                         };
                         _topController.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         if (completion) completion();
                     }];
}

@end
