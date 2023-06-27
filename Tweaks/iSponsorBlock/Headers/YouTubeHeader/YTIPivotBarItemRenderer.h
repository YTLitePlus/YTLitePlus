#import "YTICommand.h"

@interface YTIPivotBarItemRenderer : NSObject
- (NSString *)pivotIdentifier;
- (YTICommand *)navigationEndpoint;
- (void)setNavigationEndpoint:(YTICommand *)navigationEndpoint;
@end