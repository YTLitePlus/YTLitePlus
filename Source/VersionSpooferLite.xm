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
static BOOL version8() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 8;
}
static BOOL version9() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 9;
}
static BOOL version10() {
    return IsEnabled(@"enableVersionSpoofer_enabled") && appVersionSpoofer() == 10;
}

%group gVersion0
%hook YTVersionUtils // New 2024 Thin Outline Icons
+ (NSString *)appVersion { return @"19.28.1"; }
%end
%end

%group gVersion1
%hook YTVersionUtils // Restore 2020's Thin Outline Icons
+ (NSString *)appVersion { return @"19.26.5"; }
%end
%end

%group gVersion2
%hook YTVersionUtils // Last v18 App Version
+ (NSString *)appVersion { return @"18.49.3"; }
%end
%end

%group gVersion3
%hook YTVersionUtils // Oldest Supported App Version (v18) - this is a replacement of v17.33.2.
+ (NSString *)appVersion { return @"18.35.4"; }
%end
%end

%group gVersion4
%hook YTVersionUtils // Brings back Library Tab - Deprecated/Unsupported
+ (NSString *)appVersion { return @"18.34.5"; }
%end
%end

%group gVersion5
%hook YTVersionUtils // Removes Playables in Explore - Deprecated/Unsupported
+ (NSString *)appVersion { return @"18.33.3"; }
%end
%end

%group gVersion6
%hook YTVersionUtils // Fixes YTClassicVideoQuality + YTSpeed - Deprecated/Unsupported
+ (NSString *)appVersion { return @"18.18.2"; }
%end
%end

%group gVersion7
%hook YTVersionUtils // First v18 App Version - Deprecated/Unsupported
+ (NSString *)appVersion { return @"18.01.2"; }
%end
%end

%group gVersion8
%hook YTVersionUtils // Last v17 App Version - Deprecated/Unsupported
+ (NSString *)appVersion { return @"17.49.6"; }
%end
%end

%group gVersion9
%hook YTVersionUtils // v17.38.10 Fixes LowContrastMode + No Rounded Thumbnails - Deprecated/Unsupported
+ (NSString *)appVersion { return @"17.38.10"; }
%end
%end

%group gVersion10
%hook YTVersionUtils // Oldest Supported App Version (v17) - Deprecated/Unsupported
+ (NSString *)appVersion { return @"17.33.2"; }
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (version0()) {
        %init(gVersion0);
    }
    if (version1()) {
        %init(gVersion1);
    }
    if (version2()) {
        %init(gVersion2);
    }
    if (version3()) {
        %init(gVersion3);
    }
    if (version4()) {
        %init(gVersion4);
    }
    if (version5()) {
        %init(gVersion5);
    }
    if (version6()) {
        %init(gVersion6);
    }
    if (version7()) {
        %init(gVersion7);
    }
    if (version8()) {
        %init(gVersion8);
    }
    if (version9()) {
        %init(gVersion9);
    }
    if (version10()) {
        %init(gVersion10);
    }
}
