#import "YTLitePlus.h"

NSBundle *YTLitePlusBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTLitePlus" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/YTLitePlus.bundle")];
    });
    return bundle;
}
NSBundle *tweakBundle = YTLitePlusBundle();

// Keychain fix
static NSString *accessGroupID() {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status != errSecSuccess)
            return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];

    return accessGroup;
}

# pragma mark - Tweaks

// Activate FLEX
%hook YTAppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    BOOL didFinishLaunching = %orig;

    if (IsEnabled(@"flex_enabled")) {
        [[FLEXManager sharedManager] showExplorer];
    }

    return didFinishLaunching;
}
- (void)appWillResignActive:(id)arg1 {
    %orig;
        if (IsEnabled(@"flex_enabled")) {
        [[FLEXManager sharedManager] showExplorer];
    }
}
%end

// Enable Alternate Icons
%hook UIApplication
- (BOOL)supportsAlternateIcons {
    return YES;
}
%end

/* TEMP-DISABLED
// Fix Google Sign in by @PoomSmart, @level3tjg & Dayanch96 (qnblackcat/uYouPlus#684)
BOOL isSelf() {
    NSArray *address = [NSThread callStackReturnAddresses];
    Dl_info info = {0};
    if (dladdr((void *)[address[2] longLongValue], &info) == 0) return NO;
    NSString *path = [NSString stringWithUTF8String:info.dli_fname];
    return [path hasPrefix:NSBundle.mainBundle.bundlePath];
}
%hook NSBundle
- (NSString *)bundleIdentifier {
    return isSelf() ? "com.google.ios.youtube" : %orig;
}
- (NSDictionary *)infoDictionary {
    NSDictionary *dict = %orig;
    if (!isSelf())
        return %orig;
    NSMutableDictionary *info = [dict mutableCopy];
    if (info[@"CFBundleIdentifier"]) info[@"CFBundleIdentifier"] = @"com.google.ios.youtube";
    if (info[@"CFBundleDisplayName"]) info[@"CFBundleDisplayName"] = @"YouTube";
    if (info[@"CFBundleName"]) info[@"CFBundleName"] = @"YouTube";
    return info;
}
- (id)objectForInfoDictionaryKey:(NSString *)key {
    if (!isSelf())
        return %orig;
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return @"com.google.ios.youtube";
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return @"YouTube";
    return %orig;
}
%end
*/

// Skips content warning before playing *some videos - @PoomSmart
%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert { [self confirmAlertDidPressConfirm]; }
%end

// YTMiniPlayerEnabler: https://github.com/level3tjg/YTMiniplayerEnabler/
%hook YTWatchMiniBarViewController
- (void)updateMiniBarPlayerStateFromRenderer {
    if (IsEnabled(@"ytMiniPlayer_enabled")) {}
    else { return %orig; }
}
%end

# pragma mark - Hide SponsorBlock Button
%hook YTRightNavigationButtons
- (void)didMoveToWindow {
    %orig;
}

- (void)layoutSubviews {
    %orig;
    if (IsEnabled(@"hideSponsorBlockButton_enabled")) { 
        self.sponsorBlockButton.hidden = YES;
    }
}
%end

// Hide Video Player Cast Button
%group gHideCastButton
%hook MDXPlaybackRouteButtonController
- (BOOL)isPersistentCastIconEnabled { return NO; }
- (void)updateRouteButton:(id)arg1 {} // hide Cast button in video controls overlay
%end

%hook YTSettings
- (void)setDisableMDXDeviceDiscovery:(BOOL)arg1 { %orig(YES); }
%end
%end

// Enable Share Button / Enable Save to Playlist Button
%hook YTMainAppControlsOverlayView
- (void)setShareButtonAvailable:(BOOL)arg1 { // enable Share button
    if (IsEnabled(@"enableShareButton_enabled")) {
        %orig(YES);
    } else {
        %orig(NO);
    }
}
- (void)setAddToButtonAvailable:(BOOL)arg1 { // enable Save To Playlist button
    if (IsEnabled(@"enableSaveToButton_enabled")) {
        %orig(YES);
    } else {
        %orig(NO);
    }
}
%end

// Disable the right panel in fullscreen mode
%hook YTColdConfig
- (BOOL)isLandscapeEngagementPanelEnabled {
    return IsEnabled(@"hideRightPanel_enabled") ? NO : %orig;
}
%end

%group gHideVideoPlayerShadowOverlayButtons
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
	%orig();
    MSHookIvar<YTTransportControlsButtonView *>(self, "_previousButtonView").backgroundColor = nil;
    MSHookIvar<YTTransportControlsButtonView *>(self, "_nextButtonView").backgroundColor = nil;
    MSHookIvar<YTTransportControlsButtonView *>(self, "_seekBackwardAccessibilityButtonView").backgroundColor = nil;
    MSHookIvar<YTTransportControlsButtonView *>(self, "_seekForwardAccessibilityButtonView").backgroundColor = nil;
    MSHookIvar<YTPlaybackButton *>(self, "_playPauseButton").backgroundColor = nil;
}
%end
%end


// A/B flags
%hook YTColdConfig 
- (BOOL)respectDeviceCaptionSetting { return NO; } // YouRememberCaption: https://poomsmart.github.io/repo/depictions/youremembercaption.html
- (BOOL)isLandscapeEngagementPanelSwipeRightToDismissEnabled { return YES; } // Swipe right to dismiss the right panel in fullscreen mode
- (BOOL)commercePlatformClientEnablePopupWebviewInWebviewDialogController { return NO;}
%end

