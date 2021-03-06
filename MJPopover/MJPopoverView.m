//
//  MJPopoverView.m
//  Popover
//
//  Created by Michael Lyons on 8/12/13.
//  Copyright (c) 2013 MJ Lyco LLC (http://mjlyco.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "MJPopoverView.h"
#import "MJArrowView.h"

#define kMJPopoverMargin 10.0
#define kMJPopoverPadding 0.0
#define kMJPopoverArrowHeight 13.0
#define kMJPopoverArrowWidth 26.0
#define kMJPopoverMinimumHeight 100.0
#define kMJPopoverMinimumWidth 80.0

@implementation MJPopoverView
{
    UIPopoverArrowDirection _arrowDirections;
    __weak MJPopoverContainerViewController *_popoverContainerVC;
    __weak MJArrowView *_arrowView;
    __weak UIView *_popoverView;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view = [super hitTest:point withEvent:event];
    if(view == self)
    {
        view = nil;
    }
    return view;
}

- (id)initFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections withPopoverContainerViewController:(MJPopoverContainerViewController*)popoverContainerVC
{
    self = [super init];
    if (self != nil)
    {
        _arrowDirections = arrowDirections;
        _popoverContainerVC = popoverContainerVC;

		self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.0;

        [self calculateGeometryFromRect:rect inView:view];
        [_popoverView addSubview:_popoverContainerVC.MJPopoverController.contentViewController.view];
    }
    return self;
}

- (void)animatePopover
{
    _arrowView.alpha = 1.0;
    _popoverView.alpha = 1.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
#warning TODO: Better animation
    /*
    CGAffineTransform originalTransform = _popoverView.transform;
    CGRect originalFrame = _popoverView.frame;
    _popoverView.center = _arrowView.center;
    __block CGRect frame = _popoverView.frame;
    _popoverView.transform = CGAffineTransformMakeScale(0.1, 0.05);

    [UIView animateKeyframesWithDuration:0.25 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{

        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            _arrowView.alpha = 1.0;
        }];

        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.2 animations:^{
            frame.origin.x = originalFrame.origin.x;
            _popoverView.transform = originalTransform;
            _popoverView.frame = frame;
            _popoverView.transform = CGAffineTransformMakeScale(1.0, 0.05);
        }];

        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:1.0 animations:^{
            _popoverView.transform = originalTransform;
            _popoverView.frame = originalFrame;
            _popoverView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];

    } completion:nil];
     */
}

- (void)calculateGeometryFromRect:(CGRect)rect inView:(UIView*)view
{
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    while (rootVC.presentedViewController) rootVC = rootVC.presentedViewController;
    self.frame = rootVC.view.bounds;

    CGRect startFrame = CGRectZero;
    startFrame.size = _popoverContainerVC.MJPopoverController.popoverContentSize;
    startFrame.size.width += kMJPopoverPadding*2.0;
    startFrame.size.height += kMJPopoverPadding*2.0;
    startFrame.origin = [view convertRect:rect toView:rootVC.view].origin;
    if (!IS_IOS_7_OR_GREATER)
    {
        startFrame.origin.y -= [UIApplication sharedApplication].statusBarFrame.size.height;
    }

    // calculateFrameAndArrowDirectionFromRectで扱う'rect'は、'view'座標系ではなく'rootVC.view'座標系
    rect = [view convertRect:rect toView:rootVC.view];
    if (![self calculateFrameAndArrowDirectionFromRect:rect withStartFrame:startFrame permittedArrowDirections:_arrowDirections forceFit:NO])
    {
        NSLog(@"The popover did not fit. We will try to auto-resize.");

        if (![self calculateFrameAndArrowDirectionFromRect:rect withStartFrame:startFrame permittedArrowDirections:_arrowDirections forceFit:YES])
        {
            if (_arrowDirections == UIPopoverArrowDirectionAny)
            {
                NSLog(@"We could not get the popover to fit!");
            }
            else
            {
                NSLog(@"The popover did not fit. We will try all arrow directions.");

                if (![self calculateFrameAndArrowDirectionFromRect:rect withStartFrame:startFrame permittedArrowDirections:UIPopoverArrowDirectionAny forceFit:YES])
                {
                    NSLog(@"We could not get the popover to fit!");
                }
            }
        }
    }
}

