#import "../Header.h"

//
static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static int colorContrastMode() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"lcmColor"];
}
static BOOL defaultContrastMode() {
    return IsEnabled(@"lowContrastMode_enabled") && colorContrastMode() == 0;
}
static BOOL redContrastMode() {
    return IsEnabled(@"lowContrastMode_enabled") && colorContrastMode() == 1;
}
static BOOL blueContrastMode() {
    return IsEnabled(@"lowContrastMode_enabled") && colorContrastMode() == 2;
}
static BOOL greenContrastMode() {
    return IsEnabled(@"lowContrastMode_enabled") && colorContrastMode() == 3;
}
static BOOL yellowContrastMode() {
    return IsEnabled(@"lowContrastMode_enabled") && colorContrastMode() == 4;
}
static BOOL orangeContrastMode() {
    return IsEnabled(@"lowContrastMode_enabled") && colorContrastMode() == 5;
}
static BOOL purpleContrastMode() {
    return IsEnabled(@"lowContrastMode_enabled") && colorContrastMode() == 6;
}
static BOOL violetContrastMode() {
    return IsEnabled(@"lowContrastMode_enabled") && colorContrastMode() == 7;
}
static BOOL pinkContrastMode() {
    return IsEnabled(@"lowContrastMode_enabled") && colorContrastMode() == 8;
}

%group gLowContrastMode // Low Contrast Mode v1.4.0 (Compatible with only YouTube v16.05.7-v17.38.10)
%hook UIColor
+ (UIColor *)whiteColor { // Dark Theme Color
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)darkTextColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
// testing below
+ (UIColor *)systemTextColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)systemPlaceholderColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)systemLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)systemSecondaryLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)systemTertiaryLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
+ (UIColor *)systemQuaternaryLabelColor {
         return [UIColor colorWithRed: 0.56 green: 0.56 blue: 0.56 alpha: 1.00];
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig; // Dark Theme
}
- (UIColor *)textSecondary {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig; // Dark Theme
}
- (UIColor *)overlayTextPrimary {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig; // Dark Theme
}
- (UIColor *)overlayTextSecondary {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig; // Dark Theme
}
- (UIColor *)iconActive {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig; // Dark Theme
}
- (UIColor *)iconActiveOther {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig; // Dark Theme
}
- (UIColor *)brandIconActive {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig; // Dark Theme
}
- (UIColor *)staticBrandWhite {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig; // Dark Theme
}
- (UIColor *)overlayIconActiveOther {
    return self.pageStyle == 1 ? [UIColor whiteColor] : %orig; // Dark Theme
}
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnOnBrightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%end

%group gRedContrastMode // Red Contrast Mode
%hook UIColor
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
}
+ (UIColor *)darkTextColor {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 1.00 green: 0.31 blue: 0.27 alpha: 1.00];
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)textSecondary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextSecondary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)brandIconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)staticBrandWhite {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayIconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.84 green: 0.25 blue: 0.23 alpha: 1.00]; // Fallback Version
 }
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnOnBrightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%end

%group gBlueContrastMode // Blue Contrast Mode
%hook UIColor
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
}
+ (UIColor *)darkTextColor {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 0.04 green: 0.47 blue: 0.72 alpha: 1.00];
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor whiteColor]; // Dark Theme
     }
        return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextSecondary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)brandIconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)staticBrandWhite {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayIconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.04 green: 0.41 blue: 0.62 alpha: 1.00]; // Fallback Version
 }
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnOnBrightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%end

%group gGreenContrastMode // Green Contrast Mode
%hook UIColor
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
}
+ (UIColor *)darkTextColor {
         return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 0.01 green: 0.66 blue: 0.18 alpha: 1.00];
}
%end

%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor whiteColor]; // Dark Theme
     }
        return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextSecondary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)brandIconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)staticBrandWhite {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayIconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.00 green: 0.50 blue: 0.13 alpha: 1.00]; // Fallback Version
 }
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnOnBrightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%end

%group gYellowContrastMode // Yellow Contrast Mode
%hook UIColor
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
}
+ (UIColor *)darkTextColor {
         return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 0.89 green: 0.82 blue: 0.20 alpha: 1.00];
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor whiteColor]; // Dark Theme
     }
        return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextSecondary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)brandIconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)staticBrandWhite {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayIconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.77 green: 0.71 blue: 0.14 alpha: 1.00]; // Fallback Version
 }
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnOnBrightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%end

%group gOrangeContrastMode // Orange Contrast Mode
%hook UIColor
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
}
+ (UIColor *)darkTextColor {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 0.73 green: 0.45 blue: 0.05 alpha: 1.00];
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor whiteColor]; // Dark Theme
     }
        return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextSecondary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)brandIconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)staticBrandWhite {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayIconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.80 green: 0.49 blue: 0.05 alpha: 1.00]; // Fallback Version
 }
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnOnBrightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%end

%group gPurpleContrastMode // Purple Contrast Mode
%hook UIColor
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 0.42 green: 0.18 blue: 0.68 alpha: 1.00];
}
+ (UIColor *)darkTextColor {
         return [UIColor colorWithRed: 0.42 green: 0.18 blue: 0.68 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 0.42 green: 0.18 blue: 0.68 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 0.42 green: 0.18 blue: 0.68 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 0.42 green: 0.18 blue: 0.68 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 0.42 green: 0.18 blue: 0.68 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 0.42 green: 0.18 blue: 0.68 alpha: 1.00];
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.42 green: 0.05 blue: 0.68 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor whiteColor]; // Dark Theme
     }
        return [UIColor colorWithRed: 0.42 green: 0.05 blue: 0.68 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.42 green: 0.05 blue: 0.68 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextSecondary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.42 green: 0.05 blue: 0.68 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.42 green: 0.05 blue: 0.68 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.42 green: 0.05 blue: 0.68 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)brandIconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.42 green: 0.05 blue: 0.68 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)staticBrandWhite {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.42 green: 0.05 blue: 0.68 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayIconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.42 green: 0.05 blue: 0.68 alpha: 1.00]; // Fallback Version
 }
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnOnBrightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%end

