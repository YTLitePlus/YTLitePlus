#import <UIKit/UIKit.h>

NS_CLASS_AVAILABLE_IOS(9_0)
@interface CAMFramerateIndicatorView : UIView

@property NSInteger style;
- (NSInteger)_framesPerSecond;

- (NSString *)_labelText;
- (UIImageView *)_borderImageView;

- (UILabel *)_bottomLabel;
- (UILabel *)_topLabel;

- (void)_updateForAppearanceChange;
- (void)_updateLabels;

@end