- (BOOL)calculateFrameAndArrowDirectionFromRect:(CGRect)rect withStartFrame:(CGRect)startFrame permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections forceFit:(BOOL)forceFit
{
    BOOL frameFitsInSuperview = NO;
    CGRect frame = CGRectZero;
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    while (rootVC.presentedViewController) rootVC = rootVC.presentedViewController;
    UIPopoverArrowDirection arrowDirection = UIPopoverArrowDirectionUp;

    while (arrowDirection <= UIPopoverArrowDirectionRight)
    {
        if (arrowDirections & arrowDirection)
        {
            frame = startFrame;

            switch (arrowDirection)
            {
                case UIPopoverArrowDirectionUp:
                {
                    frame.origin.y = startFrame.origin.y + rect.size.height + kMJPopoverArrowHeight;
                    frame.origin.x = rect.origin.x - (frame.size.width - rect.size.width) / 2.0;
                    CGRect intersect = CGRectIntersection(frame, rootVC.view.bounds);
                    if (!CGRectEqualToRect(intersect, frame))
                    {
                        if (frame.origin.x > 0)
                        {
                            frame.origin.x -= frame.size.width - intersect.size.width;
                        }
                        else
                        {
                            frame.origin.x += frame.size.width - intersect.size.width;
                        }
                    }

                    if (frame.origin.x < kMJPopoverMargin)
                    {
                        frame.origin.x = kMJPopoverMargin;
                    }
                    else if (frame.origin.x + frame.size.width > rootVC.view.bounds.size.width - kMJPopoverMargin)
                    {
                        frame.origin.x = rootVC.view.bounds.size.width - frame.size.width - kMJPopoverMargin;
                    }

                    if (forceFit)
                    {
                        intersect = CGRectIntersection(frame, rootVC.view.bounds);
                        if (!CGRectEqualToRect(intersect, frame))
                        {
                            frame.size = intersect.size;

                            CGFloat maxWidth = rootVC.view.bounds.size.width - kMJPopoverMargin*2.0;
                            if (maxWidth < kMJPopoverMinimumWidth)
                            {
                                frame.size.width = MAXFLOAT;
                            }
                            else if (frame.size.width > maxWidth)
                            {
                                frame.origin.x = kMJPopoverMargin;
                                frame.size.width = maxWidth;
                            }

                            CGFloat maxHeight = rootVC.view.bounds.size.height - startFrame.origin.y - rect.size.height - kMJPopoverArrowHeight - kMJPopoverMargin - ((IS_IOS_7_OR_GREATER) ? 0.0 : 20.0);

                            if (maxHeight < kMJPopoverMinimumHeight)
                            {
                                frame.size.height = MAXFLOAT;
                            }
                            else if (frame.size.height > maxHeight)
                            {
                                frame.size.height = maxHeight;
                            }
                        }
                    }
                }
                    break;

                case UIPopoverArrowDirectionDown:
                {
                    frame.origin.y = startFrame.origin.y - kMJPopoverArrowHeight - frame.size.height;
                    frame.origin.x = rect.origin.x - (frame.size.width - rect.size.width) / 2.0;
                    CGRect intersect = CGRectIntersection(frame, rootVC.view.bounds);
                    if (!CGRectEqualToRect(intersect, frame))
                    {
                        if (frame.origin.x > 0)
                        {
                            frame.origin.x -= frame.size.width - intersect.size.width;
                        }
                        else
                        {
                            frame.origin.x += frame.size.width - intersect.size.width;
                        }
                    }

                    if (frame.origin.x < kMJPopoverMargin)
                    {
                        frame.origin.x = kMJPopoverMargin;
                    }
                    else if (frame.origin.x + frame.size.width > rootVC.view.bounds.size.width - kMJPopoverMargin)
                    {
                        frame.origin.x = rootVC.view.bounds.size.width - frame.size.width - kMJPopoverMargin;
                    }

                    if (forceFit)
                    {
                        intersect = CGRectIntersection(frame, rootVC.view.bounds);
                        if (!CGRectEqualToRect(intersect, frame))
                        {
                            frame.size = intersect.size;
                            frame.origin.y = startFrame.origin.y - kMJPopoverArrowHeight - frame.size.height;

                            CGFloat maxWidth = rootVC.view.bounds.size.width - kMJPopoverMargin*2.0;
                            if (maxWidth < kMJPopoverMinimumWidth)
                            {
                                frame.size.width = MAXFLOAT;
                            }
                            else if (frame.size.width > maxWidth)
                            {
                                frame.origin.x = kMJPopoverMargin;
                                frame.size.width = maxWidth;
                            }

                            CGFloat maxHeight = startFrame.origin.y - kMJPopoverArrowHeight - kMJPopoverMargin - 20.0;

                            if (maxHeight < kMJPopoverMinimumHeight)
                            {
                                frame.size.height = MAXFLOAT;
                            }
                            else if (frame.size.height > maxHeight)
                            {
                                frame.size.height = maxHeight;
                                frame.origin.y = startFrame.origin.y - kMJPopoverArrowHeight - frame.size.height;
                            }
                        }
                    }
                }
                    break;

                case UIPopoverArrowDirectionRight:
                {
                    frame.origin.x = startFrame.origin.x - frame.size.width - kMJPopoverArrowHeight;
                    frame.origin.y = rect.origin.y - (frame.size.height - rect.size.height) / 2.0;
                    CGRect intersect = CGRectIntersection(frame, rootVC.view.bounds);
                    if (!CGRectEqualToRect(intersect, frame))
                    {
                        if (frame.origin.y > 0)
                        {
                            frame.origin.y -= frame.size.height - intersect.size.height;
                        }
                        else
                        {
                            frame.origin.y += frame.size.height - intersect.size.height;
                        }
                    }

                    if (frame.origin.y < kMJPopoverMargin)
                    {
                        frame.origin.y = kMJPopoverMargin;
                    }
                    else if (frame.origin.y + frame.size.height > rootVC.view.bounds.size.height - kMJPopoverMargin)
                    {
                        frame.origin.y = rootVC.view.bounds.size.height - frame.size.height - kMJPopoverMargin;
                    }

                    if (forceFit)
                    {
                        intersect = CGRectIntersection(frame, rootVC.view.bounds);
                        if (!CGRectEqualToRect(intersect, frame))
                        {
                            frame.size = intersect.size;
                            frame.origin.x = startFrame.origin.x - frame.size.width - kMJPopoverArrowHeight;

                            CGFloat maxWidth = startFrame.origin.x - kMJPopoverArrowHeight - kMJPopoverMargin;
                            if (maxWidth < kMJPopoverMinimumWidth)
                            {
                                frame.size.width = MAXFLOAT;
                            }
                            else if (frame.size.width > maxWidth)
                            {
                                frame.origin.x = kMJPopoverMargin;
                                frame.size.width = maxWidth;
                            }

                            CGFloat maxHeight = rootVC.view.bounds.size.height - kMJPopoverMargin*2.0 - ((IS_IOS_7_OR_GREATER) ? 0.0 : 20.0);

                            if (maxHeight < kMJPopoverMinimumHeight)
                            {
                                frame.size.height = MAXFLOAT;
                            }
                            else if (frame.size.height > maxHeight)
                            {
                                frame.origin.y = kMJPopoverMargin;
                                frame.size.height = maxHeight;
                            }

                        }
                    }
                }
                    break;

                case UIPopoverArrowDirectionLeft:
                {
                    frame.origin.x = startFrame.origin.x + rect.size.width + kMJPopoverArrowHeight;
                    frame.origin.y = rect.origin.y - (frame.size.height - rect.size.height) / 2.0;
                    CGRect intersect = CGRectIntersection(frame, rootVC.view.bounds);
                    if (!CGRectEqualToRect(intersect, frame))
                    {
                        if (frame.origin.y > 0)
                        {
                            frame.origin.y -= frame.size.height - intersect.size.height;
                        }
                        else
                        {
                            frame.origin.y += frame.size.height - intersect.size.height;
                        }
                    }

                    if (frame.origin.y < kMJPopoverMargin)
                    {
                        frame.origin.y = kMJPopoverMargin;
                    }
                    else if (frame.origin.y + frame.size.height > rootVC.view.bounds.size.height - kMJPopoverMargin)
                    {
                        frame.origin.y = rootVC.view.bounds.size.height - frame.size.height - kMJPopoverMargin;
                    }

                    if (forceFit)
                    {
                        intersect = CGRectIntersection(frame, rootVC.view.bounds);
                        if (!CGRectEqualToRect(intersect, frame))
                        {
                            frame.size = intersect.size;
                            frame.origin.x = startFrame.origin.x + rect.size.width + kMJPopoverArrowHeight;

                            CGFloat maxWidth = rootVC.view.bounds.size.width - startFrame.origin.x - rect.size.width - kMJPopoverArrowHeight - kMJPopoverMargin;
                            if (maxWidth < kMJPopoverMinimumWidth)
                            {
                                frame.size.width = MAXFLOAT;
                            }
                            else if (frame.size.width > maxWidth)
                            {
                                frame.size.width = maxWidth;
                                frame.origin.x = startFrame.origin.x + rect.size.width + kMJPopoverArrowHeight;
                            }

                            CGFloat maxHeight = rootVC.view.bounds.size.height - kMJPopoverMargin*2.0 - ((IS_IOS_7_OR_GREATER) ? 0.0 : 20.0);

                            if (maxHeight < kMJPopoverMinimumHeight)
                            {
                                frame.size.height = MAXFLOAT;
                            }
                            else if (frame.size.height > maxHeight)
                            {
                                frame.origin.y = kMJPopoverMargin;
                                frame.size.height = maxHeight;
                            }
                        }
                    }
                }
                    break;

                default:
                    break;
            }

            CGRect intersect = CGRectIntersection(frame, rootVC.view.bounds);
            if (CGRectEqualToRect(intersect, frame))
            {
                frameFitsInSuperview = YES;
                [self layoutViewFromRect:rect withStartFrame:startFrame popoverRect:frame andArrowDirection:arrowDirection];
                break;
            }
        }

        arrowDirection <<= 1;
    }

    return frameFitsInSuperview;
}

