#import "../YTLitePlus.h"

#define IS_DARK_APPEARANCE_ENABLED ([[NSUserDefaults standardUserDefaults] integerForKey:@"page_style"] == 1)
#define IS_OLED_DARK_THEME_SELECTED (APP_THEME_IDX == 1)
#define IS_OLD_DARK_THEME_SELECTED (APP_THEME_IDX == 2)

# pragma mark - Old dark theme (lighter grey)

%group gOldDarkTheme
UIColor *originalColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative { return NO; }
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteTextColorForNative { return NO; }
- (BOOL)enableCinematicContainerOnClient { return NO; }
%end

%hook YTCommonColorPalette
- (UIColor *)background1 {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)background2 {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)background3 {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)baseBackground {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)brandBackgroundSolid {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)brandBackgroundPrimary {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)brandBackgroundSecondary {
    return self.pageStyle == 1 ? [originalColor colorWithAlphaComponent:0.9] : %orig;
}
- (UIColor *)raisedBackground {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)staticBrandBlack {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)generalBackgroundA {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)generalBackgroundB {
    return self.pageStyle == 1 ? originalColor : %orig;
}
- (UIColor *)menuBackground {
    return self.pageStyle == 1 ? originalColor : %orig;
}
%end

// Hide separators
%hook YTCollectionSeparatorView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
}
%end

%hook YTInnerTubeCollectionViewController
- (UIColor *)backgroundColor:(NSInteger)pageStyle {
    return pageStyle == 1 ? originalColor : %orig;
}
%end

%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = [UIColor clearColor]; }
    if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = [UIColor clearColor]; }
}
%end

%hook YTFullscreenEngagementOverlayView
- (void)didMoveToWindow {
    %orig;
    self.subviews[0].backgroundColor = [UIColor clearColor];
}
%end

%hook YTRelatedVideosView
- (void)didMoveToWindow {
    %orig;
    self.subviews[0].backgroundColor = [UIColor clearColor];
}
%end
%end

# pragma mark - OLED dark mode by BandarHL

UIColor* raisedColor = [UIColor colorWithRed:0.035 green:0.035 blue:0.035 alpha:1.0];

%group gOLED
%hook YTCommonColorPalette
- (UIColor *)baseBackground {
    return self.pageStyle == 1 ? [UIColor blackColor] : %orig;
}
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

// Hide separators
%hook YTCollectionSeparatorView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES); 
}
%end

// Explore
%hook ASScrollView 
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED) {
        self.backgroundColor = [UIColor clearColor];
    }
}
%end

// Your videos
%hook ASCollectionView
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED && [self.nextResponder isKindOfClass:%c(_ASDisplayView)]) {
        self.superview.backgroundColor = [UIColor blackColor];
    }
}
%end

// Sub menu?
%hook ELMView
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED) {
        // self.subviews[0].backgroundColor = [UIColor clearColor];
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

// Search view
%hook YTSearchBarView 
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;
}
%end

// History search view
%hook YTSearchBoxView 
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;

}
%end

// Comment view
%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;
}
- (void)setTextColor:(UIColor *)color { // fix black text in #Shorts video's comment
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor whiteColor]) : %orig;
}
%end

%hook YTCommentDetailHeaderCell
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED) {
        // self.subviews[2].backgroundColor = [UIColor blackColor];
    }
}
%end

%hook YTFormattedStringLabel  // YT is werid...
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor clearColor]) : %orig;
}
%end

// Live chat comment
%hook YCHLiveChatActionPanelView 
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;
}
%end

%hook YCHLiveChatView
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED) {
        // self.subviews[1].backgroundColor = [UIColor blackColor];
    }
}
%end

%hook YTCollectionView 
- (void)setBackgroundColor:(UIColor *)color { 
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;
}
%end

//
%hook YTBackstageCreateRepostDetailView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig([UIColor blackColor]) : %orig;
}
%end

// Others
%hook _ASDisplayView
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED) {
        if ([self.nextResponder isKindOfClass:%c(ASScrollView)]) { self.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.cvr"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"eml.live_chat_text_message"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"rich_header"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.comment_cell"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.ui.cancel.button"]) { self.superview.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.comment_composer"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.elements.components.video_list_entry"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.guidelines_text"]) { self.superview.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_bottom_sheet_container"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.channel_guidelines_entry_banner_container"]) { self.backgroundColor = [UIColor blackColor]; }
        if ([self.accessibilityIdentifier isEqualToString:@"id.comment.comment_group_detail_container"]) { self.backgroundColor = [UIColor clearColor]; }
        if ([self.accessibilityIdentifier hasPrefix:@"id.elements.components.overflow_menu_item_"]) { self.backgroundColor = [UIColor clearColor]; }
    }
}
%end

// Open link with...
%hook ASWAppSwitchingSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig(raisedColor) : %orig;
}
%end

%hook ASWAppSwitchingSheetFooterView
- (void)setBackgroundColor:(UIColor *)color {
    return IS_DARK_APPEARANCE_ENABLED ? %orig(raisedColor) : %orig;
}
%end

%hook ASWAppSwitcherCollectionViewCell
- (void)didMoveToWindow {
    %orig;
    if (IS_DARK_APPEARANCE_ENABLED) {
        self.backgroundColor = raisedColor;
        // self.subviews[1].backgroundColor = raisedColor;
        self.superview.backgroundColor = raisedColor;
    }
}
%end

// Incompatibility with the new YT Dark theme
%hook YTColdConfig
- (BOOL)uiSystemsClientGlobalConfigUseDarkerPaletteBgColorForNative { return NO; }
%end
%end

# pragma mark - OLED keyboard by @ichitaso <3 - http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e

%group gOLEDKB 
%hook TUIEmojiSearchView
- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor blackColor];
}
%end

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

%ctor {
    if (IS_OLED_DARK_THEME_SELECTED) {
        %init(gOLED);
    }
    if (IS_OLD_DARK_THEME_SELECTED) {
        %init(gOldDarkTheme)
    }
    if (IS_ENABLED(@"oledKeyBoard_enabled")) {
        %init(gOLEDKB);
    }
}
