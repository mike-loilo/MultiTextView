
@class UIResponder;
@class UIViewController;
@class NSString;

#ifdef __cplusplus
extern "C" {
#endif

UIViewController *findViewControllerInResponderChain(UIResponder *responder);
NSString *getUniqueID();
void performActionOnMainThread(void (^action)());
void performActionOnSubThread(void (^action)(), void (^completionOnMainThread)());

#ifdef __cplusplus
}
#endif
