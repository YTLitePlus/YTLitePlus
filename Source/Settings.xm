#import "../YTLitePlus.h"
#import "../Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSearchableSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../Tweaks/YouTubeHeader/YTUIUtils.h"
#import "../Tweaks/YouTubeHeader/YTSettingsPickerViewController.h"
// #import "AppIconOptionsController.h"

// Basic switch item
#define BASIC_SWITCH(title, description, key) \
    [YTSettingsSectionItemClass switchItemWithTitle:title \
        titleDescription:description \
        accessibilityIdentifier:nil \
        switchOn:IsEnabled(key) \
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) { \
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:key]; \
            return YES; \
        } \
        settingItemId:0]

/*
// Custom switch item that has customizable code
#define CUSTOM_SWITCH(title, description, key, code) \
    [YTSettingsSectionItemClass switchItemWithTitle:title \
        titleDescription:description \
        accessibilityIdentifier:nil \
        switchOn:IsEnabled(key) \
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enable) { \
            code \
        } \
        settingItemId:0]
*/

static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static int GetSelection(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}
static int contrastMode() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcm"];
}
static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}

@interface YTSettingsSectionItemManager (YTLitePlus)
- (void)updateYTLitePlusSectionWithEntry:(id)entry;
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls;
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller;
@end

extern NSBundle *YTLitePlusBundle();

// Keys for "Copy Settings" button (for: YTLitePlus)
NSArray *copyKeys = @[
/* MAIN    Controls Keys 1/2 */ @"enableShareButton_enabled", @"enableSaveToButton_enabled", @"hideVideoPlayerShadowOverlayButtons_enabled", @"hideRightPanel_enabled", @"hideHeatwaves_enabled", @"disableAmbientModePortrait_enabled",
/* MAIN    Controls Keys 2/2 */ @"disableAmbientModeFullscreen_enabled", @"fullscreenToTheRight_enabled", @"seekAnywhere_enabled", @"YTTapToSeek_enabled", @"disablePullToFull_enabled", @"alwaysShowRemainingTime_enabled", @"disableRemainingTime_enabled", @"disableEngagementOverlay_enabled",
/* MAIN App Overlay Keys 1/2 */ @"disableAccountSection_enabled", @"disableAutoplaySection_enabled", @"disableTryNewFeaturesSection_enabled", @"disableVideoQualityPreferencesSection_enabled", @"disableNotificationsSection_enabled",
/* MAIN App Overlay Keys 2/2 */ @"disableManageAllHistorySection_enabled", @"disableYourDataInYouTubeSection_enabled", @"disablePrivacySection_enabled", @"disableLiveChatSection_enabled",
/* MAIN        Playback Keys */ @"inline_muted_playback_enabled",
/* MAIN            Misc Keys */ @"newSettingsUI_enabled", @"ytStartupAnimation_enabled", @"ytNoModernUI_enabled", @"iPadLayout_enabled", @"iPhoneLayout_enabled", @"castConfirm_enabled", @"bigYTMiniPlayer_enabled", @"hideCastButton_enabled", @"hideSponsorBlockButton_enabled", @"hideHomeTab_enabled", @"fixCasting_enabled", @"flex_enabled", @"enableVersionSpoofer_enabled",
/* TWEAK          YTUHD Keys */ @"EnableVP9", @"AllVP9"
];

// Add both YTLite and YTLitePlus to YouGroupSettings
static const NSInteger YTLitePlusSection = 788;
static const NSInteger YTLiteSection = 789;
%hook YTSettingsGroupData
+ (NSMutableArray <NSNumber *> *)tweaks {
    NSMutableArray <NSNumber *> *originalTweaks = %orig;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [originalTweaks addObject:@(YTLitePlusSection)];
        [originalTweaks addObject:@(YTLiteSection)];
    });

    return originalTweaks;
}
%end


// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(YTLitePlusSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionController

- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}

%end

