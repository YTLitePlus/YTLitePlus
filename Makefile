TARGET = iphone:clang:16.5:15.0
YTLitePlus_USE_FISHHOOK = 0
ARCHS = arm64
MODULES = jailed
FINALPACKAGE = 1
CODESIGN_IPA = 0
PACKAGE_VERSION = X.X.X-X.X

TWEAK_NAME = YTLitePlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

# Setup variables for YTLite download and install
YTLITE_PATH = Tweaks/YTLite
# Grab the YTLite version from the releases page on GitHub
YTLITE_VERSION := $(shell wget -qO- "https://github.com/dayanch96/YTLite/releases/latest" | grep -o -E '/tag/v[^"]+' | head -n 1 | sed 's/\/tag\/v//')
YTLITE_DEB = $(YTLITE_PATH)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb
YTLITE_DYLIB = $(YTLITE_PATH)/var/jb/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib
YTLITE_BUNDLE = $(YTLITE_PATH)/var/jb/Library/Application\ Support/YTLite.bundle

# Todo figure out the purpose of this
EXTRA_CFLAGS := $(addprefix -I,$(shell find Tweaks/FLEX -name '*.h' -exec dirname {} \;)) -I$(THEOS_PROJECT_DIR)/Tweaks

# Allow YouTubeHeader to be accessible using #include <...>
export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks

$(TWEAK_NAME)_INJECT_DYLIBS = $(YTLITE_DYLIB) $(THEOS_OBJ_DIR)/libcolorpicker.dylib $(THEOS_OBJ_DIR)/iSponsorBlock.dylib $(THEOS_OBJ_DIR)/YTUHD.dylib $(THEOS_OBJ_DIR)/YouPiP.dylib $(THEOS_OBJ_DIR)/YouTubeDislikesReturn.dylib $(THEOS_OBJ_DIR)/YTABConfig.dylib $(THEOS_OBJ_DIR)/YouMute.dylib $(THEOS_OBJ_DIR)/DontEatMyContent.dylib $(THEOS_OBJ_DIR)/YTHoldForSpeed.dylib $(THEOS_OBJ_DIR)/YTVideoOverlay.dylib $(THEOS_OBJ_DIR)/YouGroupSettings.dylib $(THEOS_OBJ_DIR)/YouQuality.dylib
$(TWEAK_NAME)_FILES = YTLitePlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m') $(shell find Tweaks/FLEX -type f \( -iname \*.c -o -iname \*.m -o -iname \*.mm \))
$(TWEAK_NAME)_IPA = ./tmp/Payload/YouTube.app
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unsupported-availability-guard -Wno-unused-but-set-variable -DTWEAK_VERSION=$(PACKAGE_VERSION) $(EXTRA_CFLAGS)
$(TWEAK_NAME)_FRAMEWORKS = UIKit Security

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Tweaks/Alderis Tweaks/iSponsorBlock Tweaks/YTUHD Tweaks/YouPiP Tweaks/Return-YouTube-Dislikes Tweaks/YTABConfig Tweaks/YouMute Tweaks/DontEatMyContent Tweaks/YTHoldForSpeed Tweaks/YTVideoOverlay Tweaks/YouQuality Tweaks/YouGroupSettings
include $(THEOS_MAKE_PATH)/aggregate.mk

# Embed bundles and extensions
$(TWEAK_NAME)_BUNDLE_RESOURCE_DIRS = $(wildcard Tweaks/*/var/jb/Library/Application\ Support/*.bundle) $(wildcard Tweaks/*/layout/Library/Application\ Support/*.bundle)


before-package::
	@echo -e "==> \033[1mMoving tweak's bundle to Resources/...\033[0m"
	@mkdir -p Resources/Frameworks/Alderis.framework && find $(THEOS_OBJ_DIR)/install/Library/Frameworks/Alderis.framework -maxdepth 1 -type f -exec cp {} Resources/Frameworks/Alderis.framework/ \;	
	@cp -R Tweaks/YTLite/var/jb/Library/Application\ Support/YTLite.bundle Resources/
	@cp -R lang/YTLitePlus.bundle Resources/
	@echo -e "==> \033[1mChanging the installation path of dylibs...\033[0m"
	@ldid -r .theos/obj/iSponsorBlock.dylib && install_name_tool -change /usr/lib/libcolorpicker.dylib @rpath/libcolorpicker.dylib .theos/obj/iSponsorBlock.dylib
	@codesign --remove-signature $(THEOS_OBJ_DIR)/libcolorpicker.dylib && install_name_tool -change /Library/Frameworks/Alderis.framework/Alderis @rpath/Alderis.framework/Alderis $(THEOS_OBJ_DIR)/libcolorpicker.dylib

internal-clean::
	@rm -rf $(YTLITE_PATH)/*

before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
		rm -rf $(YTLITE_PATH)/*; \
		$(PRINT_FORMAT_BLUE) "Downloading YTLite"; \
		echo "YTLITE_VERSION: $(YTLITE_VERSION)"; \
		curl -s -L "https://github.com/dayanch96/YTLite/releases/download/v$(YTLITE_VERSION)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb" -o $(YTLITE_DEB); \
		tar -xf $(YTLITE_DEB) -C $(YTLITE_PATH); tar -xf $(YTLITE_PATH)/data.tar* -C $(YTLITE_PATH); \
		if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
			$(PRINT_FORMAT_ERROR) "Failed to extract YTLite"; exit 1; \
		fi; \
	fi
