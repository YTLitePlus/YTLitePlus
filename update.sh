#!/bin/bash
# YTLitePlus Tweak Extraction Script v2
# This script creates a clean ytliteplus-tweak-only branch
# Now with automatic submodule cleanup!

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}  YTLitePlus Tweak Extraction Script v2${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo ""

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo -e "${RED}Error: Not in a git repository. Please run this from your YTLitePlus directory.${NC}"
    exit 1
fi

# Check if branch already exists
if git show-ref --verify --quiet refs/heads/ytliteplus-tweak-only; then
    echo -e "${YELLOW}Warning: Branch 'ytliteplus-tweak-only' already exists.${NC}"
    read -p "Do you want to delete it and create a new one? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -D ytliteplus-tweak-only
    else
        echo -e "${RED}Aborting.${NC}"
        exit 1
    fi
fi

# Ask which method to use
echo -e "${YELLOW}Choose extraction method:${NC}"
echo "  1) Clean branch (recommended) - Creates fresh branch with no history"
echo "  2) Filtered branch - Keeps git history but removes unwanted files"
read -p "Enter choice (1 or 2): " -n 1 -r
echo

case $REPLY in
    1)
        METHOD="clean"
        ;;
    2)
        METHOD="filtered"
        ;;
    *)
        echo -e "${RED}Invalid choice. Aborting.${NC}"
        exit 1
        ;;
esac

# Ask about Alderis
echo ""
echo -e "${YELLOW}Do you want to keep Alderis color picker framework?${NC}"
echo "  - Yes: Keep Alderis (adds dependency but richer UI)"
echo "  - No: Remove Alderis (simpler, standard color picker)"
read -p "Keep Alderis? (y/N): " -n 1 -r
echo
KEEP_ALDERIS=false
if [[ $REPLY =~ ^[Yy]$ ]]; then
    KEEP_ALDERIS=true
fi

# Save current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${BLUE}Current branch: $CURRENT_BRANCH${NC}"

# ============================================================
# Clean up submodule cache to prevent errors
# ============================================================
echo -e "${YELLOW}Cleaning up submodule cache...${NC}"
rm -rf .git/modules/Tweaks 2>/dev/null || true

# ============================================================
# METHOD 1: Clean Branch
# ============================================================
if [ "$METHOD" == "clean" ]; then
    echo -e "${GREEN}Creating clean orphan branch...${NC}"
    
    # Create orphan branch
    git checkout --orphan ytliteplus-tweak-only
    
    # Remove everything
    git rm -rf .
    
    # Restore YTLitePlus files
    echo -e "${BLUE}Restoring YTLitePlus files...${NC}"
    git checkout $CURRENT_BRANCH -- YTLitePlus.xm YTLitePlus.h
    git checkout $CURRENT_BRANCH -- Source/
    git checkout $CURRENT_BRANCH -- lang/
    git checkout $CURRENT_BRANCH -- LICENSE
    
    # Create directory structure
    mkdir -p Tweaks
    
    # Create Makefile based on Alderis choice
    echo -e "${BLUE}Creating Makefile...${NC}"
    if [ "$KEEP_ALDERIS" == true ]; then
        echo -e "${YELLOW}Creating Makefile with Alderis support...${NC}"
        cat > Makefile << 'EOF'
# YTLitePlus - Standalone Tweak Build Configuration
export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64 arm64e
export THEOS_PACKAGE_SCHEME = rootless

# Alderis color picker configuration
export Alderis_XCODEOPTS = LD_DYLIB_INSTALL_NAME=@rpath/Alderis.framework/Alderis
export Alderis_XCODEFLAGS = DYLIB_INSTALL_NAME_BASE=/Library/Frameworks BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS="$(ARCHS)"

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = YTLitePlus
PACKAGE_VERSION = 1.0.0

