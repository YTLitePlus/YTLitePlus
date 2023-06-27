TARGET = iphone:clang:15.5:13.0
ARCHS = arm64
FINALPACKAGE = 1
include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libcolorpicker

libcolorpicker_FILES = $(wildcard *.m)
libcolorpicker_PRIVATE_FRAMEWORKS = Preferences
libcolorpicker_EXTRA_FRAMEWORKS = Alderis
libcolorpicker_CFLAGS = -Wno-unguarded-availability -Wno-deprecated-declarations -fmodules

include $(THEOS_MAKE_PATH)/library.mk
