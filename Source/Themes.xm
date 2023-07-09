#import "../Header.h"

static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static BOOL isDarkMode() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"page_style"] == 1);
}
static BOOL oledDarkTheme() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"] == 1);
}
static BOOL oldDarkTheme() {
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"appTheme"] == 2);
}

// Themes.xm - Theme Options
// Old dark theme (gray)
%group gOldDarkTheme
UIColor *customColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
%hook YTCommonColorPalette
- (UIColor *)brandBackgroundSolid {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)brandBackgroundPrimary {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)brandBackgroundSecondary {
    return self.pageStyle == 1 ? [customColor colorWithAlphaComponent:0.9] : %orig;
}
- (UIColor *)raisedBackground {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)staticBrandBlack {
    return self.pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)generalBackgroundA {
    return self.pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTAppView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTPivotBarView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTAsyncCollectionView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTAppViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTNavigationBar
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

BOOL areColorsEqual(UIColor *color1, UIColor *color2, CGFloat tolerance) {
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

    return (fabs(r1 - r2) <= tolerance) &&
           (fabs(g1 - g2) <= tolerance) &&
           (fabs(b1 - b2) <= tolerance) &&
           (fabs(a1 - a2) <= tolerance);
}

%hook UIView
- (void)setBackgroundColor:(UIColor *)color {
    UIColor *targetColor1 = [UIColor colorWithRed:0.0588235 green:0.0588235 blue:0.0588235 alpha:1];
    UIColor *targetColor2 = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]; // Replace with the new target color values
    CGFloat tolerance = 0.01; // Adjust this value as needed

    if (areColorsEqual(color, targetColor1, tolerance) || areColorsEqual(color, targetColor2, tolerance)) {
        color = customColor;
    }
    %orig(color);
}
%end

// Hide separators
%hook YTCollectionSeparatorView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
}
%end

// Testing OLED YTPlayerView for OldDarkmode (video background)
%hook YTPlayerView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

// Hide broken YTCinematicContainerView
%hook YTCinematicContainerView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
}
%end

%hook YTCollectionViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTWatchView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTChannelMobileHeaderViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTELMView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook _ASDisplayView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook UIDeviceWhiteColor
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTHeaderViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
- (UIColor *)barTintColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTInnerTubeCollectionViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTSettingsCell
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTSearchViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTSectionListViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTWatchMiniBarViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

%hook YTWrapperSplitViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? customColor : %orig;
}
%end

// Explore
%hook ASScrollView 
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

// Your videos
%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode() && [self.nextResponder isKindOfClass:%c(_ASDisplayView)]) {
        self.superview.backgroundColor = customColor;
    }
}
%end

// Sub?
%hook ELMView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].backgroundColor = customColor;
    }
}
%end

// iSponsorBlock
%hook SponsorBlockSettingsController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.tableView.backgroundColor = customColor;
    } else { return %orig; }
}
%end

%hook SponsorBlockViewController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.view.backgroundColor = customColor;
    } else { return %orig; }
}
%end

// Search View
%hook YTSearchBarView 
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

// History Search view
%hook YTSearchBoxView 
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

// Comment view
%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
- (void)setTextColor:(UIColor *)color { // fix black text in #Shorts video's comment
    return isDarkMode() ? %orig([UIColor whiteColor]) : %orig;
}
%end

%hook YTCommentDetailHeaderCell
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[2].backgroundColor = customColor;
    }
}
%end

%hook YTFormattedStringLabel  // YT is werid...
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor clearColor]) : %orig;
}
%end

// Live chat comment
%hook YCHLiveChatActionPanelView 
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

%hook YCHLiveChatView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[1].backgroundColor = customColor;
    }
}
%end

//
%hook YTBackstageCreateRepostDetailView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

// Others
%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        if ([self.nextResponder isKindOfClass:%c(ASScrollView)]) { self.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.cvr"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"rich_header"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.cancel.button"]) { self.superview.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) { self.backgroundColor = customColor; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.backgroundColor = customColor; }
		if ([self.accessibilityIdentifier isEqualToString:@"id.comment.comment_group_detail_container"]) { self.backgroundColor = [UIColor clearColor]; }
    }
}
%end

// Open link with...
%hook ASWAppSwitchingSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

%hook ASWAppSwitchingSheetFooterView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(customColor) : %orig;
}
%end

%hook ASWAppSwitcherCollectionViewCell
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.backgroundColor = customColor;
        self.subviews[1].backgroundColor = customColor;
        self.superview.backgroundColor = customColor;
    }
}
%end
%end

