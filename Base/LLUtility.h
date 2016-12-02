
@class UIResponder;
@class UIViewController;
@class NSString;

#ifdef __cplusplus
extern "C" {
#endif

UIViewController *findViewControllerInResponderChain(UIResponder *responder);
NSString *getUniqueID();

#ifdef __cplusplus
}
#endif
