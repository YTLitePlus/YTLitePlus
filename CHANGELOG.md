# CHANGELOG - iOS SDK 18.5 Upgrade

## [Unreleased] - 2026-02-04

### 🚀 Major Changes

#### iOS SDK Upgraded from 17.5 to 18.5
- **Motivation**: Support latest iOS features and resolve module compatibility issues
- **Impact**: Full compatibility with modern iOS 18 applications and APIs

### ✨ Added

#### Makefile
- Added `-fmodules-validate-once-per-build-session` flag to `ADDITIONAL_CFLAGS`
- Added `-fmodules-validate-once-per-build-session` flag to `YTLitePlus_CFLAGS`
- Updated `TARGET` to use iOS SDK 18.5: `iphone:clang:18.5:14.0`
- Updated `SDK_PATH` to point to `iPhoneOS18.5.sdk`

#### GitHub Actions Workflow (`.github/workflows/buildapp.yml`)
- New step: "Configure SDK Environment for iOS 18.5"
  - Sets `SDKROOT` explicitly to prevent system SDK conflicts
  - Sets `EXTRA_CFLAGS` for module validation
  - Verifies SDK configuration before build
- Added SDK verification output in build step
- Added explicit `SDKROOT` parameter to make command

### 🔄 Changed

#### Makefile
- `TARGET`: `iphone:clang:17.5:14.0` → `iphone:clang:18.5:14.0`
- `SDK_PATH`: `$(THEOS)/sdks/iPhoneOS17.5.sdk/` → `$(THEOS)/sdks/iPhoneOS18.5.sdk/`

#### GitHub Actions Workflow
- Default `sdk_version` input: `"17.5"` → `"18.5"`
- SDK download repository: Fixed typo from `aricloverALT/sdks` → `arichornlover/sdks`
- Updated workflow header with iOS 18.5 documentation
- Enhanced build step with environment verification

### 📚 Documentation

#### New Files
- `SDK_18.5_UPGRADE.md` - Complete upgrade guide with:
  - Problem analysis
  - Solution details
  - Benefits comparison
  - Testing procedures
  - Rollback plan
- `CHANGELOG.md` - This file

#### Updated Files
- `.github/workflows/buildapp.yml` - Added explanatory header comments

### 🐛 Bug Fixes

#### Resolved Compilation Issues
- Fixed module validation errors with newer SDKs
- Resolved conflicts between system SDK and downloaded SDK
- Fixed missing headers errors in C standard library modules

### 🔧 Technical Details

#### Module Validation Flag
The `-fmodules-validate-once-per-build-session` flag:
- Optimizes module cache validation
- Reduces compilation conflicts with updated C/C++ standard library modules
- Improves build performance by validating modules only once per session

#### SDK Isolation
Explicit `SDKROOT` setting ensures:
- Downloaded SDK (18.5) takes precedence over system SDKs
- Consistent builds across different macOS/Xcode versions
- No interference from incompatible system SDK modules

### ⚠️ Breaking Changes

None. This upgrade is backward compatible with existing code.

### 📝 Migration Notes

#### For Developers
If building locally:
1. Download iOS SDK 18.5 to `$THEOS/sdks/`
2. Set `SDKROOT` environment variable
3. Clean build directory before rebuilding

#### For CI/CD
- Workflow now defaults to SDK 18.5
- Can still override with `sdk_version` input parameter
- Cached SDK version changed (will download new SDK on first run)

### 🎯 Tested Configurations

- ✅ macOS 15 (Intel) + Xcode 16.x + iOS SDK 18.5
- ✅ GitHub Actions runner: macos-15-intel
- ⏳ Local testing pending

### 🔮 Future Improvements

Potential enhancements for future versions:
- [ ] Test with iOS 19 beta SDKs when available
- [ ] Evaluate arm64e architecture support
- [ ] Consider Swift module improvements
- [ ] Monitor Theos updates for native iOS 18+ features

### 📊 Metrics

**Files Changed**: 3
- `Makefile` - 6 lines modified
- `.github/workflows/buildapp.yml` - 25 lines modified  
- Documentation - 2 new files

**Build Time Impact**: Negligible (module validation optimization may improve build times)

**Risk Level**: Low (SDK upgrade maintains API compatibility)

---

## Comparison with Previous Approach

### Branch: `fix-sdk-26-compatibility` (Temporary Workaround)
- Downgraded to macOS 14 runner
- Kept old SDK 17.5
- Temporary solution only

### Branch: `upgrade-sdk-18-native-support` (This Update)
- Uses modern macOS 15 runner
- Upgrades to SDK 18.5
- Long-term maintainable solution
- Properly isolates SDK environment

---

**Branch**: upgrade-sdk-18-native-support  
**Date**: February 4, 2026  
**Author**: Giuseppe Mauro Costa  
**Status**: Ready for review and testing
