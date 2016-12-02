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

NSString *getUniqueID()
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *s = (id)CFBridgingRelease(CFUUIDCreateString(NULL,uuid));
    CFRelease(uuid);
    return s;
}
