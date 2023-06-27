#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <UIKit/UIKit.h>

@interface AVPlayerController : UIResponder
@end

@interface AVPictureInPictureControllerContentSource (Private)
@property(assign) bool hasInitialRenderSize;
@end

@interface AVPictureInPictureController (Private)
@property(nonatomic, retain) AVPictureInPictureControllerContentSource *contentSource API_AVAILABLE(ios(15.0)); // retain -> strong on iOS 15
- (instancetype)initWithContentSource:(AVPictureInPictureControllerContentSource *)contentSource API_AVAILABLE(ios(15.0));
- (void)sampleBufferDisplayLayerRenderSizeDidChangeToSize:(CGSize)renderSize;
- (void)sampleBufferDisplayLayerDidAppear;
- (void)sampleBufferDisplayLayerDidDisappear;
@end