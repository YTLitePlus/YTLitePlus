# Copilot / AI agent instructions — YTLitePlus

Purpose
- Short, actionable guidance to help an AI agent be productive in this repository.

Big picture
- This repo produces a modified YouTube iPA by combining: original YouTube app contents + Theos-built tweaks/bundles and `Extensions/*.appex`.
- Sources of behavior: `Source/*.xm` (Logos/Objective-C hooks), `Tweaks/*` (tweak modules), `Bundles/` and `Extensions/` (runtime bundles and app extensions).
- Packaging/build pipeline: The GitHub Action `.github/workflows/buildapp.yml` downloads a decrypted YouTube ipa, strips signatures, copies `Extensions/*.appex` into the app, adjusts `Info.plist`, then builds a rootless package via Theos (`make package` → `main/packages/*.ipa`).

Where to look first
- Core hooking code: `Source/` (examples: `Settings.xm`, `LowContrastMode.xm`, `Themes.xm`).
- Per-feature tweaks: `Tweaks/` subfolders mirror features and Theos projects.
- UI/localization: `lang/YTLitePlus.bundle/*/Localizable.strings` and `Bundles/`.
- Packaging & CI: `Makefile`, `build.sh`, and `.github/workflows/buildapp.yml`.

Build & release (practical steps)
- CI reproduces these steps. For local development on macOS with Theos:
  - Ensure Theos + iPhoneOS SDK are available (same SDK used in CI).
  - In repo root run edits, then `cd main && make package THEOS=/path/to/theos THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1`.
  - The CI updates `Makefile` lines (BUNDLE_ID, DISPLAY_NAME, PACKAGE_VERSION, TARGET, SDK_PATH) before building — follow the same sed replacements when scripting.
- Quick check: built IPA is at `main/packages/*.ipa`; CI renames to `YTLitePlus_${YT_VERSION}_5.0.1.ipa`.

Patterns & conventions
- Versioning: `PACKAGE_VERSION` is derived from the YouTube ipa `CFBundleVersion` (workflow writes `YT_VERSION`) and appended with a repo-specific suffix (`-5.0.1` in CI).
- Logos/.xm usage: prefer hooks in `Source/*.xm`. New features go in `Tweaks/<feature>` when they require a separate Theos target.
- Extensions: place .appex files in `Extensions/`. The workflow copies `Extensions/*.appex` into the unpacked YouTube.app/PlugIns before packaging.
- Rootless packaging: packages are built with `THEOS_PACKAGE_SCHEME=rootless` and `FINALPACKAGE=1`.

Integrations & external dependencies
- Theos: fetched from `theos/theos` and `qnblackcat/theos-jailed` in CI.
- SDKs: pulled from `aricloverALT/sdks` by workflow (iPhoneOS<version>.sdk).
- Tools required in CI: `ldid`, `dpkg`, `make` (installed via Homebrew in CI).
- Upload/dispatch: CI uploads to Catbox (`catbox.moe`) and dispatches an AltStore update (`Balackburn/YTLitePlusAltstore`).

Code edit checklist for agents
- When changing runtime behavior, update `Source/*.xm` (or add a `Tweaks/*` project) and run a local `make package` to validate packaging.
- If adding UI text, update `lang/YTLitePlus.bundle/*/Localizable.strings`.
- If adding an extension, place `.appex` in `Extensions/` and confirm the CI copies it to the app PlugIns.
- If changing packaging or bundle IDs, mimic the sed replacements in `.github/workflows/buildapp.yml` (BUNDLE_ID / DISPLAY_NAME / PACKAGE_VERSION / SDK_PATH).

Notes & gotchas
- CI extracts `YT_VERSION` from the provided YouTube ipa and hardcodes a repo `YTLITE_VERSION` in the workflow — when bumping plugin core, update `.github/workflows/buildapp.yml` and `main/.github/RELEASE_TEMPLATE/Release.md`.
- A small Python snippet in CI modifies `Info.plist` (removes `UISupportedDevices`) — agents modifying plist logic should mirror that behavior.
- No automated unit tests in repo; validate changes by building and inspecting the resulting IPA.

If something is unclear or a task needs extra privileges (e.g., access to secrets or a macOS Theos environment), ask the human maintainer. After edits, run a local `make package` and provide the built IPA path for verification.

— End of file

Examples — common edit tasks
- Edit an existing hook in `Source/` (fast path)
  - Change behavior: modify or add a Logos file under `Source/` (e.g. `Settings.xm` or `Themes.xm`).
  - Build locally (macOS with Theos + SDK):
    - Ensure Theos and the matching `iPhoneOS<SDK>.sdk` are installed and `THEOS` env is set.
    - From repo root run:
      - `cd main`
      - `sed -i '' "s/^PACKAGE_VERSION.*$/PACKAGE_VERSION = $YT_VERSION-5.0.1/" Makefile` (or edit manually)
      - `make package THEOS=/path/to/theos THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1`
  - Result: built IPA in `main/packages/` (CI renames to `YTLitePlus_${YT_VERSION}_5.0.1.ipa`).

- Add a new standalone tweak (Theos project)
  - Create `Tweaks/YourFeature/` with the usual Theos layout (`Makefile`, `Tweak.xm`, `control`, etc.). See existing `Tweaks/YouSpeed/` for an example layout.
  - Add any localized strings under `lang/YTLitePlus.bundle/<locale>.lproj/Localizable.strings` if UI text is added.
  - If the tweak produces a bundle/appex, place the `.appex` in `Extensions/` so CI copies it into the `.app` PlugIns during packaging.
  - Build & test: run the same `make package` step above; verify the new tweak's files are present inside the unpacked app (look under `main/tmp/Payload/YouTube.app/PlugIns` after running the unpack step in CI or reproducing it locally).

Feedback
- If you'd like, I can add one or two concrete small examples (a trivial `Tweak.xm` and Makefile) to `Tweaks/ExampleFeature/` to serve as a template. Which example do you prefer?