YTLitePlus_FILES = YTLitePlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
YTLitePlus_FRAMEWORKS = UIKit Security Foundation AVFoundation AVKit MediaPlayer MobileCoreServices UniformTypeIdentifiers
YTLitePlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-unsupported-availability-guard -Wno-vla-cxx-extension -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\" -I$(THEOS_PROJECT_DIR)/Tweaks
YTLitePlus_EMBED_FRAMEWORKS = $(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install_Alderis.xcarchive/Products/var/jb/Library/Frameworks/Alderis.framework

SUBPROJECTS += Tweaks/Alderis

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "mkdir -p /var/jb/Library/Application\ Support && cp -r /tmp/YTLitePlus.bundle /var/jb/Library/Application\ Support/" || true

before-package::
	@mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support
	@cp -r lang/YTLitePlus.bundle $(THEOS_STAGING_DIR)/Library/Application\ Support/
EOF
    else
        echo -e "${YELLOW}Creating Makefile without Alderis...${NC}"
        cat > Makefile << 'EOF'
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
EOF
    fi
    
    # Create .gitmodules
    echo -e "${BLUE}Creating .gitmodules...${NC}"
    cat > .gitmodules << 'EOF'
[submodule "Tweaks/YouTubeHeader"]
	path = Tweaks/YouTubeHeader
	url = https://github.com/PoomSmart/YouTubeHeader.git
EOF
    
    if [ "$KEEP_ALDERIS" == true ]; then
        cat >> .gitmodules << 'EOF'
[submodule "Tweaks/Alderis"]
	path = Tweaks/Alderis
	url = https://github.com/hbang/Alderis.git
EOF
    fi
    
    # Add submodules (with force to handle any caching issues)
    echo -e "${BLUE}Adding submodules...${NC}"
    git submodule add --force https://github.com/PoomSmart/YouTubeHeader.git Tweaks/YouTubeHeader
    if [ "$KEEP_ALDERIS" == true ]; then
        git submodule add --force https://github.com/hbang/Alderis.git Tweaks/Alderis
    fi
    
    # Create control file
    cat > control << 'EOF'
Package: com.ytliteplus.tweak
Name: YTLitePlus
Version: 5.0.0
Architecture: iphoneos-arm64
Description: YTLitePlus is a comprehensive YouTube tweak that enhances your viewing experience with custom themes, advanced settings, low contrast mode, and extensive customization options. Features include theme support, version spoofing, UI improvements, and localization in 15+ languages.
Homepage: https://github.com/YTLitePlus/YTLitePlus
Maintainer: YTLitePlus Team
Author: Balackburn, dayanch96, arichornloverALT, and contributors
Section: Tweaks
Depends: mobilesubstrate (>= 0.9.5000), firmware (>= 14.0)
Icon: https://raw.githubusercontent.com/YTLitePlus/Assets/main/Github/YTLitePlusColored-128.png
EOF

    # Create README
    cat > README.md << 'EOF'
# YTLitePlus Tweak

A standalone iOS tweak that enhances YouTube with custom themes, settings, and UI improvements.

## Features
- Custom themes and color schemes
- Low contrast mode
- Extensive settings customization
- Version spoofing support
- Localized in 15+ languages

## Building

### Prerequisites
- Theos installed
- iOS SDK
- Git with submodules support

### Build Steps
```bash
# Clone with submodules
git clone --recursive <your-repo-url>

# Or initialize submodules after cloning
git submodule update --init --recursive

# Build
make clean
make package
```

## Installation
1. Build the .deb package
2. Install via package manager (Sileo, Zebra, Cydia)
3. Respring or restart YouTube

## Dependencies
- YouTubeHeader (included as submodule)
- iOS 14.0 or later
- CydiaSubstrate/libhooker

## License
See LICENSE file.
EOF

# ============================================================
# METHOD 2: Filtered Branch
# ============================================================
else
    echo -e "${GREEN}Creating filtered branch...${NC}"
    
    # Create branch from current
    git checkout -b ytliteplus-tweak-only
    
    # Remove unwanted tweak directories
    echo -e "${BLUE}Removing other tweak directories...${NC}"
    git rm -rf Tweaks/YTLite 2>/dev/null || true
    git rm -rf Tweaks/YTUHD 2>/dev/null || true
    git rm -rf Tweaks/YouPiP 2>/dev/null || true
    git rm -rf Tweaks/YTVideoOverlay 2>/dev/null || true
    git rm -rf Tweaks/YouTimeStamp 2>/dev/null || true
    git rm -rf Tweaks/YouGroupSettings 2>/dev/null || true
    git rm -rf Tweaks/YTABConfig 2>/dev/null || true
    git rm -rf Tweaks/DontEatMyContent 2>/dev/null || true
    git rm -rf Tweaks/Return-YouTube-Dislikes 2>/dev/null || true
    git rm -rf Tweaks/FLEXing 2>/dev/null || true
    git rm -rf Tweaks/YTHeaders 2>/dev/null || true
    git rm -rf Tweaks/protobuf 2>/dev/null || true
    git rm -rf Extensions 2>/dev/null || true
    git rm -f build.sh 2>/dev/null || true
    
    # Remove or keep Alderis
    if [ "$KEEP_ALDERIS" == false ]; then
        echo -e "${YELLOW}Removing Alderis...${NC}"
        git rm -rf Tweaks/Alderis 2>/dev/null || true
    fi
    
    # Update .gitmodules
    echo -e "${BLUE}Updating .gitmodules...${NC}"
    cat > .gitmodules << 'EOF'
[submodule "Tweaks/YouTubeHeader"]
	path = Tweaks/YouTubeHeader
	url = https://github.com/PoomSmart/YouTubeHeader.git
EOF
    
    if [ "$KEEP_ALDERIS" == true ]; then
        cat >> .gitmodules << 'EOF'
[submodule "Tweaks/Alderis"]
	path = Tweaks/Alderis
	url = https://github.com/hbang/Alderis.git
EOF
    fi
    
    # Replace Makefile
    echo -e "${BLUE}Replacing Makefile...${NC}"
    if [ "$KEEP_ALDERIS" == true ]; then
        cat > Makefile << 'EOF'
# YTLitePlus - Standalone Tweak Build Configuration
export TARGET = iphone:clang:latest:14.0
export ARCHS = arm64 arm64e
export THEOS_PACKAGE_SCHEME = rootless

# Alderis color picker configuration
export Alderis_XCODEOPTS = LD_DYLIB_INSTALL_NAME=@rpath/Alderis.framework/Alderis
export Alderis_XCODEFLAGS = DYLIB_INSTALL_NAME_BASE=/Library/Frameworks BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS="$(ARCHS)"

INSTALL_TARGET_PROCESSES = YouTube
TWEAK_NAME = YTLitePlus
PACKAGE_VERSION = 1.0.0

YTLitePlus_FILES = YTLitePlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m')
YTLitePlus_FRAMEWORKS = UIKit Security Foundation AVFoundation AVKit MediaPlayer MobileCoreServices UniformTypeIdentifiers
YTLitePlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-unsupported-availability-guard -Wno-vla-cxx-extension -DTWEAK_VERSION=\"$(PACKAGE_VERSION)\" -I$(THEOS_PROJECT_DIR)/Tweaks
YTLitePlus_EMBED_FRAMEWORKS = $(_THEOS_LOCAL_DATA_DIR)/$(THEOS_OBJ_DIR_NAME)/install_Alderis.xcarchive/Products/var/jb/Library/Frameworks/Alderis.framework

SUBPROJECTS += Tweaks/Alderis

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "mkdir -p /var/jb/Library/Application\ Support && cp -r /tmp/YTLitePlus.bundle /var/jb/Library/Application\ Support/" || true

before-package::
	@mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support
	@cp -r lang/YTLitePlus.bundle $(THEOS_STAGING_DIR)/Library/Application\ Support/
EOF
    else
        cat > Makefile << 'EOF'
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
EOF
    fi
fi

# Stage all files
echo -e "${BLUE}Staging files...${NC}"
git add .

# Commit
echo -e "${BLUE}Creating commit...${NC}"
git commit -m "Extract YTLitePlus as standalone tweak

- Removed all other tweak integrations (YTLite, YTUHD, YouPiP, etc.)
- Cleaned Makefile to build only YTLitePlus
- Kept only required YouTubeHeader dependency$([ "$KEEP_ALDERIS" == true ] && echo ' and Alderis')
- Preserved localization bundle
- Updated README for standalone usage"

echo ""
echo -e "${GREEN}==================================================================${NC}"
echo -e "${GREEN}  Extraction Complete!${NC}"
echo -e "${GREEN}==================================================================${NC}"
echo ""
echo -e "${BLUE}Branch created: ytliteplus-tweak-only${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Initialize submodules:"
echo "     ${BLUE}git submodule update --init --recursive${NC}"
echo ""
echo "  2. Test build:"
echo "     ${BLUE}make clean && make${NC}"
echo ""
echo "  3. Verify package:"
echo "     ${BLUE}make package${NC}"
echo "     ${BLUE}dpkg -c packages/*.deb${NC}"
echo ""
echo "  4. Push to remote:"
echo "     ${BLUE}git push -u origin ytliteplus-tweak-only${NC}"
echo ""
echo -e "${YELLOW}To return to your original branch:${NC}"
echo "     ${BLUE}git checkout $CURRENT_BRANCH${NC}"
echo ""