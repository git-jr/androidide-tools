#!/bin/bash
# Repackages Lzhiyong/android-sdk-tools .zip releases into the .tar.xz format
# expected by the androidide-tools manifest.
#
# Usage: ./repackage.sh <sdk_version> <arch>
#   sdk_version  e.g. 35.0.2
#   arch         one of: aarch64 arm x86_64
#
# The script produces:
#   build-tools-<version>-<arch>.tar.xz
#   platform-tools-<version>-<arch>.tar.xz
#
# Upload both files as assets to a GitHub release tagged v<sdk_version>
# in your androidide-tools fork.

set -eu

SDK_VERSION="${1:-35.0.2}"
ARCH="${2:-aarch64}"

# Map androidide arch names to Lzhiyong's zip arch names
case "$ARCH" in
  aarch64) LZHIYONG_ARCH="aarch64" ;;
  arm)     LZHIYONG_ARCH="arm" ;;
  x86_64)  LZHIYONG_ARCH="x86_64" ;;
  *)
    echo "Unknown arch: $ARCH. Supported: aarch64, arm, x86_64"
    exit 1
    ;;
esac

ZIP_NAME="android-sdk-tools-static-${LZHIYONG_ARCH}.zip"
ZIP_URL="https://github.com/lzhiyong/android-sdk-tools/releases/download/${SDK_VERSION}/${ZIP_NAME}"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

echo "Downloading $ZIP_URL..."
curl -L -o "$WORK_DIR/$ZIP_NAME" "$ZIP_URL"

echo "Extracting..."
unzip -q "$WORK_DIR/$ZIP_NAME" -d "$WORK_DIR/extracted"

SRC="$WORK_DIR/extracted"

# ── Build tools ──────────────────────────────────────────────────────────────
# Binaries that belong in build-tools/<version>/
BUILD_TOOLS_BINS=(
  aapt aapt2 aapt2_jni.so apksigner bcc_compat d8 dx
  lld lld-link llvm-rs-cc mainDexClasses mainDexClasses.rules
  split-select zipalign
)

BT_DIR="$WORK_DIR/build-tools/${SDK_VERSION}"
mkdir -p "$BT_DIR"

for bin in "${BUILD_TOOLS_BINS[@]}"; do
  # Search recursively; skip silently if not present in this SDK version
  found=$(find "$SRC" -name "$bin" -type f 2>/dev/null | head -1)
  if [ -n "$found" ]; then
    cp "$found" "$BT_DIR/"
    chmod +x "$BT_DIR/$bin" 2>/dev/null || true
  fi
done

BT_ARCHIVE="build-tools-${SDK_VERSION}-${ARCH}.tar.xz"
echo "Packing $BT_ARCHIVE..."
tar -C "$WORK_DIR" -cJf "$BT_ARCHIVE" "build-tools"
echo "Created: $BT_ARCHIVE"

# ── Platform tools ────────────────────────────────────────────────────────────
# Binaries that belong in platform-tools/
PLATFORM_TOOLS_BINS=(
  adb fastboot make_f2fs make_f2fs_casefold mke2fs e2fsdroid
  ext2simg img2simg simg2img simg2simg sqlite3
)

PT_DIR="$WORK_DIR/platform-tools"
mkdir -p "$PT_DIR"

for bin in "${PLATFORM_TOOLS_BINS[@]}"; do
  found=$(find "$SRC" -name "$bin" -type f 2>/dev/null | head -1)
  if [ -n "$found" ]; then
    cp "$found" "$PT_DIR/"
    chmod +x "$PT_DIR/$bin" 2>/dev/null || true
  fi
done

PT_ARCHIVE="platform-tools-${SDK_VERSION}-${ARCH}.tar.xz"
echo "Packing $PT_ARCHIVE..."
tar -C "$WORK_DIR" -cJf "$PT_ARCHIVE" "platform-tools"
echo "Created: $PT_ARCHIVE"

echo ""
echo "Done! Upload these files as assets to GitHub release v${SDK_VERSION}:"
echo "  $BT_ARCHIVE"
echo "  $PT_ARCHIVE"
