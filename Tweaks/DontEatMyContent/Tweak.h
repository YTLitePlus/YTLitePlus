#import <UIKit/UIKit.h>

#define DEMC @"DontEatMyContent"

// Keys
#define ENABLED_KEY @"DEMC_enabled"
#define COLOR_VIEWS_ENABLED_KEY @"DEMC_colorViewsEnabled"
#define SAFE_AREA_CONSTANT_KEY @"DEMC_safeAreaConstant"

#define DEFAULT_CONSTANT 22.0
#define IS_TWEAK_ENABLED [[NSUserDefaults standardUserDefaults] boolForKey:ENABLED_KEY]
#define IS_COLOR_VIEWS_ENABLED [[NSUserDefaults standardUserDefaults] boolForKey:COLOR_VIEWS_ENABLED_KEY]
#define LOCALIZED_STRING(s) [bundle localizedStringForKey:s value:nil table:nil]

@interface YTPlayerViewController : UIViewController
- (id)activeVideoPlayerOverlay;
- (id)playerView;
- (BOOL)isCurrentVideoVertical;
@end

@interface YTPlayerView : UIView
- (id)renderingView;
@end

@interface YTMainAppVideoPlayerOverlayViewController : UIViewController
- (BOOL)isFullscreen;
@end

@interface MLHAMSBDLSampleBufferRenderingView : UIView
@end

@interface YTMainAppEngagementPanelViewController : UIViewController
- (BOOL)isLandscapeEngagementPanel;
- (BOOL)isPeekingSupported;
@end

@interface YTEngagementPanelContainerViewController : UIViewController
- (BOOL)isLandscapeEngagementPanel;
- (BOOL)isPeekingSupported;
@end

@interface YTLabel : UILabel
@property (nonatomic, copy, readwrite) NSString *text;
@end

@interface YTSettingsCell : UICollectionViewCell
@end

@interface YTSettingsSectionItemManager : NSObject
- (id)parentResponder;
@end

@interface YTSettingsPickerViewController : UIViewController
- (instancetype)initWithNavTitle:(NSString *)navTitle
    pickerSectionTitle:(NSString *)pickerSectionTitle
    rows:(NSArray *)rows
    selectedItemIndex:(NSUInteger)selectedItemIndex
    parentResponder:(id)parentResponder;
@end

@interface YTSettingsSectionItem : NSObject
+ (instancetype)switchItemWithTitle:(NSString *)title
    titleDescription:(NSString *)titleDescription
    accessibilityIdentifier:(NSString *)accessibilityIdentifier
    switchOn:(BOOL)switchOn
    switchBlock:(BOOL (^)(YTSettingsCell *, BOOL))switchBlock
    settingItemId:(int)settingItemId;
+ (instancetype)itemWithTitle:(NSString *)title
    titleDescription:(NSString *)titleDescription
    accessibilityIdentifier:(NSString *)accessibilityIdentifier
    detailTextBlock:(id)detailTextBlock
    selectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))selectBlock;
+ (instancetype)checkmarkItemWithTitle:(NSString *)title
    selectBlock:(BOOL (^)(YTSettingsCell *, NSUInteger))selectBlock;
@end

@interface YTSettingsViewController : UIViewController
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *> *)sectionItems
    forCategory:(NSInteger)category
    title:(NSString *)title
    titleDescription:(NSString *)titleDescription
    headerHidden:(BOOL)headerHidden;
- (void)pushViewController:(UIViewController *)viewController;
- (void)reloadData;
@end

// Alert
@interface YTAlertView : UIView
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *subtitle;
+ (instancetype)confirmationDialogWithAction:(void (^)(void))action
    actionTitle:(NSString *)actionTitle
    cancelTitle:(NSString *)cancelTitle;
- (void)show;
@end

// Snack bar
@interface YTHUDMessage : NSObject
+ (id)messageWithText:(id)text;
@end
@interface GOOHUDManagerInternal : NSObject
- (void)showMessageMainThread:(id)message;
+ (id)sharedInstance;
@end

@interface YTUIUtils : NSObject
+ (BOOL)openURL:(NSURL *)url;
@end