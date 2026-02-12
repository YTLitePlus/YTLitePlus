# YTLitePlus

A patched YouTube IPA with tweaks injected — built entirely from `config.yml`.

## How It Works

1. **`config.yml`** — single source of truth. Every tweak is an entry with a repo, fetch method, and enabled flag.
2. **`lib.sh`** — shared logic for fetching tweaks, patching the IPA, and applying customization.
3. **`build.sh`** — local build script. Sources `lib.sh`.
4. **`.github/workflows/build.yml`** — CI workflow. Same pipeline via `lib.sh`, outputs a GitHub Release.

## Quick Start (Local)

```bash
# Provide a decrypted YouTube IPA
./build.sh /path/to/YouTube.ipa

# Or pass a URL
./build.sh https://example.com/YouTube.ipa

# Or place a single .ipa in the project root and run:
./build.sh
```

Output: `YouTube-patched.ipa`

### Dependencies

- `curl`, `jq`, `python3` (with `pyyaml`), `unzip`, `zip`
- `optool` or `insert_dylib` (for dylib injection)
- `make` + Theos (only if any tweak has `fetch: build`)

## How to Add a Tweak

Add an entry to `config.yml`:

```yaml
tweaks:
  - id: my_new_tweak
    enabled: true
    repo: owner/RepoName
    fetch: release        # or "build" for source-build tweaks
```

That's it. No other files need to change.

## CI (GitHub Actions)

Trigger the **Build YTLitePlus (v2)** workflow manually:

- Provide a YouTube IPA URL as input, or set the `IPA_URL` repository secret.
- A draft release with the patched IPA is created automatically.

## Included Tweaks

| Tweak | Repo | Enabled |
|-------|------|---------|
| YTLite | dayanch96/YTLite | ✅ |
| YouPiP | PoomSmart/YouPiP | ✅ |
| YTUHD | splaser/YTUHD | ✅ |
| YTABConfig | PoomSmart/YTABConfig | ✅ |
| Return YouTube Dislikes | PoomSmart/Return-YouTube-Dislikes | ✅ |
| DontEatMyContent | therealFoxster/DontEatMyContent | ✅ |
| YTVideoOverlay | PoomSmart/YTVideoOverlay | ✅ |
| YouGroupSettings | PoomSmart/YouGroupSettings | ✅ |
| Alderis | hbang/Alderis | ✅ |
| FLEXing | PoomSmart/FLEXing | ❌ |
| YouTimeStamp | aricloverALT/YouTimeStamp | ❌ |
| YTHeaders | therealFoxster/YTHeaders | ❌ |
| OpenYouTubeSafari | BillyCurtis/OpenYouTubeSafariExtension | ❌ |

## License

See [LICENSE](LICENSE).
