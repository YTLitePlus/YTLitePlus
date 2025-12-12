# ExampleFeature (template tweak)

This is a minimal Theos tweak template showing how to add a small Logos hook.

How to build (macOS + Theos):

1. Ensure `THEOS` is set and you have the matching `iPhoneOS<SDK>.sdk` installed.
2. From repo root:

```bash
cd main
# adjust Makefile vars as CI does (optional)
make package THEOS=/path/to/theos THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1
```

Notes:
- The tweak hooks `UIApplication` as a trivial example. Replace with target classes needed.
- If this tweak should produce an `.appex` place the built appex in `Extensions/` for CI copying.

Sample `control` (packaging)

You can include a Debian `control` file in the project root so Theos packaging will pick up metadata. Example (already included as `control`):

```
Package: ytlite-examplefeature
Name: ExampleFeature
Section: tweaks
Priority: optional
Architecture: iphoneos-arm
Version: 1.0-1
Maintainer: YTLitePlus Contributors <noreply@example.com>
Depends: mobilesubstrate
Description: ExampleFeature — minimal Theos tweak for YTLitePlus
 A trivial example tweak that logs on app launch.
```

Building a bundle / .appex (Theos `bundle.mk`)

To produce a bundle (which you can rename to `.appex` or adapt for an extension), change your Makefile to use `bundle.mk` instead of `tweak.mk`. Minimal snippet:

```makefile
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ExampleFeature
ExampleFeature_FILES = Tweak.xm
ExampleFeature_FRAMEWORKS = UIKit

# Optional: tell Theos to use a different extension (if supported)
# BUNDLE_EXTENSION = appex

include $(THEOS_MAKE_PATH)/bundle.mk
```

After building, copy the produced bundle into `Extensions/` (rename `YourBundle.appex` if necessary) so the CI step `cp -R main/Extensions/*.appex main/tmp/Payload/YouTube.app/PlugIns` will include it inside the app.

Pre-built Makefile variant

This repo includes a `Makefile.bundle` you can use directly to build a bundle/appex variant of this tweak. Two ways to use it locally (macOS + Theos):

1) Run make with an explicit makefile:

```bash
cd Tweaks/ExampleFeature
make -f Makefile.bundle package THEOS=/path/to/theos
```

2) Or copy it into place and run normally:

```bash
cd Tweaks/ExampleFeature
cp Makefile.bundle Makefile
make package THEOS=/path/to/theos
```

After building, copy the produced bundle into `Extensions/` so CI includes it in the final IPA.
