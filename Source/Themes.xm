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
%hook UIView
- (void)setBackgroundColor:(UIColor *)color {
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTPivotBarView")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTSlideForActionsView")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTChipCloudCell")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTEngagementPanelView")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTPlaylistPanelProminentThumbnailVideoCell")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTPlaylistHeaderView")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTAsyncCollectionView")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTLinkCell")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTMessageCell")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTSearchView")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTDrawerAvatarCell")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTFeedHeaderView")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatTextCell")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatViewerEngagementCell")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTCommentsHeaderView")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatView")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatTickerViewController")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTInnerTubeCollectionViewController")]) {
        color = customColor;
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTEditSheetControllerHeader")]) {
        color = customColor;
    }
    %orig;
}
%end
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
%hook ELMView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].backgroundColor = [UIColor clearColor];
    }
}
%end
%hook YTAsyncCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTRelatedVideosCollectionViewController")]) {
        color = [UIColor clearColor];
    } else if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTFullscreenMetadataHighlightsCollectionViewController")]) {
        color = [UIColor clearColor];
    } else {
        color = customColor;
    }
    %orig;
}
- (UIColor *)darkBackgroundColor {
    return customColor;
}
- (void)setDarkBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
- (void)layoutSubviews {
    %orig();
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTWatchNextResultsViewController")]) {
        self.subviews[0].subviews[0].backgroundColor = customColor;
    }
}
%end
%hook YTPivotBarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTSubheaderContainerView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTAppView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTChannelListSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTSlideForActionsView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTPageView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTWatchView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTPlaylistMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTEngagementPanelHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTPlaylistPanelControlsView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTHorizontalCardListView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTWatchMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTSearchView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTVideoView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTTabTitlesView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTPrivacyTosFooterView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTOfflineStorageUsageView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTInlineSignInView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTFeedChannelFilterHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YCHLiveChatView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTTopAlignedView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTTopAlignedView *>(self, "_contentView").backgroundColor = customColor;
}
%end
%hook GOODialogView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTNavigationBar
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
- (void)setBarTintColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTChannelMobileHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTChannelSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTWrapperSplitView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTReelShelfCell
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTReelShelfItemView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTReelShelfView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTChannelListSubMenuAvatarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTSearchBarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YCHLiveChatBannerCell
- (void)layoutSubviews {
    %orig();
    MSHookIvar<UIImageView *>(self, "_bannerContainerImageView").hidden = YES;
    MSHookIvar<UIView *>(self, "_bannerContainerView").backgroundColor = customColor;
}
%end
%hook YTDialogContainerScrollView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTShareTitleView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTShareBusyView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTELMView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTActionSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig(customColor);
}
%end
%hook YTSearchSuggestionCollectionViewCell
- (void)updateColors {
}
%end
%hook YTShareMainView
- (void)layoutSubviews {
	%orig();
    MSHookIvar<YTQTMButton *>(self, "_cancelButton").backgroundColor = customColor;
    MSHookIvar<UIControl *>(self, "_safeArea").backgroundColor = customColor;
}
%end
%hook _ASDisplayView
- (void)layoutSubviews {
    %orig();
    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:NSClassFromString(@"YTActionSheetDialogViewController")]) {
            self.backgroundColor = customColor;
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTPanelLoadingStrategyViewController")]) {
            self.backgroundColor = customColor;
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTTabHeaderElementsViewController")]) {
            self.backgroundColor = customColor;
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTEditSheetControllerElementsContentViewController")]) {
            self.backgroundColor = customColor;
        }
        responder = [responder nextResponder];
    }
}
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
%hook YTCinematicContainerView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
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
%hook UIView
- (void)setBackgroundColor:(UIColor *)color {
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTPivotBarView")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTSlideForActionsView")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTChipCloudCell")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTEngagementPanelView")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTPlaylistPanelProminentThumbnailVideoCell")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTPlaylistHeaderView")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTAsyncCollectionView")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTLinkCell")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTMessageCell")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTSearchView")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTDrawerAvatarCell")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTFeedHeaderView")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatTextCell")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatViewerEngagementCell")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTCommentsHeaderView")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatView")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatTickerViewController")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTInnerTubeCollectionViewController")]) {
        color = [UIColor blackColor];
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTEditSheetControllerHeader")]) {
        color = [UIColor blackColor];
    }
    %orig;
}
%end
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
%hook ELMView
- (void)didMoveToWindow {
    %orig;
    if (isDarkMode()) {
        self.subviews[0].backgroundColor = [UIColor clearColor];
    }
}
%end
%hook YTAsyncCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTRelatedVideosCollectionViewController")]) {
        color = [UIColor clearColor];
    } else if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTFullscreenMetadataHighlightsCollectionViewController")]) {
        color = [UIColor clearColor];
    } else {
        color = [UIColor blackColor];
    }
    %orig;
}
- (UIColor *)darkBackgroundColor {
    return [UIColor blackColor];
}
- (void)setDarkBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
- (void)layoutSubviews {
    %orig();
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTWatchNextResultsViewController")]) {
        self.subviews[0].subviews[0].backgroundColor = [UIColor blackColor];
    }
}
%end
%hook YTPivotBarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTSubheaderContainerView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTAppView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTCollectionView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTChannelListSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTSlideForActionsView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTPageView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTWatchView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTPlaylistMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTEngagementPanelHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTPlaylistPanelControlsView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTHorizontalCardListView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTWatchMiniBarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTSearchView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTVideoView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTTabTitlesView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTPrivacyTosFooterView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTOfflineStorageUsageView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTInlineSignInView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTFeedChannelFilterHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YCHLiveChatView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTTopAlignedView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTTopAlignedView *>(self, "_contentView").backgroundColor = [UIColor blackColor];
}
%end
%hook GOODialogView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTNavigationBar
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
- (void)setBarTintColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTChannelMobileHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTChannelSubMenuView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTWrapperSplitView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTReelShelfCell
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTReelShelfItemView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTReelShelfView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTCommentView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTChannelListSubMenuAvatarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTSearchBarView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YCHLiveChatBannerCell
- (void)layoutSubviews {
    %orig();
    MSHookIvar<UIImageView *>(self, "_bannerContainerImageView").hidden = YES;
    MSHookIvar<UIView *>(self, "_bannerContainerView").backgroundColor = [UIColor blackColor];
}
%end
%hook YTDialogContainerScrollView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTShareTitleView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTShareBusyView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTELMView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTActionSheetHeaderView
- (void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor blackColor]);
}
%end
%hook YTSearchSuggestionCollectionViewCell
- (void)updateColors {
}
%end
%hook YTShareMainView
- (void)layoutSubviews {
	%orig();
    MSHookIvar<YTQTMButton *>(self, "_cancelButton").backgroundColor = [UIColor blackColor];
    MSHookIvar<UIControl *>(self, "_safeArea").backgroundColor = [UIColor blackColor];
}
%end
%hook _ASDisplayView
- (void)layoutSubviews {
	%orig();
    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:NSClassFromString(@"YTActionSheetDialogViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTPanelLoadingStrategyViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTTabHeaderElementsViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        if ([responder isKindOfClass:NSClassFromString(@"YTEditSheetControllerElementsContentViewController")]) {
            self.backgroundColor = [UIColor blackColor];
        }
        responder = [responder nextResponder];
    }
}
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
%hook YTCinematicContainerView
- (void)setHidden:(BOOL)arg1 {
    %orig(YES);
}
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
