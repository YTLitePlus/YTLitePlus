NS_CLASS_AVAILABLE_IOS(7_0)
@interface CAMModeDialItem : UIView
@property (retain, nonatomic) NSString *title;
- (BOOL)isSelected;
- (CAShapeLayer *)_scalableTextLayer;
@end
