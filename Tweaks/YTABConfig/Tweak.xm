#import <rootless.h>
#import "../YouTubeHeader/YTAlertView.h"
#import "../YouTubeHeader/YTAppDelegate.h"
#import "../YouTubeHeader/YTCommonUtils.h"
#import "../YouTubeHeader/YTUIUtils.h"
#import "../YouTubeHeader/YTVersionUtils.h"
#import "../YouTubeHeader/YTGlobalConfig.h"
#import "../YouTubeHeader/YTColdConfig.h"
#import "../YouTubeHeader/YTHotConfig.h"
#import "../YouTubeHeader/YTSettingsSectionItem.h"
#import "../YouTubeHeader/YTSettingsSectionItemManager.h"
#import "../YouTubeHeader/YTSettingsPickerViewController.h"
#import "../YouTubeHeader/YTSettingsViewController.h"
#import "../YouTubeHeader/YTSearchableSettingsViewController.h"
#import "../YouTubeHeader/YTToastResponderEvent.h"

#define Prefix @"YTABC"
#define EnabledKey @"EnabledYTABC"
#define GroupedKey @"GroupedYTABC"
#define INCLUDED_CLASSES @"Included classes: YTGlobalConfig, YTColdConfig, YTHotConfig"
#define EXCLUDED_METHODS @"Excluded settings: android*, amsterdam*, musicClient* and unplugged*"

#define _LOC(b, x) [b localizedStringForKey:x value:nil table:nil]
#define LOC(x) _LOC(tweakBundle, x)

static const NSInteger YTABCSection = 404;

@interface YTSettingsSectionItemManager (YTABConfig)
- (void)updateYTABCSectionWithEntry:(id)entry;
@end

NSMutableDictionary <NSString *, NSMutableDictionary <NSString *, NSNumber *> *> *cache;
NSUserDefaults *defaults;
NSArray <NSString *> *allKeys;

static BOOL tweakEnabled() {
    return [defaults boolForKey:EnabledKey];
}

static BOOL groupedSettings() {
    return [defaults boolForKey:GroupedKey];
}

static NSString *getKey(NSString *method, NSString *classKey) {
    return [NSString stringWithFormat:@"%@.%@.%@", Prefix, classKey, method];
}

static NSString *getCacheKey(NSString *method, NSString *classKey) {
    return [NSString stringWithFormat:@"%@.%@", classKey, method];
}

static BOOL getValue(NSString *methodKey) {
    if (![allKeys containsObject:methodKey])
        return [[cache valueForKeyPath:[methodKey substringFromIndex:Prefix.length + 1]] boolValue];
    return [defaults boolForKey:methodKey];
}

static void setValue(NSString *method, NSString *classKey, BOOL value) {
    [cache setValue:@(value) forKeyPath:getCacheKey(method, classKey)];
    [defaults setBool:value forKey:getKey(method, classKey)];
}

static void updateAllKeys() {
    allKeys = [defaults dictionaryRepresentation].allKeys;
}

static BOOL returnFunction(id const self, SEL _cmd) {
    NSString *method = NSStringFromSelector(_cmd);
    NSString *methodKey = getKey(method, NSStringFromClass([self class]));
    return getValue(methodKey);
}

static BOOL getValueFromInvocation(id target, SEL selector) {
    NSInvocationOperation *i = [[NSInvocationOperation alloc] initWithTarget:target selector:selector object:nil];
    [i start];
    BOOL result = NO;
    [i.result getValue:&result];
    return result;
}

NSBundle *YTABCBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTABC" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/YTABC.bundle")];
    });
    return bundle;
}

%group Search

%hook YTSettingsViewController

- (void)loadWithModel:(id)model fromView:(UIView *)view {
    %orig;
    if ([[self valueForKey:@"_detailsCategoryID"] integerValue] == YTABCSection)
        MSHookIvar<BOOL>(self, "_shouldShowSearchBar") = YES;
}

- (void)setSectionControllers {
    %orig;
    if (MSHookIvar<BOOL>(self, "_shouldShowSearchBar")) {
        YTSettingsSectionController *settingsSectionController = [self settingsSectionControllers][[self valueForKey:@"_detailsCategoryID"]];
        if (settingsSectionController) {
            YTSearchableSettingsViewController *searchableVC = [self valueForKey:@"_searchableSettingsViewController"];
            [searchableVC storeCollectionViewSections:@[settingsSectionController]];
        }
    }
}

%end

%end

%hook YTSettingsSectionController

- (void)setSelectedItem:(NSUInteger)selectedItem {
    if (selectedItem != NSNotFound) %orig;
}

