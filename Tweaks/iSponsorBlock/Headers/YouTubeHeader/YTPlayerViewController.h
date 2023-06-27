#import <UIKit/UIKit.h>
#import "GIMMe.h"
#import "YTPlaybackController.h"
#import "YTSingleVideoController.h"

@interface YTPlayerViewController : UIViewController <YTPlaybackController>
@property (nonatomic, readonly, assign) BOOL isPlayingAd;
@property (nonatomic, strong, readwrite) NSString *channelID;
- (GIMMe *)gimme; // Deprecated
- (NSString *)currentVideoID;
- (YTSingleVideoController *)activeVideo;
- (CGFloat)currentVideoMediaTime;
- (CGFloat)currentVideoTotalMediaTime;
- (int)playerViewLayout;
- (BOOL)isMDXActive;
- (void)didPressToggleFullscreen;
- (void)setMuted:(BOOL)muted;
- (void)setPlayerViewLayout:(int)layout;
- (void)scrubToTime:(CGFloat)time; // Deprecated
- (void)seekToTime:(CGFloat)time;
@end
