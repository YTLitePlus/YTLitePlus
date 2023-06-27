#import <sys/utsname.h>
#import <rootless.h>
#import "Tweak.h"

#define UNSUPPORTED_DEVICES @[@"iPhone14,3", @"iPhone14,6", @"iPhone14,8"]
#define THRESHOLD 1.99

CGFloat constant; // Makes rendering view a bit larger since constraining to safe area leaves a gap between the notch/Dynamic Island and video
static CGFloat videoAspectRatio = 16/9;
static BOOL isZoomedToFill = NO;
static BOOL isEngagementPanelVisible = NO;
static BOOL isRemoveEngagementPanelViewControllerWithIdentifierCalled = NO;

static MLHAMSBDLSampleBufferRenderingView *renderingView;
static NSLayoutConstraint *widthConstraint, *heightConstraint, *centerXConstraint, *centerYConstraint;

static BOOL DEMC_isDeviceSupported();
static void DEMC_activateConstraints();
static void DEMC_deactivateConstraints();
static void DEMC_centerRenderingView();
void DEMC_showSnackBar(NSString *text);
NSBundle *DEMC_getTweakBundle();

%group DEMC_Tweak

// Retrieve video aspect ratio
%hook YTPlayerView
- (void)setAspectRatio:(CGFloat)aspectRatio {
    %orig(aspectRatio);
    videoAspectRatio = aspectRatio;
}
%end

%hook YTPlayerViewController
- (void)viewDidAppear:(BOOL)animated {
    YTPlayerView *playerView = [self playerView];
    UIView *renderingViewContainer = [playerView valueForKey:@"_renderingViewContainer"];
    renderingView = [playerView renderingView];

    widthConstraint = [renderingView.widthAnchor constraintEqualToAnchor:renderingViewContainer.safeAreaLayoutGuide.widthAnchor constant:constant];
    heightConstraint = [renderingView.heightAnchor constraintEqualToAnchor:renderingViewContainer.safeAreaLayoutGuide.heightAnchor constant:constant];
    centerXConstraint = [renderingView.centerXAnchor constraintEqualToAnchor:renderingViewContainer.centerXAnchor];
    centerYConstraint = [renderingView.centerYAnchor constraintEqualToAnchor:renderingViewContainer.centerYAnchor];

    if (IS_COLOR_VIEWS_ENABLED) {
        playerView.backgroundColor = [UIColor blueColor];
        renderingViewContainer.backgroundColor = [UIColor greenColor];
        renderingView.backgroundColor = [UIColor redColor];
    } else {
        playerView.backgroundColor = nil;
        renderingViewContainer.backgroundColor = nil;
        renderingView.backgroundColor = [UIColor blackColor];
    }

    YTMainAppVideoPlayerOverlayViewController *activeVideoPlayerOverlay = [self activeVideoPlayerOverlay];

    // Must check class since YTInlineMutedPlaybackPlayerOverlayViewController doesn't have -(BOOL)isFullscreen
    if ([activeVideoPlayerOverlay isKindOfClass:%c(YTMainAppVideoPlayerOverlayViewController)] &&
        [activeVideoPlayerOverlay isFullscreen] && !isZoomedToFill && !isEngagementPanelVisible)
        DEMC_activateConstraints();

    %orig(animated);
}
// New video played
- (void)playbackController:(id)playbackController didActivateVideo:(id)video withPlaybackData:(id)playbackData {
    %orig(playbackController, video, playbackData);

    isEngagementPanelVisible = NO;
    isRemoveEngagementPanelViewControllerWithIdentifierCalled = NO;

    if ([[self activeVideoPlayerOverlay] isFullscreen])
        // New video played while in full screen (landscape)
        // Activate since new videos played in full screen aren't zoomed-to-fill by default
        // (i.e. the notch/Dynamic Island will cut into content when playing a new video in full screen)
        DEMC_activateConstraints();
    else if (![self isCurrentVideoVertical] && ((YTPlayerView *)[self playerView]).userInteractionEnabled)
        DEMC_deactivateConstraints();
}
- (void)setPlayerViewLayout:(int)layout {
    %orig(layout);

    if (![[self activeVideoPlayerOverlay] isKindOfClass:%c(YTMainAppVideoPlayerOverlayViewController)]) return;

    switch (layout) {
    case 1: // Mini bar
        break;
    case 2:
        DEMC_deactivateConstraints();
        break;
    case 3: // Fullscreen
        if (!isZoomedToFill && !isEngagementPanelVisible) DEMC_activateConstraints();
        break;
    default:
        break;
    }
}
%end

// Pinch to zoom
%hook YTVideoFreeZoomOverlayView
- (void)didRecognizePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    DEMC_deactivateConstraints();
    %orig(pinchGestureRecognizer);
}
// Detect zoom to fill
- (void)showLabelForSnapState:(NSInteger)snapState {
    if (snapState == 0) { // Original
        isZoomedToFill = NO;
        DEMC_activateConstraints();
    } else if (snapState == 1) { // Zoomed to fill
        isZoomedToFill = YES;
        // No need to deactivate constraints as it's already done in -(void)didRecognizePinch:(UIPinchGestureRecognizer *)
    }
    %orig(snapState);
}
%end

