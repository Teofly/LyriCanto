# Changelog

Tutte le modifiche notevoli a LyriCanto sono documentate in questo file.

Il formato è basato su [Keep a Changelog](https://keepachangelog.com/it/1.0.0/),
e questo progetto aderisce al [Semantic Versioning](https://semver.org/lang/it/).

## [1.2.0] - 2025-10-30

### ✨ Nuove Funzionalità

**Download Audio da YouTube**
- 🎥 **Nuovo Tab "Scarica Audio"** - Download diretto da YouTube usando YT-API
- 🔍 **Ricerca YouTube integrata** con preview dei risultati
- 🎵 **Supporto multi-formato**: MP3, WAV, M4A
- 🖼️ **Preview video** con thumbnail, titolo, canale e durata
- 📥 **Download diretto** nella cartella Downloads di macOS
- 🔄 **Progress bar** in tempo reale durante il download
- 🔑 **Usa YT-API (RapidAPI)** - API affidabile e ben mantenuta
- ⚙️ **Gestione API Key** con salvataggio sicuro
- 📊 **500 richieste/mese** nel piano free
- 🎯 **Interfaccia intuitiva** coerente con il resto dell'app

### 🔧 Miglioramenti Tecnici

- 📁 Nuovi file: `YouTubeDownloader.swift` e `YouTubeDownloaderView.swift`
- 🏗️ Integrazione con YT-API via RapidAPI
- 🔄 Gestione asincrona con async/await
- 🎨 UI nativa SwiftUI con supporto Dark/Light mode
- 💾 Salvataggio automatico API key in UserDefaults
- 📡 Gestione errori robusta per chiamate API

### 🆚 Alternative Disponibili

Il progetto include anche versione yt-dlp (vedi documentazione):
- File alternativi: `YouTubeDownloader_ytdlp.swift` e `YouTubeDownloaderView_ytdlp.swift`
- Documenti guida: `SETUP_YTAPI.md` e `QUICK_SETUP_YOUTUBE.md`

## [1.1.0] - 2025-01-30

### 🎉 Primo Rilascio Ufficiale

#### ✨ Caratteristiche Principali

**Riscrittura Testi con AI**
- 🤖 Integrazione completa con Claude Sonnet 4.5 (Anthropic)
- 🤖 Supporto alternativo per GPT-4 Turbo (OpenAI)
- 🎯 Dual provider: scegli il modello AI preferito
- 📝 Riscrittura intelligente con preservazione metrica
- 🔤 Supporto multi-lingua: IT, EN, ES, FR, DE, PT
- 🎼 Validatore metrico con conteggio sillabe accurato
- 🎨 Similarità fonetica regolabile (slider 0.0-1.0)
- 📊 Analisi automatica schema di rime (ABAB, AABB, ABBA, etc.)

**Gestione Audio**
- 🎵 Import file locali (MP3, WAV, AIFF)
- 🌐 Import da URL audio
- 🎚️ Analisi audio automatica: BPM, tonalità, scala
- 🎼 Rilevamento accordi suggeriti
- ✂️ Audio trimming integrato
- ⏱️ Gestione sezioni con timecodes personalizzabili (strofe, ritornelli, bridge)
- 🔄 Conversione formati audio (api2convert.com)

**Export Avanzato**
- 📄 **TXT/Markdown** con metadata completi
- 🎤 **LRC (Lyric)** con timestamp sincronizzati
- 🎬 **SRT (SubRip)** per sottotitoli video
- 📦 **JSON** con struttura completa e metriche
- ⭐ **TXT Avanzato** - NOVITÀ v1.1.0:
  - Nome brano originale e assegnato
  - Informazioni Google (artista, album, anno)
  - Analisi musicale completa (BPM, tonalità, scala, accordi)
  - Metrica dettagliata
  - Testo originale e proposto
  - **Comparazione riga per riga** dei testi
  - Copyright: "All Rights Reserved Teofly 2025-2030 matteo@arteni.it"

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

#### 🔧 Componenti Tecnici

**Architettura**
- 📐 Pattern MVVM pulito e scalabile
- 🔌 Dependency injection ready
- 🧪 Suite di test unitari (MetricsValidator)
- 🏗️ Modularità alta con 21 file Swift
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

#### 📚 Documentazione

- 📖 README.md completo con esempi e troubleshooting
- 🚀 QUICKSTART.md per setup rapido (5 minuti)
- 🤝 CONTRIBUTING.md con linee guida
- 📜 LICENSE proprietaria Teofly
- 🎓 Prompt engineering guide con esempi
- 🧪 Documentazione test unitari

#### ⚠️ Limitazioni Note

- ⚠️ BPM auto-detection è approssimativo (placeholder per ora)
- ⚠️ Conteggio sillabe basato su regole euristiche (non perfetto al 100%)
- ⚠️ Rhyme detection limitato a pattern semplici
- ⚠️ Nessuna integrazione API testi (Genius/Musixmatch) - pianificata per v1.2.0
- ⚠️ Solo audio locali o URL diretti (no streaming Spotify/Apple Music)

#### 🔮 Prossimi Passi (v1.2.0)

Pianificato per Q2 2025:
- 🔜 Integrazione API Genius/Musixmatch per testi
- 🔜 BPM detection algoritmo avanzato
- 🔜 Batch processing (multiple canzoni)
- 🔜 Miglioramento conteggio sillabe con NLP
- 🔜 Supporto lingue aggiuntive (JP, AR, RU)
- 🔜 Export video con sottotitoli integrati

---

## Legenda Emoji

- 🎵 Feature musicali
- 📝 Gestione testi
- 🔤 Internazionalizzazione
- 🎼 Metriche e analisi
- 📤 Export e salvataggio
- 🎨 UI/UX
- 🔧 Configurazione
- 🔐 Sicurezza
- 📖 Documentazione
- 🧪 Testing
- 🔨 Build system
- ⚠️ Limitazioni note
- 🐛 Bug fix
- 🚀 Performance
- ♻️ Refactoring

---

## Copyright

Copyright © 2025-2030 **Teofly** - Tutti i diritti riservati  
Email: matteo@arteni.it

---

[1.2.0]: https://github.com/teofly/lyricanto/releases/tag/v1.2.0
[1.1.0]: https://github.com/teofly/lyricanto/releases/tag/v1.1.0
