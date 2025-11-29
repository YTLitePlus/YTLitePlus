# ==> Tweak Configuration
# All tweaks are enabled by default.
# You can disable them by passing TWEAK_NAME=0 to the make command.
TWEAK_FLEX ?= 1
TWEAK_ISPONSORBLOCK ?= 1
TWEAK_YTUHD ?= 1
TWEAK_YOUPIP ?= 1
TWEAK_RETURN_YOUTUBE_DISLIKES ?= 1
TWEAK_YTABCONFIG ?= 1
TWEAK_DONTEATMYCONTENT ?= 1
TWEAK_YTHOLDFORSPEED ?= 1
TWEAK_YTVIDEOOVERLAY ?= 1
TWEAK_YOULOOP ?= 1
TWEAK_YOUMUTE ?= 1
TWEAK_YOUQUALITY ?= 1
TWEAK_YOUSPEED ?= 1
TWEAK_YOUTIMESTAMP ?= 1
TWEAK_YOUGROUPSETTINGS ?= 1

# ==> Build Configuration
# Default SDK version. This can be overridden by passing SDK_VERSION to the make command.
SDK_VERSION ?= 18.0
MIN_IOS_VERSION ?= 14.0

export TARGET = iphone:clang:$(SDK_VERSION):$(MIN_IOS_VERSION)
export SDK_PATH = $(THEOS)/sdks/iPhoneOS$(SDK_VERSION).sdk/
export SYSROOT = $(SDK_PATH)
export ARCHS = arm64

export libcolorpicker_ARCHS = arm64
export libFLEX_ARCHS = arm64
export Alderis_XCODEOPTS = LD_DYLIB_INSTALL_NAME=@rpath/Alderis.framework/Alderis
export Alderis_XCODEFLAGS = DYLIB_INSTALL_NAME_BASE=/Library/Frameworks BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS="$(ARCHS)"
export libcolorpicker_LDFLAGS = -F$(TARGET_PRIVATE_FRAMEWORK_PATH) -install_name @rpath/libcolorpicker.dylib
export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks/RemoteLog -I$(THEOS_PROJECT_DIR)/Tweaks # Allow YouTubeHeader to be accessible using #include <...>

