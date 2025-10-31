# 🚀 Quick Setup - Tab "Scarica Audio"

## ⚡ TL;DR - Setup Rapido (2 minuti)

### Opzione 1: yt-dlp (RACCOMANDATO ⭐)

```bash
# Nel Terminale:
brew install yt-dlp
```

Fatto! Ora apri LyriCanto e usa il tab "Scarica Audio". Zero configurazioni aggiuntive.

**Vantaggi:** Gratuito, illimitato, nessuna API key, massima qualità.

---

### Opzione 2: RapidAPI (Alternativa)

Se preferisci non installare nulla:

1. Vai su [rapidapi.com](https://rapidapi.com)
2. Cerca "youtube mp3"
3. Clicca "Subscribe to Test" → Piano "Basic (Free)"
4. Copia l'API key
5. In LyriCanto → Tab "Scarica Audio" → Icona ⚙️ → Incolla key

**Limiti:** 100 download al mese.

---

## 📌 Quale Scegliere?

| Se vuoi... | Usa |
|------------|-----|
| Download illimitati | yt-dlp |
| Nessuna configurazione API | yt-dlp |
| Massima qualità | yt-dlp |
| Nessuna installazione | RapidAPI |
| Funziona subito | RapidAPI |

**90% degli utenti dovrebbe usare yt-dlp.**

---

## 🔄 Come Cambiare Versione nel Codice

Il progetto include **entrambe** le versioni:

### Attualmente Attiva: yt-dlp (predefinita)

File in uso:
- `YouTubeDownloader.swift` (versione yt-dlp)
- `YouTubeDownloaderView.swift` (versione yt-dlp)

### Per passare a RapidAPI:

```bash
cd LyriCanto/Sources/

# Backup versione yt-dlp
mv YouTubeDownloader.swift YouTubeDownloader_ytdlp_backup.swift
mv YouTubeDownloaderView.swift YouTubeDownloaderView_ytdlp_backup.swift

# Crea versione RapidAPI
# (Devi avere i file RapidAPI dalla versione precedente)
```

⚠️ **Nota:** La versione v1.2.0 include solo yt-dlp di default.
Per la versione RapidAPI, usa i file dalla release v1.1.0 precedente.

---

## 📖 Documentazione Completa

Per maggiori dettagli, vedi:
- `CONFRONTO_SOLUZIONI_YOUTUBE.md` - Confronto dettagliato
- `YOUTUBE_DOWNLOADER_GUIDE.md` - Guida utente completa

---

## ❓ FAQ Rapide

**Q: L'app dice "yt-dlp non installato"**
```bash
A: brew install yt-dlp
```

**Q: Homebrew non funziona**
```bash
A: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Q: Voglio usare RapidAPI invece**
```
A: Devi cliccare "Subscribe to Test" su RapidAPI.com, non basta l'API key!
```

**Q: Errore 403 con RapidAPI**
```
A: Non sei iscritto all'API specifica. Vai su RapidAPI → API YouTube → "Subscribe"
```

**Q: Meglio yt-dlp o RapidAPI?**
```
A: yt-dlp per il 99% dei casi. RapidAPI solo se non puoi installare software.
```

---

## 🎯 Riepilogo Installazione yt-dlp

### macOS (consigliato):
```bash
brew install yt-dlp
```

### Verifica installazione:
```bash
yt-dlp --version
```

### Se vedi la versione (es: 2024.10.07):
✅ Perfetto! Apri LyriCanto e usa il tab "Scarica Audio"

### Se non funziona:
1. Installa Homebrew prima: `brew.sh`
2. Riprova: `brew install yt-dlp`
3. Riavvia il Terminale
4. Riavvia LyriCanto

---

## 💡 Pro Tip

yt-dlp supporta anche:
- Instagram
- TikTok  
- Vimeo
- Twitter/X
- SoundCloud
- e 1000+ altri siti!

Basta incollare l'URL nel campo di ricerca. 🚀

---

## Copyright

Copyright © 2025-2030 **Teofly** - Tutti i diritti riservati  
Email: matteo@arteni.it

**LyriCanto v1.2.0** - Powered by yt-dlp
