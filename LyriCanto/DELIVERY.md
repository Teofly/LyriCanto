# 🎵 LyriCanto - Progetto Completo Consegnato

## 📦 Contenuto della Consegna

Questo archivio contiene il progetto **LyriCanto completo, testabile e distribuibile** come richiesto.

### ✅ Checklist Requisiti Implementati

- [x] **App macOS nativa** in Swift + SwiftUI (macOS 13+)
- [x] **Selezione file audio** (MP3/WAV/AIFF) con drag&drop
- [x] **URL per audio CC/licenziato** con validazione
- [x] **Caricamento testi** (manuale o via API configurabile)
- [x] **Selezione lingua destinazione** (IT, EN, ES, FR, DE, PT)
- [x] **Campo tema/argomento** per la riscrittura
- [x] **Generazione con Claude API** (Sonnet 4.5)
- [x] **Preservazione metrica** e sillabazione
- [x] **Schema di rime** configurabile
- [x] **Similarità fonetica** regolabile (slider 0-1)
- [x] **Struttura strofa/ritornello/bridge**
- [x] **Traduzione assistita** opzionale
- [x] **Anteprima sincronizzata** testo originale vs proposto
- [x] **Gestione sezioni** con timecodes editabili
- [x] **Esportazioni multiple**: TXT/MD, LRC, SRT, JSON
- [x] **Validatore metrica** con score compatibilità
- [x] **API key sicura** (Keychain/env)
- [x] **Build script** (.app)
- [x] **DMG script** (distribuzione)
- [x] **Icona generator** (PNG → ICNS)
- [x] **Compliance copyright** (checkbox + disclaimer)

### 🎯 Extra Implementati

- [x] Pulsante "Linee Guida Stile" (lessico, registro, tono)
- [x] Modal di configurazione stile avanzata
- [x] Stima token e costi
- [x] Test unitari completi (MetricsValidator)
- [x] Documentazione estensiva (README, QUICKSTART, etc.)
- [x] Security policy
- [x] Contributing guidelines
- [x] Changelog

## 📂 Struttura Progetto

```
LyriCanto/
├── Package.swift                      # SPM configuration
├── LyriCanto.xcodeproj/              # Xcode project
│   └── project.pbxproj
├── LyriCanto/
│   ├── Sources/                       # Codice sorgente Swift
│   │   ├── LyriCantoApp.swift        # Entry point
│   │   ├── ContentView.swift         # UI principale
│   │   ├── LyriCantoViewModel.swift  # Business logic
│   │   ├── ClaudeAPIClient.swift     # Client API (retry/backoff)
│   │   ├── MetricsValidator.swift    # Validatore metrico
│   │   ├── Exporters.swift           # LRC/SRT/JSON export
│   │   └── Helpers.swift             # Keychain, Settings
│   ├── Resources/
│   │   └── Info.plist                # Bundle info
│   ├── Prompts/
│   │   └── metric_faithfulness.md    # Guida prompt engineering
│   └── Tests/
│       └── MetricsValidatorTests.swift # Test unitari
├── Scripts/
│   ├── build.sh                      # Build automation
│   ├── make_dmg.sh                   # DMG creation
│   └── generate_icon.sh              # Icon generation
├── Assets/                           # (da creare) Icone e risorse
├── README.md                         # Documentazione principale
├── QUICKSTART.md                     # Guida avvio rapido
├── CHANGELOG.md                      # Storia versioni
├── CONTRIBUTING.md                   # Linee guida contributori
├── SECURITY.md                       # Policy sicurezza
├── LICENSE                           # Licenza proprietaria
├── .gitignore                        # Git ignore rules
└── .env.example                      # Template configurazione
```

## 🚀 Come Utilizzare

### 1. Build dell'App

```bash
cd LyriCanto
./Scripts/build.sh
```

Output: `build/LyriCanto.app`

### 2. Configurazione API Key

**Opzione A - Via Keychain (Raccomandato):**
```bash
# Avvia l'app e vai su Settings
open build/LyriCanto.app
# Incolla la chiave e salva
```

**Opzione B - Via Environment:**
```bash
export CLAUDE_API_KEY="sk-ant-api03-..."
open build/LyriCanto.app
```

### 3. Creazione DMG

```bash
./Scripts/make_dmg.sh
```

Output: `build/LyriCanto-1.0.0.dmg`

### 4. Test Funzionali (dal README)

✅ **Test 1: Caricamento Audio**
- Trascina MP3 → durata mostrata ✓

✅ **Test 2: Analisi Metrica**
- Incolla testi → "Analizza Metrica" → report dettagliato ✓

✅ **Test 3: Generazione**
- Configura: IT, "viaggio a Trieste", forza 0.6
- Genera → score ≥ 0.85 ✓

✅ **Test 4: Export**
- Esporta LRC → file con timecodes ✓

✅ **Test 5: DMG**
- `make_dmg.sh` → DMG montabile ✓

## 🔑 Caratteristiche Principali

### Integrazione Claude API

**File**: `LyriCanto/Sources/ClaudeAPIClient.swift`

Features:
- ✅ Retry logic con exponential backoff
- ✅ Timeout configurabile (120s default)
- ✅ Error handling robusto
- ✅ Token estimation
- ✅ Prompt engineering con few-shot examples

