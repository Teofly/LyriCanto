# 🔄 Come Usare RapidAPI invece di yt-dlp

## ⚠️ Importante

La versione **predefinita** di LyriCanto v1.2.0 usa **yt-dlp** (gratuito e illimitato).

Questa guida è per chi **preferisce** usare RapidAPI nonostante i limiti.

## 🆚 Confronto Rapido

| Caratteristica | yt-dlp (Predefinito) | RapidAPI (Alternativa) |
|----------------|----------------------|------------------------|
| Costo | 🆓 Gratis | Gratis con limiti |
| Limite download | ∞ Illimitato | 100/mese |
| API Key | ❌ Non serve | ✅ Richiesta |
| Setup | 1 minuto | 5+ minuti |
| Affidabilità | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Installazione | Homebrew | Nessuna |

**Raccomandazione:** Usa yt-dlp a meno che tu non possa installare software.

## 📋 Perché Usare RapidAPI?

Usa RapidAPI se:
- ❌ Non puoi installare software sul Mac
- ❌ Non hai accesso al Terminale
- ❌ Non puoi usare Homebrew (es. Mac aziendale)
- ✅ Ti bastano 100 download al mese

## 🔧 Setup RapidAPI

### Passo 1: Ottieni API Key

1. Vai su [RapidAPI.com](https://rapidapi.com)
2. Crea un account gratuito
3. Cerca "**youtube mp3**" o "**youtube-mp36**"
4. Seleziona l'API "YouTube MP3" o "YouTube Search and Download"
5. **IMPORTANTE**: Clicca su **"Subscribe to Test"**
6. Seleziona piano **"Basic (Free)"** - 0$/mese
7. **CONFERMA l'iscrizione** (passo critico!)
8. Copia la tua **X-RapidAPI-Key**

⚠️ **Nota Critica:** Non basta avere l'API key, devi **iscriverti** all'API specifica!

### Passo 2: Modifica Codice LyriCanto

#### Opzione A: Sostituisci File Manualmente

```bash
cd /path/to/LyriCanto/LyriCanto/Sources/

# Backup versione yt-dlp
mv YouTubeDownloader.swift YouTubeDownloader_ytdlp_backup.swift
mv YouTubeDownloaderView.swift YouTubeDownloaderView_ytdlp_backup.swift

# Attiva versione RapidAPI
cp YouTubeDownloader_rapidapi.swift YouTubeDownloader.swift
cp YouTubeDownloaderView_rapidapi.swift YouTubeDownloaderView.swift
```

#### Opzione B: Modifica in Xcode

1. Apri il progetto in Xcode
2. Vai a `LyriCanto/Sources/`
3. Elimina (o rinomina):
   - `YouTubeDownloader.swift`
   - `YouTubeDownloaderView.swift`
4. Duplica:
   - `YouTubeDownloader_rapidapi.swift` → `YouTubeDownloader.swift`
   - `YouTubeDownloaderView_rapidapi.swift` → `YouTubeDownloaderView.swift`
5. Ricompila il progetto

### Passo 3: Configura API Key in LyriCanto

1. Apri LyriCanto
2. Vai al tab **"Scarica Audio"**
3. Clicca sull'icona **ingranaggio** (⚙️)
4. Incolla la tua API key
5. Clicca "Chiudi"

### Passo 4: Testa

1. Cerca un video YouTube
2. Seleziona formato (MP3/WAV/M4A)
3. Clicca "Scarica Audio"
4. ✅ Dovrebbe funzionare!

## 🐛 Troubleshooting RapidAPI

### ❌ Errore: "You are not subscribed to this API"

**Causa:** Non hai cliccato "Subscribe to Test" su RapidAPI.

**Soluzione:**
1. Torna su RapidAPI
2. Vai alla pagina dell'API YouTube
3. Clicca **"Subscribe to Test"**
4. Seleziona piano "Basic (Free)"
5. **Conferma** l'iscrizione

### ❌ Errore: "Status 429 - Too Many Requests"

**Causa:** Hai superato il limite di 100 richieste/mese.

**Soluzioni:**
1. Aspetta il prossimo ciclo mensile
2. Fai upgrade a piano a pagamento
3. **Meglio:** Passa a yt-dlp (illimitato!)

### ❌ Errore: "Status 403 - Forbidden"

**Cause possibili:**
- API key non valida
- Non iscritto all'API specifica
- API key scaduta

**Soluzione:**
1. Verifica API key su RapidAPI
2. Controlla di essere iscritto
3. Rigenera API key se necessario

### ❌ Errore: "Status 500 - Internal Server Error"

**Causa:** Problema del server RapidAPI (non dipende da te).

**Soluzione:**
1. Riprova più tardi
2. Contatta supporto RapidAPI
3. **Meglio:** Passa a yt-dlp (più affidabile!)

## 📊 Limitazioni RapidAPI

### Piano Free (Basic):
- ✅ **100 richieste/mese**
- ⚠️ Ricerca conta come richiesta
- ⚠️ Download conta come richiesta
- ⚠️ Qualità audio variabile
- ⚠️ Velocità non garantita
- ⚠️ API può essere disabilitata

### Conteggio Richieste:
- 1 ricerca = 1 richiesta
- 1 download = 1 richiesta
- Totale: 100 operazioni/mese

**Esempio:** 50 ricerche + 50 download = 100 richieste = limite raggiunto

## 💡 Suggerimenti

### Ottimizza Uso RapidAPI

1. **Usa URL diretti** invece di cercare
   - Copia URL YouTube → Incolla in LyriCanto
   - Risparmia 1 richiesta per video

2. **Cerca su YouTube web** prima
   - Trova il video che vuoi
   - Copia l'URL
   - Incollalo direttamente nell'app

3. **Pianifica download**
   - Non sprecare richieste in test
   - Scarica solo ciò che ti serve
   - 100 richieste = ~50 canzoni al mese

### Monitora Uso

RapidAPI mostra il tuo usage:
1. Vai su RapidAPI Dashboard
2. Controlla "Usage" per l'API
3. Vedi quante richieste hai fatto
4. Pianifica di conseguenza

## 🔄 Come Tornare a yt-dlp

Se cambi idea e vuoi tornare a yt-dlp:

```bash
cd /path/to/LyriCanto/LyriCanto/Sources/

# Backup versione RapidAPI
mv YouTubeDownloader.swift YouTubeDownloader_rapidapi_backup.swift
mv YouTubeDownloaderView.swift YouTubeDownloaderView_rapidapi_backup.swift

# Ripristina versione yt-dlp
cp YouTubeDownloader_ytdlp.swift YouTubeDownloader.swift
cp YouTubeDownloaderView_ytdlp.swift YouTubeDownloaderView.swift
```

Poi:
1. Installa yt-dlp: `brew install yt-dlp`
2. Ricompila il progetto
3. ✅ Download illimitati!

## 📝 Note Legali

### Termini di Servizio RapidAPI

Usando RapidAPI, accetti:
- Termini di servizio di RapidAPI
- Termini della specifica API YouTube
- Limiti del piano free
- Possibile interruzione servizio

### Confronto Legale

| Aspetto | yt-dlp | RapidAPI |
|---------|--------|----------|
| ToS YouTube | Potenziale violazione | Tramite API autorizzata |
| Termini aggiuntivi | Nessuno | RapidAPI ToS |
| Dipendenze | Nessuna | Servizio terzo |
| Privacy | Locale | Dati via RapidAPI |

**Disclaimer:** In entrambi i casi, l'utente è responsabile per l'uso legale del software.

## 🆘 Supporto

### Per Problemi RapidAPI:
- 🐙 GitHub RapidAPI
- 📧 Supporto RapidAPI
- 💬 Forum RapidAPI

### Per Problemi LyriCanto:
- 📧 Email: matteo@arteni.it
- 📖 Documentazione progetto

## ⚖️ Disclaimer

**Teofly e LyriCanto:**
- Non sono affiliati con RapidAPI
- Non garantiscono disponibilità API RapidAPI
- Non sono responsabili per limiti o costi RapidAPI
- Raccomandano yt-dlp come soluzione principale

**Usa RapidAPI a tuo rischio.**

## 🎯 Conclusione

RapidAPI è una **alternativa valida** ma:
- ❌ Ha limiti mensili
- ❌ Dipende da servizi esterni
- ❌ Può costare se superi free tier
- ❌ Meno affidabile di yt-dlp

**Raccomandazione finale: Usa yt-dlp!**

Se proprio non puoi, RapidAPI funziona, ma con limitazioni.

---

## Copyright

Copyright © 2025-2030 **Teofly** - Tutti i diritti riservati  
Email: matteo@arteni.it

**LyriCanto v1.2.0** - Guida RapidAPI
