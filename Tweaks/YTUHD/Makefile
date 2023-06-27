TARGET := iphone:clang:latest:11.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = YouTube

EXTRA_CFLAGS =
ifeq ($(SIDELOADED),1)
EXTRA_CFLAGS += -DSIDELOADED
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTUHD
$(TWEAK_NAME)_FILES = Common.x Tweak.x Settings.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc $(EXTRA_CFLAGS)
$(TWEAK_NAME)_FRAMEWORKS = VideoToolbox

# SUBPROJECTS = YTUHD-AVD

include $(THEOS_MAKE_PATH)/tweak.mk
# include $(THEOS_MAKE_PATH)/aggregate.mk