// Hide Upgrade Dialog - @arichornlover
%hook YTGlobalConfig
- (BOOL)shouldBlockUpgradeDialog { return YES;}
- (BOOL)shouldForceUpgrade { return NO;}
- (BOOL)shouldShowUpgrade { return NO;}
- (BOOL)shouldShowUpgradeDialog { return NO;}
%end

// Hide Speed Toast - @bhackel
// YTLite Speed Toast
%hook PlayerToast
- (void)showPlayerToastWithText:(id)text 
                          value:(CGFloat)value 
                          style:(NSInteger)style 
                         onView:(id)view 
{
    if (IsEnabled(@"hideSpeedToast_enabled")) {
        return;
    }
    %orig;
}
%end
// Default YouTube Speed Toast
%hook YTInlinePlayerScrubUserEducationView
- (void)setVisible:(BOOL)visible {
    if (IsEnabled(@"hideSpeedToast_enabled")) {
        return;
    }
    %orig;
}
%end

// Hide Home Tab - @bhackel
%group gHideHomeTab
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    // Iterate over each renderer item
    NSUInteger indexToRemove = -1;
    NSMutableArray <YTIPivotBarSupportedRenderers *> *itemsArray = renderer.itemsArray;
    for (NSUInteger i = 0; i < itemsArray.count; i++) {
        YTIPivotBarSupportedRenderers *item = itemsArray[i];
        // Check if this is the home tab button
        YTIPivotBarItemRenderer *pivotBarItemRenderer = item.pivotBarItemRenderer;
        NSString *pivotIdentifier = pivotBarItemRenderer.pivotIdentifier;
        if ([pivotIdentifier isEqualToString:@"FEwhat_to_watch"]) {
            // Remove the home tab button
            indexToRemove = i;
            break;
        }
    }
    if (indexToRemove != -1) {
        [itemsArray removeObjectAtIndex:indexToRemove];
    }
    %orig;
}
%end
// Fix bug where contents of leftmost tab is replaced by Home tab
BOOL isTabSelected = NO;
%hook YTPivotBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (!isTabSelected) {
        // Get the identifier of the selected pivot
        NSString *selectedPivotIdentifier = self.selectedPivotIdentifier;
        // Find any different tab to switch from by looping through the renderer items
        YTIPivotBarRenderer *renderer = self.renderer;
        NSArray <YTIPivotBarSupportedRenderers *> *itemsArray = renderer.itemsArray;
        for (YTIPivotBarSupportedRenderers *item in itemsArray) {
            YTIPivotBarItemRenderer *pivotBarItemRenderer = item.pivotBarItemRenderer;
            NSString *pivotIdentifier = pivotBarItemRenderer.pivotIdentifier;
            if (![pivotIdentifier isEqualToString:selectedPivotIdentifier]) {
                // Switch to this tab
                [self selectItemWithPivotIdentifier:pivotIdentifier];
                break;
            }
        }
        // Clear any cached controllers to delete the broken home tab
        [self resetViewControllersCache];
        // Switch back to the original tab
        [self selectItemWithPivotIdentifier:selectedPivotIdentifier];
        // Update flag to not do it again
        isTabSelected = YES;
    }
}
%end
%end

// Disable fullscreen engagement overlay - @bhackel
%group gDisableEngagementOverlay
%hook YTFullscreenEngagementOverlayController
- (void)setEnabled:(BOOL)enabled {
    %orig(NO);
}
%end
%end

// YTNoModernUI - @arichornlover
%group gYTNoModernUI
%hook YTVersionUtils // YTNoModernUI Original Version
+ (NSString *)appVersion { return @"17.38.10"; }
%end

%hook YTSettingsCell // Remove v17.38.10 Version Number - @Dayanch96
- (void)setDetailText:(id)arg1 {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];

    if ([arg1 isEqualToString:@"17.38.10"]) {
        arg1 = appVersion;
    } %orig(arg1);
}
%end

%hook YTInlinePlayerBarContainerView // Red Progress Bar - YTNoModernUI
- (id)quietProgressBarColor {
    return [UIColor redColor];
}
%end

%hook YTSegmentableInlinePlayerBarView // Gray Buffer Progress - YTNoModernUI
- (void)setBufferedProgressBarColor:(id)arg1 {
     [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.90];
}
%end

%hook YTQTMButton // No Modern/Rounded Buttons - YTNoModernUI
+ (BOOL)buttonModernizationEnabled { return NO; }
%end

%hook YTBubbleHintView // No Modern/Rounded Hints - YTNoModernUI
+ (BOOL)modernRoundedCornersEnabled { return NO; }
%end