ifneq ($(JAILBROKEN),1)
export DEBUGFLAG = -ggdb -Wno-unused-command-line-argument -L$(THEOS_OBJ_DIR) -F$(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install/Library/Frameworks
MODULES = jailed
endif
PACKAGE_NAME = YTLitePlus
PACKAGE_VERSION = X.X.X-X.X

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = YTLitePlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

YTLitePlus_FILES = YTLitePlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
YTLitePlus_FRAMEWORKS = UIKit Security

YTLitePlus_INJECT_DYLIBS = Tweaks/YTLite/var/jb/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib
SUBPROJECTS = Tweaks/Alderis

ifeq ($(TWEAK_FLEX),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/libFLEX.dylib
SUBPROJECTS += Tweaks/FLEXing/libflex
endif
ifeq ($(TWEAK_ISPONSORBLOCK),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/iSponsorBlock.dylib
SUBPROJECTS += Tweaks/iSponsorBlock
endif
ifeq ($(TWEAK_YTUHD),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YTUHD.dylib
SUBPROJECTS += Tweaks/YTUHD
endif
ifeq ($(TWEAK_YOUPIP),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YouPiP.dylib
SUBPROJECTS += Tweaks/YouPiP
endif
ifeq ($(TWEAK_RETURN_YOUTUBE_DISLIKES),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YouTubeDislikesReturn.dylib
SUBPROJECTS += Tweaks/Return-YouTube-Dislikes
endif
ifeq ($(TWEAK_YTABCONFIG),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YTABConfig.dylib
SUBPROJECTS += Tweaks/YTABConfig
endif
ifeq ($(TWEAK_DONTEATMYCONTENT),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/DontEatMyContent.dylib
SUBPROJECTS += Tweaks/DontEatMyContent
endif
ifeq ($(TWEAK_YTHOLDFORSPEED),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YTHoldForSpeed.dylib
SUBPROJECTS += Tweaks/YTHoldForSpeed
endif
ifeq ($(TWEAK_YTVIDEOOVERLAY),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YTVideoOverlay.dylib
SUBPROJECTS += Tweaks/YTVideoOverlay
endif
ifeq ($(TWEAK_YOULOOP),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YouLoop.dylib
SUBPROJECTS += Tweaks/YouLoop
endif
ifeq ($(TWEAK_YOUMUTE),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YouMute.dylib
SUBPROJECTS += Tweaks/YouMute
endif
ifeq ($(TWEAK_YOUQUALITY),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YouQuality.dylib
SUBPROJECTS += Tweaks/YouQuality
endif
ifeq ($(TWEAK_YOUSPEED),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YouSpeed.dylib
SUBPROJECTS += Tweaks/YouSpeed
endif
ifeq ($(TWEAK_YOUTIMESTAMP),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YouTimeStamp.dylib
SUBPROJECTS += Tweaks/YouTimeStamp
endif
ifeq ($(TWEAK_YOUGROUPSETTINGS),1)
YTLitePlus_INJECT_DYLIBS += .theos/obj/YouGroupSettings.dylib
SUBPROJECTS += Tweaks/YouGroupSettings
endif

YTLitePlus_EMBED_LIBRARIES = $(THEOS_OBJ_DIR)/libcolorpicker.dylib
YTLitePlus_EMBED_FRAMEWORKS = $(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install_Alderis.xcarchive/Products/var/jb/Library/Frameworks/Alderis.framework
YTLitePlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-but-set-variable -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\"
YTLitePlus_EMBED_BUNDLES = $(wildcard Bundles/*.bundle)
YTLitePlus_EMBED_EXTENSIONS = $(wildcard Extensions/*.appex)
YTLitePlus_IPA = ./tmp/Payload/YouTube.app
YTLitePlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unsupported-availability-guard -Wno-unused-but-set-variable -DTWEAK_VERSION=$(PACKAGE_VERSION) $(EXTRA_CFLAGS)
YTLitePlus_USE_FISHHOOK = 0

include $(THEOS)/makefiles/common.mk
ifneq ($(JAILBROKEN),1)
include $(THEOS_MAKE_PATH)/aggregate.mk
endif
include $(THEOS_MAKE_PATH)/tweak.mk

FINALPACKAGE = 1
REMOVE_EXTENSIONS = 1
CODESIGN_IPA = 0

YTLITE_PATH = Tweaks/YTLite
YTLITE_VERSION := 5.0.1
YTLITE_DEB = $(YTLITE_PATH)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb
YTLITE_DYLIB = $(YTLITE_PATH)/var/jb/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib
YTLITE_BUNDLE = $(YTLITE_PATH)/var/jb/Library/Application\ Support/YTLite.bundle

internal-clean::
	@rm -rf $(YTLITE_PATH)/*

ifneq ($(JAILBROKEN),1)
before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
        	rm -rf $(YTLITE_PATH)/*; \
        	$(PRINT_FORMAT_BLUE) "Downloading YTLite"; \
	fi
before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
		curl -s -L "https://github.com/dayanch96/YTLite/releases/download/v$(YTLITE_VERSION)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb" -o $(YTLITE_DEB); \
	fi; \
	if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
		tar -xf $(YTLITE_DEB) -C $(YTLITE_PATH); tar -xf $(YTLITE_PATH)/data.tar* -C $(YTLITE_PATH); \
		if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
			$(PRINT_FORMAT_ERROR) "Failed to extract YTLite"; exit 1; \
		fi; \
	fi;
else
before-package::
	@mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support; cp -r lang/YTLitePlus.bundle $(THEOS_STAGING_DIR)/Library/Application\ Support/
endif