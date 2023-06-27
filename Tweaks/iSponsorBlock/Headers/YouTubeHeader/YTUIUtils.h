#import <UIKit/UIKit.h>

@interface YTUIUtils : NSObject
+ (BOOL)canOpenURL:(NSURL *)url;
+ (BOOL)openURL:(NSURL *)url;
+ (UIViewController *)topViewControllerForPresenting;
@end