%group gVioletContrastMode // Violet Contrast Mode
%hook UIColor
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 0.50 green: 0.00 blue: 1.00 alpha: 1.00];
}
+ (UIColor *)darkTextColor {
         return [UIColor colorWithRed: 0.50 green: 0.00 blue: 1.00 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 0.50 green: 0.00 blue: 1.00 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 0.50 green: 0.00 blue: 1.00 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 0.50 green: 0.00 blue: 1.00 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 0.50 green: 0.00 blue: 1.00 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 0.50 green: 0.00 blue: 1.00 alpha: 1.00];
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.29 green: 0.00 blue: 0.51 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor whiteColor]; // Dark Theme
     }
        return [UIColor colorWithRed: 0.29 green: 0.00 blue: 0.51 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.29 green: 0.00 blue: 0.51 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextSecondary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.29 green: 0.00 blue: 0.51 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.29 green: 0.00 blue: 0.51 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.29 green: 0.00 blue: 0.51 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)brandIconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.29 green: 0.00 blue: 0.51 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)staticBrandWhite {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.29 green: 0.00 blue: 0.51 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayIconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.29 green: 0.00 blue: 0.51 alpha: 1.00]; // Fallback Version
 }
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnOnBrightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%end

%group gPinkContrastMode // Pink Contrast Mode
%hook UIColor
+ (UIColor *)whiteColor {
         return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
}
+ (UIColor *)darkTextColor {
         return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
}
+ (UIColor *)placeholderTextColor {
         return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
}
+ (UIColor *)labelColor {
         return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
}
+ (UIColor *)secondaryLabelColor {
         return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
}
+ (UIColor *)tertiaryLabelColor {
         return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
}
+ (UIColor *)quaternaryLabelColor {
         return [UIColor colorWithRed: 0.74 green: 0.02 blue: 0.46 alpha: 1.00];
}
%end
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor whiteColor]; // Dark Theme
     }
        return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextPrimary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayTextSecondary {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)iconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)brandIconActive {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)staticBrandWhite {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00]; // Fallback Version
 }
- (UIColor *)overlayIconActiveOther {
     if (self.pageStyle == 1) {
         return [UIColor whiteColor]; // Dark Theme
     }
         return [UIColor colorWithRed: 0.81 green: 0.56 blue: 0.71 alpha: 1.00]; // Fallback Version
 }
%end
%hook QTMColorGroup
- (UIColor *)tint100 {
    return [UIColor whiteColor];
}
- (UIColor *)tint300 {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnLighterColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnRegularColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnDarkerColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)bodyTextColorOnOnBrightAccentColor {
    return [UIColor whiteColor];
}
- (UIColor *)lightBodyTextColor {
    return [UIColor whiteColor];
}
- (UIColor *)buttonBackgroundColor {
    return [UIColor whiteColor];
}
%end
%hook YTQTMButton
- (void)setImage:(UIImage *)image {
    UIImage *currentImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setTintColor:[UIColor whiteColor]];
    %orig(currentImage);
}
%end
%hook VideoTitleLabel
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UILabel
+ (void)load {
    @autoreleasepool {
        [[UILabel appearance] setTextColor:[UIColor whiteColor]];
    }
}
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextField
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UITextView
- (void)setTextColor:(UIColor *)textColor {
    %log;
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISearchBar
- (void)setTextColor:(UIColor *)textColor {
    textColor = [UIColor whiteColor];
    %orig(textColor);
}
%end
%hook UISegmentedControl
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook UIButton
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    color = [UIColor whiteColor];
    %orig(color, state);
}
%end
%hook UIBarButtonItem
- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    %orig(modifiedAttributes, state);
}
%end
%hook NSAttributedString
- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    NSMutableDictionary *modifiedAttributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    [modifiedAttributes setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    return %orig(str, modifiedAttributes);
}
%end
%hook CATextLayer
- (void)setTextColor:(CGColorRef)textColor {
    %orig([UIColor whiteColor].CGColor);
}
%end
%hook ASTextNode
- (NSAttributedString *)attributedString {
    NSAttributedString *originalAttributedString = %orig;
    NSMutableAttributedString *newAttributedString = [originalAttributedString mutableCopy];
    [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, newAttributedString.length)];
    return newAttributedString;
}
%end
%hook ASTextFieldNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASTextView
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%hook ASButtonNode
- (void)setTextColor:(UIColor *)textColor {
   %orig([UIColor whiteColor]);
}
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (defaultContrastMode()) {
        %init(gLowContrastMode);
    }
    if (redContrastMode()) {
        %init(gRedContrastMode);
    }
    if (blueContrastMode()) {
        %init(gBlueContrastMode);
    }
    if (greenContrastMode()) {
        %init(gGreenContrastMode);
    }
    if (yellowContrastMode()) {
        %init(gYellowContrastMode);
    }
    if (orangeContrastMode()) {
        %init(gOrangeContrastMode);
    }
    if (purpleContrastMode()) {
        %init(gPurpleContrastMode);
    }
    if (violetContrastMode()) {
        %init(gVioletContrastMode);
    }
    if (pinkContrastMode()) {
        %init(gPinkContrastMode);
    }
}
