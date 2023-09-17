#import "../Header.h"

//
static BOOL IsEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}
static int appVersionSpoofer() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"versionSpoofer"];
}
static BOOL version0() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 0;
}
static BOOL version1() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 1;
}
static BOOL version2() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 2;
}
static BOOL version3() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 3;
}
static BOOL version4() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 4;
}
static BOOL version5() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 5;
}
static BOOL version6() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 6;
}
static BOOL version7() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 7;
}
static BOOL version8() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 8;
}

%group gDefault
%hook YTVersionUtils
+ (NSString *)appVersion {
    NSURL *versionURL = [NSURL URLWithString:@"https://raw.githubusercontent.com/arichorn/YTAppVersionSpoofer-WIP/main/version.txt"];
    NSString *latestVersion = [NSString stringWithContentsOfURL:versionURL encoding:NSUTF8StringEncoding error:nil];
    
    return latestVersion ?: @"18.35.4"; // <-- Fallback Version
}
%end
%end

%group gVersion1
%hook YTVersionUtils // Fixes YTClassicVideoQuality & YTSpeed
+ (NSString *)appVersion { return @"18.18.2"; }
%end
%end

%group gVersion2
%hook YTVersionUtils // Final v17 App Version
+ (NSString *)appVersion { return @"17.49.6"; }
%end
%end

%group gVersion3
%hook YTVersionUtils // v17.38.10 Fixes the LowContrastMode Tweak + No Rounded Thumbnails
+ (NSString *)appVersion { return @"17.38.10"; }
%end
%end

%group gVersion4
%hook YTVersionUtils // Last 2nd Supported YouTube App Version
+ (NSString *)appVersion { return @"17.01.4"; }
%end
%end

%group gVersion5
%hook YTVersionUtils // Final v16 App Version
+ (NSString *)appVersion { return @"16.46.5"; }
%end
%end

%group gVersion6
%hook YTVersionUtils // Popular v16 App Version
+ (NSString *)appVersion { return @"16.42.3"; }
%end
%end

%group gVersion7
%hook YTVersionUtils // Old Comment Section & Description Layout
+ (NSString *)appVersion { return @"16.08.2"; }
%end
%end

%group gVersion8
%hook YTVersionUtils // Last Supported YouTube App Version
+ (NSString *)appVersion { return @"16.05.7"; }
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (version0()) { // 0
        %init(gDefault);
    }
    if (version1()) { // 1
        %init(gVersion1);
    }
    if (version2()) { // 2
        %init(gVersion2);
    }
    if (version3()) { // 3
        %init(gVersion3);
    }
    if (version4()) { // 4
        %init(gVersion4);
    }
    if (version5()) { // 5
        %init(gVersion5);
    }
    if (version6()) { // 6
        %init(gVersion6);
    }
    if (version7()) { // 7
        %init(gVersion7);
    }
    if (version8()) { // 8
        %init(gVersion8);
    }
}
