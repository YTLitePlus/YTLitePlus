//
//  YTHFSTweak.x
//
//  Created by Joshua Seltzer on 12/5/22.
//
//

#import "YTHFSHeaders.h"
#import "YTHFSPrefsManager.h"

@interface YTPlayerViewController (YTHFS)

// the long press gesture that will be created and added to the player view
@property (nonatomic, retain) UILongPressGestureRecognizer *YTHFSLongPressGesture;

// switch between the user-selected playback rate and the normal playback rate, invoked either via the hold gesture or
// automatically when the video starts (dependent on settings)
- (void)YTHFSSwitchPlaybackRate;

@end

// define some non-configurable defaults for the long press gesture
#define kYTHFSNormalPlaybackRate        1.0
#define kYTHFSNumTouchesRequired        1
#define kYTHFSAllowableMovement         50

// the static variables to keep track of the settings which shall persist until the YTPlayerViewController is recreated
static CGFloat sYTHFSTogglePlaybackRate;
static BOOL sYTHFSHapticFeedbackEnabled;
static BOOL sYTHFSAutoApplyRateEnabled;

// enum to define the direction of the playback rate feedback indicator
typedef enum YTHFSFeedbackDirection : NSInteger {
    kYTHFSFeedbackDirectionForward,
    kYTHFSFeedbackDirectionBackward
} YTHFSFeedbackDirection;

%hook YTWatchLayerViewController

// invoked when the player view controller is either created or destroyed
- (void)watchController:(YTWatchController *)watchController didSetPlayerViewController:(YTPlayerViewController *)playerViewController
{
    if (playerViewController) {
        // grab the state of the settings for this instance of the player view controller
        sYTHFSTogglePlaybackRate = [YTHFSPrefsManager togglePlaybackRate];
        sYTHFSHapticFeedbackEnabled = [YTHFSPrefsManager hapticFeedbackEnabled];

        // check to see if the toggle rate should automatically be applied when the video starts
        sYTHFSAutoApplyRateEnabled = [YTHFSPrefsManager autoApplyRateEnabled];

        // add a long press gesture to configure the playback rate
        if ([YTHFSPrefsManager holdGestureEnabled]) {
            // check to see if the long press gesture is already created
            if (!playerViewController.YTHFSLongPressGesture) {
                playerViewController.YTHFSLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:playerViewController
                                                                                                           action:@selector(YTHFSHandleLongPressGesture:)];
                playerViewController.YTHFSLongPressGesture.numberOfTouchesRequired = kYTHFSNumTouchesRequired;
                playerViewController.YTHFSLongPressGesture.allowableMovement = kYTHFSAllowableMovement;
                [playerViewController.playerView addGestureRecognizer:playerViewController.YTHFSLongPressGesture];
            }

            // update the minimum press duration with whatever the user set in the settings
            playerViewController.YTHFSLongPressGesture.minimumPressDuration = [YTHFSPrefsManager holdDuration];
        }
    }

    %orig;
}

%end

%hook YTPlayerViewController

// the long press gesture that will be created and added to the player view
%property (nonatomic, retain) UILongPressGestureRecognizer *YTHFSLongPressGesture;

%new
- (void)YTHFSHandleLongPressGesture:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan && [self.contentVideoPlayerOverlay isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayViewController")]) {
        YTMainAppVideoPlayerOverlayViewController *overlayViewController = (YTMainAppVideoPlayerOverlayViewController *)self.contentVideoPlayerOverlay;
        if (overlayViewController.isVarispeedAvailable) {
            [self YTHFSSwitchPlaybackRate];
        }
    }
}

