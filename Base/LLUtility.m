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

void performActionOnMainThread(void (^action)())
{
    if (!action) return;
    
    if (NSThread.isMainThread)
        action();
    else
        dispatch_async(dispatch_get_main_queue(), action);
}

void performActionOnSubThread(void (^action)(), void (^completionOnMainThread)())
{
    if (!action) return;
    
    if (NSThread.isMainThread) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            action();
            if (completionOnMainThread) performActionOnMainThread(completionOnMainThread);
        });
    }
    else {
        action();
        if (completionOnMainThread) performActionOnMainThread(completionOnMainThread);
    }
}
