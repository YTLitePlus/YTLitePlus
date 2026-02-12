#!/usr/bin/env bash
# lib.sh — Shared core logic for YTLitePlus build system
# Used by both build.sh (local) and the GitHub Actions workflow.
# All tweak fetching, IPA patching, and customization logic lives here.

set -euo pipefail

###############################################################################
# Globals
###############################################################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.yml"
WORK_DIR="${SCRIPT_DIR}/_work"
TWEAKS_DIR="${WORK_DIR}/tweaks"
DYLIBS_DIR="${WORK_DIR}/dylibs"
FRAMEWORKS_DIR="${WORK_DIR}/frameworks"
PAYLOAD_DIR="${WORK_DIR}/payload"

###############################################################################
# Colour helpers (no-op when stdout is not a terminal)
###############################################################################
if [ -t 1 ]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'
  YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
else
  RED=''; GREEN=''; BLUE=''; YELLOW=''; BOLD=''; NC=''
fi

log_info()  { echo -e "${BLUE}==> ${BOLD}$*${NC}"; }
log_ok()    { echo -e "${GREEN}✔  $*${NC}"; }
log_warn()  { echo -e "${YELLOW}⚠  $*${NC}"; }
log_error() { echo -e "${RED}❌ $*${NC}"; }
die()       { log_error "$@"; exit 1; }

###############################################################################
# YAML parsing via Python (works on macOS + Linux without extra deps)
###############################################################################
# Returns the number of enabled tweaks
config_tweak_count() {
  python3 -c "
import yaml, sys
with open('${CONFIG_FILE}') as f:
    cfg = yaml.safe_load(f)
print(sum(1 for t in cfg.get('tweaks', []) if t.get('enabled', False)))
"
}

# Returns a JSON array of enabled tweaks (consumed by bash via jq)
config_enabled_tweaks_json() {
  python3 -c "
import yaml, json, sys
with open('${CONFIG_FILE}') as f:
    cfg = yaml.safe_load(f)
enabled = [t for t in cfg.get('tweaks', []) if t.get('enabled', False)]
print(json.dumps(enabled))
"
}

# Returns a single customization value by key
config_custom() {
  local key="$1"
  python3 -c "
import yaml, sys
with open('${CONFIG_FILE}') as f:
    cfg = yaml.safe_load(f)
val = cfg.get('customization', {}).get('${key}', '')
print(val if val is not None else '')
"
}

