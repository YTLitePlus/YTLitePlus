#import "AppIconOptionsController.h"

@interface AppIconOptionsController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIImageView *iconPreview;
@property (strong, nonatomic) NSArray<NSString *> *appIcons;
@property (assign, nonatomic) NSInteger selectedIconIndex;

@end

@implementation AppIconOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedIconIndex = 0;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = closeButton;

    UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeSystem];
    defaultButton.frame = CGRectMake(20, 100, 100, 40);
    [defaultButton setTitle:@"Default" forState:UIControlStateNormal];
    [defaultButton addTarget:self action:@selector(setDefaultIcon) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:defaultButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.frame = CGRectMake(20, 100, 100, 40);
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveIcon) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];

    self.iconPreview = [[UIImageView alloc] initWithFrame:CGRectMake(20, 150, 60, 60)];
    self.iconPreview.layer.cornerRadius = 10.0;
    self.iconPreview.clipsToBounds = YES;
    [self.view addSubview:self.iconPreview];
        
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
    cell.textLabel.text = [self.appIcons[indexPath.row] lastPathComponent];

    if (indexPath.row == self.selectedIconIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *previousSelectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIconIndex inSection:0]];
    previousSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    self.selectedIconIndex = indexPath.row;
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;

    UIImage *selectedIconImage = [UIImage imageWithContentsOfFile:self.appIcons[self.selectedIconIndex]];
    self.iconPreview.image = [self resizedImageWithImage:selectedIconImage];
}

- (void)saveIcon {
    NSString *selectedIcon = self.appIcons[self.selectedIconIndex];
    [[UIApplication sharedApplication] setAlternateIconName:selectedIcon completionHandler:^(NSError * _Nullable error){
        if (error) {
            NSLog(@"Error setting alternate icon: %@", error.localizedDescription);
            [self showAlertWithTitle:@"Error" message:@"Failed to set alternate icon"];
        } else {
            NSLog(@"Alternate icon set successfully");
            [self showAlertWithTitle:@"Success" message:@"Alternate icon set successfully"];
        }
    }];
}

- (UIImage *)resizedImageWithImage:(UIImage *)image {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize newSize = CGSizeMake(image.size.width / scale, image.size.height / scale);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)close {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