%hook YTColdConfig
// Disable Modern Content - YTNoModernUI
- (BOOL)creatorClientConfigEnableStudioModernizedMdeThumbnailPickerForClient { return NO; }
- (BOOL)cxClientEnableModernizedActionSheet { return NO; }
- (BOOL)enableClientShortsSheetsModernization { return NO; }
- (BOOL)enableTimestampModernizationForNative { return NO; }
- (BOOL)mainAppCoreClientEnableModernIaFeedStretchBottom { return NO; }
- (BOOL)mainAppCoreClientEnableModernIaFrostedBottomBar { return NO; }
- (BOOL)mainAppCoreClientEnableModernIaFrostedPivotBar { return NO; }
- (BOOL)mainAppCoreClientEnableModernIaFrostedPivotBarUpdatedBackdrop { return NO; }
- (BOOL)mainAppCoreClientEnableModernIaFrostedTopBar { return NO; }
- (BOOL)mainAppCoreClientEnableModernIaOpacityPivotBar { return NO; }
- (BOOL)mainAppCoreClientEnableModernIaTopAndBottomBarIconRefresh { return NO; }
- (BOOL)mainAppCoreClientEnableModernizedBedtimeReminderU18DefaultSettings { return NO; }
- (BOOL)modernizeCameoNavbar { return NO; }
- (BOOL)modernizeCollectionLockups { return NO; }
- (BOOL)modernizeCollectionLockupsShowVideoCount { return NO; }
- (BOOL)modernizeElementsBgColor { return NO; }
- (BOOL)modernizeElementsTextColor { return NO; }
- (BOOL)postsCreatorClientEnableModernButtonsUi { return NO; }
- (BOOL)pullToFullModernEdu { return NO; }
- (BOOL)showModernMiniplayerRedesign { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableModernButtonsForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigIosEnableModernTabsForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigIosEnableSnackbarModernization { return NO; }
- (BOOL)uiSystemsClientGlobalConfigModernizeNativeBgColor { return NO; }
- (BOOL)uiSystemsClientGlobalConfigModernizeNativeTextColor { return NO; }
// Disable Rounded Content - YTNoModernUI
- (BOOL)iosDownloadsPageRoundedThumbs { return NO; }
- (BOOL)iosRoundedSearchBarSuggestZeroPadding { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedDialogForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedThumbnailsForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedThumbnailsForNativeLongTail { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedTimestampForNative { return NO; }
// Disable Darker Dark Mode - YTNoModernUI
- (BOOL)enableDarkerDarkMode { return NO; }
- (BOOL)useDarkerPaletteBgColorForElements { return NO; }
- (BOOL)useDarkerPaletteTextColorForElements { return NO; }
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteTextColorForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative { return NO; }
// Disable Ambient Mode - YTNoModernUI
- (BOOL)disableCinematicForLowPowerMode { return NO; }
- (BOOL)enableCinematicContainer { return NO; }
- (BOOL)enableCinematicContainerOnClient { return NO; }
- (BOOL)enableCinematicContainerOnTablet { return NO; }
- (BOOL)enableTurnOffCinematicForFrameWithBlackBars { return YES; }
- (BOOL)enableTurnOffCinematicForVideoWithBlackBars { return YES; }
- (BOOL)iosCinematicContainerClientImprovement { return NO; }
- (BOOL)iosEnableGhostCardInlineTitleCinematicContainerFix { return NO; }
- (BOOL)iosUseFineScrubberMosaicStoreForCinematic { return NO; }
- (BOOL)mainAppCoreClientEnableClientCinematicPlaylists { return NO; }
- (BOOL)mainAppCoreClientEnableClientCinematicPlaylistsPostMvp { return NO; }
- (BOOL)mainAppCoreClientEnableClientCinematicTablets { return NO; }
- (BOOL)iosEnableFullScreenAmbientMode { return NO; }
// 16.42.3 Styled YouTube Channel Page Interface - YTNoModernUI
- (BOOL)channelsClientConfigIosChannelNavRestructuring { return NO; }
- (BOOL)channelsClientConfigIosMultiPartChannelHeader { return NO; }
// Disable Optional Content - YTNoModernUI
- (BOOL)elementsClientIosElementsEnableLayoutUpdateForIob { return NO; }
- (BOOL)supportElementsInMenuItemSupportedRenderers { return NO; }
- (BOOL)isNewRadioButtonStyleEnabled { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableButtonSentenceCasingForNative { return NO; }
- (BOOL)mainAppCoreClientEnableClientYouTab { return NO; }
- (BOOL)mainAppCoreClientEnableClientYouLatency { return NO; }
- (BOOL)mainAppCoreClientEnableClientYouTabTablet { return NO; }
%end

%hook YTHotConfig
- (BOOL)liveChatIosUseModernRotationDetection { return NO; } // Disable Modern Content (YTHotConfig)
- (BOOL)liveChatModernizeClassicElementizeTextMessage { return NO; }
- (BOOL)iosShouldRepositionChannelBar { return NO; }
- (BOOL)enableElementRendererOnChannelCreation { return NO; }
%end
%end

// Hide YouTube Heatwaves in Video Player (YouTube v17.19.2-present) - @level3tjg - https://www.reddit.com/r/jailbreak/comments/v29yvk/
%group gHideHeatwaves
%hook YTInlinePlayerBarContainerView
- (BOOL)canShowHeatwave { return NO; }
%end
%end

%hook YTYouThereController
- (BOOL)shouldShowYouTherePrompt { return NO; }
%end
// Fix login for YouTube 18.13.2 and higher
%hook SSOKeychainHelper
+ (NSString *)accessGroup {
    return accessGroupID();
}
+ (NSString *)sharedAccessGroup {
    return accessGroupID();
}
%end

// Fix login for YouTube 17.33.2 and higher - @BandarHL
// https://gist.github.com/BandarHL/492d50de46875f9ac7a056aad084ac10
%hook SSOKeychainCore
+ (NSString *)accessGroup {
    return accessGroupID();
}

+ (NSString *)sharedAccessGroup {
    return accessGroupID();
}
%end

// Fix App Group Directory by move it to document directory
%hook NSFileManager
- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    if (groupIdentifier != nil) {
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsURL = [paths lastObject];
        return [documentsURL URLByAppendingPathComponent:@"AppGroup"];
    }
    return %orig(groupIdentifier);
}
%end

// Fix Casting: https://github.com/arichornlover/uYouEnhanced/issues/606#issuecomment-2098289942
%group gFixCasting
%hook YTColdConfig
- (BOOL)cxClientEnableIosLocalNetworkPermissionReliabilityFixes { return YES; }
- (BOOL)cxClientEnableIosLocalNetworkPermissionUsingSockets { return NO; }
- (BOOL)cxClientEnableIosLocalNetworkPermissionWifiFixes { return YES; }
%end
%hook YTHotConfig
- (BOOL)isPromptForLocalNetworkPermissionsEnabled { return YES; }
%end
%end

// Seek anywhere gesture - @bhackel
%hook YTColdConfig
- (BOOL)speedMasterArm2FastForwardWithoutSeekBySliding {
    return IsEnabled(@"seekAnywhere_enabled") ? NO : %orig;
}
%end

// New Settings UI - @bhackel
%hook YTColdConfig
- (BOOL)mainAppCoreClientEnableCairoSettings { 
    return IS_ENABLED(@"newSettingsUI_enabled"); 
}
%end

// Fullscreen to the Right (iPhone-Exclusive) - @arichornlover & @bhackel
// WARNING: Please turn off the “Portrait Fullscreen” or "iPad Layout" Option in YTLite while the option "Fullscreen to the Right" is enabled below.
%group gFullscreenToTheRight
%hook YTWatchViewController
- (UIInterfaceOrientationMask)allowedFullScreenOrientations {
    UIInterfaceOrientationMask orientations = UIInterfaceOrientationMaskLandscapeRight;
    return orientations;
}
%end
%end

// YTTapToSeek - https://github.com/bhackel/YTTapToSeek
%group gYTTapToSeek
    %hook YTInlinePlayerBarContainerView
    - (void)didPressScrubber:(id)arg1 {
        %orig;
        // Get access to the seekToTime method
        YTMainAppVideoPlayerOverlayViewController *mainAppController = [self.delegate valueForKey:@"_delegate"];
        YTPlayerViewController *playerViewController = [mainAppController valueForKey:@"parentViewController"];
        // Get the X position of this tap from arg1
        UIGestureRecognizer *gestureRecognizer = (UIGestureRecognizer *)arg1;
        CGPoint location = [gestureRecognizer locationInView:self];
        CGFloat x = location.x;
        // Get the associated proportion of time using scrubRangeForScrubX
        double timestampFraction = [self scrubRangeForScrubX:x];
        // Get the timestamp from the fraction
        double timestamp = [mainAppController totalTime] * timestampFraction;
        // Jump to the timestamp
        [playerViewController seekToTime:timestamp];
    }
    %end
%end

// Disable pull to enter vertical/portrait fullscreen gesture - @bhackel
// This was introduced in version 19.XX
// This does not apply to portrait videos
%group gDisablePullToFull
%hook YTWatchPullToFullController
- (BOOL)shouldRecognizeOverscrollEventsFromWatchOverscrollController:(id)arg1 {
    // Get the current player orientation
    YTWatchViewController *watchViewController = (YTWatchViewController *) self.playerViewSource;
    NSUInteger allowedFullScreenOrientations = [watchViewController allowedFullScreenOrientations];
    // Check if the current player orientation is portrait
    if (allowedFullScreenOrientations == UIInterfaceOrientationMaskAllButUpsideDown
            || allowedFullScreenOrientations == UIInterfaceOrientationMaskPortrait
            || allowedFullScreenOrientations == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return %orig;
    } else {
        return NO;
    }
}
%end
%end

// Always use remaining time in the video player - @bhackel
%hook YTPlayerBarController
// When a new video is played, enable time remaining flag
- (void)setActiveSingleVideo:(id)arg1 {
    %orig;
    if (IS_ENABLED(@"alwaysShowRemainingTime_enabled")) {
        // Get the player bar view
        YTInlinePlayerBarContainerView *playerBar = self.playerBar;
        if (playerBar) {
            // Enable the time remaining flag
            playerBar.shouldDisplayTimeRemaining = YES;
        }
    }
}
%end

// Disable toggle time remaining - @bhackel
%hook YTInlinePlayerBarContainerView
- (void)setShouldDisplayTimeRemaining:(BOOL)arg1 {
    if (IS_ENABLED(@"disableRemainingTime_enabled")) {
        // Set true if alwaysShowRemainingTime
        if (IS_ENABLED(@"alwaysShowRemainingTime_enabled")) {
            %orig(YES);
        } else {
            %orig(NO);
        }
        return;
    }
    %orig;
}
%end

// Disable Ambient Mode - @bhackel
%hook YTWatchCinematicContainerController
- (BOOL)isCinematicLightingAvailable {
    // Check if we are in fullscreen or not, then decide if ambient is disabled
    YTWatchViewController *watchViewController = (YTWatchViewController *) self.parentResponder;
    BOOL isFullscreen = watchViewController.fullscreen;
    if (IsEnabled(@"disableAmbientModePortrait_enabled") && !isFullscreen) {
        return NO;   
    }
    if (IsEnabled(@"disableAmbientModeFullscreen_enabled") && isFullscreen) {
        return NO;
    }
    return %orig;
}
%end

%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;

    // Hide the Comment Section Previews under the Video Player - @arichornlover
    if ((IsEnabled(@"hidePreviewCommentSection_enabled")) && ([self.accessibilityIdentifier isEqualToString:@"id.ui.comments_entry_point_teaser"])) {
        self.hidden = YES;
        self.opaque = YES;
        self.userInteractionEnabled = NO;
        CGRect bounds = self.frame;
        bounds.size.height = 0;
        self.frame = bounds;
        [self.superview layoutIfNeeded];
        [self setNeedsLayout];
        [self removeFromSuperview];
    }

    // Live chat OLED dark mode - @bhackel
    CGFloat alpha;
    if ([[%c(YTLUserDefaults) standardUserDefaults] boolForKey:@"oledTheme"] // YTLite OLED Theme
            && [self.accessibilityIdentifier isEqualToString:@"eml.live_chat_text_message"] // Live chat text message
            && [self.backgroundColor getWhite:nil alpha:&alpha] // Check if color is grayscale and get alpha
            && alpha != 0.0) // Ignore shorts live chat
    {
        self.backgroundColor = [UIColor blackColor];
    }
}
%end

// Hide Autoplay Mini Preview - @bhackel
%hook YTAutonavPreviewView
- (void)layoutSubviews {
    %orig;
    if (IsEnabled(@"hideAutoplayMiniPreview_enabled")) {
        self.hidden = YES;
    }
}
- (void)setHidden:(BOOL)arg1 {
    if (IsEnabled(@"hideAutoplayMiniPreview_enabled")) {
        %orig(YES);
    } else {
        %orig(arg1);
    }
}
%end

// Hide HUD Messages - @qnblackcat
%hook YTHUDMessageView
- (id)initWithMessage:(id)arg1 dismissHandler:(id)arg2 {
    return IsEnabled(@"hideHUD_enabled") ? nil : %orig;
}
%end

// Hide Video Player Collapse Button - @arichornlover
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
    %orig; 
    if (IsEnabled(@"disableCollapseButton_enabled")) {  
        if (self.watchCollapseButton) {
            [self.watchCollapseButton removeFromSuperview];
        }
    }
}
- (BOOL)watchCollapseButtonHidden {
    if (IsEnabled(@"disableCollapseButton_enabled")) {
        return YES;
    } else {
        return %orig;
    }
}
- (void)setWatchCollapseButtonAvailable:(BOOL)available {
    if (IsEnabled(@"disableCollapseButton_enabled")) {
    } else {
        %orig(available);
    }
}
%end

// Gestures - @bhackel
%group playerGestures
%hook YTWatchLayerViewController
// invoked when the player view controller is either created or destroyed
- (void)watchController:(YTWatchController *)watchController didSetPlayerViewController:(YTPlayerViewController *)playerViewController {
    if (playerViewController) {
        // check to see if the pan gesture is already created
        if (!playerViewController.YTLitePlusPanGesture) {
            playerViewController.YTLitePlusPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:playerViewController
                                                                                               action:@selector(YTLitePlusHandlePanGesture:)];
            playerViewController.YTLitePlusPanGesture.delegate = playerViewController;
            [playerViewController.playerView addGestureRecognizer:playerViewController.YTLitePlusPanGesture];
        }        
    }
    %orig;
}
%end


