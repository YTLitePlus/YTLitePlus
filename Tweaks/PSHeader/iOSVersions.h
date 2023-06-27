#ifndef _PS_IOSVER
#define _PS_IOSVER

#import <CoreFoundation/CoreFoundation.h>
#import <version.h>

#define IS_IOS_BETWEEN_EEX(start, end) (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_ ## start && kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_ ## end)

#endif
