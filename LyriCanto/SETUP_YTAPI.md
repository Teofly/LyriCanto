# 🎯 Setup Completo - YT-API (RapidAPI)

## ✅ La Tua API Key

Ho visto che hai già questa API key funzionante:
```
30a766cd84mshfa1cf401d78bce2p18d501jsn32aec82050b4
```

Perfetto! Questa dovrebbe funzionare senza l'errore 403 che avevi prima.

## 🚀 Setup Rapido (2 Minuti)

### 1. Estrai il Progetto
Estrai `LyriCanto-v1_2_0_ytapi.zip`

### 2. Apri in Xcode
Apri `LyriCanto.xcodeproj`

### 3. Compila ed Esegui
Premi Command + R

### 4. Configura l'API Key

1. Apri LyriCanto
2. Vai al tab **"Scarica Audio"**
3. Clicca sull'icona **ingranaggio** (⚙️) in alto a destra
4. Incolla la tua API key:
   ```
   30a766cd84mshfa1cf401d78bce2p18d501jsn32aec82050b4
   ```
5. Clicca "Chiudi"

**Fatto!** Ora puoi scaricare audio da YouTube!

## 📖 Come Usare

### Ricerca Video

1. Nel campo di ricerca, inserisci:
   - Nome canzone + artista (es: "Imagine Dragons Believer")
   - URL YouTube diretto

2. Clicca "Cerca"

3. Vedrai una lista di risultati con:
   - Thumbnail
   - Titolo
   - Canale
   - Durata

### Download Audio

1. Clicca sul video che vuoi scaricare
2. Scegli il formato:
   - **MP3** - Compresso, universale
   - **WAV** - Non compresso, qualità massima
   - **M4A** - Formato Apple, ottima qualità

3. Clicca "Scarica Audio"

4. Attendi il download (barra di progresso)

5. Il file sarà in **~/Downloads**

## 🔍 API Endpoints Usati

LyriCanto usa questi endpoint di YT-API:

### 1. Ricerca Video
```
GET https://yt-api.p.rapidapi.com/search?query={query}
```
Restituisce lista di video con ID, titolo, thumbnail, durata, canale

### 2. Info Video
```
GET https://yt-api.p.rapidapi.com/video/info?id={videoId}
```
Restituisce info dettagliate inclusi stream audio disponibili

### 3. Stream Download
L'API fornisce URL diretti per lo streaming audio che possiamo scaricare

## ⚙️ Caratteristiche YT-API

### Pro ✅
- ✅ Funziona subito con API key
- ✅ Nessuna installazione software
- ✅ Ricerca integrata potente
- ✅ Thumbnail e metadata completi
- ✅ URL diretti per download
- ✅ Qualità audio buona

### Limitazioni ⚠️
- ⚠️ Piano Free: Limiti di utilizzo mensile
- ⚠️ Dipende da servizio RapidAPI
- ⚠️ Richiede connessione internet attiva
- ⚠️ Velocità dipende dall'API provider

## 📊 Limiti del Piano Free

Il piano gratuito di YT-API su RapidAPI include:
- **500 richieste/mese** (molto più di prima!)
- **Rate limiting**: Alcune pause tra richieste consecutive
- **Qualità audio**: Buona qualità, non sempre massima

Per uso intensivo, considera l'upgrade ai piani a pagamento.

## 🐛 Risoluzione Problemi

### Errore 403 "Not Subscribed"

**Causa:** Non sei iscritto a YT-API su RapidAPI

