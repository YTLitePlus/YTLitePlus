#import "Header.h"

BOOL UseVP9() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:UseVP9Key];
}

// Remove any <= 1080p VP9 formats
NSArray *filteredFormats(NSArray <MLFormat *> *formats) {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(MLFormat *format, NSDictionary *bindings) {
        return [format height] > 1080 || [[format MIMEType] videoCodec] != 'vp09';
    }];
    return [formats filteredArrayUsingPredicate:predicate];
}

%hook MLHAMPlayerItem

- (void)load {
    MLInnerTubePlayerConfig *config = [self config];
    YTIMediaCommonConfig *mediaCommonConfig = [config mediaCommonConfig];
    mediaCommonConfig.useServerDrivenAbr = NO;
    %orig;
}

%end

static void hookFormats(MLABRPolicy *self) {
    YTIHamplayerConfig *config = [self valueForKey:@"_hamplayerConfig"];
    config.videoAbrConfig.preferSoftwareHdrOverHardwareSdr = YES;
    if ([config respondsToSelector:@selector(setDisableResolveOverlappingQualitiesByCodec:)])
        config.disableResolveOverlappingQualitiesByCodec = NO;
    YTIHamplayerStreamFilter *filter = config.streamFilter;
    filter.enableVideoCodecSplicing = YES;
    filter.vp9.maxArea = MAX_PIXELS;
    filter.vp9.maxFps = MAX_FPS;
}

%hook MLABRPolicy

- (void)setFormats:(NSArray *)formats {
    hookFormats(self);
    %orig(filteredFormats(formats));
}

%end

%hook MLABRPolicyOld

- (void)setFormats:(NSArray *)formats {
    hookFormats(self);
    %orig(filteredFormats(formats));
}

%end

%hook YTHotConfig

- (BOOL)iosClientGlobalConfigEnableNewMlabrpolicy {
    return NO;
}

- (BOOL)iosPlayerClientSharedConfigEnableNewMlabrpolicy {
    return NO;
}

%end

%ctor {
    if (UseVP9()) {
        %init;
    }
}
