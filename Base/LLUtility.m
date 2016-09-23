#import "LLUtility.h"
#import <UIKit/UIKit.h>

UIViewController *findViewControllerInResponderChain(UIResponder *responder)
{
    UIResponder *next = responder.nextResponder;
    if ([next isKindOfClass:UIViewController.class])
        return (UIViewController *)next;
    else if ([next isKindOfClass:UIView.class])
        return findViewControllerInResponderChain(next);
    else
        return nil;
}