**Soluzione:**
1. Vai su [YT-API su RapidAPI](https://rapidapi.com/ytjar/api/yt-api)
2. Clicca **"Subscribe to Test"**
3. Scegli il piano **"Basic (Free)"**
4. Conferma l'iscrizione
5. La tua API key funzionerà

### Errore 429 "Too Many Requests"

**Causa:** Hai superato il limite di richieste

**Soluzione:**
- Attendi il prossimo ciclo mensile
- Oppure upgrade al piano Pro su RapidAPI

### Errore 401 "Invalid API Key"

**Causa:** API key non valida o scaduta

**Soluzione:**
1. Verifica di aver copiato la key completa
2. Controlla su RapidAPI se la key è ancora attiva
3. Genera una nuova key se necessario

### Download Fallito

**Possibili cause:**
- Video rimosso o privato
- Restrizioni geografiche
- Video protetto da copyright
- Limiti API raggiunti

**Soluzioni:**
- Prova con un altro video
- Verifica che il video sia pubblico
- Controlla il tuo utilizzo mensile su RapidAPI

## 💡 Suggerimenti

### Per Risultati Migliori

1. **Ricerca Precisa**
   - Usa "Titolo - Artista"
   - Aggiungi anno se ci sono ambiguità

2. **URL Diretti**
   - Se conosci già il video, usa l'URL diretto
   - Più veloce della ricerca

3. **Formato MP3**
   - Raccomandato per uso quotidiano
   - Compatibile ovunque
   - Dimensioni ragionevoli

### Ottimizzazione API

- Non cercare ripetutamente lo stesso video
- Usa URL diretti quando possibile
- Limita le ricerche per risparmiare quote

## 🆚 Confronto con yt-dlp

| Caratteristica | YT-API | yt-dlp |
|----------------|--------|--------|
| Setup | ⚡ Immediato | 🔧 Richiede installazione |
| Costo | 💰 Limitato free | 🆓 Totalmente free |
| Limiti | 500/mese | ∞ Illimitato |
| API Key | ✅ Necessaria | ❌ Non serve |
| Qualità | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Affidabilità | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Entrambe le soluzioni sono valide!**
- Usa **YT-API** se preferisci non installare nulla
- Usa **yt-dlp** se vuoi download illimitati e gratuiti

## 📝 Struttura Risposta API

### Search Response
```json
{
  "data": [
    {
      "videoId": "dQw4w9WgXcQ",
      "title": "Rick Astley - Never Gonna Give You Up",
      "channelTitle": "Rick Astley",
      "thumbnail": [
        {
          "url": "https://...",
          "width": 320,
          "height": 180
        }
      ],
      "lengthSeconds": 213
    }
  ]
}
```

### Video Info Response
```json
{
  "adaptiveFormats": [
    {
      "itag": 140,
      "mimeType": "audio/mp4",
      "bitrate": 128000,
      "url": "https://..."
    }
  ]
}
```

## 🔒 Privacy e Sicurezza

### Cosa Salviamo
- ✅ API key in UserDefaults (locale)
- ✅ File scaricati in ~/Downloads

### Cosa NON Salviamo
- ❌ Cronologia ricerche
- ❌ Lista video scaricati
- ❌ Dati personali
- ❌ Analytics

**Privacy completa garantita.**

## 📞 Supporto

### Per problemi con LyriCanto
- 📧 Email: matteo@arteni.it

### Per problemi con YT-API
- 🌐 RapidAPI: [YT-API Dashboard](https://rapidapi.com/ytjar/api/yt-api)
- 📖 Documentazione: Vedi RapidAPI per endpoint details

### Per problemi con RapidAPI
- 🆘 Support: [RapidAPI Help Center](https://docs.rapidapi.com/)

## ⚖️ Note Legali

**Usa questo strumento responsabilmente:**
- ✅ Scarica SOLO contenuti di cui hai i diritti
- ✅ Rispetta copyright e ToS YouTube
- ✅ Uso personale e legittimo

**Disclaimer:**
Teofly e LyriCanto non sono responsabili per uso improprio.
L'utente è l'unico responsabile per l'uso legale del software.

## 🎉 Conclusione

YT-API è una soluzione **eccellente** per scaricare audio da YouTube:
- ✅ Setup velocissimo
- ✅ Nessuna installazione richiesta
- ✅ Funziona subito
- ✅ Buoni limiti per uso normale

Se hai già la API key funzionante (come nel tuo caso), è perfetta!

---

## Copyright

Copyright © 2025-2030 **Teofly** - Tutti i diritti riservati  
Email: matteo@arteni.it

**LyriCanto v1.2.0** - Powered by YT-API (RapidAPI) 🚀
