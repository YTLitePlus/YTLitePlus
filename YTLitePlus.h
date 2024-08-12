#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CaptainHook/CaptainHook.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <sys/utsname.h>
#import <substrate.h>
#import <rootless.h>

#import "Tweaks/FLEX/FLEX.h"
#import "Tweaks/YouTubeHeader/YTAppDelegate.h"
#import "Tweaks/YouTubeHeader/YTPlayerViewController.h"
#import "Tweaks/YouTubeHeader/YTQTMButton.h"
#import "Tweaks/YouTubeHeader/YTVideoQualitySwitchOriginalController.h"
#import "Tweaks/YouTubeHeader/YTPlayerViewController.h"
#import "Tweaks/YouTubeHeader/YTWatchController.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponse.h"
#import "Tweaks/YouTubeHeader/YTIGuideResponseSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarSupportedRenderers.h"
#import "Tweaks/YouTubeHeader/YTIPivotBarRenderer.h"
#import "Tweaks/YouTubeHeader/YTIBrowseRequest.h"
#import "Tweaks/YouTubeHeader/YTCommonColorPalette.h"
#import "Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "Tweaks/YouTubeHeader/ASCollectionView.h"
#import "Tweaks/YouTubeHeader/YTPlayerOverlay.h"
#import "Tweaks/YouTubeHeader/YTPlayerOverlayProvider.h"
#import "Tweaks/YouTubeHeader/YTReelWatchPlaybackOverlayView.h"
#import "Tweaks/YouTubeHeader/YTReelPlayerBottomButton.h"
#import "Tweaks/YouTubeHeader/YTReelPlayerViewController.h"
#import "Tweaks/YouTubeHeader/YTAlertView.h"
#import "Tweaks/YouTubeHeader/YTISectionListRenderer.h"
#import "Tweaks/YouTubeHeader/YTPivotBarItemView.h"
#import "Tweaks/YouTubeHeader/YTVideoWithContextNode.h"
#import "Tweaks/YouTubeHeader/ELMCellNode.h"
#import "Tweaks/YouTubeHeader/ELMNodeController.h"
#import "Tweaks/YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h"
#import "Tweaks/YouTubeHeader/YTInlinePlayerBarContainerView.h"
#import "Tweaks/YouTubeHeader/YTWatchViewController.h"
#import "Tweaks/YouTubeHeader/YTWatchPullToFullController.h"
#import "Tweaks/YouTubeHeader/YTPlayerBarController.h"
#import "Tweaks/YouTubeHeader/YTResponder.h"
#import "Tweaks/YouTubeHeader/YTMainAppControlsOverlayView.h"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]
#define YT_BUNDLE_ID @"com.google.ios.youtube"
#define YT_NAME @"YouTube"
#define LOWCONTRASTMODE_CUTOFF_VERSION @"17.38.10"
#define IS_ENABLED(k) [[NSUserDefaults standardUserDefaults] boolForKey:k]
#define APP_THEME_IDX [[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"]

// YTSpeed
@interface YTVarispeedSwitchControllerOption : NSObject
- (id)initWithTitle:(id)title rate:(float)rate;
@end

@interface MLHAMQueuePlayer : NSObject
@property id playerEventCenter;
@property id delegate;
- (void)setRate:(float)rate;
- (void)internalSetRate;
@end

@interface MLPlayerEventCenter : NSObject
- (void)broadcastRateChange:(float)rate;
@end

@interface HAMPlayerInternal : NSObject
- (void)setRate:(float)rate;
@end

@interface SSOConfiguration : NSObject
@end

// YTLitePlus
@interface YTChipCloudCell : UIView
@end

@interface YTPlayabilityResolutionUserActionUIController : NSObject // Skips content warning before playing *some videos - @PoomSmart
- (void)confirmAlertDidPressConfirm;
@end 

@interface YTTransportControlsButtonView : UIView
@end

@interface _ASCollectionViewCell : UICollectionViewCell
- (id)node;
@end

@interface YTAsyncCollectionView : UICollectionView
- (void)removeShortsAndFeaturesAdsAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface YTPlaybackButton : UIControl
@end

