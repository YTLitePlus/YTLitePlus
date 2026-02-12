#!/usr/bin/env bash
# build.sh — Local build script for YTLitePlus
#
# Usage:
#   ./build.sh /path/to/YouTube.ipa          # explicit IPA path
#   ./build.sh https://example.com/YT.ipa    # download from URL
#   ./build.sh                               # auto-detect IPA in current dir
#
# Reads config.yml for tweak list and customization settings.
# Shares all core logic with the CI workflow via lib.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

###############################################################################
# Resolve the IPA source
###############################################################################
IPA_SOURCE="${1:-}"

if [ -z "$IPA_SOURCE" ]; then
  # Auto-detect: look for a single .ipa in the project root
  mapfile -t ipa_files < <(find "$SCRIPT_DIR" -maxdepth 1 -name "*.ipa" -type f)

  if [ ${#ipa_files[@]} -eq 0 ]; then
    die "No IPA file provided and none found in ${SCRIPT_DIR}.\nUsage: ./build.sh /path/to/YouTube.ipa"
  elif [ ${#ipa_files[@]} -gt 1 ]; then
    die "Multiple IPA files found in ${SCRIPT_DIR}. Provide the path explicitly.\nUsage: ./build.sh /path/to/YouTube.ipa"
  fi

  IPA_SOURCE="${ipa_files[0]}"
  log_info "Auto-detected IPA: ${IPA_SOURCE}"
fi

###############################################################################
# Run the pipeline
###############################################################################
OUTPUT_IPA="${SCRIPT_DIR}/YouTube-patched.ipa"

run_full_pipeline "$IPA_SOURCE" "$OUTPUT_IPA"

# Cleanup intermediate work directory
cleanup_workspace