###############################################################################
# Dependency checks
###############################################################################
check_deps() {
  local missing=()
  for cmd in curl jq python3 unzip zip; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done

  # We need either insert_dylib or optool for dylib injection
  if ! command -v insert_dylib &>/dev/null && ! command -v optool &>/dev/null; then
    missing+=("insert_dylib or optool")
  fi

  # Check if any tweak needs building (fetch: build)
  local needs_build
  needs_build=$(python3 -c "
import yaml
with open('${CONFIG_FILE}') as f:
    cfg = yaml.safe_load(f)
print('yes' if any(t.get('fetch') == 'build' and t.get('enabled', False) for t in cfg.get('tweaks', [])) else 'no')
")
  if [ "$needs_build" = "yes" ]; then
    command -v make &>/dev/null || missing+=("make")
    if [ -z "${THEOS:-}" ]; then
      log_warn "THEOS env var not set — source-build tweaks may fail"
    fi
  fi

  # python3 needs pyyaml
  python3 -c "import yaml" 2>/dev/null || missing+=("python3-yaml (pip install pyyaml)")

  if [ ${#missing[@]} -gt 0 ]; then
    die "Missing dependencies: ${missing[*]}"
  fi
  log_ok "All dependencies satisfied"
}

###############################################################################
# Workspace setup / teardown
###############################################################################
prepare_workspace() {
  rm -rf "${WORK_DIR}"
  mkdir -p "${TWEAKS_DIR}" "${DYLIBS_DIR}" "${FRAMEWORKS_DIR}" "${PAYLOAD_DIR}"
  log_ok "Workspace prepared at ${WORK_DIR}"
}

cleanup_workspace() {
  rm -rf "${WORK_DIR}"
}

###############################################################################
# IPA extraction
###############################################################################
# $1 = path or URL to the decrypted YouTube IPA
extract_ipa() {
  local ipa_source="$1"
  local ipa_path="${WORK_DIR}/YouTube.ipa"

  if [[ "$ipa_source" == http* ]]; then
    log_info "Downloading IPA from URL…"
    curl -fSL "$ipa_source" -o "$ipa_path" || die "Failed to download IPA"
  else
    [ -f "$ipa_source" ] || die "IPA file not found: $ipa_source"
    cp "$ipa_source" "$ipa_path"
  fi

  log_info "Extracting IPA…"
  unzip -q "$ipa_path" -d "${PAYLOAD_DIR}" || die "Failed to unzip IPA"

  # Locate YouTube.app inside Payload
  APP_DIR=$(find "${PAYLOAD_DIR}/Payload" -maxdepth 1 -name "*.app" -type d | head -n 1)
  [ -d "$APP_DIR" ] || die "No .app found inside IPA"
  log_ok "Extracted $(basename "$APP_DIR")"
}

###############################################################################
# Tweak fetching — release mode
###############################################################################
# Picks the best asset from a GitHub release.
# Priority: .dylib > .deb > .framework.zip > .zip
# $1 = repo (owner/name), $2 = tweak id, $3 = "always" flag (optional)
fetch_release_tweak() {
  local repo="$1" tweak_id="$2"
  local api_url="https://api.github.com/repos/${repo}/releases/latest"
  local tweak_dir="${TWEAKS_DIR}/${tweak_id}"
  mkdir -p "$tweak_dir"

  log_info "Fetching latest release for ${repo}…"

  local release_json
  release_json=$(curl -fsSL "$api_url") || die "GitHub API request failed for ${repo}"

  # Build a priority-ordered list of candidate asset URLs
  local dylib_url deb_url framework_url zip_url chosen_url chosen_name

  # Parse assets with jq — pick first match per category
  dylib_url=$(echo "$release_json" | jq -r '[.assets[] | select(.name | test("\\.dylib$"; "i"))][0].browser_download_url // empty')
  deb_url=$(echo "$release_json" | jq -r '[.assets[] | select(.name | test("\\.deb$"; "i"))][0].browser_download_url // empty')
  framework_url=$(echo "$release_json" | jq -r '[.assets[] | select(.name | test("\\.framework\\.zip$"; "i"))][0].browser_download_url // empty')
  zip_url=$(echo "$release_json" | jq -r '[.assets[] | select(.name | test("\\.zip$"; "i")) | select(.name | test("\\.framework\\.zip$"; "i") | not)][0].browser_download_url // empty')

  if [ -n "$dylib_url" ]; then
    chosen_url="$dylib_url"
  elif [ -n "$deb_url" ]; then
    chosen_url="$deb_url"
  elif [ -n "$framework_url" ]; then
    chosen_url="$framework_url"
  elif [ -n "$zip_url" ]; then
    chosen_url="$zip_url"
  else
    die "No usable asset found in latest release of ${repo}"
  fi

  chosen_name=$(basename "$chosen_url")
  log_info "  → Downloading ${chosen_name}"
  curl -fSL "$chosen_url" -o "${tweak_dir}/${chosen_name}" || die "Failed to download ${chosen_name}"

  # Extract the injectable artefact
  extract_tweak_artifact "${tweak_dir}" "${chosen_name}" "${tweak_id}"
}

###############################################################################
# Tweak fetching — build mode
###############################################################################
# $1 = repo, $2 = tweak id, $3 = branch (optional), $4 = build_cmd (optional)
fetch_build_tweak() {
  local repo="$1" tweak_id="$2" branch="${3:-}" build_cmd="${4:-make package}"
  local clone_dir="${TWEAKS_DIR}/${tweak_id}/src"

  log_info "Building ${tweak_id} from source (${repo})…"

  local clone_args=("--depth=1")
  [ -n "$branch" ] && clone_args+=("--branch" "$branch")

  git clone "${clone_args[@]}" "https://github.com/${repo}.git" "$clone_dir" \
    || die "Failed to clone ${repo}"

  (
    cd "$clone_dir"
    eval "$build_cmd"
  ) || die "Build failed for ${tweak_id}"

  # Search for output .dylib or .deb in the build tree
  local found_dylib found_deb
  found_dylib=$(find "$clone_dir" -name "*.dylib" -type f | head -n 1)
  found_deb=$(find "$clone_dir/packages" -name "*.deb" -type f 2>/dev/null | head -n 1)

  if [ -n "$found_dylib" ]; then
    cp "$found_dylib" "${DYLIBS_DIR}/${tweak_id}.dylib"
    log_ok "  → Built dylib: ${tweak_id}.dylib"
  elif [ -n "$found_deb" ]; then
    extract_dylib_from_deb "$found_deb" "$tweak_id"
  else
    die "No .dylib or .deb output found after building ${tweak_id}"
  fi
}

###############################################################################
# Artifact extraction helpers
###############################################################################
# Inspects a downloaded file and places the final .dylib / .framework into
# the appropriate output directory.
extract_tweak_artifact() {
  local dir="$1" filename="$2" tweak_id="$3"
  local filepath="${dir}/${filename}"

  case "$filename" in
    *.dylib)
      cp "$filepath" "${DYLIBS_DIR}/${tweak_id}.dylib"
      log_ok "  → Ready: ${tweak_id}.dylib"
      ;;
    *.deb)
      extract_dylib_from_deb "$filepath" "$tweak_id"
      ;;
    *.framework.zip)
      extract_framework_from_zip "$filepath" "$tweak_id"
      ;;
    *.zip)
      extract_from_zip "$filepath" "$tweak_id"
      ;;
    *)
      die "Unsupported asset type: ${filename}"
      ;;
  esac
}

