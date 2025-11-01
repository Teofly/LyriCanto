#!/bin/bash
# Script automatico per fix colori LyriCanto
# Applica tutte le patch necessarie

set -e

echo "🎨 Fix Colori LyriCanto - Script Automatico"
echo "==========================================="
echo ""

# Verifica di essere nella directory giusta
if [ ! -d "LyriCanto/Sources" ]; then
    echo "❌ Errore: Esegui lo script dalla directory principale del progetto"
    echo "   cd ~/LyriCanto && bash fix_colori_automatico.sh"
    exit 1
fi

echo "📁 Directory trovata: $(pwd)"
echo ""

# Backup dei file originali
echo "💾 Backup file originali..."
BACKUP_DIR="LyriCanto/Sources/backup_$(date +%s)"
mkdir -p "$BACKUP_DIR"

cp LyriCanto/Sources/MainAppView.swift "$BACKUP_DIR/"
cp LyriCanto/Sources/RhymeAIView.swift "$BACKUP_DIR/" 2>/dev/null || true
cp LyriCanto/Sources/ContentView.swift "$BACKUP_DIR/"

echo "✅ Backup creato in: $BACKUP_DIR"
echo ""

# Fix 1: Aggiungi colorManager a RhymeAIView
echo "🔧 Fix 1: RhymeAIView..."
if grep -q "@EnvironmentObject var colorManager: ColorSchemeManager" LyriCanto/Sources/RhymeAIView.swift 2>/dev/null; then
    echo "   ℹ️  Già presente, skip"
else
    # Aggiungi dopo la dichiarazione di appState
    sed -i.bak '/^struct RhymeAIView: View {$/a\
    @EnvironmentObject var colorManager: ColorSchemeManager
' LyriCanto/Sources/RhymeAIView.swift 2>/dev/null && rm LyriCanto/Sources/RhymeAIView.swift.bak 2>/dev/null || true
    echo "   ✅ Aggiunto @EnvironmentObject colorManager"
fi

# Fix 2: Sostituisci background scuri in RhymeAIView
if [ -f "LyriCanto/Sources/RhymeAIView.swift" ]; then
    sed -i.bak 's/\.background(Color\.black\.opacity(0\.05))/\.background(Color\.gray\.opacity(0\.05))/g' LyriCanto/Sources/RhymeAIView.swift && rm LyriCanto/Sources/RhymeAIView.swift.bak
    sed -i.bak 's/\.background(Color(NSColor\.controlBackgroundColor))/\.background(Color(NSColor\.windowBackgroundColor))/g' LyriCanto/Sources/RhymeAIView.swift && rm LyriCanto/Sources/RhymeAIView.swift.bak
    echo "   ✅ Background aggiornati"
fi

# Fix 3: Aggiungi colorManager a ContentView
echo "🔧 Fix 2: ContentView..."
if grep -q "@EnvironmentObject var colorManager: ColorSchemeManager" LyriCanto/Sources/ContentView.swift; then
    echo "   ℹ️  Già presente, skip"
else
    sed -i.bak '/^struct ContentView: View {$/a\
    @EnvironmentObject var colorManager: ColorSchemeManager
' LyriCanto/Sources/ContentView.swift && rm LyriCanto/Sources/ContentView.swift.bak
    echo "   ✅ Aggiunto @EnvironmentObject colorManager"
fi

# Fix 4: Sostituisci background scuri in ContentView
sed -i.bak 's/\.background(Color\.black\.opacity(0\.05))/\.background(Color\.gray\.opacity(0\.05))/g' LyriCanto/Sources/ContentView.swift && rm LyriCanto/Sources/ContentView.swift.bak
sed -i.bak 's/\.background(Color(NSColor\.controlBackgroundColor))/\.background(Color(NSColor\.windowBackgroundColor))/g' LyriCanto/Sources/ContentView.swift && rm LyriCanto/Sources/ContentView.swift.bak
echo "   ✅ Background aggiornati"

echo ""
echo "✨ Patch applicate con successo!"
echo ""
echo "📦 Prossimi step:"
echo "   1. Sostituisci MainAppView.swift con quello scaricato:"
echo "      cp ~/Downloads/MainAppView_COLORI_COMPLETO.swift LyriCanto/Sources/MainAppView.swift"
echo ""
echo "   2. Ricompila:"
echo "      rm -rf build .build && ./Scripts/build.sh"
echo ""
echo "   3. Testa:"
echo "      open build/LyriCanto.app"
echo ""
echo "🎉 Fatto!"
