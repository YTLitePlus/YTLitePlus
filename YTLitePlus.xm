#import "Header.h"

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

//
static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

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

# pragma mark - Tweaks
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

// Hide Upgrade Dialog - @arichorn
%hook YTGlobalConfig
- (BOOL)shouldBlockUpgradeDialog { return YES;}
- (BOOL)shouldForceUpgrade { return NO;}
- (BOOL)shouldShowUpgrade { return NO;}
- (BOOL)shouldShowUpgradeDialog { return NO;}
%end

// YTNoModernUI - @arichorn
%group gYTNoModernUI
%hook YTVersionUtils // YTNoModernUI Original Version
+ (NSString *)appVersion { return @"17.38.10"; }
%end

%hook YTSettingsCell // made by Dayanch96
- (void)setDetailText:(id)arg1 {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];

    if ([arg1 isEqualToString:@"17.38.10"]) {
        arg1 = appVersion;
    } %orig(arg1);
}
%end

%hook YTInlinePlayerBarContainerView // Red Progress Bar - YTNoModernUI - made by Dayanch96
- (id)quietProgressBarColor {
    return [UIColor redColor];
}
%end

%hook YTSegmentableInlinePlayerBarView // Gray Buffer Progress - YTNoModernUI - made by Dayanch96
- (void)setBufferedProgressBarColor:(id)arg1 {
     [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.90];
}
%end

%hook YTQTMButton
- (BOOL)buttonModernizationEnabled { return NO; }
%end

%hook YTSearchBarView
- (BOOL)_roundedSearchBarEnabled { return NO; }
%end

