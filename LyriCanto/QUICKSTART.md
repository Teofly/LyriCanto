# 🚀 LyriCanto - Guida Rapida (5 Minuti)

Questa guida ti porterà dalla installazione alla tua prima riscrittura in soli 5 minuti!

## ⏱️ Setup Veloce (2 minuti)

### Step 1: Installazione

**Opzione A: Da DMG**
```
1. Apri LyriCanto-v1.1.0.dmg
2. Trascina LyriCanto in Applicazioni
3. Tasto destro su LyriCanto → Apri
```

**Opzione B: Build da Sorgenti**
```bash
cd LyriCanto
./Scripts/build.sh
# L'app sarà in build/LyriCanto.app
```

### Step 2: Configura API Key

1. Apri **LyriCanto**
2. Menu: **LyriCanto > Settings** (o premi ⌘,)
3. Scegli tab **"API Configuration"**
4. Seleziona **Claude** o **OpenAI**
5. Incolla la tua API key
6. Clicca **"Salva Claude Key"** (o "Salva OpenAI Key")

**Non hai ancora una API key?**
- Claude: [console.anthropic.com](https://console.anthropic.com)
- OpenAI: [platform.openai.com/api-keys](https://platform.openai.com/api-keys)

---

## 🎯 Prima Riscrittura (3 minuti)

### Scenario: Riscrivere "Volare" in tema "viaggio a New York"

#### Step 1: Importa Audio (30 secondi)

```
1. Clicca "Seleziona File Audio"
2. Scegli un file MP3/WAV
   (oppure usa un file di test)
3. ✅ Spunta "Dichiaro di avere i diritti..."
```

🎵 **L'audio viene analizzato automaticamente** → BPM, tonalità, accordi

#### Step 2: Inserisci Testo Originale (1 minuto)

Copia-incolla nel campo **"Testo Originale"**:

```
Nel blu dipinto di blu
Felice di stare quassù
E volavo volavo felice più in alto del sole
Ed ancora più su
```

**Oppure**: Clicca **"Cerca Testi"** per ricerca automatica

#### Step 3: Configura Parametri (30 secondi)

```
Lingua: IT
Tema: viaggio a New York, libertà, grattacieli
Similarità fonetica: 0.6 (slider a metà)
Preserva rime: ✅ ON
```

#### Step 4: Analizza Metrica (Opzionale) (30 secondi)

```
Clicca "Analizza Metrica"
→ Verifica conteggio sillabe:
  Riga 1: 8 sillabe ✅
  Riga 2: 8 sillabe ✅
  ...
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

**Export TXT Avanzato** (NOVITÀ v1.1.0):
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

## 💡 Tips Pro

### 🎯 Migliorare i Risultati

**1. Descrivi il tema in dettaglio**
```
❌ BAD:  "amore"
✅ GOOD: "amore non corrisposto, nostalgia, estate 2024, spiaggia"
```

**2. Usa Similarità Fonetica strategicamente**
```
0.0-0.3 → Creatività massima (rime diverse)
0.4-0.6 → Bilanciato (raccomandato)
0.7-1.0 → Conservativo (simile all'originale)
```

**3. Analizza sempre la metrica prima**
```
→ Verifica sillabe corrette
→ Controlla schema di rime
→ Se score < 0.70, rigenera con parametri diversi
```

### 🎨 Linee Guida Stile (Avanzato)

Clicca **"Linee Guida Stile"** per personalizzare:

```
Lessico: poetico / tecnico / informale
Registro: formale / neutrale / colloquiale
Tono: umoristico / serio / romantico
Note: "Evita parole inglesi, preferisci dialetto toscano"
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

---

## 🆘 Problemi Comuni

### "API Key non valida"
```
✅ Verifica che inizi con:
   - Claude: sk-ant-api03-...
   - OpenAI: sk-...
✅ Controlla su console che sia attiva
✅ Risalva in Settings
```

### "Score basso < 0.70"
```
→ Aumenta "Similarità fonetica"
→ Rendi il "Tema" più specifico
→ Prova a rigenerare (clicca di nuovo "Genera")
```

### "L'app non si apre (macOS Gatekeeper)"
```
→ Tasto destro su LyriCanto.app
→ Clicca "Apri"
→ Conferma "Apri comunque"
```

### "Export TXT Avanzato vuoto"
```
✅ Genera prima i testi (bottone "Genera Testo")
✅ Attendi che l'analisi audio sia completa
✅ Verifica che ci siano dati in "Analisi Metrica"
```

---

## 📚 Prossimi Passi

### Approfondimenti
- 📖 Leggi il **README.md** completo
- 📋 Consulta **CHANGELOG.md** per tutte le features
- 🤝 Vedi **CONTRIBUTING.md** per contribuire

### Supporto
- 📧 Email: matteo@arteni.it
- 🏢 Azienda: Teofly
- 🐛 Bug Report: matteo@arteni.it

### Community
- ⭐ Lascia una stella su GitHub
- 📣 Condividi LyriCanto con altri musicisti
- 💬 Feedback sempre benvenuto!

---

## ⏱️ Riepilogo 5 Minuti

```
✅ Installazione         → 1 minuto
✅ Config API Key        → 1 minuto
✅ Import audio + testi  → 1 minuto
✅ Genera e rivedi       → 1 minuto
✅ Export report         → 1 minuto
───────────────────────────────────
   TOTALE               = 5 minuti
```

---

## 🎵 Buona Riscrittura!

**Made with ❤️ by Teofly**  
Copyright © 2025-2030 Teofly - matteo@arteni.it

*LyriCanto - Trasforma le tue parole in musica* 🎤✨