%hook YTPlayerViewController
// the pan gesture that will be created and added to the player view
%property (nonatomic, retain) UIPanGestureRecognizer *YTLitePlusPanGesture;
%new
- (void)YTLitePlusHandlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    // Haptic feedback generator
    static UIImpactFeedbackGenerator *feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    // Variables for storing initial values to be adjusted
    static float initialVolume;
    static float initialBrightness;
    static CGFloat currentTime;
    // Flag to determine if the pan gesture is valid
    static BOOL isValidHorizontalPan = NO;
    // Variable to store the section of the screen the gesture is in
    static GestureSection gestureSection = GestureSectionInvalid;
    // Variable to track the start location of the whole pan gesture
    static CGPoint startLocation;
    // Variable to track the X translation when exiting the deadzone
    static CGFloat deadzoneStartingXTranslation;
    // Constant for the deadzone radius that can be changed in the settings
    static CGFloat deadzoneRadius = (CGFloat)GetFloat(@"playerGesturesDeadzone");
    // Constant for the sensitivity factor that can be changed in the settings
    static CGFloat sensitivityFactor = (CGFloat)GetFloat(@"playerGesturesSensitivity");

/***** Helper functions *****/
    // Helper function to adjust brightness
    void (^adjustBrightness)(CGFloat, CGFloat) = ^(CGFloat translationX, CGFloat initialBrightness) {
        float newBrightness = initialBrightness + ((translationX / 1000.0) * sensitivityFactor);
        newBrightness = fmaxf(fminf(newBrightness, 1.0), 0.0);
        [[UIScreen mainScreen] setBrightness:newBrightness];
    };
    // Helper function to adjust volume
    void (^adjustVolume)(CGFloat, CGFloat) = ^(CGFloat translationX, CGFloat initialVolume) {
        float newVolume = initialVolume + ((translationX / 1000.0) * sensitivityFactor);
        newVolume = fmaxf(fminf(newVolume, 1.0), 0.0);
        // https://stackoverflow.com/questions/50737943/how-to-change-volume-programmatically-on-ios-11-4
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        UISlider *volumeViewSlider = nil;
        for (UIView *view in volumeView.subviews) {
            if ([view isKindOfClass:[UISlider class]]) {
                volumeViewSlider = (UISlider *)view;
                break;
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            volumeViewSlider.value = newVolume;
        });
    };
    // Helper function to adjust seek time
    void (^adjustSeek)(CGFloat, CGFloat) = ^(CGFloat translationX, CGFloat currentTime) {
        // Calculate a seek fraction based on the horizontal translation
        CGFloat totalDuration = self.currentVideoTotalMediaTime;
        CGFloat viewWidth = self.view.bounds.size.width;
        CGFloat seekFraction = (translationX / viewWidth);
        // Seek to the new time based on the calculated offset
        CGFloat sensitivityFactor = 1; // Adjust this value to make seeking less sensitive
        seekFraction = sensitivityFactor * seekFraction;
        CGFloat seekTime = currentTime + totalDuration * seekFraction;
        [self seekToTime:seekTime];
    };
    // Helper function to run the selected gesture action
    void (^runSelectedGesture)(NSString*, CGFloat, CGFloat, CGFloat, CGFloat) 
            = ^(NSString *sectionKey, CGFloat translationX, CGFloat initialBrightness, CGFloat initialVolume, CGFloat currentTime) {
        // Determine the selected gesture mode using the section key
        GestureMode selectedGestureMode = (GestureMode)GetInteger(sectionKey);
        // Handle the gesture action based on the selected mode
        switch (selectedGestureMode) {
            case GestureModeVolume:
                adjustVolume(translationX, initialVolume);
                break;
            case GestureModeBrightness:
                adjustBrightness(translationX, initialBrightness);
                break;
            case GestureModeSeek:
                adjustSeek(translationX, currentTime);
                break;
            case GestureModeDisabled:
                // Do nothing if the gesture is disabled
                break;
            default:
                // Show an alert if the gesture mode is invalid
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Gesture Mode" message:@"Please report this bug." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                break;
        }
    };
