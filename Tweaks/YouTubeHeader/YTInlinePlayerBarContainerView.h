#import "YTGlassContainerView.h"
#import "YTInlinePlayerBarView.h"
#import "YTSegmentableInlinePlayerBarView.h"
#import "YTLabel.h"
#import "YTQTMButton.h"

@interface YTInlinePlayerBarContainerView : YTGlassContainerView
@property (nonatomic, strong, readwrite) YTInlinePlayerBarView *playerBar; // Replaced by segmentablePlayerBar in newer versions
@property (nonatomic, strong, readwrite) YTSegmentableInlinePlayerBarView *segmentablePlayerBar;
@property (nonatomic, strong, readwrite) UIView *multiFeedElementView;
@property (nonatomic, strong, readwrite) YTLabel *durationLabel;
@property (nonatomic, assign, readwrite) BOOL showOnlyFullscreenButton;
@property (nonatomic, assign, readwrite) int layout;
@property (nonatomic, weak, readwrite) id delegate;
- (YTQTMButton *)exitFullscreenButton;
- (YTQTMButton *)enterFullscreenButton;
- (void)setChapters:(NSArray *)chapters;
@end