// OLED dark mode by BandarHL
UIColor* raisedColor = [UIColor blackColor];
%group gOLED
%hook YTCommonColorPalette
- (UIColor *)brandBackgroundSolid {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundPrimary {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)brandBackgroundSecondary {
    return self.pageStyle == 1 ? [[UIColor blackColor] colorWithAlphaComponent:0.9] : %orig;
}
- (UIColor *)raisedBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)staticBrandBlack {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)generalBackgroundA {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTAppView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTPivotBarView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTAsyncCollectionView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTAppViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTNavigationBar
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook UIView
- (void)setBackgroundColor:(UIColor *)color {
    UIColor *targetColor = [UIColor colorWithRed:0.0588235 green:0.0588235 blue:0.0588235 alpha:1];
    CGFloat tolerance = 0.01; // Adjust this value as needed

    if (areColorsEqual(color, targetColor, tolerance)) {
        color = [UIColor blackColor];
    }
    %orig(color);
}
%end

%hook YTCollectionViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook _ASDisplayView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook UIDeviceWhiteColor
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTChannelMobileHeaderViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

// Hide separators
%hook YTCollectionSeparatorView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
}
%end

%hook YTELMView
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTHeaderViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
- (UIColor *)barTintColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTInnerTubeCollectionViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTSettingsCell
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTSearchViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTSectionListViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTWatchMiniBarViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

%hook YTWrapperSplitViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? [UIColor blackColor] : %orig;
}
%end

// Explore
%hook ASScrollView 
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

// Your videos
%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode() && [self.nextResponder isKindOfClass:%c(_ASDisplayView)]) {
        self.superview.backgroundColor = [UIColor blackColor];
    }
}
%end

// Sub?
%hook ELMView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].backgroundColor = [UIColor blackColor];
    }
}
%end

// iSponsorBlock
%hook SponsorBlockSettingsController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.tableView.backgroundColor = [UIColor blackColor];
    } else { return %orig; }
}
%end

%hook SponsorBlockViewController
- (void)viewDidLoad {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        %orig;
        self.view.backgroundColor = [UIColor blackColor];
    } else { return %orig; }
}
%end

// Search View
%hook YTSearchBarView 
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

// History Search view
%hook YTSearchBoxView 
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

// Comment view
%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
- (void)setTextColor:(UIColor *)color { // fix black text in #Shorts video's comment
    return isDarkMode() ? %orig([UIColor whiteColor]) : %orig;
}
%end

%hook YTCommentDetailHeaderCell
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[2].backgroundColor = [UIColor blackColor];
    }
}
%end

%hook YTFormattedStringLabel  // YT is werid...
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor clearColor]) : %orig;
}
%end

// Live chat comment
%hook YCHLiveChatActionPanelView 
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YCHLiveChatView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[1].backgroundColor = [UIColor blackColor];
    }
}
%end

//
%hook YTBackstageCreateRepostDetailView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig([UIColor blackColor]) : %orig;
}
%end

// Others
%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        if ([self.nextResponder isKindOfClass:%c(ASScrollView)]) { self.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.cvr"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"rich_header"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.cancel.button"]) { self.superview.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.backgroundColor = [UIColor blackColor]; }
		if ([self.accessibilityIdentifier isEqualToString:@"id.comment.comment_group_detail_container"]) { self.backgroundColor = [UIColor clearColor]; }
    }
}
%end

// Open link with...
%hook ASWAppSwitchingSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(raisedColor) : %orig;
}
%end

%hook ASWAppSwitchingSheetFooterView
- (void)setBackgroundColor:(UIColor *)color {
    return isDarkMode() ? %orig(raisedColor) : %orig;
}
%end

%hook ASWAppSwitcherCollectionViewCell
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.backgroundColor = raisedColor;
        self.subviews[1].backgroundColor = raisedColor;
        self.superview.backgroundColor = raisedColor;
    }
}
%end

// Incompatibility with the new YT Dark theme
%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative { return NO; }
%end
%end

// OLED keyboard by @ichitaso <3 - http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e
%group gOLEDKB 
%hook UIPredictionViewController
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UICandidateViewController
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UIKeyboardDockView
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKeyboardLayoutStar 
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

%hook UIKBRenderConfig // Prediction text color
- (void)setLightKeyboard:(BOOL)arg1 { %orig(NO); }
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (IsEnabled(@"oledKeyBoard_enabled")) {
        %init(gOLEDKB);
    }
    if (oledDarkTheme()) {
        %init(gOLED);
    }
    if (oldDarkTheme()) {
        %init(gOldDarkTheme);
    }
}