/***** End of Helper functions *****/

    // Handle gesture based on current gesture state
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Get the gesture's start position
        startLocation = [panGestureRecognizer locationInView:self.view];
        CGFloat viewHeight = self.view.bounds.size.height;
        
        // Determine the section based on the start position
        // by dividing the view into thirds
        if (startLocation.y <= viewHeight / 3.0) {
            gestureSection = GestureSectionTop;
            // Cancel the gesture if the mode is disabled
            if (GetInteger(@"playerGestureTopSelection") == GestureModeDisabled) {
                panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
                return;
            }
        } else if (startLocation.y <= 2 * viewHeight / 3.0) {
            gestureSection = GestureSectionMiddle;
            // Cancel the gesture if the mode is disabled
            if (GetInteger(@"playerGestureMiddleSelection") == GestureModeDisabled) {
                panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
                return;
            }
        } else if (startLocation.y <= viewHeight) {
            gestureSection = GestureSectionBottom;
            // Cancel the gesture if the mode is disabled
            if (GetInteger(@"playerGestureBottomSelection") == GestureModeDisabled) {
                panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
                return;
            }
        } else {
            gestureSection = GestureSectionInvalid;
        }
        // Deactive the activity flag
        isValidHorizontalPan = NO;
    }

    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // Determine if the gesture is predominantly horizontal
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        if (!isValidHorizontalPan) {
            if (fabs(translation.x) > fabs(translation.y)) {
                // Check if the touch has moved outside the deadzone
                CGFloat distanceFromStart = hypot(translation.x, translation.y);
                if (distanceFromStart < deadzoneRadius) {
                    // If within the deadzone, don't activate the pan gesture
                    return;
                }
                // If outside the deadzone, activate the pan gesture and store the initial values
                isValidHorizontalPan = YES;
                deadzoneStartingXTranslation = translation.x;
                initialBrightness = [UIScreen mainScreen].brightness;
                initialVolume = [[AVAudioSession sharedInstance] outputVolume];
                currentTime = self.currentVideoMediaTime;
                // Provide haptic feedback to indicate a gesture start
                [feedbackGenerator prepare];
                [feedbackGenerator impactOccurred];
            } else {
                // Cancel the gesture if the translation is not horizontal
                panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
                return;
            }
        }
        
        // Handle the gesture based on the identified section
        if (isValidHorizontalPan) {
            // Adjust the X translation based on the value hit after
            // exiting the deadzone
            CGFloat adjustedTranslationX = translation.x - deadzoneStartingXTranslation;
            // Pass the adjusted translation to the selected gesture
            if (gestureSection == GestureSectionTop) {
                runSelectedGesture(@"playerGestureTopSelection", adjustedTranslationX, initialBrightness, initialVolume, currentTime);
            } else if (gestureSection == GestureSectionMiddle) {
                runSelectedGesture(@"playerGestureMiddleSelection", adjustedTranslationX, initialBrightness, initialVolume, currentTime);
            } else if (gestureSection == GestureSectionBottom) {
                runSelectedGesture(@"playerGestureBottomSelection", adjustedTranslationX, initialBrightness, initialVolume, currentTime);
            } else {
                // If the section is invalid, cancel the gesture
                panGestureRecognizer.state = UIGestureRecognizerStateCancelled;
            }
        }
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (isValidHorizontalPan) {
            // Provide haptic feedback upon successful gesture recognition
            [feedbackGenerator prepare];
            [feedbackGenerator impactOccurred];
        }
    }

}
// allow the pan gesture to be recognized simultaneously with other gestures
%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
%end
%end

