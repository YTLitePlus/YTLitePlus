#ifndef _PS_MISC
#define _PS_MISC

#import <Foundation/Foundation.h>
#import <rootless.h>
#import "PAC.h"

#if TARGET_OS_SIMULATOR

#import <UIKit/UIFunctions.h>

#define realPath(path) [UISystemRootDirectory() stringByAppendingPathComponent:path]
#define realPath2(path) [realPath(path) UTF8String]
#define realPrefPath(domain) [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", @(getenv("SIMULATOR_SHARED_RESOURCES_DIRECTORY")), domain]
#else
#define realPath(path) (path)
#define realPath2(path) ([path UTF8String])
#define realPrefPath(domain) [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", domain]
#endif

#define fileExist(path) [[NSFileManager defaultManager] fileExistsAtPath:path]
#define CFStringEqual(s1, s2) (CFStringCompare(s1, s2, kCFCompareCaseInsensitive) == kCFCompareEqualTo)
#define NSStringEqual(str1, str2) ([str1 isEqualToString:str2])

#define _PSFindSymbolCallable(image, name) make_sym_callable(MSFindSymbol(image, name))
#define _PSFindSymbolReadable(image, name) make_sym_readable(MSFindSymbol(image, name))

#endif
