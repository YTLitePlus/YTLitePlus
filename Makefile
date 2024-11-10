export TARGET = iphone:clang:16.5:14.0
export SDK_PATH = $(THEOS)/sdks/iPhoneOS16.5.sdk/
export SYSROOT = $(SDK_PATH)
export ARCHS = arm64
MODULES = jailed
export FINALPACKAGE = 1
export CODESIGN_IPA = 0
export REMOVE_EXTENSIONS = 1
export PACKAGE_NAME = $(TWEAK_NAME)
export PACKAGE_VERSION = X.X.X-X.X

export libcolorpicker_ARCHS = arm64
export libFLEX_ARCHS = arm64
export Alderis_XCODEOPTS = LD_DYLIB_INSTALL_NAME=@rpath/Alderis.framework/Alderis
export Alderis_XCODEFLAGS = DYLIB_INSTALL_NAME_BASE=/Library/Frameworks BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS="$(ARCHS)"
export libcolorpicker_LDFLAGS = -F$(TARGET_PRIVATE_FRAMEWORK_PATH) -install_name @rpath/libcolorpicker.dylib
export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks/RemoteLog -I$(THEOS_PROJECT_DIR)/Tweaks
export DEBUGFLAG = -ggdb -Wno-unused-command-line-argument -L$(THEOS_OBJ_DIR) -F$(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install/Library/Frameworks

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = YTLitePlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

$(TWEAK_NAME)_FILES = YTLitePlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation AVFoundation AVKit Photos Accelerate CoreMotion GameController VideoToolbox Security
$(TWEAK_NAME)_LIBRARIES = bz2 c++ iconv z
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-but-set-variable -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\"
$(TWEAK_NAME)_INJECT_DYLIBS = Tweaks/YTLite/var/jb/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib .theos/obj/libFLEX.dylib .theos/obj/libcolorpicker.dylib .theos/obj/iSponsorBlock.dylib .theos/obj/YTUHD.dylib .theos/obj/YouPiP.dylib .theos/obj/YouTubeDislikesReturn.dylib .theos/obj/YTABConfig.dylib .theos/obj/YouMute.dylib .theos/obj/DontEatMyContent.dylib .theos/obj/YTHoldForSpeed.dylib .theos/obj/YTVideoOverlay.dylib .theos/obj/YouGroupSettings.dylib .theos/obj/YouQuality.dylib .theos/obj/YouTimeStamp.dylib .theos/obj/YouLoop.dylib
$(TWEAK_NAME)_EMBED_LIBRARIES = $(THEOS_OBJ_DIR)/libcolorpicker.dylib
$(TWEAK_NAME)_EMBED_FRAMEWORKS = $(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install_Alderis.xcarchive/Products/var/jb/Library/Frameworks/Alderis.framework
$(TWEAK_NAME)_EMBED_BUNDLES = $(wildcard Bundles/*.bundle)
$(TWEAK_NAME)_EMBED_EXTENSIONS = $(wildcard Extensions/*.appex)

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Tweaks/Alderis Tweaks/DontEatMyContent Tweaks/FLEXing/libflex Tweaks/iSponsorBlock Tweaks/Return-YouTube-Dislikes Tweaks/YTABConfig Tweaks/YouGroupSettings Tweaks/YouLoop Tweaks/YouMute Tweaks/YouPiP Tweaks/YouQuality Tweaks/YouTimeStamp Tweaks/YTHoldForSpeed Tweaks/YTUHD Tweaks/YTVideoOverlay
include $(THEOS_MAKE_PATH)/aggregate.mk

YTLITE_VERSION := 5.0.1
YTLITE_PATH = Tweaks/YTLite
YTLITE_DEB = $(YTLITE_PATH)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb
YTLITE_DYLIB = $(YTLITE_PATH)/var/jb/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib
YTLITE_BUNDLE = $(YTLITE_PATH)/var/jb/Library/Application\ Support/YTLite.bundle

internal-clean::
	@rm -rf $(YTLITE_PATH)/*

before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
		rm -rf $(YTLITE_PATH)/*; \
		$(PRINT_FORMAT_BLUE) "Downloading YTLite"; \
		curl -s -L "https://github.com/dayanch96/YTLite/releases/download/v$(YTLITE_VERSION)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb" -o $(YTLITE_DEB); \
		tar -xf $(YTLITE_DEB) -C $(YTLITE_PATH); tar -xf $(YTLITE_PATH)/data.tar* -C $(YTLITE_PATH); \
		if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
			$(PRINT_FORMAT_ERROR) "Failed to extract YTLite"; exit 1; \
		fi; \
    	fi

before-package::
	@mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support; cp -r lang/YTLitePlus.bundle $(THEOS_STAGING_DIR)/Library/Application\ Support/
