# 📝 Changelog

Tutte le modifiche notevoli a questo progetto saranno documentate in questo file.

Il formato è basato su [Keep a Changelog](https://keepachangelog.com/it/1.0.0/),
e questo progetto aderisce a [Semantic Versioning](https://semver.org/lang/it/).

---

## [1.2.0] - 2025-11-01

### 🆕 Novità

#### AI Rime - Assistente per Ricerca Rime ✨
- **Nuova funzionalità**: Modulo AI Rime integrato
- Ricerca rime e assonanze con AI (Claude/OpenAI)
- Supporto multi-lingua (Italiano, Inglese, Spagnolo, Francese, Tedesco, Portoghese)
- Filtri avanzati: lunghezza parole, tipo di rima (perfetta/imperfetta/assonanza)
- Definizioni e contesto per ogni parola suggerita
- Storico ricerche con salvataggio automatico
- Statistiche d'uso dettagliate
- Selezione provider AI configurabile

#### Gestione Provider AI
- Selezione tra Claude (Anthropic) e OpenAI
- Gestione centralizzata delle API keys
- Persistenza delle preferenze provider
- Keychain sicuro per entrambi i provider

### 🐛 Fix

#### Menu Help → Guida LyriCanto Funzionante
- **RISOLTO**: Il menu Help ora apre correttamente la guida integrata
- Implementato sistema NotificationCenter per apertura WindowGroup
- Scorciatoia da tastiera ⌘? funzionante
- Guida accessibile anche da Menu → Window

#### AppState Completo
- **RISOLTO**: Errori di compilazione in RhymeAIView
- Aggiunta proprietà `currentProvider: AIProvider`
- Implementato metodo `getAPIKey(for: AIProvider)`
- Gestione completa preferenze provider

### 🔧 Miglioramenti

#### Interfaccia Utente
- Nuova sezione "AI Rime" nella barra laterale
- Design coerente con il resto dell'applicazione
- Dark mode completamente supportato
- Animazioni fluide e feedback visivo

#### Performance
- Ottimizzazione caricamento WindowGroup
- Cache intelligente per le ricerche AI
- Gestione memoria migliorata

#### Documentazione
- Nuova guida: `FIX_COMPLETO_LYRICANTO.md`
- Aggiornato `README.md` con funzionalità AI Rime
- Script automatico `apply_fix.sh` per aggiornamenti
- Documentazione tecnica completa dei fix

### 📦 File Aggiunti
- `RhymeAIView.swift` - Vista principale AI Rime
- `RhymeAIViewModel.swift` - Business logic AI Rime
- `LyriCantoApp_COMPLETE_FIX.swift` - Versione corretta di LyriCantoApp
- `FIX_COMPLETO_LYRICANTO.md` - Documentazione fix
- `apply_fix.sh` - Script automatico per applicare fix

---

## [1.1.0] - 2025-01-28

### 🆕 Novità

#### Export TXT Avanzato ⭐
- **Nuovo formato di export**: TXT Avanzato con report completo
- Include tutte le informazioni del brano in un unico documento
- Sezioni dettagliate:
  - Informazioni Brano (nome originale e assegnato)
  - Informazioni Google (artista, album, anno)
  - Analisi Musicale completa (BPM, tonalità, scala, accordi)
  - Analisi Metrica dettagliata
  - Testo originale e proposto side-by-side
  - **Comparazione riga per riga** dei testi
- Copyright automatico: "All Rights Reserved Teofly 2025-2030 matteo@arteni.it"
- Formato professionale e leggibile

#### YouTube Downloader con yt-dlp
- Integrazione diretta con yt-dlp (nessuna API key necessaria)
- Download illimitati e gratuiti
- Supporto formati: MP3, WAV, M4A
- Ricerca integrata YouTube
- Selezione qualità audio
- Guida installazione yt-dlp integrata
- Massima qualità disponibile garantita

### 🔧 Miglioramenti

#### Interfaccia Utente
- Aggiunto tab "Scarica Audio" nella barra laterale
- Migliorato feedback visivo durante operazioni lunghe
- Progress bar dettagliati per download e analisi
- Toast notifications per operazioni completate

#### Gestione Audio
- Ottimizzazione analisi BPM
- Migliorato rilevamento tonalità
- Cache intelligente per risultati analisi
- Supporto drag & drop migliorato

#### Export
- Nuovi pulsanti di export più chiari
- Anteprima formato prima dell'export
- Validazione dati prima dell'export
- Messaggi di errore più descrittivi

### 📚 Documentazione
- Nuova guida: `YOUTUBE_DOWNLOADER_GUIDE.md`
- Aggiornato `README.md` con sezione YouTube Downloader
- Aggiunta sezione Troubleshooting estesa
- Tutorial video (link nel README)

---

## [1.0.0] - 2025-01-15

### 🎉 Release Iniziale

#### Core Features

**Gestione Audio**
- 🎵 Import file locali (MP3, WAV, AIFF)
- 🌐 Import da URL audio
- 🎚️ Analisi audio automatica: BPM, tonalità, scala
- 🎼 Rilevamento accordi suggeriti
- ✂️ Audio trimming integrato
- ⏱️ Gestione sezioni con timecodes personalizzabili (strofe, ritornelli, bridge)
- 🔄 Conversione formati audio (api2convert.com)

**Generazione Testi con AI**
- 🤖 Integrazione Claude API (Sonnet 4.5)
- 🌍 Supporto multi-lingua (IT, EN, ES, FR, DE, PT)
- 📊 Preservazione metrica e sillabazione
- 🎼 Schema di rime configurabile
- 🎯 Similarità fonetica regolabile (0.0-1.0)
- 📝 Linee guida stile personalizzabili
- 🔄 Rigenerazione iterativa
- ⚡ Stima token e costi in tempo reale

**Analisi Metrica**
- 📏 Conteggio sillabe multi-lingua
- 🎵 Rilevamento schema rime
- 🎯 Score di compatibilità automatico
- ⚠️ Warning per irregolarità metriche
- 📊 Report dettagliato analisi

**Export Avanzato**
- 📄 **TXT/Markdown** con metadata completi
- 🎤 **LRC (Lyric)** con timestamp sincronizzati
- 🎬 **SRT (SubRip)** per sottotitoli video
- 📦 **JSON** con struttura completa e metriche

**Interfaccia Utente**
- 🎨 Interfaccia SwiftUI nativa per macOS
- 🌓 Supporto Dark/Light mode
- 🎯 Design moderno e intuitivo
- 📖 Guida utente integrata
- ⚙️ Pannello Settings completo
- 🎨 Gestione color scheme personalizzabili

**Sicurezza e Privacy**
- 🔐 Archiviazione sicura API key nel Keychain macOS
- ✅ Validazione input per prevenire injection
- 🛡️ Gestione errori robusta per chiamate API
- ⚖️ Sistema di compliance copyright integrato
- 📋 Disclaimer legale nell'interfaccia

**Ricerca e Utilities**
- 🔍 Ricerca testi online (Google Music Search)
- 📊 Analisi metrica pre-generazione
- 🎯 Score di compatibilità automatico
- 📝 Linee guida stile personalizzabili
- 💾 Salvataggio parametri utente

#### Componenti Tecnici

**Architettura**
- 📐 Pattern MVVM pulito e scalabile
- 🔌 Dependency injection ready
- 🧪 Suite di test unitari (MetricsValidator)
- 🏗️ Modularità alta con 21+ file Swift
- 📦 Zero dipendenze esterne (solo framework Apple)

**Performance**
- ⚡ Async/await per operazioni non-bloccanti
- 🚀 Processing efficiente audio
- 💾 Cache intelligente
- 🔄 Retry automatico per chiamate API

**Build e Distribuzione**
- 🔨 Script build.sh per compilazione automatizzata
- 📦 Script make_dmg.sh per creazione DMG
- 🖼️ Script generate_icon.sh per conversione PNG → ICNS
- ✍️ Supporto code signing e notarizzazione Apple
- 📋 Template Xcode project completo

#### Documentazione

- 📖 README.md completo con esempi e troubleshooting
- 🚀 QUICKSTART.md per setup rapido (5 minuti)
- 🤝 CONTRIBUTING.md con linee guida
- 📜 LICENSE proprietaria Teofly
- 🎓 Prompt engineering guide con esempi
- 🧪 Documentazione test completa
- 🔒 SECURITY.md policy di sicurezza

---

## Formati delle Versioni

- **MAJOR.MINOR.PATCH** (Semantic Versioning)
- MAJOR: Breaking changes
- MINOR: Nuove features (backward compatible)
- PATCH: Bug fixes

---

## Link e Risorse

- **Repository**: [GitHub](https://github.com/teofly/lyricanto)
- **Documentazione**: Vedi README.md
- **Support**: matteo@arteni.it
- **Website**: [Coming Soon]

---

**Sviluppato con ❤️ e 🎵 da Teofly**  
Copyright © 2025-2030 Teofly - matteo@arteni.it
