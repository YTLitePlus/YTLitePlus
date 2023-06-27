TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DontEatMyContent

DontEatMyContent_FILES = Tweak.x Settings.x
DontEatMyContent_CFLAGS = -fobjc-arc
DontEatMyContent_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
