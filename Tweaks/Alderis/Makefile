export TARGET = iphone:latest:14.0

FRAMEWORK_OUTPUT_DIR = $(THEOS_OBJ_DIR)/xcode_derived/install/Library/Frameworks
ALDERIS_SDK_DIR = $(THEOS_OBJ_DIR)/alderis_sdk_$(THEOS_PACKAGE_BASE_VERSION)

export ADDITIONAL_CFLAGS = -fobjc-arc -Wextra -Wno-unused-parameter -F$(FRAMEWORK_OUTPUT_DIR)
export ADDITIONAL_LDFLAGS = -F$(FRAMEWORK_OUTPUT_DIR)

INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = Alderis

FINALPACKAGE = 1

Alderis_XCODEFLAGS = DYLIB_INSTALL_NAME_BASE=/Library/Frameworks BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS="$(ARCHS)" -quiet

SUBPROJECTS = lcpshim

include $(THEOS_MAKE_PATH)/xcodeproj.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

