#import "Header.h"
#import <VideoToolbox/VideoToolbox.h>
#import <sys/sysctl.h>
#import <version.h>

extern BOOL UseVP9();

%hook YTSettings

- (BOOL)isWebMEnabled {
    return YES;
}

%end

%group Spoofing

%hook UIDevice

- (NSString *)systemVersion {
    return @"15.7.6";
}

%end

%hook NSProcessInfo

- (NSOperatingSystemVersion)operatingSystemVersion {
    NSOperatingSystemVersion version;
    version.majorVersion = 15;
    version.minorVersion = 7;
    version.patchVersion = 6;
    return version;
}

%end

%hookf(int, sysctlbyname, const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if (strcmp(name, "kern.osversion") == 0) {
        if (oldp)
            strcpy((char *)oldp, IOS_BUILD);
        *oldlenp = strlen(IOS_BUILD);
    }
    return %orig(name, oldp, oldlenp, newp, newlen);
}

%end

// #ifdef SIDELOADED

// #import "../PSHeader/Misc.h"

// typedef struct OpaqueVTVideoDecoder VTVideoDecoderRef;
// extern OSStatus VTSelectAndCreateVideoDecoderInstance(CMVideoCodecType codecType, CFAllocatorRef allocator, CFDictionaryRef videoDecoderSpecification, VTVideoDecoderRef *decoderInstanceOut);

// #endif

%ctor {
    if (UseVP9()) {
        %init;
// #ifdef SIDELOADED
//         CFMutableDictionaryRef payload = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
//         if (payload) {
//             CFDictionarySetValue(payload, CFSTR("RequireHardwareAcceleratedVideoDecoder"), kCFBooleanTrue);
//             CFDictionarySetValue(payload, CFSTR("AllowAlternateDecoderSelection"), kCFBooleanTrue);
//             VTSelectAndCreateVideoDecoderInstance(kCMVideoCodecType_VP9, kCFAllocatorDefault, payload, NULL);
//             CFRelease(payload);
//         }
// #endif
        if (!IS_IOS_OR_NEWER(iOS_15_0)) {
            %init(Spoofing);
        }
    }
}