- (void)layoutViewFromRect:(CGRect)rect withStartFrame:(CGRect)startFrame popoverRect:(CGRect)frame andArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    while (rootVC.presentedViewController) rootVC = rootVC.presentedViewController;

    switch (arrowDirection)
    {
        case UIPopoverArrowDirectionUp:
            rect.origin.y = startFrame.origin.y + rect.size.height;
            rect.origin.x = startFrame.origin.x + (rect.size.width/2.0) - (kMJPopoverArrowWidth/2.0);
            rect.size.width = kMJPopoverArrowWidth;
            rect.size.height = kMJPopoverArrowHeight + kMJPopoverArrowHeightBleed;

            if (rect.origin.x < kMJPopoverMargin)
            {
                rect.origin.x = kMJPopoverMargin;
            }
            else
            {
                CGFloat difference = kMJPopoverMargin - (rootVC.view.frame.size.width - rect.origin.x - rect.size.width);
                if (difference > 0)
                {
                    rect.origin.x -= difference;
                }
            }
            break;

        case UIPopoverArrowDirectionDown:
            rect.origin.y = startFrame.origin.y - kMJPopoverArrowHeight - kMJPopoverArrowHeightBleed;
            rect.origin.x = startFrame.origin.x + (rect.size.width/2.0) - (kMJPopoverArrowWidth/2.0);
            rect.size.width = kMJPopoverArrowWidth;
            rect.size.height = kMJPopoverArrowHeight + kMJPopoverArrowHeightBleed;

            if (rect.origin.x < kMJPopoverMargin)
            {
                rect.origin.x = kMJPopoverMargin;
            }
            else
            {
                CGFloat difference = kMJPopoverMargin - (rootVC.view.frame.size.width - rect.origin.x - rect.size.width);
                if (difference > 0)
                {
                    rect.origin.x -= difference;
                }
            }
            break;

        case UIPopoverArrowDirectionLeft:
            rect.origin.y = startFrame.origin.y + (rect.size.height/2.0) - (kMJPopoverArrowWidth/2.0);
            rect.origin.x = startFrame.origin.x + rect.size.width;
            rect.size.width = kMJPopoverArrowHeight + kMJPopoverArrowHeightBleed;
            rect.size.height = kMJPopoverArrowWidth;

            if (rect.origin.y < kMJPopoverMargin)
            {
                rect.origin.y = kMJPopoverMargin;
            }
            else
            {
                CGFloat difference = kMJPopoverMargin - (rootVC.view.frame.size.height - rect.origin.y - rect.size.height);
                if (difference > 0)
                {
                    rect.origin.y -= difference;
                }
            }
            break;

        case UIPopoverArrowDirectionRight:
            rect.origin.y = startFrame.origin.y + (rect.size.height/2.0) - (kMJPopoverArrowWidth/2.0);
            rect.origin.x = startFrame.origin.x - kMJPopoverArrowHeight - kMJPopoverArrowHeightBleed;
            rect.size.width = kMJPopoverArrowHeight + kMJPopoverArrowHeightBleed;
            rect.size.height = kMJPopoverArrowWidth;

            if (rect.origin.y < kMJPopoverMargin)
            {
                rect.origin.y = kMJPopoverMargin;
            }
            else
            {
                CGFloat difference = kMJPopoverMargin - (rootVC.view.frame.size.height - rect.origin.y - rect.size.height);
                if (difference > 0)
                {
                    rect.origin.y -= difference;
                }
            }
            break;

        default:
            break;
    }

    if (_arrowView == nil)
    {
        MJArrowView *arrowView = [[MJArrowView alloc] initWithFrame:rect andArrowDirection:arrowDirection];
        arrowView.alpha = 0.0;
        [self addSubview:arrowView];
        _arrowView = arrowView;
    }
    else
    {
        [_arrowView setFrame:rect andArrowDirection:arrowDirection];
    }

    if (_popoverView == nil)
    {
        // 簡易の磨りガラス効果のため、UIToolbarを使う
        UIToolbar *popoverView = [[UIToolbar alloc] initWithFrame:frame];
        popoverView.userInteractionEnabled = YES;
        [popoverView setClipsToBounds:YES];
        [popoverView.layer setCornerRadius:10.0];
        popoverView.alpha = 0.0;
        [self addSubview:popoverView];
        _popoverView = popoverView;
    }
    else
    {
        [_popoverView setFrame:frame];
    }

    self.popoverFrame = frame;

    frame.origin = CGPointZero;
    [_popoverContainerVC.MJPopoverController.contentViewController.view setFrame:frame];
}

@end
