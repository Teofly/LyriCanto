#!/bin/bash
#
# make_dmg.sh
# Create a distributable DMG for LyriCanto
#

set -e

APP_NAME="LyriCanto"
VERSION="1.1.0"
DMG_NAME="${APP_NAME}-${VERSION}"
BUILD_DIR="build"
DMG_DIR="dmg_temp"
FINAL_DMG="${BUILD_DIR}/${DMG_NAME}.dmg"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🎵 Creating DMG for ${APP_NAME}...${NC}"

# Check if app exists
if [ ! -d "$BUILD_DIR/${APP_NAME}.app" ]; then
    echo -e "${RED}❌ Error: ${APP_NAME}.app not found in ${BUILD_DIR}${NC}"
    echo "Run ./Scripts/build.sh first"
    exit 1
fi

# Clean previous DMG files
echo -e "${BLUE}🧹 Cleaning previous DMG files...${NC}"
rm -f "$FINAL_DMG"
rm -rf "$DMG_DIR"

# Check for create-dmg or appdmg
if command -v create-dmg &> /dev/null; then
    USE_METHOD="create-dmg"
elif command -v appdmg &> /dev/null; then
    USE_METHOD="appdmg"
else
    USE_METHOD="hdiutil"
    echo -e "${YELLOW}⚠️  Neither create-dmg nor appdmg found. Using hdiutil (basic DMG).${NC}"
    echo -e "${YELLOW}   For better results, install one of these:${NC}"
    echo -e "${YELLOW}   - create-dmg: brew install create-dmg${NC}"
    echo -e "${YELLOW}   - appdmg: npm install -g appdmg${NC}"
fi

# Method 1: create-dmg (Homebrew)
if [ "$USE_METHOD" = "create-dmg" ]; then
    echo -e "${BLUE}📦 Using create-dmg...${NC}"
    
    create-dmg \
        --volname "$APP_NAME" \
        --volicon "Assets/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 800 400 \
        --icon-size 100 \
        --icon "${APP_NAME}.app" 200 190 \
        --hide-extension "${APP_NAME}.app" \
        --app-drop-link 600 185 \
        --no-internet-enable \
        "$FINAL_DMG" \
        "$BUILD_DIR/${APP_NAME}.app"
fi

# Method 2: appdmg (npm)
if [ "$USE_METHOD" = "appdmg" ]; then
    echo -e "${BLUE}📦 Using appdmg...${NC}"
    
    # Create appdmg config
    cat > appdmg.json <<EOF
{
  "title": "${APP_NAME}",
  "icon": "Assets/AppIcon.icns",
  "background": "Assets/dmg_background.png",
  "contents": [
    { "x": 448, "y": 344, "type": "link", "path": "/Applications" },
    { "x": 192, "y": 344, "type": "file", "path": "${BUILD_DIR}/${APP_NAME}.app" }
  ],
  "window": {
    "size": {
      "width": 640,
      "height": 480
    }
  }
}
EOF
    
    appdmg appdmg.json "$FINAL_DMG"
    rm appdmg.json
fi

# Method 3: hdiutil (built-in, basic)
if [ "$USE_METHOD" = "hdiutil" ]; then
    echo -e "${BLUE}📦 Using hdiutil (basic DMG)...${NC}"
    
    # Create temporary directory
    mkdir -p "$DMG_DIR"
    
    # Copy app
    cp -R "$BUILD_DIR/${APP_NAME}.app" "$DMG_DIR/"
    
    # Create symlink to Applications
    ln -s /Applications "$DMG_DIR/Applications"
    
    # Create README
    cat > "$DMG_DIR/README.txt" <<EOF
${APP_NAME} v${VERSION}

Installation:
1. Drag ${APP_NAME}.app to the Applications folder
2. Open ${APP_NAME} from Applications
3. Configure your Claude API key in Settings

For more information, visit the documentation.
EOF
    
    # Create DMG
    hdiutil create \
        -volname "$APP_NAME" \
        -srcfolder "$DMG_DIR" \
        -ov \
        -format UDZO \
        "$FINAL_DMG"
    
    # Clean up
    rm -rf "$DMG_DIR"
fi

# Verify DMG was created
if [ -f "$FINAL_DMG" ]; then
    DMG_SIZE=$(du -sh "$FINAL_DMG" | cut -f1)
    echo ""
    echo -e "${GREEN}✅ DMG created successfully!${NC}"
    echo -e "${GREEN}📍 Location: $FINAL_DMG${NC}"
    echo -e "${BLUE}📊 Size: $DMG_SIZE${NC}"
    echo ""
    echo -e "${GREEN}🎉 Distribution steps:${NC}"
    echo "1. Test: open $FINAL_DMG"
    echo "2. (Optional) Code sign:"
    echo "   codesign -s 'Developer ID Application: Your Name' $FINAL_DMG"
    echo "3. (Optional) Notarize for macOS Gatekeeper:"
    echo "   xcrun notarytool submit $FINAL_DMG --keychain-profile 'AC_PASSWORD'"
    echo "4. Distribute!"
else
    echo -e "${RED}❌ Failed to create DMG${NC}"
    exit 1
fi