%end

%hook YTAppSettingsPresentationData

+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    [mutableOrder insertObject:@(YTABCSection) atIndex:0];
    return mutableOrder;
}

%end

static NSString *getCategory(char c, NSString *method) {
    if (c == 'e') {
        if ([method hasPrefix:@"elements"]) return @"elements";
        if ([method hasPrefix:@"enable"]) return @"enable";
    }
    if (c == 'i') {
        if ([method hasPrefix:@"ios"]) return @"ios";
        if ([method hasPrefix:@"is"]) return @"is";
    }
    if (c == 's') {
        if ([method hasPrefix:@"shorts"]) return @"shorts";
        if ([method hasPrefix:@"should"]) return @"should";
    }
    unichar uc = (unichar)c;
    return [NSString stringWithCharacters:&uc length:1];;
}

%hook YTSettingsSectionItemManager

%new(v@:@)
- (void)updateYTABCSectionWithEntry:(id)entry {
    NSMutableArray *sectionItems = [NSMutableArray array];
    int totalSettings = 0;
    NSBundle *tweakBundle = YTABCBundle();
    BOOL isPhone = ![%c(YTCommonUtils) isIPad];
    NSString *yesText = _LOC([NSBundle mainBundle], @"settings.yes");
    NSString *cancelText = _LOC([NSBundle mainBundle], @"confirm.cancel");
    NSString *deleteText = _LOC([NSBundle mainBundle], @"search.action.delete");
    Class YTSettingsSectionItemClass = %c(YTSettingsSectionItem);
    Class YTAlertViewClass = %c(YTAlertView);
    if (tweakEnabled()) {
        NSMutableDictionary <NSString *, NSMutableArray <YTSettingsSectionItem *> *> *properties = [NSMutableDictionary dictionary];
        for (NSString *classKey in cache) {
            for (NSString *method in cache[classKey]) {
                char c = tolower([method characterAtIndex:0]);
                NSString *category = getCategory(c, method);
                if (![properties objectForKey:category]) properties[category] = [NSMutableArray array];
                updateAllKeys();
                BOOL modified = [allKeys containsObject:getKey(method, classKey)];
                NSString *modifiedTitle = modified ? [NSString stringWithFormat:@"%@ *", method] : method;
                YTSettingsSectionItem *methodSwitch = [YTSettingsSectionItemClass switchItemWithTitle:modifiedTitle
                    titleDescription:isPhone && method.length > 26 ? modifiedTitle : nil
                    accessibilityIdentifier:nil
                    switchOn:getValue(getKey(method, classKey))
                    switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                        setValue(method, classKey, enabled);
                        return YES;
                    }
                    selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                        NSString *content = [NSString stringWithFormat:@"%@.%@", classKey, method];
                        YTAlertView *alertView = [YTAlertViewClass confirmationDialog];
                        alertView.title = method;
                        alertView.subtitle = content;
                        [alertView addTitle:LOC(@"COPY_TO_CLIPBOARD") withAction:^{
                            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                            pasteboard.string = content;
                            [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"COPIED_TO_CLIPBOARD") firstResponder:[self parentResponder]] send];
                        }];
                        updateAllKeys();
                        NSString *key = getKey(method, classKey);
                        if ([allKeys containsObject:key]) {
                            [alertView addTitle:deleteText withAction:^{
                                [defaults removeObjectForKey:key];
                                updateAllKeys();
                            }];
                        }
                        [alertView addCancelButton:NULL];
                        [alertView show];
                        return NO;
                    }
                    settingItemId:0];
                [properties[category] addObject:methodSwitch];
            }
        }
        YTSettingsViewController *settingsViewController = [self valueForKey:@"_settingsViewControllerDelegate"];
        BOOL grouped = groupedSettings();
        for (NSString *category in properties) {
            NSMutableArray <YTSettingsSectionItem *> *rows = properties[category];
            totalSettings += rows.count;
            if (grouped) {
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
                [rows sortUsingDescriptors:@[sort]];
                NSString *shortTitle = [NSString stringWithFormat:@"\"%@\" (%ld)", category, rows.count];
                NSString *title = [NSString stringWithFormat:@"%@ %@", LOC(@"SETTINGS_START_WITH"), shortTitle];
                YTSettingsSectionItem *sectionItem = [YTSettingsSectionItemClass itemWithTitle:title accessibilityIdentifier:nil detailTextBlock:nil selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                    YTSettingsPickerViewController *picker = [[%c(YTSettingsPickerViewController) alloc] initWithNavTitle:shortTitle pickerSectionTitle:nil rows:rows selectedItemIndex:NSNotFound parentResponder:[self parentResponder]];
                    [settingsViewController pushViewController:picker];
                    return YES;
                }];
                [sectionItems addObject:sectionItem];
            } else {
                [sectionItems addObjectsFromArray:rows];
            }
        }
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        [sectionItems sortUsingDescriptors:@[sort]];
        YTSettingsSectionItem *copyAll = [YTSettingsSectionItemClass itemWithTitle:LOC(@"COPY_CURRENT_SETTINGS")
            titleDescription:LOC(@"COPY_CURRENT_SETTINGS_DESC")
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                NSMutableArray *content = [NSMutableArray array];
                for (NSString *classKey in cache) {
                    [cache[classKey] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *value, BOOL* stop) {
                        [content addObject:[NSString stringWithFormat:@"%@: %d", key, [value boolValue]]];
                    }];
                }
                [content sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                [content insertObject:[NSString stringWithFormat:@"Device model: %@", [%c(YTCommonUtils) hardwareModel]] atIndex:0];
                [content insertObject:[NSString stringWithFormat:@"App version: %@", [%c(YTVersionUtils) appVersion]] atIndex:0];
                [content insertObject:EXCLUDED_METHODS atIndex:0];
                [content insertObject:INCLUDED_CLASSES atIndex:0];
                [content insertObject:[NSString stringWithFormat:@"YTABConfig version: %@", @(OS_STRINGIFY(TWEAK_VERSION))] atIndex:0];
                pasteboard.string = [content componentsJoinedByString:@"\n"];
                [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"COPIED_TO_CLIPBOARD") firstResponder:[self parentResponder]] send];
                return YES;
            }];
        [sectionItems insertObject:copyAll atIndex:0];
        YTSettingsSectionItem *modified = [YTSettingsSectionItemClass itemWithTitle:LOC(@"VIEW_MODIFIED_SETTINGS")
            titleDescription:LOC(@"VIEW_MODIFIED_SETTINGS_DESC")
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                NSMutableArray *features = [NSMutableArray array];
                updateAllKeys();
                for (NSString *key in allKeys) {
                    if ([key hasPrefix:Prefix]) {
                        NSString *displayKey = [key substringFromIndex:Prefix.length + 1];
                        [features addObject:[NSString stringWithFormat:@"%@: %d", displayKey, [defaults boolForKey:key]]];
                    }
                }
                [features sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                [features insertObject:[NSString stringWithFormat:LOC(@"TOTAL_MODIFIED_SETTINGS"), features.count] atIndex:0];
                NSString *content = [features componentsJoinedByString:@"\n"];
                YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = content;
                    [[%c(YTToastResponderEvent) eventWithMessage:LOC(@"COPIED_TO_CLIPBOARD") firstResponder:[self parentResponder]] send];
                } actionTitle:LOC(@"COPY_TO_CLIPBOARD")];
                alertView.title = LOC(@"MODIFIED_SETTINGS_TITLE");
                alertView.subtitle = content;
                [alertView show];
                return YES;
            }];
        [sectionItems insertObject:modified atIndex:0];
        YTSettingsSectionItem *reset = [YTSettingsSectionItemClass itemWithTitle:LOC(@"RESET_KILL")
            titleDescription:LOC(@"RESET_KILL_DESC")
            accessibilityIdentifier:nil
            detailTextBlock:nil
            selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
                YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{
                    updateAllKeys();
                    for (NSString *key in allKeys) {
                        if ([key hasPrefix:Prefix])
                            [defaults removeObjectForKey:key];
                    }
                    exit(0);
                } actionTitle:yesText];
                alertView.title = LOC(@"WARNING");
                alertView.subtitle = LOC(@"APPLY_DESC");
                [alertView show];
                return YES;
            }];
        [sectionItems insertObject:reset atIndex:0];
        YTSettingsSectionItem *group = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"GROUPED")
            titleDescription:nil
            accessibilityIdentifier:nil
            switchOn:groupedSettings()
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{
                        [defaults setBool:enabled forKey:GroupedKey];
                        exit(0);
                    }
                    actionTitle:yesText
                    cancelAction:^{
                        [cell setSwitchOn:!enabled animated:YES];
                    }
                    cancelTitle:cancelText];
                alertView.title = LOC(@"WARNING");
                alertView.subtitle = LOC(@"APPLY_DESC");
                [alertView show];
                return YES;
            }
            settingItemId:0];
        [sectionItems insertObject:group atIndex:0];
    }
    YTSettingsSectionItem *thread = [YTSettingsSectionItemClass itemWithTitle:LOC(@"OPEN_MEGATHREAD")
        titleDescription:LOC(@"OPEN_MEGATHREAD_DESC")
        accessibilityIdentifier:nil
        detailTextBlock:nil
        selectBlock:^BOOL (YTSettingsCell *cell, NSUInteger arg1) {
            return [%c(YTUIUtils) openURL:[NSURL URLWithString:@"https://github.com/PoomSmart/YTABConfig/discussions"]];
        }];
    [sectionItems insertObject:thread atIndex:0];
    YTSettingsSectionItem *master = [YTSettingsSectionItemClass switchItemWithTitle:LOC(@"ENABLED")
        titleDescription:LOC(@"ENABLED_DESC")
        accessibilityIdentifier:nil
        switchOn:tweakEnabled()
        switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
            [defaults setBool:enabled forKey:EnabledKey];
            YTAlertView *alertView = [YTAlertViewClass confirmationDialogWithAction:^{ exit(0); }
                actionTitle:yesText
                cancelAction:^{
                    [cell setSwitchOn:!enabled animated:YES];
                }
                cancelTitle:cancelText];
            alertView.title = LOC(@"WARNING");
            alertView.subtitle = LOC(@"APPLY_DESC");
            [alertView show];
            return YES;
        }
        settingItemId:0];
    [sectionItems insertObject:master atIndex:0];
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    [delegate setSectionItems:sectionItems
        forCategory:YTABCSection
        title:@"A/B"
        titleDescription:tweakEnabled() ? [NSString stringWithFormat:@"YTABConfig %@, %d feature flags.", @(OS_STRINGIFY(TWEAK_VERSION)), totalSettings] : nil
        headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YTABCSection) {
        [self updateYTABCSectionWithEntry:entry];
        return;
    }
    %orig;
}