# Extract .dylib from a .deb package
# Deb structure: data.tar.* contains the actual files
extract_dylib_from_deb() {
  local deb_path="$1" tweak_id="$2"
  local extract_dir="${TWEAKS_DIR}/${tweak_id}/deb_extract"
  mkdir -p "$extract_dir"

  log_info "  → Extracting .deb for ${tweak_id}…"

  # ar extracts the deb; data.tar.* contains the payload
  local ar_output
  if ! ar_output=$(cd "$extract_dir" && ar -x "$deb_path" 2>&1); then
    log_warn "ar extraction failed (${ar_output}), trying tar fallback…"
    tar -xf "$deb_path" -C "$extract_dir" || die "Cannot extract deb: $deb_path"
  fi

  # Extract data.tar.* (could be .gz, .xz, .lzma, .zst, or uncompressed)
  local data_tar
  data_tar=$(find "$extract_dir" -name "data.tar*" -type f | head -n 1)
  [ -n "$data_tar" ] || die "No data.tar found in deb for ${tweak_id}"
  tar -xf "$data_tar" -C "$extract_dir" 2>/dev/null || die "Failed to extract data.tar for ${tweak_id}"

  # Look for .dylib files
  local dylib
  dylib=$(find "$extract_dir" -name "*.dylib" -type f | head -n 1)
  if [ -n "$dylib" ]; then
    cp "$dylib" "${DYLIBS_DIR}/${tweak_id}.dylib"
    log_ok "  → Extracted dylib: ${tweak_id}.dylib"
  else
    # Look for .framework instead
    local fw
    fw=$(find "$extract_dir" -name "*.framework" -type d | head -n 1)
    if [ -n "$fw" ]; then
      cp -R "$fw" "${FRAMEWORKS_DIR}/"
      log_ok "  → Extracted framework: $(basename "$fw")"
    else
      die "No .dylib or .framework found in deb for ${tweak_id}"
    fi
  fi

  # Also look for .bundle resources (some tweaks ship localization bundles)
  local bundle
  bundle=$(find "$extract_dir" -name "*.bundle" -type d | head -n 1)
  if [ -n "$bundle" ]; then
    mkdir -p "${WORK_DIR}/bundles_extra"
    cp -R "$bundle" "${WORK_DIR}/bundles_extra/"
    log_ok "  → Extracted bundle: $(basename "$bundle")"
  fi
}