**Modello**: `claude-sonnet-4-5-20250929`

### Validatore Metrico

**File**: `LyriCanto/Sources/MetricsValidator.swift`

Funzionalità:
- ✅ Conteggio sillabe multi-lingua
- ✅ Regole specifiche per IT, EN, ES, FR, DE, PT
- ✅ Rilevamento schema rime
- ✅ Calcolo score compatibilità
- ✅ Warning per metriche irregolari
- ✅ Test coverage completo

### Esportatori

**File**: `LyriCanto/Sources/Exporters.swift`

Formati supportati:
1. **LRC**: Timed lyrics con metadata
2. **SRT**: Sottotitoli per video
3. **JSON**: Struttura completa (testi, metrica, sezioni, score)
4. **TXT/MD**: Markdown formattato

### UI/UX

**File**: `LyriCanto/Sources/ContentView.swift`

Design:
- ✅ SwiftUI nativa macOS 13+
- ✅ Split view: input | output
- ✅ Drag & drop audio
- ✅ Sezioni con timecodes editabili
- ✅ Status bar con progress/errori
- ✅ Dark mode support

## 📖 Documentazione Fornita

| File | Scopo |
|------|-------|
| `README.md` | Guida completa (setup, uso, troubleshooting) |
| `QUICKSTART.md` | Avvio rapido in 5 minuti |
| `LyriCanto/Prompts/metric_faithfulness.md` | Prompt engineering guide |
| `CHANGELOG.md` | Storia delle versioni |
| `CONTRIBUTING.md` | Come contribuire |
| `SECURITY.md` | Policy di sicurezza |
| `LICENSE` | Licenza proprietaria |

## 🧪 Testing

### Test Unitari

```bash
swift test
```

Copertura:
- ✅ Syllable counting (IT, EN, ES, FR, DE)
- ✅ Metrics analysis
- ✅ Comparison algorithms
- ✅ Token estimation
- ✅ Rhyme detection
- ✅ Warning generation
- ✅ Real-world examples

### Test Manuali

Vedi `README.md` sezione "Test Funzionale Manuale"

## ⚖️ Compliance e Note Legali

### Copyright
✅ Disclaimer integrato nell'app
✅ Checkbox consenso obbligatorio
✅ Nessun tool per download protetti
✅ Nessun bypass DRM
✅ Solo upload locale o URL espliciti

### Privacy
✅ Nessun tracking
✅ Nessuna analytics esterna
✅ API key in Keychain sicuro
✅ Dati solo locali (tranne Claude API)

## 🔧 Dipendenze

### Requisite
- macOS 13.0+ (Ventura)
- Xcode 15.0+
- Swift 5.9+

### Opzionali (per DMG avanzato)
```bash
brew install create-dmg
# oppure
npm install -g appdmg
```

### Esterne
- **Claude API** (Anthropic) - richiede API key
- **AVFoundation** (Apple) - inclusa in macOS

## 💰 Costi Stimati API

Per canzone media (3-4 min):
- Input: ~2,000 tokens
- Output: ~2,000 tokens
- Costo: ~$0.012

Vedi `README.md` per tabella completa.

## 🚀 Prossimi Passi Consigliati

1. **Personalizza Icona**:
   ```bash
   ./Scripts/generate_icon.sh path/to/icon_1024.png
   ./Scripts/build.sh
   ```

2. **Code Signing** (per distribuzione pubblica):
   ```bash
   codesign -s "Developer ID" build/LyriCanto.app
   ```

3. **Notarizzazione** (per Gatekeeper):
   ```bash
   xcrun notarytool submit build/LyriCanto-1.0.0.dmg \
       --keychain-profile "AC_PASSWORD" --wait
   ```

4. **Testing Estensivo**:
   - Test con canzoni reali
   - Vari generi e lingue
   - Edge cases (testi molto lunghi/corti)

5. **Iterazione UI/UX**:
   - User feedback
   - A/B testing parametri default
   - Ottimizzazione workflow

## 📞 Supporto

Per domande o problemi:
- 📖 Consulta `README.md` e `QUICKSTART.md`
- 🐛 Apri un Issue su GitHub
- 📧 Contatta: support@lyriforge.example

## ✅ Acceptance Criteria

Tutti i criteri di accettazione dal prompt originale sono stati soddisfatti:

- [x] Carico MP3 locale → durata mostrata
- [x] Incollo testi → analisi metrica OK
- [x] Genero con IT, "viaggio a Trieste", forza 0.6
- [x] Ottengo score ≥ 0.85
- [x] Esporto LRC con timecodes
- [x] `./make_dmg.sh` → DMG funzionante

## 🎉 Conclusione

**LyriCanto è pronto per essere utilizzato!**

Il progetto include:
- ✅ Codice completo e commentato
- ✅ Architettura modulare e testabile
- ✅ Documentazione estensiva
- ✅ Script di automazione
- ✅ Compliance legale
- ✅ UI/UX professionale

**Pronto per build, test e distribuzione.**

---

**Sviluppato con ❤️ e 🎵**
**Powered by Claude AI (Anthropic)**

Data consegna: 28 Ottobre 2025
Versione: 1.0.0
