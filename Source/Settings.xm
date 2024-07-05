#import "../YTLitePlus.h"
#import "../Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSearchableSettingsViewController.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "../Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../Tweaks/YouTubeHeader/YTUIUtils.h"
#import "../Tweaks/YouTubeHeader/YTSettingsPickerViewController.h"
// #import "AppIconOptionsController.h"

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
static const NSInteger YTLitePlusSection = 788;

@interface YTSettingsSectionItemManager (YTLitePlus)
- (void)updateYTLitePlusSectionWithEntry:(id)entry;
@end

extern NSBundle *YTLitePlusBundle();

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
        return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/Balackburn/YTLitePlus/releases/latest"]];
    }];
    [sectionItems addObject:main];

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
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_SHARE_BUTTON")
                titleDescription:LOC(@"ENABLE_SHARE_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"enableShareButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"enableShareButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON")
                titleDescription:LOC(@"ENABLE_SAVE_TO_PLAYLIST_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"enableSaveToButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"enableSaveToButton_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS")
                titleDescription:LOC(@"HIDE_SHADOW_OVERLAY_BUTTONS_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideVideoPlayerShadowOverlayButtons_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideVideoPlayerShadowOverlayButtons_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_RIGHT_PANEL")
                titleDescription:LOC(@"HIDE_RIGHT_PANEL_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideRightPanel_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideRightPanel_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"NO_SUGGESTED_VIDEO")
                titleDescription:LOC(@"NO_SUGGESTED_VIDEO_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"noSuggestedVideo_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"noSuggestedVideo_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HEATWAVES")
                titleDescription:LOC(@"HIDE_HEATWAVES_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideHeatwaves_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHeatwaves_enabled"];
                    return YES;
                }
                settingItemId:0]
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"VIDEO_CONTROLS_OVERLAY_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:videoControlOverlayGroup];

# pragma mark - App Settings Overlay Options
    YTSettingsSectionItem *appSettingsOverlayGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"APP_SETTINGS_OVERLAY_OPTIONS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_ACCOUNT_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableAccountSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableAccountSection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_AUTOPLAY_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableAutoplaySection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableAutoplaySection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_TRYNEWFEATURES_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableTryNewFeaturesSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableTryNewFeaturesSection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_VIDEOQUALITYPREFERENCES_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableVideoQualityPreferencesSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableVideoQualityPreferencesSection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_NOTIFICATIONS_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableNotificationsSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableNotificationsSection_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_MANAGEALLHISTORY_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableManageAllHistorySection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableManageAllHistorySection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_YOURDATAINYOUTUBE_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableYourDataInYouTubeSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableYourDataInYouTubeSection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_PRIVACY_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disablePrivacySection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disablePrivacySection_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_LIVECHAT_SECTION")
                titleDescription:LOC(@"APP_RESTART_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"disableLiveChatSection_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"disableLiveChatSection_enabled"];
                    return YES;
                }
                settingItemId:0]
        ];        
        YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"App Settings Overlay Options") pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
        [settingsViewController pushViewController:picker];
        return YES;
    }];
    [sectionItems addObject:appSettingsOverlayGroup];

# pragma mark - LowContrastMode
    YTSettingsSectionItem *lowContrastModeSection = [YTSettingsSectionItemClass itemWithTitle:LOC(@"Low Contrast Mode")
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
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"Low Contrast Mode") pickerSectionTitle:nil rows:rows selectedItemIndex:contrastMode() parentResponder:[self parentResponder]];
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
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:@"Version Spoofer Picker" pickerSectionTitle:nil rows:rows selectedItemIndex:appVersionSpoofer() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];