%hook YTSettingsSectionItemManager
%new(v@:@)
- (void)updateYTLitePlusSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YTLitePlusBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];

    YTSettingsSectionItem *main = [%c(YTSettingsSectionItem)
    itemWithTitle:[NSString stringWithFormat:LOC(@"VERSION"), @(OS_STRINGIFY(TWEAK_VERSION))]
    titleDescription:LOC(@"VERSION_CHECK")
    accessibilityIdentifier:nil
    detailTextBlock:nil
    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/YTLitePlus/YTLitePlus/releases/latest"]];
    }];
    [sectionItems addObject:main];

    YTSettingsSectionItem *copySettings = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"COPY_SETTINGS")
        titleDescription:IS_ENABLED(@"switchCopyandPasteFunctionality_enabled") ? LOC(@"COPY_SETTINGS_DESC_2") : LOC(@"COPY_SETTINGS_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            if (IS_ENABLED(@"switchCopyandPasteFunctionality_enabled")) {
                // Export Settings functionality
                NSURL *tempFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"exported_settings.txt"]];
                NSMutableString *settingsString = [NSMutableString string];
                for (NSString *key in copyKeys) {
                    id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                    if (value) {
                        [settingsString appendFormat:@"%@: %@\n", key, value];
                    }
                }
                [settingsString writeToURL:tempFileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
                UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:tempFileURL inMode:UIDocumentPickerModeExportToService];
                documentPicker.delegate = (id<UIDocumentPickerDelegate>)self;
                documentPicker.allowsMultipleSelection = NO;
                [settingsViewController presentViewController:documentPicker animated:YES completion:nil];
            } else {
                // Copy Settings functionality (DEFAULT - Copies to Clipboard)
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSMutableString *settingsString = [NSMutableString string];
                for (NSString *key in copyKeys) {
                    if ([userDefaults objectForKey:key]) {
                        NSString *value = [userDefaults objectForKey:key];
                        [settingsString appendFormat:@"%@: %@\n", key, value];
                    }
                }       
                [[UIPasteboard generalPasteboard] setString:settingsString];
                // Show a confirmation message or perform some other action here
            }
            return YES;
        }
    ];
    [sectionItems addObject:copySettings];

    YTSettingsSectionItem *pasteSettings = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"PASTE_SETTINGS")
        titleDescription:IS_ENABLED(@"switchCopyandPasteFunctionality_enabled") ? LOC(@"PASTE_SETTINGS_DESC_2") : LOC(@"PASTE_SETTINGS_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            if (IS_ENABLED(@"switchCopyandPasteFunctionality_enabled")) {
                // Paste Settings functionality (ALTERNATE - Pastes from ".txt")
                UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.text"] inMode:UIDocumentPickerModeImport];
                documentPicker.delegate = (id<UIDocumentPickerDelegate>)self;
                documentPicker.allowsMultipleSelection = NO;
                [settingsViewController presentViewController:documentPicker animated:YES completion:nil];
                return YES;
            } else {
                // Paste Settings functionality (DEFAULT - Pastes from Clipboard)
                UIAlertController *confirmPasteAlert = [UIAlertController alertControllerWithTitle:LOC(@"PASTE_SETTINGS_ALERT") message:nil preferredStyle:UIAlertControllerStyleAlert];
                [confirmPasteAlert addAction:[UIAlertAction actionWithTitle:LOC(@"Cancel") style:UIAlertActionStyleCancel handler:nil]];
                [confirmPasteAlert addAction:[UIAlertAction actionWithTitle:LOC(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSString *settingsString = [[UIPasteboard generalPasteboard] string];
                    if (settingsString.length > 0) {
                        NSArray *lines = [settingsString componentsSeparatedByString:@"\n"];
                        for (NSString *line in lines) {
                            NSArray *components = [line componentsSeparatedByString:@": "];
                            if (components.count == 2) {
                                NSString *key = components[0];
                                NSString *value = components[1];
                                [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
                            }
                        }                 
                        [settingsViewController reloadData];
                        // Show a confirmation message or perform some other action here
                    }
                }]];
                [settingsViewController presentViewController:confirmPasteAlert animated:YES completion:nil];
            }
            return YES;
        }
    ];
    [sectionItems addObject:pasteSettings];

    YTSettingsSectionItem *videoPlayer = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"VIDEO_PLAYER")
        titleDescription:LOC(@"VIDEO_PLAYER_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            // Access the current view controller
            UIViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
            if (settingsViewController) {
                // Present the video picker
                UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo] inMode:UIDocumentPickerModeImport];
                documentPicker.delegate = (id<UIDocumentPickerDelegate>)self;
                documentPicker.allowsMultipleSelection = NO;
                [settingsViewController presentViewController:documentPicker animated:YES completion:nil];
            } else {
                NSLog(@"settingsViewController is nil");
            }
            
            return YES; // Return YES to indicate that the action was handled
        }
    ];
    [sectionItems addObject:videoPlayer];

