#import "MLFormat.h"
#import "YTSingleVideoControllerDelegate.h"
#import "YTSingleVideo.h"

@interface YTSingleVideoController : NSObject
@property (nonatomic, weak, readwrite) NSObject <YTSingleVideoControllerDelegate> *delegate;
- (YTSingleVideo *)singleVideo;
- (YTSingleVideo *)videoData;
- (NSArray <MLFormat *> *)selectableVideoFormats;
- (BOOL)isMuted;
- (void)playerRateDidChange:(float)rate;
- (void)setMuted:(BOOL)muted;
@end
