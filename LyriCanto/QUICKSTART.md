# 🚀 LyriCanto - Guida Rapida (5 Minuti)

Questa guida ti porterà dalla installazione alla tua prima riscrittura in soli 5 minuti!

**Versione:** 1.2.0 (01 Novembre 2025)

---

## ⏱️ Setup Veloce (2 minuti)

### Step 1: Installazione

**Opzione A: Da DMG (Raccomandato)**
```
1. Apri LyriCanto-v1.2.0.dmg
2. Trascina LyriCanto in Applicazioni
3. Tasto destro su LyriCanto → Apri
4. Conferma "Apri" se Gatekeeper lo richiede
```

**Opzione B: Build da Sorgenti**
```bash
cd LyriCanto

# Applica il fix se necessario
chmod +x apply_fix.sh
./apply_fix.sh

# Build
./Scripts/build.sh

# L'app sarà in build/LyriCanto.app
open build/LyriCanto.app
```

### Step 2: Configura API Key

1. Apri **LyriCanto**
2. Menu: **LyriCanto > Settings** (o premi ⌘,)
3. Scegli tab **"API Configuration"**
4. Seleziona **Claude** o **OpenAI** (o entrambi!)
5. Incolla la tua API key
6. Clicca **"Salva Claude Key"** (o "Salva OpenAI Key")

