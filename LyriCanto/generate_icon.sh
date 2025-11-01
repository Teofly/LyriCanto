#!/bin/bash
#
# generate_icon.sh
# Generate .icns file from PNG for macOS app icon
#

set -e

INPUT_PNG="$1"
OUTPUT_ICNS="Assets/AppIcon.icns"
ICONSET_DIR="AppIcon.iconset"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🎨 Generating macOS app icon...${NC}"

# Check input
if [ -z "$INPUT_PNG" ]; then
    echo "Usage: ./Scripts/generate_icon.sh <input_1024x1024.png>"
    echo ""
    echo "This script will generate an .icns file from a 1024x1024 PNG"
    exit 1
fi

if [ ! -f "$INPUT_PNG" ]; then
    echo -e "${RED}❌ Error: File $INPUT_PNG not found${NC}"
    exit 1
fi

# Check if sips is available (built-in macOS)
if ! command -v sips &> /dev/null; then
    echo -e "${RED}❌ Error: sips command not found (should be available on macOS)${NC}"
    exit 1
fi

# Create iconset directory
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# Generate all required sizes
echo -e "${BLUE}📐 Generating icon sizes...${NC}"

sizes=(16 32 64 128 256 512 1024)

for size in "${sizes[@]}"; do
    echo "  - ${size}x${size}"
    sips -z $size $size "$INPUT_PNG" --out "${ICONSET_DIR}/icon_${size}x${size}.png" > /dev/null 2>&1
    
    # Also create @2x versions for sizes that need them
    if [ $size -le 512 ]; then
        size_2x=$((size * 2))
        echo "  - ${size}x${size}@2x (${size_2x}x${size_2x})"
        sips -z $size_2x $size_2x "$INPUT_PNG" --out "${ICONSET_DIR}/icon_${size}x${size}@2x.png" > /dev/null 2>&1
    fi
done

# Convert iconset to icns
echo -e "${BLUE}🔨 Creating .icns file...${NC}"
mkdir -p Assets
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_ICNS"

# Clean up
rm -rf "$ICONSET_DIR"

if [ -f "$OUTPUT_ICNS" ]; then
    ICON_SIZE=$(du -sh "$OUTPUT_ICNS" | cut -f1)
    echo -e "${GREEN}✅ Icon created successfully!${NC}"
    echo -e "${GREEN}📍 Location: $OUTPUT_ICNS${NC}"
    echo -e "${BLUE}📊 Size: $ICON_SIZE${NC}"
    echo ""
    echo "To use this icon:"
    echo "1. Update Info.plist to reference: <string>AppIcon</string>"
    echo "2. Rebuild the app: ./Scripts/build.sh"
    echo "3. The icon will appear in the .app bundle"
else
    echo -e "${RED}❌ Failed to create icon${NC}"
    exit 1
fi