# Extract .framework from a zip
extract_framework_from_zip() {
  local zip_path="$1" tweak_id="$2"
  local extract_dir="${TWEAKS_DIR}/${tweak_id}/fw_extract"
  mkdir -p "$extract_dir"

  unzip -qo "$zip_path" -d "$extract_dir" || die "Failed to unzip framework for ${tweak_id}"

  local fw
  fw=$(find "$extract_dir" -name "*.framework" -type d | head -n 1)
  [ -n "$fw" ] || die "No .framework found in zip for ${tweak_id}"

  cp -R "$fw" "${FRAMEWORKS_DIR}/"
  log_ok "  → Extracted framework: $(basename "$fw")"
}

# Generic zip extraction — look for .dylib, .framework, etc.
extract_from_zip() {
  local zip_path="$1" tweak_id="$2"
  local extract_dir="${TWEAKS_DIR}/${tweak_id}/zip_extract"
  mkdir -p "$extract_dir"

  unzip -qo "$zip_path" -d "$extract_dir" || die "Failed to unzip for ${tweak_id}"

  # Try .dylib first, then .framework
  local dylib
  dylib=$(find "$extract_dir" -name "*.dylib" -type f | head -n 1)
  if [ -n "$dylib" ]; then
    cp "$dylib" "${DYLIBS_DIR}/${tweak_id}.dylib"
    log_ok "  → Extracted dylib from zip: ${tweak_id}.dylib"
    return
  fi

  local fw
  fw=$(find "$extract_dir" -name "*.framework" -type d | head -n 1)
  if [ -n "$fw" ]; then
    cp -R "$fw" "${FRAMEWORKS_DIR}/"
    log_ok "  → Extracted framework from zip: $(basename "$fw")"
    return
  fi

  die "No usable artifact found in zip for ${tweak_id}"
}

###############################################################################
# Fetch all enabled tweaks
###############################################################################
fetch_all_tweaks() {
  local tweaks_json
  tweaks_json=$(config_enabled_tweaks_json)
  local count
  count=$(echo "$tweaks_json" | jq 'length')

  log_info "Fetching ${count} enabled tweak(s)…"

  for i in $(seq 0 $((count - 1))); do
    local tweak
    tweak=$(echo "$tweaks_json" | jq -r ".[$i]")

    local id repo fetch_method branch build_cmd
    id=$(echo "$tweak" | jq -r '.id')
    repo=$(echo "$tweak" | jq -r '.repo')
    fetch_method=$(echo "$tweak" | jq -r '.fetch')
    branch=$(echo "$tweak" | jq -r '.branch // empty')
    build_cmd=$(echo "$tweak" | jq -r '.build_cmd // empty')

    case "$fetch_method" in
      release)
        fetch_release_tweak "$repo" "$id"
        ;;
      build)
        fetch_build_tweak "$repo" "$id" "$branch" "$build_cmd"
        ;;
      *)
        die "Unknown fetch method '${fetch_method}' for tweak ${id}"
        ;;
    esac
  done

  log_ok "All tweaks fetched"
}