// BigYTMiniPlayer: https://github.com/Galactic-Dev/BigYTMiniPlayer
%group Main
%hook YTWatchMiniBarView
- (void)setWatchMiniPlayerLayout:(int)arg1 {
    %orig(1);
}
- (int)watchMiniPlayerLayout {
    return 1;
}
- (void)layoutSubviews {
    %orig;
    self.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - self.frame.size.width), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}
%end

%hook YTMainAppVideoPlayerOverlayView
- (BOOL)isUserInteractionEnabled {
    if([[self _viewControllerForAncestor].parentViewController.parentViewController isKindOfClass:%c(YTWatchMiniBarViewController)]) {
        return NO;
    }
    return %orig;
}
%end
%end

// Video player button in the navigation bar - @bhackel
// This code is based on the iSponsorBlock button code
%group gVideoPlayerButton
NSInteger pageStyle = 0;
%hook YTRightNavigationButtons
%property (retain, nonatomic) YTQTMButton *videoPlayerButton;
- (NSMutableArray *)buttons {
    NSMutableArray *retVal = %orig.mutableCopy;
    [self.videoPlayerButton removeFromSuperview];
    [self addSubview:self.videoPlayerButton];
    if (!self.videoPlayerButton || pageStyle != [%c(YTPageStyleController) pageStyle]) {
        self.videoPlayerButton = [%c(YTQTMButton) iconButton];
	    [self.videoPlayerButton enableNewTouchFeedback];
        self.videoPlayerButton.frame = CGRectMake(0, 0, 40, 40);
        
        if ([%c(YTPageStyleController) pageStyle]) { //dark mode
            [self.videoPlayerButton setImage:[UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"YTLitePlusColored-1024" ofType:@"png"]] forState:UIControlStateNormal];
        }
        else { // light mode
            UIImage *image = [UIImage imageWithContentsOfFile:[tweakBundle pathForResource:@"YTLitePlusColored-1024" ofType:@"png"]];
            image = [image imageWithTintColor:UIColor.blackColor renderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.videoPlayerButton setImage:image forState:UIControlStateNormal];
            [self.videoPlayerButton setTintColor:UIColor.blackColor];
        }
        pageStyle = [%c(YTPageStyleController) pageStyle];
        
        [self.videoPlayerButton addTarget:self action:@selector(videoPlayerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [retVal insertObject:self.videoPlayerButton atIndex:0];
    }
    return retVal;
}
- (NSMutableArray *)visibleButtons {
    NSMutableArray *retVal = %orig.mutableCopy;
    
    // fixes button overlapping yt logo on smaller devices
    [self setLeadingPadding:-10];
    if (self.videoPlayerButton) {
        [self.videoPlayerButton removeFromSuperview];
        [self addSubview:self.videoPlayerButton];
        [retVal insertObject:self.videoPlayerButton atIndex:0];
    }
    return retVal;
}
// Method to handle the video player button press by showing a document picker
%new
- (void)videoPlayerButtonPressed:(UIButton *)sender {
    // Traversing the responder chain to find the nearest UIViewController
    UIResponder *responder = sender;
    UIViewController *settingsViewController = nil;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            settingsViewController = (UIViewController *)responder;
            break;
        }
        responder = responder.nextResponder;
    }

    if (settingsViewController) {
        // Present the video picker
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo] inMode:UIDocumentPickerModeImport];
        documentPicker.delegate = (id<UIDocumentPickerDelegate>)self;
        documentPicker.allowsMultipleSelection = NO;
        [settingsViewController presentViewController:documentPicker animated:YES completion:nil];
    } else {
        NSLog(@"No view controller found for the sender button.");
    }
}
// Delegate method to handle the picked video by showing the apple player
%new
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *pickedURL = [urls firstObject];
    
    if (pickedURL) {
        // Use AVPlayerViewController to play the video
        AVPlayer *player = [AVPlayer playerWithURL:pickedURL];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = player;
        
        // Get the root view controller
        UIViewController *presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        // Present the Video Player
        if (presentingViewController) {
            [presentingViewController presentViewController:playerViewController animated:YES completion:^{
                [player play];
            }];
        } else {
            // Handle case where no view controller was found
            NSLog(@"Error: No view controller found to present AVPlayerViewController.");
        }
    }
}
%end
%end