/*
    YTSettingsSectionItem *appIcon = [%c(YTSettingsSectionItem)
        itemWithTitle:LOC(@"CHANGE_APP_ICON")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            AppIconOptionsController *appIconController = [[AppIconOptionsController alloc] init];
            [settingsViewController.navigationController pushViewController:appIconController animated:YES];
            return YES;
        }
    ];
    [sectionItems addObject:appIcon];
*/

# pragma mark - Video Controls Overlay Options
    YTSettingsSectionItem *videoControlOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            BASIC_SWITCH(LOC(@"ENABLE_SHARE_BUTTON"), LOC(@"ENABLE_SHARE_BUTTON_DESC"), @"enableShareButton_enabled"),
            BASIC_SWITCH(LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON"), LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON_DESC"), @"enableSaveToButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS"), LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS_DESC"), @"hideVideoPlayerShadowOverlayButtons_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_RIGHT_PANEL"), LOC(@"HIDE_RIGHT_PANEL_DESC"), @"hideRightPanel_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_HEATWAVES"), LOC(@"HIDE_HEATWAVES_DESC"), @"hideHeatwaves_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_AMBIENT_PORTRAIT"), LOC(@"DISABLE_AMBIENT_PORTRAIT_DESC"), @"disableAmbientModePortrait_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_AMBIENT_FULLSCREEN"), LOC(@"DISABLE_AMBIENT_FULLSCREEN_DESC"), @"disableAmbientModeFullscreen_enabled"),
            BASIC_SWITCH(LOC(@"FULLSCREEN_TO_THE_RIGHT"), LOC(@"FULLSCREEN_TO_THE_RIGHT_DESC"), @"fullscreenToTheRight_enabled"),
            BASIC_SWITCH(LOC(@"SEEK_ANYWHERE"), LOC(@"SEEK_ANYWHERE_DESC"), @"seekAnywhere_enabled"),
            BASIC_SWITCH(LOC(@"ENABLE_TAP_TO_SEEK"), LOC(@"ENABLE_TAP_TO_SEEK_DESC"), @"YTTapToSeek_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_PULL_TO_FULLSCREEN_GESTURE"), LOC(@"DISABLE_PULL_TO_FULLSCREEN_GESTURE_DESC"), @"disablePullToFull_enabled"),
            BASIC_SWITCH(LOC(@"ALWAYS_USE_REMAINING_TIME"), LOC(@"ALWAYS_USE_REMAINING_TIME_DESC"), @"alwaysShowRemainingTime_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_TOGGLE_TIME_REMAINING"), LOC(@"DISABLE_TOGGLE_TIME_REMAINING_DESC"), @"disableRemainingTime_enabled"),
            BASIC_SWITCH(LOC(@"DISABLE_ENGAGEMENT_OVERLAY"), LOC(@"DISABLE_ENGAGEMENT_OVERLAY_DESC"), @"disableEngagementOverlay_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_COMMENT_PREVIEWS_UNDER_PLAYER"), LOC(@"HIDE_COMMENT_PREVIEWS_UNDER_PLAYER_DESC"), @"hidePreviewCommentSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_AUTOPLAY_MINI_PREVIEW"), LOC(@"HIDE_AUTOPLAY_MINI_PREVIEW_DESC"), @"hideAutoplayMiniPreview_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_HUD_MESSAGES"), LOC(@"HIDE_HUD_MESSAGES_DESC"), @"hideHUD_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_COLLAPSE_BUTTON"), LOC(@"HIDE_COLLAPSE_BUTTON_DESC"), @"disableCollapseButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_SPEED_TOAST"), LOC(@"HIDE_SPEED_TOAST_DESC"), @"hideSpeedToast_enabled"),
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:videoControlOverlayGroup];

