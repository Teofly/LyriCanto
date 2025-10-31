# 🎵 LyriCanto v1.2.0

**LyriCanto** è un'applicazione macOS professionale per la riscrittura creativa di testi musicali assistita da intelligenza artificiale (Claude e ChatGPT).

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![Version](https://img.shields.io/badge/Version-1.2.0-green)
![License](https://img.shields.io/badge/License-Teofly-red)

## 📋 Caratteristiche Principali

- ✅ **Riscrittura intelligente con AI** - Claude Sonnet 4.5 e GPT-4 Turbo
- ✅ **Dual Provider** - Scegli tra Claude (Anthropic) o ChatGPT (OpenAI)
- ✅ **Download Audio da YouTube** - 🆕 Ricerca e download diretto in MP3, WAV, M4A
- ✅ **Preservazione metrica** - Mantiene automaticamente le sillabe per verso
- ✅ **Schema di rime** - Supporto ABAB, AABB, ABBA e schemi personalizzati
- ✅ **Similarità fonetica regolabile** - Slider 0-1 per controllo creativo
- ✅ **Multi-lingua** - IT, EN, ES, FR, DE, PT
- ✅ **Gestione sezioni musicali** - Strofe, ritornelli, bridge con timecodes
- ✅ **Export multipli** - TXT/MD, LRC, SRT, JSON, TXT Avanzato
- ✅ **Analisi audio integrata** - BPM, tonalità, accordi suggeriti
- ✅ **Conversione formati audio** - Supporto api2convert.com
- ✅ **Report completo** - Export TXT avanzato con comparazione testi
- ✅ **Interfaccia nativa SwiftUI** - Design moderno per macOS
- ✅ **Compliance copyright** - Sistema di consenso integrato

## 🔧 Requisiti di Sistema

### Hardware e Software
- **macOS 13.0** (Ventura) o superiore
- **Xcode 15.0+** per build e sviluppo
- **8GB RAM** minimo (16GB raccomandato)
- **Connessione internet** per API AI

### API Keys Richieste

#### Claude API (Anthropic) - Raccomandato
1. Registrati su [Anthropic Console](https://console.anthropic.com)
2. Crea un nuovo API key
3. Modello utilizzato: `claude-sonnet-4-5-20250929`

#### OpenAI API (Opzionale)
1. Registrati su [OpenAI Platform](https://platform.openai.com)
2. Vai su [API Keys](https://platform.openai.com/api-keys)
3. Crea una nuova secret key
4. Modello utilizzato: `gpt-4-turbo-preview`

#### YT-API (RapidAPI) - YouTube Download 🆕
1. Registrati su [RapidAPI](https://rapidapi.com)
2. Cerca "YT-API" 
3. Clicca "Subscribe to Test" e scegli piano Basic (Free)
4. Copia la tua x-rapidapi-key
5. API utilizzata: `yt-api.p.rapidapi.com`
6. **Vantaggi**: Setup immediato, nessuna installazione richiesta
7. **Limiti**: 500 richieste/mese (piano free)

## 🚀 Installazione Rapida

### Metodo 1: Installazione da DMG (Raccomandato)

1. **Scarica il DMG** dal release package
2. **Apri il file DMG** 
3. **Trascina LyriCanto** nella cartella Applicazioni
4. **Primo avvio**: Tasto destro → Apri (per bypassare Gatekeeper)
5. **Configura API Key**: LyriCanto > Settings (⌘,)

### Metodo 2: Build da Sorgenti

```bash
# 1. Clone del repository
cd ~/Downloads
unzip LyriCanto-v1.1.0.zip
cd LyriCanto

# 2. Build con script
./Scripts/build.sh

# 3. L'app sarà in: build/LyriCanto.app
```

## 🎯 Guida Rapida all'Uso

### Workflow in 7 Passi

#### 1. Importa Audio
- Clicca **"Seleziona File Audio"** o trascina un file MP3/WAV/AIFF
- Oppure incolla un URL audio
- ✅ Spunta "Dichiaro di avere i diritti di utilizzo"

#### 2. Analizza Audio (Automatico)
- BPM viene rilevato automaticamente
- Tonalità e scala vengono analizzate
- Accordi suggeriti vengono generati

#### 3. Inserisci Testi Originali
- Incolla nel campo "Testo Originale"
- Oppure usa "Cerca Testi" per ricerca Google automatica

#### 4. Configura Parametri
- **Lingua**: Scegli IT, EN, ES, FR, DE o PT
- **Tema**: Descrivi il nuovo tema (es. "viaggio in Toscana")
- **Similarità fonetica**: Slider 0.0-1.0 (0.6 raccomandato)
- **Preserva rime**: Toggle ON/OFF

#### 5. Analizza Metrica (Opzionale ma Raccomandato)
- Clicca **"Analizza Metrica"**
- Verifica conteggio sillabe per ogni riga
- Conferma schema di rime rilevato

#### 6. Genera Testo Riscritto
- Clicca **"Genera Testo"**
- Attendi elaborazione AI (10-30 secondi)
- Rivedi il testo proposto

#### 7. Esporta
- **TXT/MD**: Formato markdown con metadata
- **LRC**: Lyrics con timestamp sincronizzati
- **SRT**: Sottotitoli per video
- **JSON**: Dati strutturati completi
- **TXT Avanzato**: 🆕 Report completo con comparazione

## 🆕 Novità v1.1.0: Export TXT Avanzato

Il nuovo export TXT Avanzato include:

### Sezioni del Report

1. **Informazioni Brano**
   - Nome file originale
   - Nome assegnato dall'utente

2. **Informazioni Google**
   - Artista, album, anno (se recuperati)

3. **Analisi Musicale**
   - Tonalità e scala
   - BPM (velocità)
   - Accordi suggeriti

4. **Analisi Metrica**
   - Conteggio sillabe per riga
   - Schema di rime
   - Score di compatibilità

5. **Testi**
   - Testo originale completo
   - Testo proposto completo
   - **Comparazione riga per riga** 🎯

6. **Copyright**
   - All Rights Reserved Teofly 2025-2030
   - matteo@arteni.it

### Esempio Output

```
═══════════════════════════════════════════════════════════════════
                        LYRICANTO - REPORT                          
═══════════════════════════════════════════════════════════════════

📋 INFORMAZIONI BRANO
─────────────────────────────────────────────────────────────────
Nome Originale: canzone.mp3
Nome Assegnato: La Mia Canzone

🎵 ANALISI MUSICALE
─────────────────────────────────────────────────────────────────
Tonalità: C Major
Scala: Major
BPM (Velocità): 120
Accordi Suggeriti: C, G, Am, F

📝 TESTO ORIGINALE
═════════════════════════════════════════════════════════════════
[testo originale qui]
═════════════════════════════════════════════════════════════════

✨ TESTO PROPOSTO
═════════════════════════════════════════════════════════════════
[testo proposto qui]
═════════════════════════════════════════════════════════════════

🔄 COMPARAZIONE TESTI (Riga per Riga)
═════════════════════════════════════════════════════════════════
Riga 1:
  Originale: Nel blu dipinto di blu
  Proposta:  Nel cielo azzurro lassù

Riga 2:
  Originale: Felice di stare quassù
  Proposta:  Contento di volare qui
...
```

## 📁 Struttura del Progetto

```
LyriCanto/
├── Package.swift                      # Configurazione Swift Package Manager
├── LyriCanto/
│   ├── Sources/                       # Codice sorgente
│   │   ├── LyriCantoApp.swift        # Entry point applicazione
│   │   ├── MainAppView.swift         # Vista principale
│   │   ├── ContentView.swift         # UI form e controlli
│   │   ├── LyriCantoViewModel.swift  # Business logic
│   │   ├── AIAPIClient.swift         # Client API AI
│   │   ├── MetricsValidator.swift    # Validatore metrica
│   │   ├── AudioAnalyzer.swift       # Analisi audio
│   │   ├── AudioConverter.swift      # Conversione formati
│   │   ├── AudioTrimmer.swift        # Trim sezioni audio
│   │   ├── Exporters.swift           # 🆕 Include TXT Avanzato
│   │   ├── GoogleMusicSearch.swift   # Ricerca testi
│   │   └── ... (altri componenti)
│   ├── Resources/
│   │   └── Info.plist
│   ├── Tests/
│   │   └── MetricsValidatorTests.swift
│   └── Prompts/
│       └── metric_faithfulness.md    # Guida prompt engineering
├── Scripts/
│   ├── build.sh                      # Build automatico
│   ├── make_dmg.sh                   # Creazione DMG
│   └── generate_icon.sh              # Generazione icona
├── Assets/
│   └── AppIcon.icns                  # Icona applicazione
├── README.md                         # Questo file
├── CHANGELOG.md                      # Storia versioni
├── QUICKSTART.md                     # Guida rapida
└── LICENSE                           # Licenza
```

## 🎨 Configurazione API Keys

### Opzione A: Tramite Interfaccia (Raccomandato)

1. Avvia LyriCanto
2. Vai su **LyriCanto > Settings** (⌘,)
3. Seleziona tab **"API Configuration"**
4. Scegli provider (Claude o OpenAI)
5. Incolla la tua API key
6. Clicca **"Salva"**

Le chiavi vengono salvate nel **Keychain** di macOS in modo sicuro.

### Opzione B: Variabili d'Ambiente

```bash
# Per Claude
export CLAUDE_API_KEY="sk-ant-api03-..."

# Per OpenAI
export OPENAI_API_KEY="sk-..."

# Aggiungi al tuo ~/.zshrc per renderlo permanente
echo 'export CLAUDE_API_KEY="sk-ant-api03-..."' >> ~/.zshrc
```

## 💰 Costi API Stimati

### Claude Sonnet 4.5

| Lunghezza Canzone | Token Input | Token Output | Costo Stimato |
|-------------------|-------------|--------------|---------------|
| Breve (1-2 min)   | ~1,000      | ~1,000       | ~$0.006       |
| Media (3-4 min)   | ~2,000      | ~2,000       | ~$0.012       |
| Lunga (5+ min)    | ~4,000      | ~4,000       | ~$0.024       |

**Prezzi aggiornati**: Verifica su [anthropic.com/pricing](https://www.anthropic.com/pricing)

### Consigli per Ridurre Costi

- ✅ Usa "Raffina questa strofa" invece di rigenerare tutto
- ✅ Testa con brani brevi durante sviluppo
- ✅ Monitora usage su [console.anthropic.com](https://console.anthropic.com)

## 🧪 Testing

### Test Unitari

```bash
# Esegui test suite
swift test

# Test con coverage
swift test --enable-code-coverage
```

### Test Funzionale Manuale

**Checklist:**
- [ ] Import MP3 locale → durata mostrata correttamente
- [ ] Analisi audio → BPM, tonalità, accordi rilevati
- [ ] Input testi → analisi metrica corretta
- [ ] Generazione → testo proposto con score ≥ 0.85
- [ ] Export TXT Avanzato → report completo con comparazione
- [ ] Export LRC → timestamp sincronizzati
- [ ] Export SRT → sottotitoli corretti

## ⚖️ Note Legali e Copyright

### Compliance

**LyriCanto è uno strumento per riscrittura creativa.** L'utente è **pienamente responsabile** di:

1. ✅ Possedere i diritti o le licenze per l'audio utilizzato
2. ✅ Possedere i diritti o le licenze per i testi originali
3. ✅ Rispettare tutte le leggi sul copyright applicabili

### Fonti Audio Consentite

✅ **Consentite:**
- File audio di tua proprietà
- Audio con licenza Creative Commons
- Audio di pubblico dominio
- Audio con licenza esplicita per modifica

❌ **NON Consentite:**
- Download di contenuti protetti da copyright
- Bypass di DRM
- Utilizzo senza permesso del titolare dei diritti

### Copyright Export

Tutti i file esportati con **TXT Avanzato** includono:

```
All Rights Reserved Teofly 2025-2030 matteo@arteni.it
```

## 🛠️ Troubleshooting

### Problemi Comuni

#### 1. "Xcode non trovato"
```bash
xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app
```

#### 2. "API Key non valida"
- Verifica che inizi con `sk-ant-api03-` (Claude) o `sk-` (OpenAI)
- Controlla su console che sia attiva
- Ricontrolla di averla salvata correttamente in Settings

#### 3. "Build fallisce"
```bash
# Pulisci build cache
rm -rf .build build
swift package clean
./Scripts/build.sh
```

#### 4. "L'app non si apre (Gatekeeper)"
```bash
# Rimuovi quarantena
xattr -cr build/LyriCanto.app
# Oppure: Tasto destro → Apri
```

#### 5. "Export TXT Avanzato vuoto"
- Verifica di aver generato i testi prima
- Controlla che ci siano dati in "Analisi Audio"
- Riprova l'analisi metrica

### Log e Debug

Per vedere log dettagliati:
```bash
# Apri Console.app
open -a Console

# Filtra per "LyriCanto"
```

## 📊 Funzionalità Future Pianificate

- 🔜 Integrazione API Genius/Musixmatch per testi
- 🔜 Batch processing (multiple canzoni)
- 🔜 Export video con sottotitoli integrati
- 🔜 Supporto lingue aggiuntive (JP, AR, RU)
- 🔜 Plugin system per estensioni custom
- 🔜 iOS/iPadOS companion app

## 🤝 Supporto

### Contatti

- 📧 Email: matteo@arteni.it
- 🏢 Azienda: Teofly
- 🐛 Bug Report: Invia a matteo@arteni.it

### Documentazione Aggiuntiva

- `QUICKSTART.md` - Guida rapida 5 minuti
- `CHANGELOG.md` - Storia completa versioni
- `CONTRIBUTING.md` - Linee guida per contributi

## 📜 Licenza

Copyright © 2025-2030 **Teofly** - Tutti i diritti riservati.  
Email: matteo@arteni.it

Questo software è proprietario. Redistribuzione e uso in forma source o binaria, con o senza modifiche, **non sono permessi** senza esplicita autorizzazione scritta del titolare del copyright.

Per richieste di licenza commerciale, contattare: matteo@arteni.it

---

## 🎵 Crediti

**Sviluppato da**: Teofly  
**Powered by**: Claude AI (Anthropic) & GPT-4 (OpenAI)  
**Versione**: 1.1.0  
**Data Rilascio**: Gennaio 2025

---

**Made with ❤️ and 🎵 for music creators worldwide**

*LyriCanto - Trasforma le tue parole in musica* 🎤✨