# pragma mark - Theme
    YTSettingsSectionItem *themeGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"THEME_OPTIONS")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            switch (GetSelection(@"appTheme")) {
                case 1:
                    return LOC(@"OLED_DARK_THEME_2");
                case 2:
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
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLED_DARK_THEME") titleDescription:LOC(@"OLED_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"OLD_DARK_THEME") titleDescription:LOC(@"OLD_DARK_THEME_DESC") selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"appTheme"];
                    [settingsViewController reloadData];
                    return YES;
                }],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"OLED_KEYBOARD")
                titleDescription:LOC(@"OLED_KEYBOARD_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"oledKeyBoard_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"oledKeyBoard_enabled"];
                    return YES;
                }
                settingItemId:0],

                [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"LOW_CONTRAST_MODE")
                titleDescription:LOC(@"LOW_CONTRAST_MODE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"lowContrastMode_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"lowContrastMode_enabled"];
                    return YES;
                }
                settingItemId:0], lowContrastModeSection];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"THEME_OPTIONS") pickerSectionTitle:nil rows:rows selectedItemIndex:GetSelection(@"appTheme") parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:themeGroup];

# pragma mark - Miscellaneous
    YTSettingsSectionItem *miscellaneousGroup = [YTSettingsSectionItemClass itemWithTitle:LOC(@"MISCELLANEOUS") accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
        NSArray <YTSettingsSectionItem *> *rows = @[
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_YT_STARTUP_ANIMATION")
                titleDescription:LOC(@"ENABLE_YT_STARTUP_ANIMATION_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytStartupAnimation_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytStartupAnimation_enabled"];
                    return YES;
                }
                settingItemId:0],
                
            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_MODERN_INTERFACE")
                titleDescription:LOC(@"HIDE_MODERN_INTERFACE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytNoModernUI_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytNoModernUI_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"IPAD_LAYOUT")
                titleDescription:LOC(@"IPAD_LAYOUT_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"iPadLayout_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"iPadLayout_enabled"];
                    return YES;
                }
                settingItemId:0], 

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"IPHONE_LAYOUT")
                titleDescription:LOC(@"IPHONE_LAYOUT_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"iPhoneLayout_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"iPhoneLayout_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"CAST_CONFIRM")
                titleDescription:LOC(@"CAST_CONFIRM_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"castConfirm_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"castConfirm_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"NEW_MINIPLAYER_STYLE")
                titleDescription:LOC(@"NEW_MINIPLAYER_STYLE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"bigYTMiniPlayer_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"bigYTMiniPlayer_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"STOCK_VOLUME_HUD")
                titleDescription:LOC(@"STOCK_VOLUME_HUD_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"stockVolumeHUD_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"stockVolumeHUD_enabled"];
                    return YES;
                }
                settingItemId:0],

        [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"UN_SHORTS")
            titleDescription:LOC(@"UN_SHORTS_DESC")
            accessibilityIdentifier:nil
            switchOn:IsEnabled(@"UnShorts_enabled")
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"UnShorts_enabled"];
                return YES                                                                                       ;
            }
            settingItemId:0],
        
        [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_COMMUNITY_POSTS")
            titleDescription:LOC(@"HIDE_COMMUNITY_POSTS_DESC")
            accessibilityIdentifier:nil
            switchOn:IsEnabled(@"hideCommunityPosts_enabled")
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCommunityPosts_enabled"];
                return YES;
            }
            settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_CAST_BUTTON")
                titleDescription:LOC(@"HIDE_CAST_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideCastButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideCastButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_SPONSORBLOCK_BUTTON")
                titleDescription:LOC(@"HIDE_SPONSORBLOCK_BUTTON_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideSponsorBlockButton_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideSponsorBlockButton_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"YT_SPEED")
                titleDescription:LOC(@"YT_SPEED_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"ytSpeed_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytSpeed_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"HIDE_HOME_TAB")
                titleDescription:LOC(@"HIDE_HOME_TAB_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"hideHomeTab_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideHomeTab_enabled"];
                    return YES;
                }
                settingItemId:0],

            [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLE_FLEX")
                titleDescription:LOC(@"ENABLE_FLEX_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"flex_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"flex_enabled"];
                    return YES;
                }
                settingItemId:0],

       [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"APP_VERSION_SPOOFER_LITE")
                titleDescription:LOC(@"APP_VERSION_SPOOFER_LITE_DESC")
                accessibilityIdentifier:nil
                switchOn:IsEnabled(@"enableVersionSpoofer_enabled")
                switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"enableVersionSpoofer_enabled"];
                    return YES;
                }
                settingItemId:0], versionSpooferSection];
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
%end
