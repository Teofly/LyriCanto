# 🎥 YouTube Audio Downloader - Guida Utente

## 📋 Panoramica

Il tab "Scarica Audio" di LyriCanto ti permette di cercare e scaricare audio da video YouTube nei formati MP3, WAV e M4A usando **yt-dlp**, un tool open-source gratuito e illimitato.

## ⭐ Perché yt-dlp?

- ✅ **Completamente GRATUITO** - Nessun costo nascosto
- ✅ **Download ILLIMITATI** - Nessun limite mensile
- ✅ **Nessuna API key richiesta** - Zero configurazioni complesse
- ✅ **Massima qualità audio** - Qualità originale preservata
- ✅ **Open-source** - Sicuro e trasparente
- ✅ **Sempre aggiornato** - Community attiva di sviluppatori
- ✅ **1000+ siti supportati** - Non solo YouTube!

## 🚀 Setup Iniziale

### 1. Installare yt-dlp (Una volta sola)

yt-dlp è un semplice programma da riga di comando che si installa in 1 minuto.

#### Su macOS (Metodo Raccomandato - Homebrew):

**Passo 1:** Apri l'app **Terminale** (Command + Spazio, poi digita "Terminale")

**Passo 2:** Se non hai Homebrew, installalo prima:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Passo 3:** Installa yt-dlp:
```bash
brew install yt-dlp
```

**Passo 4:** Verifica che funzioni:
```bash
yt-dlp --version
```

Dovresti vedere qualcosa come: `2024.10.07`

**Passo 5:** Riavvia LyriCanto

✅ Fatto! Non devi fare altro.

### 2. Verificare l'Installazione in LyriCanto

1. Apri LyriCanto
2. Vai al tab **"Scarica Audio"** (icona play.circle)
3. Se yt-dlp è installato, vedrai un ✅ verde nell'header
4. Se non è installato, vedrai un avviso arancione con istruzioni

## 🔍 Come Usare il Downloader

### Passo 1: Cerca il Video

Due modi per cercare:

**Opzione A - Ricerca per Testo:**
1. Nel campo di ricerca, inserisci nome canzone + artista
   - Esempio: "Bohemian Rhapsody Queen"
   - Esempio: "Imagine Dragons Believer"
2. Clicca su **"Cerca"** o premi Invio
3. Attendi i risultati (10-15 secondi)

**Opzione B - URL Diretto:**
1. Copia l'URL del video YouTube
   - Esempio: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
   - O: `https://youtu.be/dQw4w9WgXcQ`
2. Incolla l'URL nel campo di ricerca
3. Clicca "Cerca"
4. Il video verrà caricato direttamente

### Passo 2: Seleziona il Video

- Verranno mostrati fino a 10 risultati
- Ogni risultato include:
  - **Thumbnail** del video (immagine di anteprima)
  - **Titolo** completo
  - **Nome del canale**
  - **Durata** del video

- Clicca sul video che vuoi scaricare
- Il video selezionato verrà evidenziato in blu con un ✓

### Passo 3: Scegli il Formato

Seleziona uno dei formati disponibili:

#### 🎵 MP3 (Raccomandato per musica)
- Formato compresso
- File di dimensioni ridotte
- Compatibile con tutti i dispositivi
- Ottimo per smartphone e lettori MP3
- **Dimensione tipica:** 3-5 MB per 3 minuti

#### 🎚️ WAV (Massima qualità)
- Formato non compresso
- Audio originale senza perdita di qualità
- Ideale per editing professionale
- File molto grandi
- **Dimensione tipica:** 30-50 MB per 3 minuti

#### 🍎 M4A (Apple native)
- Alta qualità audio
- File di dimensioni medie
- Formato nativo Apple (iTunes, iPhone, iPad)
- Buon compromesso qualità/dimensione
- **Dimensione tipica:** 4-8 MB per 3 minuti

### Passo 4: Scarica

1. Clicca su **"Scarica Audio"**
2. Vedrai una barra di progresso
3. Il download può richiedere da 10 secondi a 2 minuti (dipende dalla lunghezza)
4. Il file verrà salvato automaticamente in **~/Downloads**

### Passo 5: Accedi al File

Quando il download è completato vedrai un box verde con:

- **"Apri"** - Riproduce il file con l'app predefinita
- **"Mostra nel Finder"** - Apre la cartella Downloads

## 📁 Dove Vengono Salvati i File?

I file scaricati vengono salvati nella tua cartella **Downloads**:

```
~/Downloads/youtube_[VIDEO_ID]_[TIMESTAMP].[formato]
```

Esempio:
```
~/Downloads/youtube_dQw4w9WgXcQ_1730304000.mp3
```

**Suggerimento:** Puoi rinominare e organizzare i file come preferisci dopo il download.

## ⚙️ Formati e Qualità Audio

### Confronto Formati

| Formato | Qualità | Dimensione | Compatibilità | Uso Ideale |
|---------|---------|------------|---------------|------------|
| MP3 | Buona | Piccola | ⭐⭐⭐⭐⭐ | Ascolto quotidiano |
| WAV | Massima | Grande | ⭐⭐⭐⭐ | Editing professionale |
| M4A | Alta | Media | ⭐⭐⭐⭐ | Dispositivi Apple |

