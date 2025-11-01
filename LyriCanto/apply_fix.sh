#!/bin/bash
#
# apply_fix.sh
# Script per applicare automaticamente il fix a LyriCantoApp.swift
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔧 Fix Automatico LyriCanto${NC}"
echo ""

# Trova il file da fixare
TARGET_FILE=""
if [ -f "LyriCanto/Sources/LyriCantoApp.swift" ]; then
    TARGET_FILE="LyriCanto/Sources/LyriCantoApp.swift"
elif [ -f "Sources/LyriCantoApp.swift" ]; then
    TARGET_FILE="Sources/LyriCantoApp.swift"
else
    echo -e "${RED}❌ File LyriCantoApp.swift non trovato!${NC}"
    echo "Assicurati di essere nella directory principale del progetto"
    exit 1
fi

echo -e "${GREEN}✓ File trovato: $TARGET_FILE${NC}"

# Backup del file originale
BACKUP_FILE="${TARGET_FILE}.backup_$(date +%Y%m%d_%H%M%S)"
cp "$TARGET_FILE" "$BACKUP_FILE"
echo -e "${GREEN}✓ Backup creato: $BACKUP_FILE${NC}"

# Copia il file corretto
if [ -f "LyriCantoApp_COMPLETE_FIX.swift" ]; then
    cp "LyriCantoApp_COMPLETE_FIX.swift" "$TARGET_FILE"
    echo -e "${GREEN}✓ Fix applicato!${NC}"
else
    echo -e "${RED}❌ File LyriCantoApp_COMPLETE_FIX.swift non trovato!${NC}"
    echo "Scarica il file dalla directory outputs"
    exit 1
fi

echo ""
echo -e "${BLUE}📋 Riepilogo:${NC}"
echo "  • File originale salvato in: $BACKUP_FILE"
echo "  • File corretto applicato in: $TARGET_FILE"
echo ""
echo -e "${GREEN}✅ Fix applicato con successo!${NC}"
echo ""
echo -e "${BLUE}Prossimi passi:${NC}"
echo "  1. Compila il progetto: ./Scripts/build.sh"
echo "  2. Testa l'app: open build/LyriCanto.app"
echo "  3. Verifica Help → Guida LyriCanto"
echo ""