%new
- (void)YTHFSSwitchPlaybackRate
{
    NSString *feedbackTitle = nil;
    YTHFSFeedbackDirection feedbackDirection = kYTHFSFeedbackDirectionForward;
    CGFloat currentPlaybackRate = [self currentPlaybackRateForVarispeedSwitchController:self.varispeedController];
    if (currentPlaybackRate != sYTHFSTogglePlaybackRate) {
        // change to the toggle rate if the current playback rate is any other speed
        [self varispeedSwitchController:self.varispeedController didSelectRate:sYTHFSTogglePlaybackRate];
        feedbackTitle = [YTHFSPrefsManager playbackRateStringForValue:sYTHFSTogglePlaybackRate];
        if (currentPlaybackRate > sYTHFSTogglePlaybackRate) {
            feedbackDirection = kYTHFSFeedbackDirectionBackward;
        }
    } else {
        // otherwise switch back to the default rate
        [self varispeedSwitchController:self.varispeedController didSelectRate:kYTHFSNormalPlaybackRate];
        feedbackTitle = [YTHFSPrefsManager localizedStringForKey:@"NORMAL" withDefaultValue:@"Normal"];
        if (currentPlaybackRate > kYTHFSNormalPlaybackRate) {
            feedbackDirection = kYTHFSFeedbackDirectionBackward;
        }
    }

    // if the overlay controls are displayed, ensure to hide them before displaying the visual indicator
    if (![self arePlayerControlsHidden] && [self.contentVideoPlayerOverlay isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayViewController")]) {
        YTMainAppVideoPlayerOverlayViewController *overlayViewController = (YTMainAppVideoPlayerOverlayViewController *)self.contentVideoPlayerOverlay;
        [overlayViewController hidePlayerControlsAnimated:YES];
    }

    // trigger the double tap to seek view to visibly indicate that the playback rate has changed
    if ([self.playerView.overlayView isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayView")]) {
        YTMainAppVideoPlayerOverlayView *overlayView = (YTMainAppVideoPlayerOverlayView *)self.playerView.overlayView;
        [overlayView.doubleTapToSeekView showCenteredSeekFeedbackWithTitle:feedbackTitle direction:feedbackDirection];
    }

    // fire off haptic feedback to indicate that the playback rate changed (only applies to supported devices if enabled)
    if (sYTHFSHapticFeedbackEnabled) {
        UINotificationFeedbackGenerator *feedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
        [feedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
        feedbackGenerator = nil;
    }
}

// invoked when a video (or ad) is activated inside the player
- (void)playbackController:(id)localPlaybackController didActivateVideo:(id)singleVideoController withPlaybackData:(id)playbackData
{
    %orig;

    if (sYTHFSAutoApplyRateEnabled && [self.contentVideoPlayerOverlay isKindOfClass:objc_getClass("YTMainAppVideoPlayerOverlayViewController")]) {
        YTMainAppVideoPlayerOverlayViewController *overlayViewController = (YTMainAppVideoPlayerOverlayViewController *)self.contentVideoPlayerOverlay;
        if (overlayViewController.isVarispeedAvailable) {
            // regardless of the current playback rate, at this point we know that the toggle rate will be applied
            sYTHFSAutoApplyRateEnabled = NO;

            // compare whether or not the current playback rate is what the user selected and if not, change to it now
            if ([self currentPlaybackRateForVarispeedSwitchController:self.varispeedController] != sYTHFSTogglePlaybackRate) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self YTHFSSwitchPlaybackRate];
                });
            }
        }
    }
}

- (void)dealloc
{
    // remove and destroy the gesture recognizer if it exists
    if (self.YTHFSLongPressGesture) {
        [self.playerView removeGestureRecognizer:self.YTHFSLongPressGesture];
        self.YTHFSLongPressGesture = nil;
    }

    %orig;
}

%end

%hook YTMainAppVideoPlayerOverlayView

// override the long press gesture recognizer that is used to invoke the seek gesture
- (void)setSeekAnywhereLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (![YTHFSPrefsManager holdGestureEnabled]) {
        %orig;
    }
}

// override the pan gesture recognizer that is used to invoke the seek gesture
- (void)setSeekAnywherePanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognzier
{
    if (![YTHFSPrefsManager holdGestureEnabled]) {
        %orig;
    }
}

// override the long press gesture recognizer that is used to invoke the seek gesture (introduced with YouTube 18.05.2)
- (void)setLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (![YTHFSPrefsManager holdGestureEnabled]) {
        %orig;
    }
}

%end

%ctor {
    // ensure that the default preferences are available
    [YTHFSPrefsManager registerDefaults];
}