// App Settings Overlay Options
%group gDisableAccountSection
%hook YTSettingsSectionItemManager
- (void)updateAccountSwitcherSectionWithEntry:(id)arg1 {} // Account
%end
%end

%group gDisableAutoplaySection
%hook YTSettingsSectionItemManager
- (void)updateAutoplaySectionWithEntry:(id)arg1 {} // Autoplay
%end
%end

%group gDisableTryNewFeaturesSection
%hook YTSettingsSectionItemManager
- (void)updatePremiumEarlyAccessSectionWithEntry:(id)arg1 {} // Try new features
%end
%end

%group gDisableVideoQualityPreferencesSection
%hook YTSettingsSectionItemManager
- (void)updateVideoQualitySectionWithEntry:(id)arg1 {} // Video quality preferences
%end
%end

%group gDisableNotificationsSection
%hook YTSettingsSectionItemManager
- (void)updateNotificationSectionWithEntry:(id)arg1 {} // Notifications
%end
%end

%group gDisableManageAllHistorySection
%hook YTSettingsSectionItemManager
- (void)updateHistorySectionWithEntry:(id)arg1 {} // Manage all history
%end
%end

%group gDisableYourDataInYouTubeSection
%hook YTSettingsSectionItemManager
- (void)updateYourDataSectionWithEntry:(id)arg1 {} // Your data in YouTube
%end
%end

%group gDisablePrivacySection
%hook YTSettingsSectionItemManager
- (void)updatePrivacySectionWithEntry:(id)arg1 {} // Privacy
%end
%end

%group gDisableLiveChatSection
%hook YTSettingsSectionItemManager
- (void)updateLiveChatSectionWithEntry:(id)arg1 {} // Live chat
%end
%end

// Miscellaneous
%group giPadLayout // https://github.com/LillieH001/YouTube-Reborn
%hook UIDevice
- (UIUserInterfaceIdiom)userInterfaceIdiom {
    return UIUserInterfaceIdiomPad;
}
%end
%hook UIStatusBarStyleAttributes
- (long long)idiom {
    return NO;
} 
%end
%hook UIKBTree
- (long long)nativeIdiom {
    return NO;
} 
%end
%hook UIKBRenderer
- (long long)assetIdiom {
    return NO;
} 
%end
%end

