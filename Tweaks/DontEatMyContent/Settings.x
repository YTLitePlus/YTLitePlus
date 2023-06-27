#import "Tweak.h"

// Adapted from 
// https://github.com/PoomSmart/YouPiP/blob/bd04bf37be3d01540db418061164ae17a8f0298e/Settings.x
// https://github.com/qnblackcat/uYouPlus/blob/265927b3900d886e2085d05bfad7cd4157be87d2/Settings.xm

extern void DEMC_showSnackBar(NSString *text);
extern NSBundle *DEMC_getTweakBundle();
extern CGFloat constant;

static const NSInteger sectionId = 517; // DontEatMyContent's section ID (just a random number)

// Category for additional functions
@interface YTSettingsSectionItemManager (_DEMC)
- (void)updateDEMCSectionWithEntry:(id)entry;
@end

%group DEMC_Settings

%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)]; // Index of Settings > General
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(sectionId) atIndex:insertIndex + 1]; // Insert DontEatMyContent settings under General
    return mutableOrder;
}
%end

%hook YTSettingsSectionItemManager
%new
- (void)updateDEMCSectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    NSMutableArray *sectionItems = [NSMutableArray array]; // Create autoreleased array
    NSBundle *bundle = DEMC_getTweakBundle();

    // Enabled
    YTSettingsSectionItem *enabled = [%c(YTSettingsSectionItem) switchItemWithTitle:LOCALIZED_STRING(@"ENABLED")
        titleDescription:LOCALIZED_STRING(@"TWEAK_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_TWEAK_ENABLED
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:ENABLED_KEY];

            YTAlertView *alert = [%c(YTAlertView) confirmationDialogWithAction:^
                {
                    // https://stackoverflow.com/a/17802404/19227228
                    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
                    [NSThread sleepForTimeInterval:0.5];
                    exit(0);
                }
                actionTitle:LOCALIZED_STRING(@"EXIT")
                cancelTitle:LOCALIZED_STRING(@"LATER")
            ];
            alert.title = DEMC;
            alert.subtitle = LOCALIZED_STRING(@"EXIT_YT_DESC");
            [alert show];

            return YES;
        }
        settingItemId:0
    ];
    [sectionItems addObject:enabled];

    // Safe area constant
    YTSettingsSectionItem *constraintConstant = [%c(YTSettingsSectionItem) itemWithTitle:LOCALIZED_STRING(@"SAFE_AREA_CONST")
        titleDescription:LOCALIZED_STRING(@"SAFE_AREA_CONST_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return [NSString stringWithFormat:@"%.1f", constant];
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
            __block YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
            NSMutableArray *rows = [NSMutableArray array];

            float currentConstant = 20.0;
            float storedConstant = [[NSUserDefaults standardUserDefaults] floatForKey:SAFE_AREA_CONSTANT_KEY];;
            UInt8 index = 0, selectedIndex = 0;
            while (currentConstant <= 25.0) {
                NSString *title = [NSString stringWithFormat:@"%.1f", currentConstant];
                if (currentConstant == DEFAULT_CONSTANT)
                    title = [NSString stringWithFormat:@"%.1f (%@)", currentConstant, LOCALIZED_STRING(@"DEFAULT")];
                if (currentConstant == storedConstant)
                    selectedIndex = index;
                [rows addObject:[%c(YTSettingsSectionItem) checkmarkItemWithTitle:title
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
                        [[NSUserDefaults standardUserDefaults] setFloat:currentConstant forKey:SAFE_AREA_CONSTANT_KEY];
                        constant = currentConstant;
                        [settingsViewController reloadData]; // Refresh section's detail text (constant)
                        DEMC_showSnackBar(LOCALIZED_STRING(@"SAFE_AREA_CONST_MESSAGE"));
                        return YES;
                    }
                ]];
                currentConstant += 0.5; index++;
            }

            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOCALIZED_STRING(@"SAFE_AREA_CONST")
                pickerSectionTitle:nil
                rows:rows
                selectedItemIndex:selectedIndex
                parentResponder:[self parentResponder]
            ];

            [settingsViewController pushViewController:picker];
            return YES;
        }
    ];
    if (IS_TWEAK_ENABLED) [sectionItems addObject:constraintConstant];

    // Color views
    YTSettingsSectionItem *colorViews = [%c(YTSettingsSectionItem) switchItemWithTitle:LOCALIZED_STRING(@"COLOR_VIEWS")
        titleDescription:LOCALIZED_STRING(@"COLOR_VIEWS_DESC")
        accessibilityIdentifier:nil
        switchOn:IS_COLOR_VIEWS_ENABLED
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:COLOR_VIEWS_ENABLED_KEY];
            DEMC_showSnackBar(LOCALIZED_STRING(@"CHANGES_SAVED"));
            return YES;
        }
        settingItemId:0
    ];
    if (IS_TWEAK_ENABLED) [sectionItems addObject:colorViews];

    // Report an issue
    YTSettingsSectionItem *reportIssue = [%c(YTSettingsSectionItem) itemWithTitle:LOCALIZED_STRING(@"REPORT_ISSUE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/therealFoxster/DontEatMyContent/issues/new"]];
        }
    ];
    [sectionItems addObject:reportIssue];

    // View source code
    YTSettingsSectionItem *sourceCode = [%c(YTSettingsSectionItem) itemWithTitle:LOCALIZED_STRING(@"SOURCE_CODE")
        titleDescription:nil
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger sectionItemIndex) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/therealFoxster/DontEatMyContent"]];
        }
    ];
    [sectionItems addObject:sourceCode];

    [delegate setSectionItems:sectionItems 
        forCategory:sectionId 
        title:DEMC
        titleDescription:nil 
        headerHidden:NO
    ];
}
- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == sectionId) {
        [self updateDEMCSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end

%end // group DEMC_Settings

%ctor {
    %init(DEMC_Settings);
}