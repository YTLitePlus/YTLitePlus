TARGET := iphone:clang:15.5:14.0
INSTALL_TARGET_PROCESSES = YouTube

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ytholdforspeed

ytholdforspeed_FILES = YTHFSTweak.x YTHFSSettings.x YTHFSPrefsManager.m
ytholdforspeed_CFLAGS = -fobjc-arc

THEOS_PACKAGE_BASE_VERSION = 1.0.3
_THEOS_INTERNAL_PACKAGE_VERSION = 1.0.3

include $(THEOS_MAKE_PATH)/tweak.mk