%group giPhoneLayout // https://github.com/LillieH001/YouTube-Reborn
%hook UIDevice
- (UIUserInterfaceIdiom)userInterfaceIdiom {
    return UIUserInterfaceIdiomPhone;
}
%end
%hook UIStatusBarStyleAttributes
- (long long)idiom {
    return YES;
} 
%end
%hook UIKBTree
- (long long)nativeIdiom {
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        return NO;
    } else {
        return YES;
    }
} 
%end
%hook UIKBRenderer
- (long long)assetIdiom {
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        return NO;
    } else {
        return YES;
    }
} 
%end
%end

// YT startup animation
%hook YTColdConfig
- (BOOL)mainAppCoreClientIosEnableStartupAnimation {
    return IsEnabled(@"ytStartupAnimation_enabled") ? YES : NO;
}
%end

# pragma mark - ctor
%ctor {
    %init;
    // Access YouGroupSettings methods
    dlopen([[NSString stringWithFormat:@"%@/Frameworks/YouGroupSettings.dylib", [[NSBundle mainBundle] bundlePath]] UTF8String], RTLD_LAZY);

    if (IsEnabled(@"hideCastButton_enabled")) {
        %init(gHideCastButton);
    }
    if (IsEnabled(@"iPadLayout_enabled")) {
        %init(giPadLayout);
    }
    if (IsEnabled(@"iPhoneLayout_enabled")) {
        %init(giPhoneLayout);
    }
    if (IsEnabled(@"bigYTMiniPlayer_enabled") && (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad)) {
        %init(Main);
    }
    if (IsEnabled(@"hideVideoPlayerShadowOverlayButtons_enabled")) {
        %init(gHideVideoPlayerShadowOverlayButtons);
    }
    if (IsEnabled(@"hideHeatwaves_enabled")) {
        %init(gHideHeatwaves);
    }
    if (IsEnabled(@"ytNoModernUI_enabled")) {
        %init(gYTNoModernUI);
    }
    if (IsEnabled(@"disableAccountSection_enabled")) {
        %init(gDisableAccountSection);
    }
    if (IsEnabled(@"disableAutoplaySection_enabled")) {
        %init(gDisableAutoplaySection);
    }
    if (IsEnabled(@"disableTryNewFeaturesSection_enabled")) {
        %init(gDisableTryNewFeaturesSection);
    }
    if (IsEnabled(@"disableVideoQualityPreferencesSection_enabled")) {
        %init(gDisableVideoQualityPreferencesSection);
    }
    if (IsEnabled(@"disableNotificationsSection_enabled")) {
        %init(gDisableNotificationsSection);
    }
    if (IsEnabled(@"disableManageAllHistorySection_enabled")) {
        %init(gDisableManageAllHistorySection);
    }
    if (IsEnabled(@"disableYourDataInYouTubeSection_enabled")) {
        %init(gDisableYourDataInYouTubeSection);
    }
    if (IsEnabled(@"disablePrivacySection_enabled")) {
        %init(gDisablePrivacySection);
    }
    if (IsEnabled(@"disableLiveChatSection_enabled")) {
        %init(gDisableLiveChatSection);
    }
    if (IsEnabled(@"hideHomeTab_enabled")) {
        %init(gHideHomeTab);
    }
    if (IsEnabled(@"fixCasting_enabled")) {
        %init(gFixCasting);
    }
    if (IsEnabled(@"fullscreenToTheRight_enabled")) {
        %init(gFullscreenToTheRight);
    }
    if (IsEnabled(@"YTTapToSeek_enabled")) {
        %init(gYTTapToSeek);
    }
    if (IsEnabled(@"disablePullToFull_enabled")) {
        %init(gDisablePullToFull);
    }
    if (IsEnabled(@"disableEngagementOverlay_enabled")) {
        %init(gDisableEngagementOverlay);
    }
    if (IsEnabled(@"playerGestures_enabled")) {
        %init(playerGestures);
    }
    if (IsEnabled(@"videoPlayerButton_enabled")) {
        %init(gVideoPlayerButton);
    }

    // Change the default value of some options
    NSArray *allKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    if (![allKeys containsObject:@"RYD-ENABLED"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RYD-ENABLED"]; 
    }
    if (![allKeys containsObject:@"YouPiPEnabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"YouPiPEnabled"]; 
	}
    if (![allKeys containsObject:@"newSettingsUI_enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"newSettingsUI_enabled"]; 
    }
    if (![allKeys containsObject:@"fixCasting_enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fixCasting_enabled"]; 
    }
    if (![allKeys containsObject:@"videoPlayerButton_enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"videoPlayerButton_enabled"]; 
    }
    // Default gestures as volume, brightness, seek
    if (![allKeys containsObject:@"playerGestureTopSelection"]) { 
       [[NSUserDefaults standardUserDefaults] setInteger:GestureModeVolume forKey:@"playerGestureTopSelection"]; 
    }
    if (![allKeys containsObject:@"playerGestureMiddleSelection"]) { 
       [[NSUserDefaults standardUserDefaults] setInteger:GestureModeBrightness forKey:@"playerGestureMiddleSelection"]; 
    }
    if (![allKeys containsObject:@"playerGestureBottomSelection"]) { 
       [[NSUserDefaults standardUserDefaults] setInteger:GestureModeSeek forKey:@"playerGestureBottomSelection"]; 
    }
    // Default configuration options for gestures
    if (![allKeys containsObject:@"playerGesturesDeadzone"]) { 
       [[NSUserDefaults standardUserDefaults] setFloat:20.0 forKey:@"playerGesturesDeadzone"]; 
    }
    if (![allKeys containsObject:@"playerGesturesSensitivity"]) { 
       [[NSUserDefaults standardUserDefaults] setFloat:1.0 forKey:@"playerGesturesSensitivity"]; 
    }
}
