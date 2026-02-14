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
