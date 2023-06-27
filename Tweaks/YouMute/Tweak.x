#import <rootless.h>
#import "../YouTubeHeader/YTColor.h"
#import "../YouTubeHeader/YTCommonUtils.h"
#import "../YouTubeHeader/YTInlinePlayerBarContainerView.h"
#import "../YouTubeHeader/YTMainAppControlsOverlayView.h"
#import "../YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h"
#import "../YouTubeHeader/YTSingleVideoController.h"
#import "../YouTubeHeader/YTSettingsPickerViewController.h"
#import "../YouTubeHeader/YTSettingsViewController.h"
#import "../YouTubeHeader/YTSettingsSectionItem.h"
#import "../YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../YouTubeHeader/YTQTMButton.h"
#import "../YouTubeHeader/QTMIcon.h"
#import "../YouTubeHeader/UIView+YouTube.h"

#define EnabledKey @"YouMuteEnabled"
#define PositionKey @"YouMutePosition"

#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

static const NSInteger YouMuteSection = 521;

@interface YTSettingsSectionItemManager (YouMute)
- (void)updateYouMuteSectionWithEntry:(id)entry;
@end

@interface YTMainAppControlsOverlayView (YouMute)
@property (retain, nonatomic) YTQTMButton *muteButton;
- (void)didPressMute:(id)arg;
@end

@interface YTInlinePlayerBarContainerView (YouMute)
@property (retain, nonatomic) YTQTMButton *muteButton;
- (void)didPressMute:(id)arg;
@end

static BOOL TweakEnabled() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:EnabledKey];
}

static int MuteButtonPosition() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:PositionKey];
}

static BOOL UseTopMuteButton() {
    return TweakEnabled() && MuteButtonPosition() == 0;
}

static BOOL UseBottomMuteButton() {
    return TweakEnabled() && MuteButtonPosition() == 1;
}

static BOOL isMutedTop(YTMainAppControlsOverlayView *self) {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    YTSingleVideoController *video = [c valueForKey:@"_currentSingleVideoObservable"];
    return [video isMuted];
}

static BOOL isMutedBottom(YTInlinePlayerBarContainerView *self) {
    YTSingleVideoController *video = [self.delegate valueForKey:@"_currentSingleVideo"];
    return [video isMuted];
}

static NSBundle *YTEditResourcesBundle() {
    Class YTCommonUtilsClass = %c(YTCommonUtils);
    return [YTCommonUtilsClass resourceBundleForModuleName:@"Edit" appBundle:[YTCommonUtilsClass bundleForClass:%c(YTEditBundleIdentifier)]];
}

static UIImage *muteImage(BOOL muted) {
    return [%c(QTMIcon) tintImage:[UIImage imageNamed:muted ? @"ic_volume_off" : @"ic_volume_up" inBundle:YTEditResourcesBundle() compatibleWithTraitCollection:nil] color:[%c(YTColor) white1]];
}

static void createMuteButtonTop(YTMainAppControlsOverlayView *self) {
    if (!self) return;
    CGFloat padding = [[self class] topButtonAdditionalPadding];
    UIImage *image = muteImage(isMutedTop(self));
    self.muteButton = [self buttonWithImage:image accessibilityLabel:@"Mute" verticalContentPadding:padding];
    self.muteButton.hidden = YES;
    self.muteButton.alpha = 0;
    [self.muteButton addTarget:self action:@selector(didPressMute:) forControlEvents:UIControlEventTouchUpInside];
    @try {
        [[self valueForKey:@"_topControlsAccessibilityContainerView"] addSubview:self.muteButton];
    } @catch (id ex) {
        [self addSubview:self.muteButton];
    }
}

static void createMuteButtonBottom(YTInlinePlayerBarContainerView *self) {
    if (!self) return;
    UIImage *image = muteImage(isMutedBottom(self));
    self.muteButton = [%c(YTQTMButton) iconButton];
    self.muteButton.hidden = YES;
    self.muteButton.exclusiveTouch = YES;
    self.muteButton.alpha = 0;
    self.muteButton.minHitTargetSize = 60;
    self.muteButton.accessibilityLabel = @"Mute";
    [self.muteButton setImage:image forState:0];
    [self.muteButton sizeToFit];
    [self.muteButton addTarget:self action:@selector(didPressMute:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.muteButton];
}

static NSMutableArray *topControls(YTMainAppControlsOverlayView *self, NSMutableArray *controls) {
    if (UseTopMuteButton())
        [controls insertObject:self.muteButton atIndex:0];
    return controls;
}

NSBundle *YouMuteBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YouMute" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/YouMute.bundle")];
    });
    return bundle;
}

%group Top

%hook YTMainAppVideoPlayerOverlayViewController

- (void)updateTopRightButtonAvailability {
    %orig;
    YTMainAppVideoPlayerOverlayView *v = [self videoPlayerOverlayView];
    YTMainAppControlsOverlayView *c = [v valueForKey:@"_controlsOverlayView"];
    c.muteButton.hidden = !UseTopMuteButton();
    [c setNeedsLayout];
}

%end

%hook YTMainAppControlsOverlayView

%property (retain, nonatomic) YTQTMButton *muteButton;

- (id)initWithDelegate:(id)delegate {
    self = %orig;
    createMuteButtonTop(self);
    return self;
}

