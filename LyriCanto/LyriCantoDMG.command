#!/bin/bash
#
# LyriCantoDMG.command
# Script interattivo per creare LyriCanto.app e DMG
# Doppio clic per eseguire!
#

cd "$(dirname "$0")"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

APP_NAME="LyriCanto"
BUNDLE_ID="com.lyricanto.app"
VERSION="1.2.0"
BUILD_DIR="build"

# Auto-detect sources directory
if [ -d "./LyriCanto/Sources" ]; then
    SOURCES_DIR="./LyriCanto/Sources"
elif [ -d "./Sources" ]; then
    SOURCES_DIR="./Sources"
elif [ -d "LyriCanto/Sources" ]; then
    SOURCES_DIR="LyriCanto/Sources"
elif [ -d "Sources" ]; then
    SOURCES_DIR="Sources"
else
    SOURCES_DIR=""
fi

ASSETS_DIR="./Assets"

clear
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              🎵  LYRICANTO DMG BUILDER  🎵                ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

show_step() { echo -e "${BOLD}${MAGENTA}▶ $1${NC}"; }
show_success() { echo -e "${GREEN}✅ $1${NC}"; }
show_error() { echo -e "${RED}❌ $1${NC}"; }
show_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
show_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

ask_yes_no() {
    while true; do
        read -p "$(echo -e ${CYAN}$1 [s/n]: ${NC})" yn
        case $yn in
            [Ss]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Digita 's' per sì o 'n' per no.";;
        esac
    done
}

press_any_key() {
    echo ""
    echo -e "${CYAN}Premi INVIO per continuare...${NC}"
    read
}

show_step "Verifica Prerequisiti"
echo ""

if ! command -v swiftc &> /dev/null; then
    show_error "Swift compiler non trovato!"
    show_info "Installa Xcode Command Line Tools: xcode-select --install"
    press_any_key
    exit 1
fi
show_success "Swift compiler disponibile"

if [ -z "$SOURCES_DIR" ] || [ ! -d "$SOURCES_DIR" ]; then
    show_error "Cartella sorgenti non trovata!"
    show_info "Cercati: ./LyriCanto/Sources, ./Sources, LyriCanto/Sources, Sources"
    show_info ""
    show_info "Verifica di essere nella cartella principale del progetto"
    show_info "La struttura dovrebbe essere:"
    show_info "  LyriCanto/"
    show_info "  ├── LyriCanto/"
    show_info "  │   └── Sources/  ← qui ci sono i file .swift"
    show_info "  └── LyriCantoDMG.command"
    press_any_key
    exit 1
fi
show_success "Sorgenti trovati: $SOURCES_DIR"

ICON_PATH=""
if [ -f "$ASSETS_DIR/AppIcon.icns" ]; then
    ICON_PATH="$ASSETS_DIR/AppIcon.icns"
elif [ -f "Assets/AppIcon.icns" ]; then
    ICON_PATH="Assets/AppIcon.icns"
elif [ -f "./AppIcon.icns" ]; then
    ICON_PATH="./AppIcon.icns"
fi

if [ -z "$ICON_PATH" ]; then
    show_warning "Icona non trovata, verrà creata senza icona"
else
    show_success "Icona trovata: $ICON_PATH"
fi

echo ""
show_success "Prerequisiti OK!"
echo ""

echo -e "${BOLD}${CYAN}Cosa vuoi fare?${NC}"
echo ""
echo "1) Build completo (App + DMG)"
echo "2) Solo App (.app)"
echo "3) Solo DMG (da app esistente)"
echo "4) Pulisci build precedenti"
echo "5) Esci"
echo ""
read -p "Scelta [1-5]: " choice

case $choice in
    4)
        rm -rf "$BUILD_DIR"
        show_success "Build eliminati"
        press_any_key
        exit 0
        ;;
    5)
        exit 0
        ;;
esac

