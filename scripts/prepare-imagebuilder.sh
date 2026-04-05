#!/bin/bash
set -e

# prepare-imagebuilder.sh
# Download and extract ImmortalWrt ImageBuilder for Raspberry Pi 4

VERSION="${1:-24.10.5}"
TARGET="bcm27xx"
SUBTARGET="bcm2711"
PLATFORM="Linux-x86_64"

echo "========================================="
echo "ImmortalWrt ImageBuilder Preparation"
echo "========================================="
echo "Version: $VERSION"
echo "Target: $TARGET/$SUBTARGET"
echo ""

# Construct download URL and filename
IMAGEBUILDER_FILE="immortalwrt-imagebuilder-${VERSION}-${TARGET}-${SUBTARGET}.${PLATFORM}.tar.zst"
DOWNLOAD_URL="https://downloads.immortalwrt.org/releases/${VERSION}/targets/${TARGET}/${SUBTARGET}/${IMAGEBUILDER_FILE}"

echo "Step 1: Downloading ImageBuilder..."
echo "URL: $DOWNLOAD_URL"
echo ""

# Download with retry
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 --tries=3 \
     --progress=bar:force \
     "$DOWNLOAD_URL" \
     || { echo "ERROR: Failed to download ImageBuilder"; exit 1; }

echo ""
echo "Step 2: Verifying downloaded file..."
if [ ! -f "$IMAGEBUILDER_FILE" ]; then
    echo "ERROR: Downloaded file not found"
    exit 1
fi

FILE_SIZE=$(stat -f%z "$IMAGEBUILDER_FILE" 2>/dev/null || stat -c%s "$IMAGEBUILDER_FILE" 2>/dev/null)

if [ -z "$FILE_SIZE" ]; then
    echo "ERROR: Could not determine file size"
    exit 1
fi

echo "Downloaded file size: $((FILE_SIZE / 1024 / 1024)) MB"

if [ "$FILE_SIZE" -lt 10000000 ]; then
    echo "ERROR: Downloaded file is too small (likely corrupt)"
    exit 1
fi

echo ""
echo "Step 3: Extracting ImageBuilder..."
tar -xf "$IMAGEBUILDER_FILE" || { echo "ERROR: Failed to extract ImageBuilder"; exit 1; }

# Rename extracted directory to 'imagebuilder'
EXTRACTED_DIR=$(tar -tf "$IMAGEBUILDER_FILE" | head -1 | cut -f1 -d"/")

if [ -d "imagebuilder" ]; then
    echo "WARNING: imagebuilder directory already exists, removing it..."
    rm -rf imagebuilder
fi

mv "$EXTRACTED_DIR" imagebuilder

echo ""
echo "Step 4: Verifying ImageBuilder structure..."
if [ ! -d "imagebuilder" ] || [ ! -f "imagebuilder/Makefile" ]; then
    echo "ERROR: ImageBuilder structure is invalid"
    exit 1
fi

echo "ImageBuilder directory: $(pwd)/imagebuilder"
echo ""
echo "Step 5: Detecting architecture..."
ARCH=$(grep 'CONFIG_TARGET_ARCH_PACKAGES=' imagebuilder/.config | sed 's/.*="\(.*\)"/\1/' || echo "aarch64_cortex-a72")
echo "Detected architecture: $ARCH"

if [ "$ARCH" != "aarch64_cortex-a72" ]; then
    echo "WARNING: Unexpected architecture. Expected aarch64_cortex-a72, got $ARCH"
fi

echo ""
echo "========================================="
echo "ImageBuilder preparation completed!"
echo "========================================="
echo "Location: $(pwd)/imagebuilder"
echo ""

# Cleanup downloaded archive
rm -f "$IMAGEBUILDER_FILE"
echo "Cleaned up downloaded archive"