// Mini bar dismiss
%hook YTWatchMiniBarViewController
- (void)dismissMiniBarWithVelocity:(CGFloat)velocity gestureType:(int)gestureType {
    %orig(velocity, gestureType);
    isZoomedToFill = NO; // YouTube undoes zoom-to-fill when mini bar is dismissed
}
- (void)dismissMiniBarWithVelocity:(CGFloat)velocity gestureType:(int)gestureType skipShouldDismissCheck:(BOOL)skipShouldDismissCheck {
    %orig(velocity, gestureType, skipShouldDismissCheck);
    isZoomedToFill = NO;
}
%end

%hook YTMainAppEngagementPanelViewController
// Engagement panel (comment, description, etc.) about to show up
- (void)viewWillAppear:(BOOL)animated {
    if ([self isPeekingSupported]) {
        // Shorts (only Shorts support peeking, I think)
    } else {
        // Everything else
        isEngagementPanelVisible = YES;
        if ([self isLandscapeEngagementPanel]) {
            DEMC_deactivateConstraints();
        }
    }
    %orig(animated);
}
%end

%hook YTEngagementPanelContainerViewController
// Engagement panel about to dismiss
- (void)notifyEngagementPanelContainerControllerWillHideFinalPanel {
    // Crashes if plays new video while in full screen causing engagement panel dismissal
    // Must check if engagement panel was dismissed because new video played
    // (i.e. if -(void)removeEngagementPanelViewControllerWithIdentifier:(id) was called prior)
    if (![self isPeekingSupported] && !isRemoveEngagementPanelViewControllerWithIdentifierCalled) {
        isEngagementPanelVisible = NO;
        if ([self isLandscapeEngagementPanel] && !isZoomedToFill) {
            DEMC_activateConstraints();
        }
    }
    %orig;
}
- (void)removeEngagementPanelViewControllerWithIdentifier:(id)identifier {
    // Usually called when engagement panel is open & new video is played or mini bar is dismissed
    isRemoveEngagementPanelViewControllerWithIdentifierCalled = YES;
    %orig(identifier);
}
%end

%end // group DEMC_Tweak

%group DEMC_UnsupportedDevice

// Get tweak settings' index path & prevent it from being opened on unsupported devices
id settingsCollectionView;
NSIndexPath *tweakIndexPath;
%hook YTCollectionViewController
- (id)collectionView:(id)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YTSettingsCell *cell = %orig;
    if ([cell isKindOfClass:%c(YTSettingsCell)]) {
        YTLabel *title = [cell valueForKey:@"_titleLabel"];
        if ([title.text isEqualToString:DEMC]) {
            settingsCollectionView = collectionView;
            tweakIndexPath = indexPath;
        }
    }
    return cell;
}
- (BOOL)collectionView:(id)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == settingsCollectionView && indexPath == tweakIndexPath) {
        NSBundle *bundle = DEMC_getTweakBundle();
        DEMC_showSnackBar(LOCALIZED_STRING(@"UNSUPPORTED_DEVICE"));
        return NO;
    }
    return %orig;
}
%end

%end // group DEMC_UnsupportedDevice

%ctor {
    if (!DEMC_isDeviceSupported()) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ENABLED_KEY];
        %init(DEMC_UnsupportedDevice);
        return;
    }

    constant = [[NSUserDefaults standardUserDefaults] floatForKey:SAFE_AREA_CONSTANT_KEY];
    if (constant == 0) { // First launch probably
        constant = DEFAULT_CONSTANT;
        [[NSUserDefaults standardUserDefaults] setFloat:constant forKey:SAFE_AREA_CONSTANT_KEY];
    }
    if (IS_TWEAK_ENABLED) %init(DEMC_Tweak);
}

static BOOL DEMC_isDeviceSupported() {
    // Get device model identifier (e.g. iPhone14,4)
    // https://stackoverflow.com/a/11197770/19227228
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModelId = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    NSArray *unsupportedModelIds = UNSUPPORTED_DEVICES;
    for (NSString *identifier in unsupportedModelIds) {
        if ([deviceModelId isEqualToString:identifier]) {
            return NO;
        }
    }

    if ([deviceModelId containsString:@"iPhone"]) {
        if ([deviceModelId isEqualToString:@"iPhone13,1"]) {
            // iPhone 12 mini
            return YES;
        }
        NSString *modelNumber = [[deviceModelId stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@"."];
        if ([modelNumber floatValue] >= 14.0) {
            // iPhone 13 series and newer
            return YES;
        } else return NO;
    } else return NO;
}

static void DEMC_activateConstraints() {
    if (videoAspectRatio < THRESHOLD) {
        DEMC_deactivateConstraints();
        return;
    }
    // NSLog(@"activate");
    DEMC_centerRenderingView();
    renderingView.translatesAutoresizingMaskIntoConstraints = NO;
    widthConstraint.active = YES;
    heightConstraint.active = YES;
}

static void DEMC_deactivateConstraints() {
    // NSLog(@"deactivate");
    renderingView.translatesAutoresizingMaskIntoConstraints = YES;
}

static void DEMC_centerRenderingView() {
    centerXConstraint.active = YES;
    centerYConstraint.active = YES;
}

void DEMC_showSnackBar(NSString *text) {
    YTHUDMessage *message = [%c(YTHUDMessage) messageWithText:text];
    GOOHUDManagerInternal *manager = [%c(GOOHUDManagerInternal) sharedInstance];
    [manager showMessageMainThread:message];
}

NSBundle *DEMC_getTweakBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"DontEatMyContent" ofType:@"bundle"];
        if (bundlePath)
            bundle = [NSBundle bundleWithPath:bundlePath];
        else // Rootless
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/DontEatMyContent.bundle")];
    });
    return bundle;
}