@interface YTSegmentableInlinePlayerBarView
@property (nonatomic, assign, readwrite) BOOL enableSnapToChapter;
@end

// Hide Autoplay Mini Preview - @bhackel
@interface YTAutonavPreviewView : UIView
@end

// OLED Live Chat - @bhackel
@interface YTLUserDefaults : NSUserDefaults
@end

// Hide Home Tab - @bhackel
@interface YTPivotBarViewController : UIViewController
@property NSString *selectedPivotIdentifier;
@property YTIPivotBarRenderer *renderer;
- (void)selectItemWithPivotIdentifier:(NSString *)pivotIdentifier;
- (void)resetViewControllersCache;
@end

// Disable ambient mode & Fullscreen to the Right - @bhackel
@interface YTWatchViewController (YTLitePlus) <YTResponder>
@property (nonatomic, assign, readwrite, getter=isFullscreen) BOOL fullscreen;
@end

@interface YTWatchCinematicContainerController : NSObject
@property id <YTResponder> parentResponder;
@end

// Hide Collapse Button - @arichornlover
@interface YTMainAppControlsOverlayView (YTLitePlus)
@property (nonatomic, assign, readwrite) YTQTMButton *watchCollapseButton;
@end

// SponsorBlock button in Nav bar
@interface MDCButton : UIButton
@end

@interface YTRightNavigationButtons : UIView
@property YTQTMButton *notificationButton;
@property YTQTMButton *sponsorBlockButton;
@end

// BigYTMiniPlayer
@interface YTMainAppVideoPlayerOverlayView (YTLitePlus)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface YTWatchMiniBarView : UIView
@end

// YTAutoFullscreen
@interface YTPlayerViewController (YTAFS)
- (void)autoFullscreen;
@end

// App Theme
@interface YTColor : NSObject
+ (UIColor *)white1;
+ (UIColor *)white2;
+ (UIColor *)white3;
+ (UIColor *)white4;
+ (UIColor *)white5;
+ (UIColor *)black0;
+ (UIColor *)black1;
+ (UIColor *)black2;
+ (UIColor *)black3;
+ (UIColor *)black4;
+ (UIColor *)blackPure;
+ (UIColor *)grey1;
+ (UIColor *)grey2;
+ (UIColor *)white1Alpha98;
+ (UIColor *)white1Alpha95;
@end

@interface YCHLiveChatView : UIView
@end

@interface YTFullscreenEngagementOverlayView : UIView
@end

@interface YTRelatedVideosView : UIView
@end

@interface YTTopAlignedView : UIView
@end

@interface ELMView : UIView
@end

@interface ASWAppSwitcherCollectionViewCell : UIView
@end

@interface ASScrollView : UIView
@end

@interface UIKeyboardLayoutStar : UIView
@end

@interface UIKeyboardDockView : UIView
@end

@interface _ASDisplayView : UIView
@end

@interface ELMContainerNode : NSObject
@end

@interface YTAutonavEndscreenView : UIView
@end

@interface YTPivotBarIndicatorView : UIView
@end

@interface YTCommentDetailHeaderCell : UIView
@end

@interface SponsorBlockSettingsController : UITableViewController 
@end

@interface SponsorBlockViewController : UIViewController
@end

@interface UICandidateViewController : UIViewController
@end

@interface UIPredictionViewController : UIViewController
@end

@interface TUIEmojiSearchView : UIView
@end

@interface FRPreferences : UITableViewController
@end

@interface FRPSelectListTable : UITableViewController
@end

@interface settingsReorderTable : UIViewController
@property(nonatomic, strong) UITableView *tableView;
@end

// Snack bar
@interface YTHUDMessage : NSObject
+ (id)messageWithText:(id)text;
- (void)setAction:(id)action;
@end

@interface GOOHUDMessageAction : NSObject
- (void)setTitle:(NSString *)title;
- (void)setHandler:(void (^)(id))handler;
@end

@interface GOOHUDManagerInternal : NSObject
- (void)showMessageMainThread:(id)message;
+ (id)sharedInstance;
@end
