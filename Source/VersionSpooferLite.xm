#import "../YTLitePlus.h"


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

%group gVersion0
%hook YTVersionUtils // Last v18 App Version (Memory Leak errors are gone in v18.35.4+)
+ (NSString *)appVersion { return @"18.49.3"; }
%end
%end

%group gVersion1
%hook YTVersionUtils // Brings back Library Tab - Deprecated
+ (NSString *)appVersion { return @"18.34.5"; }
%end
%end

%group gVersion2
%hook YTVersionUtils // Removes Playables in Explore - Deprecated
+ (NSString *)appVersion { return @"18.33.3"; }
%end
%end

%group gVersion3
%hook YTVersionUtils // Fixes YTClassicVideoQuality + YTSpeed - Deprecated
+ (NSString *)appVersion { return @"18.18.2"; }
%end
%end

%group gVersion4
%hook YTVersionUtils // First v18 App Version - Deprecated
+ (NSString *)appVersion { return @"18.01.2"; }
%end
%end

%group gVersion5
%hook YTVersionUtils // Last v17 App Version - Deprecated
+ (NSString *)appVersion { return @"17.49.6"; }
%end
%end

%group gVersion6
%hook YTVersionUtils // v17.38.10 Fixes LowContrastMode + No Rounded Thumbnails - Deprecated
+ (NSString *)appVersion { return @"17.38.10"; }
%end
%end

%group gVersion7
%hook YTVersionUtils // Oldest Supported App Version (v17) - Deprecated
+ (NSString *)appVersion { return @"17.33.2"; }
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (version0()) { // 0
        %init(gVersion0);
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
}
