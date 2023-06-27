TARGET = iphone:clang:latest:11.0
ARCHS = arm64
PACKAGE_VERSION = 1.7.19-2
MIN_YOUTUBE_VERSION = 15.10.4

EXTRA_CFLAGS = -DMIN_YOUTUBE_VERSION=$(MIN_YOUTUBE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouPiP
$(TWEAK_NAME)_FILES = Tweak.x Settings.x LegacyPiPCompat.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc $(EXTRA_CFLAGS)
$(TWEAK_NAME)_FRAMEWORKS = AVFoundation AVKit UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