# pragma mark - App Settings Overlay Options
    YTSettingsSectionItem *appSettingsOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"APP_SETTINGS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            BASIC_SWITCH(LOC(@"HIDE_ACCOUNT_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableAccountSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_AUTOPLAY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableAutoplaySection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_TRYNEWFEATURES_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableTryNewFeaturesSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_VIDEOQUALITYPREFERENCES_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableVideoQualityPreferencesSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_NOTIFICATIONS_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableNotificationsSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_MANAGEALLHISTORY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableManageAllHistorySection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_YOURDATAINYOUTUBE_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableYourDataInYouTubeSection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_PRIVACY_SECTION"), LOC(@"APP_RESTART_DESC"), @"disablePrivacySection_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_LIVECHAT_SECTION"), LOC(@"APP_RESTART_DESC"), @"disableLiveChatSection_enabled")
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"APP_SETTINGS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:appSettingsOverlayGroup];

# pragma mark - LowContrastMode
    YTSettingsSectionItem *lowContrastModeSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"LOW_CONTRAST_MODE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (contrastMode()) {
                case 1:
                    return LOC(@"Hex Color");
                case 0:
                default:
                    return LOC(@"Default");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Default") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"Hex Color") titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"lcm"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"LOW_CONTRAST_MODE") pickerSectionTitle:nil rows:rows selectedItemIndex:contrastMode() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - VersionSpooferLite
    YTSettingsSectionItem *versionSpooferSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VERSION_SPOOFER_TITLE")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (appVersionSpoofer()) {
                case 1:
                    return @"v18.34.5 (Enable Library Tab)";
                case 2:
                    return @"v18.33.3 (Removes Playables)";
                case 3:
                    return @"v18.18.2 (Fixes YTClassicVideoQuality & YTSpeed)";
                case 4:
                    return @"v18.01.2 (First v18 Version)";
                case 5:
                    return @"v17.49.6 (Removes Rounded Miniplayer)";
                case 6:
                    return @"v17.38.10 (Fixes LowContrastMode)";
                case 7:
                    return @"v17.33.2 (Oldest Supported Version)";
                case 0:
                default:
                    return @"v18.49.3 (Last v18 Version)";
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.49.3 (Last v18 Version)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.34.5 (Enable Library Tab)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.33.3 (Removes Playables)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.18.2 (Fixes YTClassicVideoQuality & YTSpeed)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v18.01.2 (First v18 Version)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.49.6 (Removes Rounded Miniplayer)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.38.10 (Fixes LowContrastMode)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:6 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:@"v17.33.2 (Oldest Supported Version)" titleDescription:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:7 forKey:@"versionSpoofer"];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:@"VERSION_SPOOFER_TITLE" pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - Theme
    YTSettingsSectionItem *themeGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"THEME_OPTIONS")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (GetSelection(@"appTheme")) {
                case 1:
                    return LOC(@"OLD_DARK_THEME");
                case 0:
                default:
                    return LOC(@"DEFAULT_THEME");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"DEFAULT_THEME") titleDescription:LOC(@"DEFAULT_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLD_DARK_THEME") titleDescription:LOC(@"OLD_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                BASIC_SWITCH(LOC(@"OLED_KEYBOARD"), LOC(@"OLED_KEYBOARD_DESC"), @"oledKeyBoard_enabled"),
                BASIC_SWITCH(LOC(@"LOW_CONTRAST_MODE"), LOC(@"LOW_CONTRAST_MODE_DESC"), @"lowContrastMode_enabled"),
                lowContrastModeSection
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"THEME_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:GetSelection(@"appTheme") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:themeGroup];

# pragma mark - Copy of Playback in feeds section - @bhackel
    // This section is hidden in vanilla YouTube when using the new settings UI, so
    // we can recreate it here
    YTSettingsSectionItem *playbackInFeedsGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"PLAYBACK_IN_FEEDS")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (GetSelection(@"inline_muted_playback_enabled")) {
                case 3:
                    return LOC(@"PLAYBACK_IN_FEEDS_WIFI_ONLY");
                case 1:
                    return LOC(@"PLAYBACK_IN_FEEDS_OFF");
                case 2:
                default:
                    return LOC(@"PLAYBACK_IN_FEEDS_ALWAYS_ON");
            }
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PLAYBACK_IN_FEEDS_OFF") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"inline_muted_playback_enabled"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PLAYBACK_IN_FEEDS_ALWAYS_ON") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"inline_muted_playback_enabled"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"PLAYBACK_IN_FEEDS_WIFI_ONLY") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"inline_muted_playback_enabled"];
                    [settingsViewController reloadData];
                    return YES;
                }],
            ];
            // It seems values greater than 3 act the same as Always On (Index 1)
            int (^getInlineSelection)() = ^int() {
                int selection = GetSelection(@"inline_muted_playback_enabled") - 1;
                return selection > 3 ? 1 : selection;
            };
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"PLAYBACK_IN_FEEDS") pickerSectionTitle:nil rows:rows selectedItemIndex:getInlineSelection() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];

