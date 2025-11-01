#!/bin/bash
#
# build.sh
# Build script for LyriCanto macOS application
#

set -e

echo "🎵 Building LyriCanto..."

# Configuration
APP_NAME="LyriCanto"
BUILD_DIR="build"
SCHEME="LyriCanto"
CONFIGURATION="Release"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Error: xcodebuild not found. Please install Xcode.${NC}"
    exit 1
fi

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Check if we have an Xcode project or SPM
if [ -f "${APP_NAME}.xcodeproj/project.pbxproj" ]; then
    echo -e "${BLUE}📦 Building with Xcode project...${NC}"
    
    xcodebuild clean build \
        -project "${APP_NAME}.xcodeproj" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -derivedDataPath "$BUILD_DIR/DerivedData" \
        CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
        | tee build.log | xcpretty || cat build.log
        
elif [ -f "Package.swift" ]; then
    echo -e "${BLUE}📦 Building with Swift Package Manager...${NC}"
    
    swift build -c release
    
    # Copy built product
    cp -r .build/release/${APP_NAME}.app "$BUILD_DIR/" 2>/dev/null || {
        # If .app doesn't exist, create it
        mkdir -p "$BUILD_DIR/${APP_NAME}.app/Contents/MacOS"
        cp .build/release/${APP_NAME} "$BUILD_DIR/${APP_NAME}.app/Contents/MacOS/"
        
        # Copy resources
        if [ -d "LyriCanto/Resources" ]; then
            mkdir -p "$BUILD_DIR/${APP_NAME}.app/Contents/Resources"
            cp -r LyriCanto/Resources/* "$BUILD_DIR/${APP_NAME}.app/Contents/Resources/"
        fi
        
        # Copy Info.plist
        if [ -f "LyriCanto/Resources/Info.plist" ]; then
            cp LyriCanto/Resources/Info.plist "$BUILD_DIR/${APP_NAME}.app/Contents/Info.plist"
        fi
    }
else
    echo -e "${RED}❌ Error: No Xcode project or Package.swift found${NC}"
    exit 1
fi

# Check if build was successful
if [ -d "$BUILD_DIR/${APP_NAME}.app" ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo -e "${GREEN}📍 Application location: $BUILD_DIR/${APP_NAME}.app${NC}"
    
    # Show app info
    APP_SIZE=$(du -sh "$BUILD_DIR/${APP_NAME}.app" | cut -f1)
    echo -e "${BLUE}📊 App size: $APP_SIZE${NC}"
    
    # Check for code signature
    if codesign -dv "$BUILD_DIR/${APP_NAME}.app" 2>&1 | grep -q "Signature"; then
        echo -e "${GREEN}✅ App is code signed${NC}"
    else
        echo -e "${BLUE}ℹ️  App is not code signed (ad-hoc signature will be applied for distribution)${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Next steps:${NC}"
    echo "1. Test the app: open $BUILD_DIR/${APP_NAME}.app"
    echo "2. Create DMG: ./Scripts/make_dmg.sh"
    echo "3. (Optional) Code sign: codesign -s 'Your Identity' $BUILD_DIR/${APP_NAME}.app"
    
else
    echo -e "${RED}❌ Build failed. Check build.log for details${NC}"
    exit 1
fi