### Quale Formato Scegliere?

**Usa MP3 se:**
- Ascolti musica su smartphone
- Vuoi risparmiare spazio
- Condividi file con altri
- Uso quotidiano

**Usa WAV se:**
- Fai editing audio professionale
- Vuoi la massima qualità
- Lo spazio non è un problema
- Masterizzazione CD

**Usa M4A se:**
- Hai dispositivi Apple (iPhone, iPad, Mac)
- Vuoi buona qualità con file ragionevoli
- Usi iTunes/Apple Music
- Preferisci il formato Apple

## 🔧 Funzionalità Avanzate

### Download da URL Diretto

Puoi scaricare direttamente senza cercare:
1. Copia l'URL YouTube completo
2. Incollalo nel campo di ricerca
3. L'app lo rileverà automaticamente
4. Scegli formato e scarica

### Supporto Multi-Piattaforma

yt-dlp supporta oltre 1000 siti! Oltre a YouTube, puoi scaricare da:
- SoundCloud
- Vimeo
- TikTok (solo audio)
- Instagram
- Twitter/X
- Bandcamp
- E molti altri!

Basta incollare l'URL nel campo di ricerca.

## 🐛 Risoluzione Problemi

### ⚠️ "yt-dlp non è installato"

**Causa:** yt-dlp non è presente sul tuo Mac.

**Soluzione:**
```bash
# Apri Terminale e esegui:
brew install yt-dlp

# Se non hai Homebrew:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Poi riavvia LyriCanto.

### ⚠️ "Download fallito"

**Possibili cause:**
1. **Video non disponibile** - Video rimosso o privato
2. **Connessione internet** - Verifica la tua connessione
3. **Video protetto** - Alcuni video hanno restrizioni
4. **yt-dlp obsoleto** - Aggiorna con `brew upgrade yt-dlp`

**Soluzioni:**
```bash
# Aggiorna yt-dlp
brew upgrade yt-dlp