%end

static NSMutableArray <NSString *> *getBooleanMethods(Class clz) {
    NSMutableArray *allMethods = [NSMutableArray array];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(clz, &methodCount);
    for (unsigned int i = 0; i < methodCount; ++i) {
        Method method = methods[i];
        const char *name = sel_getName(method_getName(method));
        if (strstr(name, "ndroid") || strstr(name, "musicClient") || strstr(name, "amsterdam") || strstr(name, "unplugged")) continue;
        const char *encoding = method_getTypeEncoding(method);
        if (strcmp(encoding, "B16@0:8")) continue;
        NSString *selector = [NSString stringWithUTF8String:name];
        if (![allMethods containsObject:selector])
            [allMethods addObject:selector];
    }
    free(methods);
    return allMethods;
}

static void hookClass(NSObject *instance) {
    if (!instance) [NSException raise:@"hookClass Invalid argument exception" format:@"Hooking the class of a non-existing instance"];
    Class instanceClass = [instance class];
    NSMutableArray <NSString *> *methods = getBooleanMethods(instanceClass);
    NSString *classKey = NSStringFromClass(instanceClass);
    NSMutableDictionary *classCache = cache[classKey] = [NSMutableDictionary new];
    for (NSString *method in methods) {
        SEL selector = NSSelectorFromString(method);
        BOOL result = getValueFromInvocation(instance, selector);
        classCache[method] = @(result);
        MSHookMessageEx(instanceClass, selector, (IMP)returnFunction, NULL);
    }
}

%hook YTAppDelegate

- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    defaults = [NSUserDefaults standardUserDefaults];
    if (tweakEnabled()) {
        updateAllKeys();
        YTGlobalConfig *globalConfig;
        YTColdConfig *coldConfig;
        YTHotConfig *hotConfig;
        @try {
            globalConfig = [self valueForKey:@"_globalConfig"];
            coldConfig = [self valueForKey:@"_coldConfig"];
            hotConfig = [self valueForKey:@"_hotConfig"];
        } @catch (id ex) {
            id settings = [self valueForKey:@"_settings"];
            globalConfig = [settings valueForKey:@"_globalConfig"];
            coldConfig = [settings valueForKey:@"_coldConfig"];
            hotConfig = [settings valueForKey:@"_hotConfig"];
        }
        hookClass(globalConfig);
        hookClass(coldConfig);
        hookClass(hotConfig);
        if (!groupedSettings()) {
            %init(Search);
        }
    }
    return %orig;
}

%end

%ctor {
    NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Frameworks/Module_Framework.framework", [[NSBundle mainBundle] bundlePath]]];
    if (!bundle.loaded) [bundle load];
    cache = [NSMutableDictionary new];
    %init;
}

%dtor {
    [cache removeAllObjects];
}