- (id)initWithDelegate:(id)delegate autoplaySwitchEnabled:(BOOL)autoplaySwitchEnabled {
    self = %orig;
    createMuteButtonTop(self);
    return self;
}

- (NSMutableArray *)topButtonControls {
    return topControls(self, %orig);
}

- (NSMutableArray *)topControls {
    return topControls(self, %orig);
}

- (void)setTopOverlayVisible:(BOOL)visible isAutonavCanceledState:(BOOL)canceledState {
    if (UseTopMuteButton())
        self.muteButton.alpha = canceledState || !visible ? 0.0 : 1.0;
    %orig;
}

%new(v@:@)
- (void)didPressMute:(id)arg {
    YTMainAppVideoPlayerOverlayViewController *c = [self valueForKey:@"_eventsDelegate"];
    YTSingleVideoController *video = [c valueForKey:@"_currentSingleVideoObservable"];
    [video setMuted:![video isMuted]];
    [self.muteButton setImage:muteImage([video isMuted]) forState:0];
}

%end

%end

%group Bottom

%hook YTInlinePlayerBarContainerView

%property (retain, nonatomic) YTQTMButton *muteButton;

- (id)init {
    self = %orig;
    createMuteButtonBottom(self);
    return self;
}

- (NSMutableArray *)rightIcons {
    NSMutableArray *icons = %orig;
    if (UseBottomMuteButton() && ![icons containsObject:self.muteButton])
        [icons insertObject:self.muteButton atIndex:0];
    return icons;
}

- (void)updateIconVisibility {
    %orig;
    if (UseBottomMuteButton())
        self.muteButton.hidden = NO;
}

- (void)hideScrubber {
    %orig;
    if (UseBottomMuteButton())
        self.muteButton.alpha = 0;
}

- (void)setPeekableViewVisible:(BOOL)visible fullscreenButtonVisibleShouldMatchPeekableView:(BOOL)match {
    %orig;
    if (UseBottomMuteButton())
        self.muteButton.alpha = visible ? 1 : 0;
}

- (void)layoutSubviews {
    %orig;
    if (!UseBottomMuteButton()) return;
    CGFloat multiFeedWidth = [self respondsToSelector:@selector(multiFeedElementView)] ? [self multiFeedElementView].frame.size.width : 0;
    YTQTMButton *enter = [self enterFullscreenButton];
    if ([enter yt_isVisible]) {
        CGRect frame = enter.frame;
        frame.origin.x -= multiFeedWidth + enter.frame.size.width + 16;
        self.muteButton.frame = frame;
    } else {
        YTQTMButton *exit = [self exitFullscreenButton];
        if ([exit yt_isVisible]) {
            CGRect frame = exit.frame;
            frame.origin.x -= multiFeedWidth + exit.frame.size.width + 16;
            self.muteButton.frame = frame;
        }
    }
}

%new(v@:@)
- (void)didPressMute:(id)arg {
    YTSingleVideoController *video = [self.delegate valueForKey:@"_currentSingleVideo"];
    [video setMuted:![video isMuted]];
    [self.muteButton setImage:muteImage([video isMuted]) forState:0];
}

%end

%end

%group Settings

%hook YTAppSettingsPresentationData

+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(YouMuteSection) atIndex:insertIndex + 1];
    return mutableOrder;
}

%end

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYouMuteSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    NSBundle *tweakBundle = YouMuteBundle();
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
    YTSettingsSectionItem *master = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLED")
        titleDescription:nil
        accessibilityIdentifier:nil
        switchOn:TweakEnabled()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:EnabledKey];
            return YES;
        }
        settingItemId:0];
    [sectionItems addObject:master];
    YTSettingsSectionItem *position = [YTSettingsSectionItemClass itemWithTitle:LOC(@"POSITION")
        accessibilityIdentifier:nil
        detailTextBlock:^NSString *() {
            return MuteButtonPosition() ? LOC(@"BOTTOM") : LOC(@"TOP");
        }
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            NSArray <YTSettingsSectionItem *> *rows = @[
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"TOP") titleDescription:LOC(@"TOP_DESC") selectBlock:^BOOL (YTSettingsCell *top, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:PositionKey];
                    [settingsViewController reloadData];
                    return YES;
                }],
                [YTSettingsSectionItemClass checkmarkItemWithTitle:LOC(@"BOTTOM") titleDescription:LOC(@"BOTTOM_DESC") selectBlock:^BOOL (YTSettingsCell *bottom, NSUInteger arg1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:PositionKey];
                    [settingsViewController reloadData];
                    return YES;
                }]
            ];
            YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:LOC(@"POSITION") pickerSectionTitle:nil rows:rows selectedItemIndex:MuteButtonPosition() parentResponder:[self parentResponder]];
            [settingsViewController pushViewController:picker];
            return YES;
        }];
    [sectionItems addObject:position];
    [settingsViewController setSectionItems:sectionItems forCategory:YouMuteSection title:@"YouMute" titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YouMuteSection) {
        [self updateYouMuteSectionWithEntry:entry];
        return;
    }
    %orig;
}

%end

%end

%ctor {
    %init(Settings);
    %init(Top);
    %init(Bottom);
}