%hook YTColdConfig
// Disable Modern Content - YTNoModernUI
- (BOOL)creatorClientConfigEnableStudioModernizedMdeThumbnailPickerForClient { return NO; }
- (BOOL)cxClientEnableModernizedActionSheet { return NO; }
- (BOOL)enableClientShortsSheetsModernization { return NO; }
- (BOOL)enableTimestampModernizationForNative { return NO; }
- (BOOL)mainAppCoreClientIosEnableModernOssPage { return NO; }
- (BOOL)modernizeElementsTextColor { return NO; }
- (BOOL)modernizeElementsBgColor { return NO; }
- (BOOL)modernizeCollectionLockups { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableEpUxUpdates { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableModernButtonsForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableModernButtonsForNativeLongTail { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableModernTabsForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigIosEnableSnackbarModernization { return NO; }
// Disable Rounded Content - YTNoModernUI
- (BOOL)iosDownloadsPageRoundedThumbs { return NO; }
- (BOOL)iosRoundedSearchBarSuggestZeroPadding { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedThumbnailsForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedThumbnailsForNativeLongTail { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedTimestampForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableRoundedDialogForNative { return NO; }
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
- (BOOL)iosCinematicContainerClientImprovement { return NO; }
- (BOOL)iosEnableGhostCardInlineTitleCinematicContainerFix { return NO; }
- (BOOL)iosUseFineScrubberMosaicStoreForCinematic { return NO; }
- (BOOL)mainAppCoreClientEnableClientCinematicPlaylists { return NO; }
- (BOOL)mainAppCoreClientEnableClientCinematicPlaylistsPostMvp { return NO; }
- (BOOL)mainAppCoreClientEnableClientCinematicTablets { return NO; }
// 16.xx.x Styled YouTube Channel Page Interface - YTNoModernUI
- (BOOL)channelsClientConfigIosChannelNavRestructuring { return NO; }
- (BOOL)channelsClientConfigIosMultiPartChannelHeader { return NO; }
// Disable Optional Content - YTNoModernUI
- (BOOL)elementsClientIosElementsEnableLayoutUpdateForIob { return NO; }
- (BOOL)supportElementsInMenuItemSupportedRenderers { return NO; }
- (BOOL)isNewRadioButtonStyleEnabled { return NO; }
- (BOOL)uiSystemsClientGlobalConfigEnableButtonSentenceCasingForNative { return NO; }
%end

%hook YTHotConfig
- (BOOL)liveChatIosUseModernRotationDetectiom { return NO; } // Disable Modern Content (YTHotConfig)
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

// YTNOCheckLocalNetWork - https://poomsmart.github.io/repo/depictions/ytnochecklocalnetwork.html
%hook YTHotConfig
- (BOOL)isPromptForLocalNetworkPermissionsEnabled { return NO; }
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

// YTSpeed - https://github.com/Lyvendia/YTSpeed (Only works on YouTube v16.05.7-v18.18.2)
%group gYTSpeed
%hook YTVarispeedSwitchController
- (id)init {
	id result = %orig;

	const int size = 17;
	float speeds[] = {0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0, 3.25, 3.5, 3.75, 4.0, 5.0};
	id varispeedSwitchControllerOptions[size];

	for (int i = 0; i < size; ++i) {
		id title = [NSString stringWithFormat:@"%.2fx", speeds[i]];
		varispeedSwitchControllerOptions[i] = [[%c(YTVarispeedSwitchControllerOption) alloc] initWithTitle:title rate:speeds[i]];
	}

	NSUInteger count = sizeof(varispeedSwitchControllerOptions) / sizeof(id);
	NSArray *varispeedArray = [NSArray arrayWithObjects:varispeedSwitchControllerOptions count:count];
	MSHookIvar<NSArray *>(self, "_options") = varispeedArray;

	return result;
}
%end

%hook MLHAMQueuePlayer
- (void)setRate:(float)rate {
    MSHookIvar<float>(self, "_rate") = rate;
	MSHookIvar<float>(self, "_preferredRate") = rate;

	id player = MSHookIvar<HAMPlayerInternal *>(self, "_player");
	[player setRate: rate];

	id stickySettings = MSHookIvar<MLPlayerStickySettings *>(self, "_stickySettings");
	[stickySettings setRate: rate];

	[self.playerEventCenter broadcastRateChange: rate];

	YTSingleVideoController *singleVideoController = self.delegate;
	[singleVideoController playerRateDidChange: rate];
}
%end 

%hook YTPlayerViewController
%property (nonatomic, assign) float playbackRate;
- (void)singleVideo:(id)video playbackRateDidChange:(float)rate {
	%orig;
}
%end
%end

// YTStockVolumeHUD - https://github.com/lilacvibes/YTStockVolumeHUD
%group gStockVolumeHUD
%hook YTVolumeBarView
- (void)volumeChanged:(id)arg1 {
	%orig(nil);
}
%end

%hook UIApplication 
- (void)setSystemVolumeHUDEnabled:(BOOL)arg1 forAudioCategory:(id)arg2 {
	%orig(true, arg2);
}
%end
%end

// App Settings Overlay Options
%group gDisableDontEatMyContentSection
%hook YTSettingsSectionItemManager
- (void)updateDEMCSectionWithEntry:(id)arg1 {} // DontEatMyContent
%end
%end

%group gDisableReturnYouTubeDislikeSection
%hook YTSettingsSectionItemManager
- (void)updateRYDSectionWithEntry:(id)arg1 {} // Return YouTube Dislike
%end
%end

%group gDisableYouPiPSection
%hook YTSettingsSectionItemManager
- (void)updateYouPiPSectionWithEntry:(id)arg1 {} // YouPiP
%end
%end

%group gDisableAutoplaySection
%hook YTSettingsSectionItemManager
- (void)updateAutoplaySectionWithEntry:(id)arg1 {} // Autoplay
%end
%end

%group gDisableTryNewFeaturesSection
%hook YTSettingsSectionItemManager
- (void)updatePremiumEarlyAccessSectionWithEntry:(id)arg1 {} // Try New Features
%end
%end

%group gDisableNotificationsSection
%hook YTSettingsSectionItemManager
- (void)updateNotificationSectionWithEntry:(id)arg1 {} // Notifications
%end
%end

%group gDisableHistoryAndPrivacySection
%hook YTSettingsSectionItemManager
- (void)updateHistoryAndPrivacySectionWithEntry:(id)arg1 {} // History And Privacy
- (void)updateHistorySectionWithEntry:(id)arg1 {} // History
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
- (long long)userInterfaceIdiom {
    return YES;
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
- (long long)userInterfaceIdiom {
    return NO;
} 
%end
%hook UIStatusBarStyleAttributes
- (long long)idiom {
    return YES;
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

// YT startup animation
%hook YTColdConfig
- (BOOL)mainAppCoreClientIosEnableStartupAnimation {
    return IsEnabled(@"ytStartupAnimation_enabled") ? YES : NO;
}
%end

# pragma mark - ctor
%ctor {
    %init;
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
    if (IsEnabled(@"ytSpeed_enabled")) {
        %init(gYTSpeed);
    }
    if (IsEnabled(@"stockVolumeHUD_enabled")) {
        %init(gStockVolumeHUD);
    }
    if (IsEnabled(@"disableDontEatMyContentSection_enabled")) {
        %init(gDisableDontEatMyContentSection);
    }
    if (IsEnabled(@"disableReturnYouTubeDislikeSection_enabled")) {
        %init(gDisableReturnYouTubeDislikeSection);
    }
    if (IsEnabled(@"disableYouPiPSection_enabled")) {
        %init(gDisableYouPiPSection);
    }
    if (IsEnabled(@"disableAutoplaySection_enabled")) {
        %init(gDisableAutoplaySection);
    }
    if (IsEnabled(@"disableTryNewFeaturesSection_enabled")) {
        %init(gDisableTryNewFeaturesSection);
    }
    if (IsEnabled(@"disableNotificationsSection_enabled")) {
        %init(gDisableNotificationsSection);
    }
    if (IsEnabled(@"disableHistoryAndPrivacySection_enabled")) {
        %init(gDisableHistoryAndPrivacySection);
    }
    if (IsEnabled(@"disableLiveChatSection_enabled")) {
        %init(gDisableLiveChatSection);
    }

    // Change the default value of some options
    NSArray *allKeys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
    if (![allKeys containsObject:@"RYD-ENABLED"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RYD-ENABLED"]; 
    }
    if (![allKeys containsObject:@"YouPiPEnabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"YouPiPEnabled"]; 
	}
}