# Reinstalla se necessario
brew reinstall yt-dlp
```

### ⚠️ Download Molto Lento

**Cause comuni:**
- Connessione internet lenta
- Server YouTube sovraccarico
- Video di lunga durata (>1 ora)

**Suggerimenti:**
- Attendi pazientemente
- Verifica la velocità di connessione
- Prova in un momento diverso

### ⚠️ Errore "Permission Denied"

**Soluzione:**
```bash
# Dai permessi di esecuzione
chmod +x /usr/local/bin/yt-dlp
```

### ⚠️ Video Non Trovato nella Ricerca

**Soluzioni:**
1. Usa termini di ricerca più specifici
2. Prova con l'URL diretto invece della ricerca
3. Verifica che il video esista su YouTube

## 💡 Suggerimenti e Best Practices

### Per Risultati Migliori

1. **Ricerca Precisa**
   - Usa "Titolo Canzone - Nome Artista"
   - Aggiungi anno o dettagli: "Imagine - John Lennon 1971"
   - Usa parole chiave specifiche

2. **Scelta del Formato**
   - MP3 per uso quotidiano (smartphone, auto)
   - WAV per lavori professionali
   - M4A per ecosistema Apple

3. **Gestione Downloads**
   - Rinomina i file dopo il download
   - Organizza per cartelle (artista/album)
   - Aggiungi metadata ID3 con app esterne

4. **Qualità Audio**
   - yt-dlp scarica sempre la migliore qualità disponibile
   - La qualità dipende dall'upload originale su YouTube
   - Video "HD" non sempre significa audio migliore

### Trucchi Utili

**Scaricare solo una parte del video:**
- yt-dlp supporta timestamp (vedi documentazione ufficiale)
- Puoi specificare inizio e fine del download

**Scaricare playlist:**
- Copia l'URL della playlist
- yt-dlp può scaricare l'intera playlist
- (Funzionalità da implementare in versioni future)

**Formato automatico:**
- yt-dlp rileva automaticamente il miglior formato
- Conversione post-download gestita internamente

## ⚖️ Note Legali e Copyright

### ⚠️ Uso Responsabile e Legale

**IMPORTANTE**: Il download di contenuti da YouTube deve rispettare le leggi sul copyright e i Termini di Servizio di YouTube.

✅ **Usi Legittimi e Consentiti**:
- Video di tua proprietà o da te caricati
- Contenuti con licenza Creative Commons
- Contenuti per i quali hai il permesso esplicito del creatore
- Contenuti di pubblico dominio
- Backup personale di video già acquistati legalmente
- Uso educativo nel rispetto del fair use

❌ **Usi NON Consentiti e Illegali**:
- Download di contenuti protetti da copyright senza autorizzazione
- Ridistribuzione commerciale di contenuti scaricati
- Violazione dei Termini di Servizio di YouTube
- Rimozione di protezioni DRM o tecnologie di protezione
- Download di contenuti per scopi commerciali senza licenza

### 📜 Responsabilità dell'Utente

**L'utente è l'unico responsabile per:**
- Verificare di avere i diritti legali per scaricare il contenuto
- Rispettare le leggi sul copyright del proprio paese
- Conformarsi ai Termini di Servizio di YouTube
- Uso etico e legale dei file scaricati
- Non violare diritti di proprietà intellettuale

### 🛡️ Disclaimer

**Teofly e LyriCanto:**
- Forniscono questo software "così com'è" senza garanzie
- Non autorizzano né incoraggiano la violazione del copyright
- Non sono responsabili per l'uso improprio dello strumento
- Non sono affiliati con YouTube, Google o yt-dlp
- Declinano ogni responsabilità per azioni illegali degli utenti

**yt-dlp è un progetto open-source separato** disponibile su GitHub, non affiliato con questo progetto.

### ⚠️ Avviso Legale

Prima di scaricare qualsiasi contenuto:
1. **Verifica** di avere i diritti legali
2. **Leggi** i Termini di Servizio di YouTube
3. **Rispetta** le leggi sul copyright del tuo paese
4. **Usa** il software solo per scopi legittimi e personali

**In caso di dubbio, NON scaricare.**

## 🆘 Supporto e Assistenza

### Canali di Supporto

**Per problemi con LyriCanto:**
- 📧 Email: matteo@arteni.it
- 📖 Documentazione: Vedi README.md e altri file guida

**Per problemi con yt-dlp:**
- 🐙 GitHub: [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)
- 📚 Wiki: [yt-dlp Documentation](https://github.com/yt-dlp/yt-dlp/wiki)
- 💬 Issues: [Bug Reports](https://github.com/yt-dlp/yt-dlp/issues)

**Per problemi con Homebrew:**
- 🍺 Sito: [brew.sh](https://brew.sh)
- 📖 Docs: [Homebrew Documentation](https://docs.brew.sh)

### FAQ Rapide

**Q: yt-dlp è legale?**
A: Sì, yt-dlp stesso è legale. L'illegalità dipende da COSA scarichi e COME lo usi.

**Q: yt-dlp rallenta il mio Mac?**
A: No, usa solo risorse durante il download. È molto efficiente.

**Q: Quanto spazio occupa yt-dlp?**
A: Circa 10-15 MB. Molto leggero.

**Q: Devo pagare per yt-dlp?**
A: No, è completamente gratuito e open-source.

**Q: yt-dlp raccoglie i miei dati?**
A: No, è open-source e non raccoglie dati. Privacy totale.

**Q: Posso usare yt-dlp senza LyriCanto?**
A: Sì! yt-dlp funziona benissimo da Terminale. LyriCanto offre solo un'interfaccia grafica.

**Q: Ci sono limiti di download?**
A: No, zero limiti. Scarica quanto vuoi, quando vuoi.

**Q: La qualità è buona come l'originale?**
A: Sì, yt-dlp scarica la massima qualità disponibile su YouTube.

## 📝 Note sulla Privacy

### Cosa Viene Salvato

- ✅ File audio vengono salvati localmente in ~/Downloads
- ✅ Nessun dato inviato a server esterni (eccetto YouTube per il download)
- ✅ Nessun tracking o analytics
- ✅ Privacy completa garantita

### Cosa NON Viene Salvato

- ❌ Cronologia ricerche
- ❌ Lista video scaricati
- ❌ Dati personali
- ❌ Analytics di utilizzo

**LyriCanto e yt-dlp rispettano completamente la tua privacy.**

## 🔄 Aggiornamenti

### Mantenere yt-dlp Aggiornato

È importante aggiornare yt-dlp regolarmente:

```bash
# Aggiorna yt-dlp
brew upgrade yt-dlp

# Verifica versione
yt-dlp --version
```

**Perché aggiornare?**
- YouTube cambia frequentemente la sua API
- yt-dlp si adatta ai cambiamenti
- Nuove funzionalità e bug fix
- Migliori performance

**Frequenza consigliata:** Una volta al mese

## 🎓 Uso Avanzato (Opzionale)

### Usare yt-dlp dal Terminale

Se vuoi maggiore controllo, puoi usare yt-dlp direttamente:

```bash
# Download audio MP3
yt-dlp -x --audio-format mp3 "URL_VIDEO"

# Download audio migliore qualità
yt-dlp -x --audio-format best "URL_VIDEO"

# Download con nome specifico
yt-dlp -x --audio-format mp3 -o "%(title)s.%(ext)s" "URL_VIDEO"

# Download playlist
yt-dlp -x --audio-format mp3 "URL_PLAYLIST"
```

Vedi la documentazione completa: `yt-dlp --help`

---

## Copyright

Copyright © 2025-2030 **Teofly** - Tutti i diritti riservati  
Email: matteo@arteni.it

**LyriCanto v1.2.0** - Powered by yt-dlp

---

## 🙏 Ringraziamenti

Un ringraziamento speciale a:
- **yt-dlp team** per l'eccellente tool open-source
- **Homebrew** per il package manager
- **Community open-source** per il supporto continuo

Questo software è possibile grazie al lavoro di migliaia di sviluppatori open-source! 💚
