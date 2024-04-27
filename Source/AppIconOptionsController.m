#import "AppIconOptionsController.h"

@interface AppIconOptionsController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<NSString *> *appIcons;
@property (assign, nonatomic) NSInteger selectedIconIndex;
@property (strong, nonatomic) UIImageView *backButton;
@property (assign, nonatomic) UIUserInterfaceStyle pageStyle;

@end

@implementation AppIconOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Change App Icon";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"YTSans-Bold" size:22], NSForegroundColorAttributeName: [UIColor whiteColor]}];

    self.selectedIconIndex = -1;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = (self.pageStyle == UIUserInterfaceStyleLight) ? [UIColor whiteColor] : [UIColor blackColor];
    [self.view addSubview:self.tableView];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [backButton setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont fontWithName:@"YTSans-Medium" size:20]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = backButton;

    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise.circle.fill"] style:UIBarButtonItemStylePlain target:self action:@selector(resetIcon)];

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveIcon)];
    [saveButton setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:203.0/255.0 green:22.0/255.0 blue:51.0/255.0 alpha:1.0], NSFontAttributeName: [UIFont fontWithName:@"YTSans-Medium" size:20]} forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItems = @[saveButton, resetButton];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"YTLitePlus" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    self.appIcons = [bundle pathsForResourcesOfType:@"png" inDirectory:@"AppIcons"];
    
    if (![UIApplication sharedApplication].supportsAlternateIcons) {
        NSLog(@"Alternate icons are not supported on this device.");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.appIcons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSString *iconPath = self.appIcons[indexPath.row];
    UIImage *iconImage = [UIImage imageWithContentsOfFile:iconPath];

    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.frame = CGRectMake(16, 10, 30, 30);
    [cell.contentView addSubview:iconImageView];

    UILabel *iconNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 5, self.view.frame.size.width - 56, 30)];
    iconNameLabel.text = [iconPath.lastPathComponent stringByDeletingPathExtension];
    iconNameLabel.textColor = [UIColor blackColor];
    iconNameLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    [cell.contentView addSubview:iconNameLabel];

    if (indexPath.row == self.selectedIconIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 1, cell.contentView.frame.size.width, 1)];
    separatorView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:separatorView];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIconIndex = indexPath.row;
    [self.tableView reloadData];
}

- (void)resetIcon {
    [[UIApplication sharedApplication] setAlternateIconName:nil completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error resetting icon: %@", error.localizedDescription);
            [self showAlertWithTitle:@"Error" message:@"Failed to reset icon"];
        } else {
            NSLog(@"Icon reset successfully");
            [self showAlertWithTitle:@"Success" message:@"Icon reset successfully"];
            [self.tableView reloadData];
        }
    }];
}

- (void)saveIcon {
    NSString *selectedIconPath = self.selectedIconIndex >= 0 ? self.appIcons[self.selectedIconIndex] : nil;
    if (selectedIconPath) {
        NSURL *iconURL = [NSURL fileURLWithPath:selectedIconPath];
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(setAlternateIconName:completionHandler:)]) {
            [[UIApplication sharedApplication] setAlternateIconName:selectedIconPath completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error setting alternate icon: %@", error.localizedDescription);
                    [self showAlertWithTitle:@"Error" message:@"Failed to set alternate icon"];
                } else {
                    NSLog(@"Alternate icon set successfully");
                    [self showAlertWithTitle:@"Success" message:@"Alternate icon set successfully"];
                }
            }];
        } else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:iconURL forKey:@"iconURL"];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
            [dict writeToFile:filePath atomically:YES];

            [self showAlertWithTitle:@"Alternate Icon" message:@"Please restart the app to apply the alternate icon"];
        }
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
