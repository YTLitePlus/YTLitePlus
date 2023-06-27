#import "YTMainAppVideoPlayerOverlayView.h"
#import "YTPlayerViewController.h"

@interface YTMainAppVideoPlayerOverlayViewController : UIViewController
- (YTMainAppVideoPlayerOverlayView *)videoPlayerOverlayView;
- (YTPlayerViewController *)delegate;
@end