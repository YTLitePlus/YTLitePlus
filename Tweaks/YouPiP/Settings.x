#import <version.h>
#import "Header.h"
#import "../YouTubeHeader/YTAlertView.h"
#import "../YouTubeHeader/YTHotConfig.h"
#import "../YouTubeHeader/YTSettingsViewController.h"
#import "../YouTubeHeader/YTSettingsSectionItem.h"
#import "../YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../YouTubeHeader/YTAppSettingsSectionItemActionController.h"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

#define FEATURE_CUTOFF_VERSION @"16.46.5"

static const NSInteger YouPiPSection = 200;

@interface YTSettingsSectionItemManager (YouPiP)
- (void)updateYouPiPSectionWithEntry:(id)entry;
@end

extern BOOL TweakEnabled();
extern BOOL UsePiPButton();
extern BOOL UseTabBarPiPButton();
extern BOOL NoMiniPlayerPiP();
extern BOOL LegacyPiP();
extern BOOL NonBackgroundable();
extern BOOL FakeVersion();

extern NSBundle *YouPiPBundle();

NSString *currentVersion;

static NSString *YouPiPWarnVersionKey = @"YouPiPWarnVersionKey";

%hook YTAppSettingsPresentationData

+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(YouPiPSection) atIndex:insertIndex + 1]; // Add YouPiP under General (ID: 1) section
    return mutableOrder;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYouPiPSectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YouPiPBundle();
    YTSettingsSectionItem *enabled = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"ENABLED")
        titleDescription:LOC(@"ENABLED_DESC")
        accessibilityIdentifier:nil
        switchOn:TweakEnabled()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnabledKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:enabled];
    YTSettingsSectionItem *activationMethod = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"USE_PIP_BUTTON")
        titleDescription:LOC(@"USE_PIP_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:UsePiPButton()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:PiPActivationMethodKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:activationMethod];
    YTSettingsSectionItem *activationMethod2 = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"USE_TAB_BAR_PIP_BUTTON")
        titleDescription:LOC(@"USE_TAB_BAR_PIP_BUTTON_DESC")
        accessibilityIdentifier:nil
        switchOn:UseTabBarPiPButton()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:PiPActivationMethod2Key];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:activationMethod2];
    YTSettingsSectionItem *miniPlayer = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"DISABLE_PIP_MINI_PLAYER")
        titleDescription:LOC(@"DISABLE_PIP_MINI_PLAYER_DESC")
        accessibilityIdentifier:nil
        switchOn:NoMiniPlayerPiP()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:NoMiniPlayerPiPKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:miniPlayer];
    if (IS_IOS_OR_NEWER(iOS_13_0) && [currentVersion compare:@"15.33.4" options:NSNumericSearch] == NSOrderedDescending) {
        YTSettingsSectionItem *legacyPiP = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"LEGACY_PIP")
            titleDescription:LOC(@"LEGACY_PIP_DESC")
            accessibilityIdentifier:nil
            switchOn:LegacyPiP()
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:CompatibilityModeKey];
                return YES;
            }
            settingItemId:0];
        [sectionItems addObject:legacyPiP];
    }
    YTAppSettingsSectionItemActionController *sectionItemActionController = [delegate valueForKey:@"_sectionItemActionController"];
    YTSettingsSectionItemManager *sectionItemManager = [sectionItemActionController valueForKey:@"_sectionItemManager"];
    YTHotConfig *hotConfig;
    @try {
        hotConfig = [sectionItemManager valueForKey:@"_hotConfig"];
    } @catch (id ex) {
        hotConfig = [sectionItemManager.gimme instanceForType:%c(YTHotConfig)];
    }
    YTIIosMediaHotConfig *iosMediaHotConfig = hotConfig.hotConfigGroup.mediaHotConfig.iosMediaHotConfig;
    if ([iosMediaHotConfig respondsToSelector:@selector(setEnablePipForNonBackgroundableContent:)]) {
        YTSettingsSectionItem *nonBackgroundable = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"NON_BACKGROUNDABLE_PIP")
            titleDescription:LOC(@"NON_BACKGROUNDABLE_PIP_DESC")
            accessibilityIdentifier:nil
            switchOn:NonBackgroundable()
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:NonBackgroundableKey];
                return YES;
            }
            settingItemId:0];
        [sectionItems addObject:nonBackgroundable];
    }
    if ([currentVersion compare:FEATURE_CUTOFF_VERSION options:NSNumericSearch] == NSOrderedDescending) {
        YTSettingsSectionItem *fakeVersion = [%c(YTSettingsSectionItem) switchItemWithTitle:LOC(@"FAKE_YT_VERSION")
            titleDescription:[NSString stringWithFormat:LOC(@"FAKE_YT_VERSION_DESC"), FEATURE_CUTOFF_VERSION]
            accessibilityIdentifier:nil
            switchOn:FakeVersion()
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:FakeVersionKey];
                return YES;
            }
            settingItemId:0];
        [sectionItems addObject:fakeVersion];
    }
    [delegate setSectionItems:sectionItems forCategory:YouPiPSection title:TweakName titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YouPiPSection) {
        [self updateYouPiPSectionWithEntry:entry];
        return;
    }
    %orig;
}

%end

BOOL loadWatchNextRequest = NO;

%hook YTVersionUtils

+ (NSString *)appVersion {
    return FakeVersion() && loadWatchNextRequest ? FEATURE_CUTOFF_VERSION : %orig;
}

%end

%hook YTWatchNextViewController

- (void)loadWatchNextRequest:(id)arg1 withInitialWatchNextResponse:(id)arg2 disableUnloadModel:(BOOL)arg3 {
    loadWatchNextRequest = YES;
    %orig;
    loadWatchNextRequest = NO;
}

%end

%ctor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    currentVersion = [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey];
    if (![defaults boolForKey:YouPiPWarnVersionKey] && [currentVersion compare:@(OS_STRINGIFY(MIN_YOUTUBE_VERSION)) options:NSNumericSearch] != NSOrderedDescending) {
        [defaults setBool:YES forKey:YouPiPWarnVersionKey];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSBundle *tweakBundle = YouPiPBundle();
            YTAlertView *alertView = [%c(YTAlertView) infoDialog];
            alertView.title = TweakName;
            alertView.subtitle = [NSString stringWithFormat:LOC(@"UNSUPPORTED_YT_VERSION"), currentVersion, @(OS_STRINGIFY(MIN_YOUTUBE_VERSION))];
            [alertView show];
        });
    }
    %init;
}