###############################################################################
# IPA patching — inject dylibs & frameworks
###############################################################################
inject_tweaks() {
  [ -d "$APP_DIR" ] || die "APP_DIR not set — call extract_ipa first"

  local injector=""
  if command -v optool &>/dev/null; then
    injector="optool"
  elif command -v insert_dylib &>/dev/null; then
    injector="insert_dylib"
  else
    die "Neither optool nor insert_dylib found"
  fi

  # Determine the main executable name from Info.plist
  local executable
  executable=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "${APP_DIR}/Info.plist" 2>/dev/null \
    || python3 -c "
import plistlib
with open('${APP_DIR}/Info.plist', 'rb') as f:
    print(plistlib.load(f)['CFBundleExecutable'])
")

  local exec_path="${APP_DIR}/${executable}"
  [ -f "$exec_path" ] || die "Executable not found: ${exec_path}"

  # Create Frameworks directory inside the app if needed
  mkdir -p "${APP_DIR}/Frameworks"

  # Inject each .dylib
  local dylib_count=0
  for dylib in "${DYLIBS_DIR}"/*.dylib; do
    [ -f "$dylib" ] || continue
    local dylib_name
    dylib_name=$(basename "$dylib")

    log_info "Injecting ${dylib_name}…"
    cp "$dylib" "${APP_DIR}/Frameworks/${dylib_name}"

    case "$injector" in
      optool)
        optool install -c load -p "@rpath/${dylib_name}" -t "$exec_path" \
          || die "optool injection failed for ${dylib_name}"
        ;;
      insert_dylib)
        insert_dylib --inplace --no-strip-codesig \
          "@rpath/${dylib_name}" "$exec_path" \
          || die "insert_dylib injection failed for ${dylib_name}"
        ;;
    esac

    dylib_count=$((dylib_count + 1))
  done

  # Copy frameworks
  for fw in "${FRAMEWORKS_DIR}"/*.framework; do
    [ -d "$fw" ] || continue
    local fw_name
    fw_name=$(basename "$fw")
    log_info "Embedding framework: ${fw_name}"
    cp -R "$fw" "${APP_DIR}/Frameworks/"

    # Inject the framework binary
    local fw_binary="${fw_name%.framework}"
    case "$injector" in
      optool)
        optool install -c load -p "@rpath/${fw_name}/${fw_binary}" -t "$exec_path" \
          || log_warn "optool injection for framework ${fw_name} returned non-zero (may already be loaded)"
        ;;
      insert_dylib)
        insert_dylib --inplace --no-strip-codesig \
          "@rpath/${fw_name}/${fw_binary}" "$exec_path" \
          || log_warn "insert_dylib for framework ${fw_name} returned non-zero"
        ;;
    esac
  done

  # Copy any extra bundles (e.g. localization bundles from tweaks)
  if [ -d "${WORK_DIR}/bundles_extra" ]; then
    for bundle in "${WORK_DIR}/bundles_extra"/*.bundle; do
      [ -d "$bundle" ] || continue
      log_info "Embedding bundle: $(basename "$bundle")"
      cp -R "$bundle" "${APP_DIR}/"
    done
  fi

  log_ok "Injected ${dylib_count} dylib(s) into ${executable}"
}

###############################################################################
# IPA customization — apply settings from config.yml
###############################################################################
apply_customization() {
  [ -d "$APP_DIR" ] || die "APP_DIR not set"

  local bundle_id display_name min_ios
  local strip_watch strip_plugins strip_extensions
  bundle_id=$(config_custom "bundle_id")
  display_name=$(config_custom "display_name")
  min_ios=$(config_custom "min_ios")
  strip_watch=$(config_custom "strip_watch_extension")
  strip_plugins=$(config_custom "strip_plugins")
  strip_extensions=$(config_custom "strip_extensions")

  local plist="${APP_DIR}/Info.plist"

  # Use python3 for plist manipulation (cross-platform)
  python3 - "$plist" "$bundle_id" "$display_name" "$min_ios" <<'PYEOF'
import plistlib, sys

plist_path, bundle_id, display_name, min_ios = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

with open(plist_path, 'rb') as f:
    plist = plistlib.load(f)

if bundle_id:
    plist['CFBundleIdentifier'] = bundle_id
if display_name:
    plist['CFBundleDisplayName'] = display_name
    plist['CFBundleName'] = display_name
if min_ios:
    plist['MinimumOSVersion'] = min_ios

# Remove UISupportedDevices to allow sideloading on any device
plist.pop('UISupportedDevices', None)

with open(plist_path, 'wb') as f:
    plistlib.dump(plist, f)
PYEOF

  log_ok "Updated plist: bundle_id=${bundle_id}, name=${display_name}, min_ios=${min_ios}"

  # Remove code signature (required for re-signing after modification)
  rm -rf "${APP_DIR}/_CodeSignature"
  log_ok "Removed _CodeSignature"

  # Strip watch extension
  if [ "$strip_watch" = "True" ] || [ "$strip_watch" = "true" ]; then
    rm -rf "${APP_DIR}/Watch"
    log_ok "Stripped Watch extension"
  fi

  # Strip plugins
  if [ "$strip_plugins" = "True" ] || [ "$strip_plugins" = "true" ]; then
    rm -rf "${APP_DIR}/PlugIns"
    log_ok "Stripped PlugIns"
  fi

  # Strip app extensions
  if [ "$strip_extensions" = "True" ] || [ "$strip_extensions" = "true" ]; then
    # Remove all .appex except ones we explicitly embed
    if [ -d "${APP_DIR}/PlugIns" ]; then
      find "${APP_DIR}/PlugIns" -name "*.appex" -type d -exec rm -rf {} + 2>/dev/null \
        || log_warn "Some extensions could not be stripped"
    fi
    log_ok "Stripped extensions"
  fi

  # Apply custom icon if specified and file exists
  local icon_path
  icon_path=$(config_custom "icon")
  if [ -n "$icon_path" ] && [ -f "${SCRIPT_DIR}/${icon_path}" ]; then
    # Copy icon file over existing AppIcon assets
    log_info "Custom icon specified: ${icon_path}"
    # Note: Proper icon replacement requires multiple sizes; this is a placeholder
    # for a full icon replacement implementation
  fi
}

###############################################################################
# Repackage IPA
###############################################################################
# $1 = output path (default: YouTube-patched.ipa)
repackage_ipa() {
  local output="${1:-${SCRIPT_DIR}/YouTube-patched.ipa}"

  log_info "Repackaging IPA…"

  (cd "${PAYLOAD_DIR}" && zip -qry "${output}" Payload/) \
    || die "Failed to create output IPA"

  local size
  size=$(du -h "$output" | cut -f1)
  log_ok "Output IPA: ${output} (${size})"

  # Print SHA256 for verification
  if command -v shasum &>/dev/null; then
    echo -e "${BOLD}SHA256: $(shasum -a 256 "$output" | cut -d' ' -f1)${NC}"
  elif command -v sha256sum &>/dev/null; then
    echo -e "${BOLD}SHA256: $(sha256sum "$output" | cut -d' ' -f1)${NC}"
  fi
}

###############################################################################
# Full pipeline — called by build.sh and the CI workflow
###############################################################################
# $1 = IPA source (path or URL)
# $2 = output IPA path (optional)
run_full_pipeline() {
  local ipa_source="$1"
  local output_ipa="${2:-${SCRIPT_DIR}/YouTube-patched.ipa}"

  log_info "YTLitePlus Build Pipeline"
  echo "──────────────────────────────────────"

  check_deps
  prepare_workspace
  extract_ipa "$ipa_source"
  fetch_all_tweaks
  inject_tweaks
  apply_customization
  repackage_ipa "$output_ipa"

  log_ok "Build complete!"
  echo "──────────────────────────────────────"
}