**Non hai ancora una API key?**
- Claude: [console.anthropic.com](https://console.anthropic.com) ⭐ Raccomandato
- OpenAI: [platform.openai.com/api-keys](https://platform.openai.com/api-keys)

---

## 🎯 Prima Riscrittura (3 minuti)

### Scenario: Riscrivere "Volare" in tema "viaggio a New York"

#### Step 1: Importa Audio (30 secondi)

```
1. Clicca "Seleziona File Audio"
2. Scegli un file MP3/WAV/M4A
   (oppure usa un file di test)
3. ✅ Spunta "Dichiaro di avere i diritti..."
```

🎵 **L'audio viene analizzato automaticamente** → BPM, tonalità, accordi

**Alternativa - Scarica da YouTube:**
```
1. Vai al tab "Scarica Audio"
2. Incolla URL YouTube o cerca il brano
3. Seleziona formato (MP3 raccomandato)
4. Download automatico
```

#### Step 2: Inserisci Testo Originale (1 minuto)

Copia-incolla nel campo **"Testo Originale"**:

```
Nel blu dipinto di blu
Felice di stare quassù
E volavo volavo felice più in alto del sole
Ed ancora più su
```

**Oppure**: 
- Clicca **"Cerca Testi"** per ricerca Google automatica
- Usa **"Trascrivi con Whisper"** se hai solo l'audio

#### Step 3: Configura Parametri (30 secondi)

```
Lingua: IT
Tema: viaggio a New York, libertà, grattacieli
Similarità fonetica: 0.6 (slider a metà)
Preserva rime: ✅ ON
Provider AI: Claude (o OpenAI)
```

#### Step 4: Analizza Metrica (Opzionale) (30 secondi)

```
Clicca "Analizza Metrica"
→ Verifica conteggio sillabe:
  Riga 1: 8 sillabe ✅
  Riga 2: 8 sillabe ✅
  ...
→ Schema rime rilevato: AABB
```

#### Step 5: Genera! (10-30 secondi)

```
Clicca "Genera Testo"
→ Attendi elaborazione AI...
→ Vedi risultato nel pannello destro
```

**Esempio output:**
```
A New York sul taxi che va
La città mi sorride già
E guardavo guardavo felice le luci di Times Square
Che brillavano là
```

**Score di compatibilità: 0.92** ✅

#### Step 6: Esporta (30 secondi)

Scegli il formato:

**Export TXT Avanzato** (Novità v1.1.0+):
```
Clicca "TXT Avanzato"
→ Salva come: viaggio_newyork_report.txt
```

Include:
- ✅ Informazioni brano complete
- ✅ Analisi musicale (BPM, tonalità, accordi)
- ✅ Metrica dettagliata
- ✅ Testo originale e proposto
- ✅ **Comparazione riga per riga**
- ✅ Copyright Teofly 2025-2030

**Altri formati:**
- **TXT/MD**: Markdown semplice
- **LRC**: Per karaoke (timestamp)
- **SRT**: Per sottotitoli video
- **JSON**: Dati strutturati

---

## 🎨 Nuova Funzionalità: AI Rime (v1.2.0)

### Cos'è AI Rime?

Un assistente intelligente per trovare rime, assonanze e parole alternative durante la scrittura.

### Quick Start AI Rime (1 minuto)

```
1. Click sulla barra laterale → 🎨 AI Rime
2. Scrivi una parola: es. "amore"
3. Seleziona lingua: Italiano
4. Click "🔍 Cerca Rime"
5. ✅ Vedi risultati con score e definizioni!
```

**Esempio risultati:**
```
• cuore (9/10) 💙
  "Organo centrale della circolazione..."
  
• dolore (8/10) 😢
  "Sensazione spiacevole fisica o emotiva..."
  
• splendore (7/10) ✨
  "Grande bellezza e magnificenza..."
```

### Features AI Rime

- 🌍 **6 lingue** supportate (IT, EN, ES, FR, DE, PT)
- 🎯 **Filtri avanzati** (lunghezza, tipo di rima)
- 📖 **Definizioni integrate** per ogni suggerimento
- 📊 **Storico ricerche** con salvataggio automatico
- 🤖 **Dual provider** (Claude & OpenAI)

**Guida completa:** Vedi `GUIDA_AI_RIME.md` per tutti i dettagli!

---

## 💡 Tips Pro

### 🎯 Migliorare i Risultati della Riscrittura

**1. Descrivi il tema in dettaglio**
```
❌ BAD:  "amore"
✅ GOOD: "amore non corrisposto, nostalgia, estate 2024, spiaggia al tramonto"
```

**2. Usa Similarità Fonetica strategicamente**
```
0.0-0.3 → Creatività massima (rime diverse)
0.4-0.6 → Bilanciato (raccomandato ⭐)
0.7-1.0 → Conservativo (simile all'originale)
```

**3. Analizza sempre la metrica prima**
```
→ Verifica sillabe corrette
→ Controlla schema di rime
→ Se score < 0.70, rigenera con parametri diversi
```

**4. Prova entrambi i provider**
```
Claude: Più creativo, migliore per testi poetici
OpenAI: Più veloce, ottimo per testi pop
```

### 🎨 Usare AI Rime Durante la Scrittura

**Workflow consigliato:**

```
1. Scrivi la prima strofa nel campo "Testo Originale"
2. Apri AI Rime (barra laterale)
3. Cerca rime per le parole finali
4. Scegli le migliori alternative
5. Torna al campo testo e modifica
6. Genera con AI per completare
```

**Esempio pratico:**
```
Testo iniziale:
"Cammino per la strada solitario
Pensando al nostro amore perduto"

→ Apri AI Rime
→ Cerca: "solitario"
→ Risultati: primario, ordinario, planetario
→ Scegli: "primario"

→ Cerca: "perduto"  
→ Risultati: caduto, venduto, cresciuto
→ Scegli: "cresciuto"

Testo migliorato:
"Cammino per la strada in primario
Pensando a ciò che insieme è cresciuto"
```

### 🎵 Gestione Sezioni (Avanzato)

Per brani con struttura complessa:

```
1. Clicca "+" sotto "Sezioni"
2. Tipo: Strofa / Ritornello / Bridge
3. Start Time: 00:00
4. End Time: 00:30
5. Aggiungi altre sezioni
→ L'AI userà i timecodes per export LRC/SRT
```

### 🎤 Linee Guida Stile (Avanzato)

Clicca **"Linee Guida Stile"** per personalizzare:

```
Lessico: poetico / tecnico / informale
Registro: formale / neutrale / colloquiale
Tono: umoristico / serio / romantico / nostalgico
Note: "Evita parole inglesi, preferisci dialetto toscano"
```

---

## 📥 Scarica Audio da YouTube

### Setup yt-dlp (Una volta sola - 2 minuti)

```bash
# Nel Terminale macOS:
brew install yt-dlp

# Verifica installazione:
yt-dlp --version
```

✅ Fatto! Ora puoi scaricare audio illimitati gratis.

### Usa il Downloader

```
1. Tab "Scarica Audio" nella barra laterale
2. Incolla URL YouTube o cerca brano
3. Seleziona formato:
   - MP3: Uso generale (raccomandato)
   - WAV: Massima qualità
   - M4A: Ottimizzato per Apple
4. Click "⬇️ Scarica"
5. ✅ File salvato in ~/Downloads
```

**Guida completa:** Vedi `YOUTUBE_DOWNLOADER_GUIDE.md`

---

## 🆘 Problemi Comuni

### "API Key non valida"
```
✅ Verifica che inizi con:
   - Claude: sk-ant-api03-...
   - OpenAI: sk-...
✅ Controlla su console che sia attiva
✅ Risalva in Settings (⌘,)
```

### "Score basso < 0.70"
```
→ Aumenta "Similarità fonetica"
→ Rendi il "Tema" più specifico
→ Prova a rigenerare (clicca di nuovo "Genera")
→ Cambia provider (Claude ↔ OpenAI)
```

### "Menu Help → Guida LyriCanto non si apre"
```
→ Applica il fix con apply_fix.sh
→ Oppure sostituisci LyriCantoApp.swift con la versione corretta
→ Ricompila: ./Scripts/build.sh
→ Vedi FIX_COMPLETO_LYRICANTO.md per dettagli
```

### "L'app non si apre (macOS Gatekeeper)"
```
→ Tasto destro su LyriCanto.app
→ Clicca "Apri"
→ Conferma "Apri comunque"

Oppure da Terminale:
→ xattr -cr /path/to/LyriCanto.app
```

### "Export TXT Avanzato vuoto"
```
✅ Genera prima i testi (bottone "Genera Testo")
✅ Attendi che l'analisi audio sia completa
✅ Verifica che ci siano dati in "Analisi Metrica"
✅ Riprova l'analisi se necessario
```

### "yt-dlp non installato"
```
# Installa con Homebrew:
brew install yt-dlp

# Se Homebrew non è installato:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### "AI Rime: Nessun risultato"
```
→ Verifica API key configurata (Settings)
→ Prova con parola più comune
→ Verifica lingua selezionata corretta
→ Rimuovi filtri troppo restrittivi
→ Cambia provider (Claude ↔ OpenAI)
```

---

## 📚 Prossimi Passi

### Approfondimenti

- 📖 Leggi il **README.md** completo
- 📋 Consulta **CHANGELOG.md** per tutte le novità v1.2.0
- 🎨 Esplora **GUIDA_AI_RIME.md** per padroneggiare AI Rime
- 📥 Vedi **YOUTUBE_DOWNLOADER_GUIDE.md** per yt-dlp avanzato
- 🔧 Leggi **FIX_COMPLETO_LYRICANTO.md** se hai problemi di compilazione
- 🤝 Vedi **CONTRIBUTING.md** per contribuire

### Supporto

- 📧 Email: matteo@arteni.it
- 🏢 Azienda: Teofly
- 🐛 Bug Report: matteo@arteni.it
- 💬 Feedback: Sempre benvenuto!

### Community

- ⭐ Lascia una stella su GitHub
- 📣 Condividi LyriCanto con altri musicisti
- 🎵 Taggaci nei tuoi progetti: @LyriCanto

---

## ⏱️ Riepilogo 5 Minuti

```
✅ Installazione          → 1 minuto
✅ Config API Key         → 1 minuto
✅ Import audio + testi   → 1 minuto
✅ Genera e rivedi        → 1 minuto
✅ Export report          → 1 minuto
────────────────────────────────────
   TOTALE                = 5 minuti
```

**Bonus (+2 minuti):**
```
✅ Setup yt-dlp           → 2 minuti
✅ Prima ricerca AI Rime  → 1 minuto
```

---

## 🆕 Novità v1.2.0

### Highlights

🎨 **AI Rime**
- Nuovo modulo per ricerca rime intelligente
- 6 lingue supportate
- Storico e statistiche integrate

🔧 **Fix Critici**
- Menu Help → Guida LyriCanto ora funziona
- AppState completo con currentProvider
- Zero errori di compilazione

🤖 **Dual Provider**
- Scelta tra Claude e OpenAI
- Persistenza preferenze
- Keychain sicuro per entrambi

📚 **Documentazione**
- Nuova guida: GUIDA_AI_RIME.md
- Fix documentati: FIX_COMPLETO_LYRICANTO.md
- Script automatico: apply_fix.sh

Vedi **CHANGELOG.md** per l'elenco completo!

---

## 🎵 Buona Riscrittura!

**Made with ❤️ by Teofly**  
Powered by Claude AI (Anthropic) & OpenAI  
Copyright © 2025-2030 Teofly - matteo@arteni.it

*LyriCanto v1.2.0 - Trasforma le tue parole in musica* 🎤✨

---

## 📌 Link Utili

| Risorsa | Link |
|---------|------|
| **Claude API** | [console.anthropic.com](https://console.anthropic.com) |
| **OpenAI API** | [platform.openai.com](https://platform.openai.com) |
| **yt-dlp GitHub** | [github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) |
| **Homebrew** | [brew.sh](https://brew.sh) |
| **Support Email** | matteo@arteni.it |