if [ "$choice" = "1" ] || [ "$choice" = "2" ]; then
    
    echo ""
    show_step "FASE 1: Compilazione LyriCanto.app"
    echo ""
    
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    
    APP_BUNDLE="$BUILD_DIR/${APP_NAME}.app"
    mkdir -p "$APP_BUNDLE/Contents/MacOS"
    mkdir -p "$APP_BUNDLE/Contents/Resources"
    
    show_info "Compilazione file Swift..."
    
    # Find all Swift files, handling different execution contexts
    if [ -d "$SOURCES_DIR" ]; then
        SOURCES=$(find "$SOURCES_DIR" -name "*.swift" -type f 2>/dev/null | tr '\n' ' ')
    elif [ -d "Sources" ]; then
        SOURCES=$(find "Sources" -name "*.swift" -type f 2>/dev/null | tr '\n' ' ')
        SOURCES_DIR="Sources"
    else
        show_error "Cartella Sources non trovata!"
        show_info "Percorsi cercati: $SOURCES_DIR, Sources"
        press_any_key
        exit 1
    fi
    
    if [ -z "$SOURCES" ]; then
        show_error "Nessun file Swift trovato in $SOURCES_DIR"
        press_any_key
        exit 1
    fi
    
    echo -e "${YELLOW}File trovati: $(echo $SOURCES | wc -w) file Swift${NC}"
    
    swiftc $SOURCES \
        -o "$APP_BUNDLE/Contents/MacOS/${APP_NAME}" \
        -framework SwiftUI \
        -framework Foundation \
        -framework AppKit \
        -framework AVFoundation \
        -framework Accelerate \
        -framework UniformTypeIdentifiers \
        -framework Security \
        -target arm64-apple-macos13.0 \
        -sdk $(xcrun --show-sdk-path) \
        2>&1 | tee build.log
    
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        show_error "Compilazione fallita! Vedi build.log"
        press_any_key
        exit 1
    fi
    
    show_success "Compilazione OK"
    
    cat > "$APP_BUNDLE/Contents/Info.plist" << 'PLISTEOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>LyriCanto</string>
    <key>CFBundleIdentifier</key>
    <string>com.lyricanto.app</string>
    <key>CFBundleName</key>
    <string>LyriCanto</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.2.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
PLISTEOF
    
    if [ -n "$ICON_PATH" ] && [ -f "$ICON_PATH" ]; then
        cp "$ICON_PATH" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
        show_success "Icona aggiunta"
    fi
    
    chmod +x "$APP_BUNDLE/Contents/MacOS/${APP_NAME}"
    codesign --force --deep --sign - "$APP_BUNDLE" 2>/dev/null || true
    
    if [ -d "$APP_BUNDLE" ]; then
        APP_SIZE=$(du -sh "$APP_BUNDLE" | cut -f1)
        echo ""
        show_success "APP CREATA!"
        echo -e "${CYAN}📍 $APP_BUNDLE (${APP_SIZE})${NC}"
        echo ""
        
        if ask_yes_no "Vuoi aprire l'app ora?"; then
            open "$APP_BUNDLE"
        fi
    else
        show_error "Creazione fallita!"
        exit 1
    fi
fi

if [ "$choice" = "1" ] || [ "$choice" = "3" ]; then
    
    echo ""
    show_step "FASE 2: Creazione DMG"
    echo ""
    
    APP_BUNDLE="$BUILD_DIR/${APP_NAME}.app"
    FINAL_DMG="$BUILD_DIR/${APP_NAME}-${VERSION}.dmg"
    DMG_TEMP="dmg_temp"
    
    if [ ! -d "$APP_BUNDLE" ]; then
        show_error "App non trovata in $APP_BUNDLE"
        exit 1
    fi
    
    rm -f "$FINAL_DMG"
    rm -rf "$DMG_TEMP"
    
    mkdir -p "$DMG_TEMP"
    cp -R "$APP_BUNDLE" "$DMG_TEMP/"
    ln -s /Applications "$DMG_TEMP/Applications"
    
    cat > "$DMG_TEMP/LEGGIMI.txt" << 'READMEOF'
LyriCanto v1.0.0

INSTALLAZIONE:
1. Trascina LyriCanto.app in Applicazioni
2. Apri LyriCanto
3. Configura API key in Impostazioni

Richiede macOS 13.0+
Buon divertimento! 🎵
READMEOF
    
    hdiutil create \
        -volname "$APP_NAME" \
        -srcfolder "$DMG_TEMP" \
        -ov \
        -format UDZO \
        "$FINAL_DMG" 2>&1 | grep -v "warning:" || true
    
    rm -rf "$DMG_TEMP"
    
    if [ -f "$FINAL_DMG" ]; then
        DMG_SIZE=$(du -sh "$FINAL_DMG" | cut -f1)
        echo ""
        show_success "DMG CREATO!"
        echo -e "${CYAN}📍 $FINAL_DMG (${DMG_SIZE})${NC}"
        echo ""
        
        if ask_yes_no "Vuoi aprire il DMG?"; then
            open "$FINAL_DMG"
        fi
    else
        show_error "Creazione DMG fallita!"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}${BOLD}✅  COMPLETATO!${NC}"
echo ""

press_any_key

if ask_yes_no "Aprire cartella build?"; then
    open "$BUILD_DIR"
fi

echo ""
echo -e "${GREEN}Grazie! 🎵${NC}"
echo ""
