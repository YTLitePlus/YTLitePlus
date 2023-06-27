#import "YTSettingsSectionItem.h"
#import "YTSettingsSectionController.h"

@interface YTSettingsViewController : UIViewController
- (NSMutableDictionary <NSNumber *, YTSettingsSectionController *> *)settingsSectionControllers;
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *> *)sectionItems forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden;
- (void)pushViewController:(UIViewController *)viewController;
- (void)reloadData;
@end