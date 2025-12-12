#import <UIKit/UIKit.h>

%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL ret = %orig;
    NSLog(@"[ExampleFeature] Tweak loaded");
    return ret;
}

%end
