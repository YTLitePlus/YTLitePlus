# YTLitePlus - Standalone Tweak Build Configuration
export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64 arm64e
export THEOS_PACKAGE_SCHEME = rootless

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = YTLitePlus
PACKAGE_VERSION = 1.0.0

YTLitePlus_FILES = YTLitePlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
YTLitePlus_FRAMEWORKS = UIKit Security Foundation AVFoundation AVKit MediaPlayer MobileCoreServices UniformTypeIdentifiers
YTLitePlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-unsupported-availability-guard -Wno-vla-cxx-extension -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\" -I$(THEOS_PROJECT_DIR)/Tweaks

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "mkdir -p /var/jb/Library/Application\ Support && cp -r /tmp/YTLitePlus.bundle /var/jb/Library/Application\ Support/" || true

before-package::
	@mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support
	@cp -r lang/YTLitePlus.bundle $(THEOS_STAGING_DIR)/Library/Application\ Support/