# pragma mark - Miscellaneous
    YTSettingsSectionItem *miscellaneousGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"MISCELLANEOUS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            playbackInFeedsGroup,
            // BASIC_SWITCH(LOC(@"NEW_SETTINGS_UI"), LOC(@"NEW_SETTINGS_UI_DESC"), @"newSettingsUI_enabled"), // disabled because YTLite is probably forcing it to NO
            BASIC_SWITCH(LOC(@"ENABLE_YT_STARTUP_ANIMATION"), LOC(@"ENABLE_YT_STARTUP_ANIMATION_DESC"), @"ytStartupAnimation_enabled"), 
            BASIC_SWITCH(LOC(@"HIDE_MODERN_INTERFACE"), LOC(@"HIDE_MODERN_INTERFACE_DESC"), @"ytNoModernUI_enabled"),
            BASIC_SWITCH(LOC(@"IPAD_LAYOUT"), LOC(@"IPAD_LAYOUT_DESC"), @"iPadLayout_enabled"),
            BASIC_SWITCH(LOC(@"IPHONE_LAYOUT"), LOC(@"IPHONE_LAYOUT_DESC"), @"iPhoneLayout_enabled"),
            BASIC_SWITCH(LOC(@"CAST_CONFIRM"), LOC(@"CAST_CONFIRM_DESC"), @"castConfirm_enabled"),
            BASIC_SWITCH(LOC(@"NEW_MINIPLAYER_STYLE"), LOC(@"NEW_MINIPLAYER_STYLE_DESC"), @"bigYTMiniPlayer_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_CAST_BUTTON"), LOC(@"HIDE_CAST_BUTTON_DESC"), @"hideCastButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_SPONSORBLOCK_BUTTON"), LOC(@"HIDE_SPONSORBLOCK_BUTTON_DESC"), @"hideSponsorBlockButton_enabled"),
            BASIC_SWITCH(LOC(@"HIDE_HOME_TAB"), LOC(@"HIDE_HOME_TAB_DESC"), @"hideHomeTab_enabled"),
            BASIC_SWITCH(LOC(@"FIX_CASTING"), LOC(@"FIX_CASTING_DESC"), @"fixCasting_enabled"),
            BASIC_SWITCH(LOC(@"REPLACE_COPY_AND_PASTE_BUTTONS"), LOC(@"REPLACE_COPY_AND_PASTE_BUTTONS_DESC"), @"switchCopyandPasteFunctionality_enabled"),
            BASIC_SWITCH(LOC(@"ENABLE_FLEX"), LOC(@"ENABLE_FLEX_DESC"), @"flex_enabled"),
            BASIC_SWITCH(LOC(@"APP_VERSION_SPOOFER_LITE"), LOC(@"APP_VERSION_SPOOFER_LITE_DESC"), @"enableVersionSpoofer_enabled"),    
            versionSpooferSection
        ];
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"MISCELLANEOUS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:miscellaneousGroup];

    if ([settingsViewController respondsToSelector:@selector(setSectionItems:forCategory:title:icon:titleDescription:headerHidden:)])
        [settingsViewController setSectionItems:sectionItems forCategory:YTLitePlusSection title:@"YTLitePlus" icon:nil titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];
    else
        [settingsViewController setSectionItems:sectionItems forCategory:YTLitePlusSection title:@"YTLitePlus" titleDescription:LOC(@"TITLE DESCRIPTION") headerHidden:YES];}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTLitePlusSection) {
        [self updateYTLitePlusSectionWithEntry:entry];
        return;
    }
    %orig;
}

// Implement the delegate method for document picker
%new
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *pickedURL = [urls firstObject];
    
    if (pickedURL) {
        // Use AVPlayerViewController to play the video
        AVPlayer *player = [AVPlayer playerWithURL:pickedURL];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = player;
        
        UIViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
        if (settingsViewController) {
            [settingsViewController presentViewController:playerViewController animated:YES completion:^{
                [player play];
            }];
        }
    }
}

%new
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // Handle cancellation if needed
    NSLog(@"Document picker was cancelled");
}

%end
