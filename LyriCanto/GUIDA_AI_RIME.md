# 🎨 AI Rime - Guida Completa

## 📖 Indice
- [Introduzione](#introduzione)
- [Setup Rapido](#setup-rapido)
- [Interfaccia](#interfaccia)
- [Ricerca Rime](#ricerca-rime)
- [Filtri Avanzati](#filtri-avanzati)
- [Provider AI](#provider-ai)
- [Storico e Statistiche](#storico-e-statistiche)
- [Tips & Tricks](#tips--tricks)
- [Troubleshooting](#troubleshooting)

---

## 🌟 Introduzione

**AI Rime** è un assistente intelligente integrato in LyriCanto che ti aiuta a trovare rime, assonanze e parole alternative per i tuoi testi usando l'intelligenza artificiale.

### Caratteristiche Principali

✨ **Ricerca Intelligente**
- Rime perfette, imperfette, assonanze
- Suggerimenti contestuali con definizioni
- Supporto multi-lingua (6 lingue)

🎯 **Filtri Potenti**
- Filtra per lunghezza parola
- Scegli tipo di rima
- Numero risultati configurabile

📊 **Storico & Analytics**
- Salvataggio automatico ricerche
- Statistiche d'uso dettagliate
- Riesplora ricerche passate

---

## ⚡ Setup Rapido

### 1. Verifica API Key

Prima di usare AI Rime, assicurati di avere configurato almeno una API key:

```
LyriCanto → Settings (⌘,) → API Configuration
```

Scegli tra:
- **Claude** (Anthropic) - Raccomandato per la creatività
- **OpenAI** (ChatGPT) - Ottimo per velocità

Non hai una API key? Ottienila qui:
- Claude: [console.anthropic.com](https://console.anthropic.com)
- OpenAI: [platform.openai.com](https://platform.openai.com/api-keys)

### 2. Apri AI Rime

```
Barra laterale → 🎨 AI Rime
```

### 3. Prima Ricerca (30 secondi)

```
1. Scrivi una parola: "amore"
2. Seleziona lingua: Italiano
3. Click "🔍 Cerca Rime"
4. ✅ Vedi risultati con definizioni!
```

---

## 🖥️ Interfaccia

### Layout Principale

```
┌─────────────────────────────────────┐
│ 🎨 AI Rime                          │
├─────────────────────────────────────┤
│ [ Input & Configurazione ]          │
│                                     │
│ ┌───────────────────────────────┐   │
│ │ Parola/Frase: [amore___]     │   │
│ └───────────────────────────────┘   │
│                                     │
│ Tipo: [Parola ▼]  Lingua: [IT ▼]  │
│ Cerca: [Entrambe ▼]                │
│                                     │
│ [🔍 Cerca Rime]                    │
├─────────────────────────────────────┤
│ [ Risultati ]                       │
│                                     │
│ • cuore (8/10) 💙                  │
│   "Organo centrale della..."       │
│                                     │
│ • dolore (7/10)                    │
│   "Sensazione spiacevole..."       │
├─────────────────────────────────────┤
│ [ Storico ] [ Statistiche ]        │
└─────────────────────────────────────┘
```

### Componenti

#### 1. Campo Input
- Inserisci parola singola o frase
- Supporta caratteri speciali e accentati
- Aggiornamento real-time

#### 2. Tipo Input
- **Parola**: Ricerca rime per singola parola
- **Verso**: Trova parole che rimano con l'ultima parola del verso
- **Strofa**: Analizza strofa completa e suggerisci rime

#### 3. Lingua
Seleziona tra:
- 🇮🇹 Italiano
- 🇬🇧 Inglese
- 🇪🇸 Spagnolo
- 🇫🇷 Francese
- 🇩🇪 Tedesco
- 🇵🇹 Portoghese

#### 4. Tipo Ricerca
- **Entrambe**: Rime + assonanze
- **Solo Rime**: Rime perfette e imperfette
- **Solo Assonanze**: Solo assonanze

---

## 🔍 Ricerca Rime

### Ricerca Base

**Input semplice:**
```
Parola: "mare"
Lingua: Italiano
Click: 🔍 Cerca Rime
```

**Risultati tipici:**
```
• amare (9/10) 💕
  "Provare affetto profondo..."
  
• cantare (8/10) 🎵
  "Emettere suoni melodiosi..."
  
• sognare (8/10) ✨
  "Immaginare durante il sonno..."
  
• volare (7/10) 🦅
  "Muoversi nell'aria..."
```

### Score di Compatibilità

Ogni risultato ha un punteggio da 0 a 10:

- **9-10**: Rima perfetta 🎯
- **7-8**: Rima molto buona ✅
- **5-6**: Rima accettabile ⚠️
- **3-4**: Assonanza
- **0-2**: Rima debole

### Con Definizioni

Ogni parola include:
- **Definizione**: Significato principale
- **Contesto**: Esempio d'uso (opzionale)
- **Emoji**: Icona rappresentativa

---

## 🎛️ Filtri Avanzati

### Apertura Filtri

Click sull'icona ⚙️ in alto a destra per aprire le opzioni avanzate.

### Opzioni Disponibili

#### Provider AI
```
[ Claude (Anthropic) ▼ ]
  - Claude (Anthropic) ⭐
  - ChatGPT (OpenAI)
```

Cambia provider in tempo reale senza dover riconfigurare tutto.

#### Max Risultati
```
Max Risultati: [20] ─────
               10  20  30  40  50
```

Regola il numero di suggerimenti (10-50).

#### Includi Definizioni
```
☑️ Includi definizioni
```

Attiva/disattiva le spiegazioni per ogni parola.

#### Filtro Lunghezza
```
Filtra per lunghezza: [Tutte ▼]
```

Opzioni:
- Tutte
- Corte (1-4 lettere)
- Medie (5-7 lettere)
- Lunghe (8+ lettere)

---

## 🤖 Provider AI

### Differenze tra i Provider

| Feature | Claude | OpenAI |
|---------|--------|--------|
| **Creatività** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Velocità** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Definizioni** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Costo** | €€ | €€ |
| **Lingue** | Eccellente | Ottimo |

### Quando Usare Quale

**Usa Claude se:**
- Cerchi suggerimenti creativi
- Vuoi definizioni più dettagliate
- Lavori con testi poetici/letterari

**Usa OpenAI se:**
- Privilegi la velocità
- Fai molte ricerche rapide
- Lavori con testi pop/commerciali

### Cambio Provider

```
1. Click ⚙️ → Provider
2. Seleziona provider desiderato
3. ✅ Salvataggio automatico
```

La prossima ricerca userà il nuovo provider!

---

## 📊 Storico e Statistiche

### Storico Ricerche

Accedi allo storico con il bottone **"📚 Storico"** in basso.

#### Cosa Trovi
- Tutte le tue ricerche passate
- Data e ora di ogni ricerca
- Risultati salvati
- Possibilità di rieseguire

#### Azioni Disponibili
- **👁️ Visualizza**: Vedi risultati completi
- **🔄 Ripeti**: Ri-esegui la ricerca
- **❌ Elimina**: Cancella dalla cronologia

### Statistiche

Click su **"📊 Statistiche"** per vedere:

#### Metriche Principali
```
Totale Ricerche: 127
Rime Trovate: 2,431
Lingue Usate: 3
Provider Preferito: Claude
```

#### Breakdown per Lingua
```
🇮🇹 Italiano: 89 (70%)
🇬🇧 Inglese: 28 (22%)
🇪🇸 Spagnolo: 10 (8%)
```

#### Trend Temporali
- Ricerche per giorno
- Parole più cercate
- Giorni più attivi

---

## 💡 Tips & Tricks

### 1. Usa Versi Completi per Contesto

❌ **Non ottimale:**
```
Input: "notte"
```

✅ **Meglio:**
```
Input: "Sotto il cielo della notte"
Tipo: Verso
```

Risultato: Rime che si adattano al contesto poetico.

### 2. Esplora Varianti

Se "amore" ti dà risultati troppo comuni:
```
1. Prova sinonimi: "affetto", "passione", "sentimento"
2. Usa forme diverse: "amar", "amor", "amato"
3. Cerca assonanze invece di rime perfette
```

### 3. Combina Lingue

Per testi multilingue (es. Reggaeton IT/ES):
```
1. Cerca in italiano
2. Poi cerca in spagnolo
3. Scegli le combinazioni migliori
```

### 4. Sfrutta i Filtri Lunghezza

**Per strofe veloci (rap/trap):**
```
Filtro: Corte (1-4 lettere)
→ Parole snelle e ritmiche
```

**Per ballate lente:**
```
Filtro: Lunghe (8+ lettere)
→ Parole evocative e profonde
```

### 5. Salva Risultati Importanti

Non c'è ancora un sistema di "Preferiti", ma puoi:
```
1. Copia i risultati migliori
2. Incollali in un documento esterno
3. Usa come reference durante la scrittura
```

---

## 🔧 Troubleshooting

### "API Key non configurata"

**Soluzione:**
```
1. LyriCanto → Settings (⌘,)
2. Tab "API Configuration"
3. Seleziona provider (Claude o OpenAI)
4. Incolla API key
5. Click "Salva"
```

### "Errore durante la ricerca"

**Possibili cause:**
1. **API key non valida**
   - Verifica che inizi con `sk-ant-` (Claude) o `sk-` (OpenAI)
   - Controlla che sia attiva su console.anthropic.com o platform.openai.com

2. **Limite rate raggiunto**
   - Attendi qualche secondo
   - Riprova la ricerca

3. **Connessione internet**
   - Verifica connessione
   - Prova a ricaricare l'app

### "Nessun risultato trovato"

**Possibili motivi:**
1. Parola troppo specifica o rara
2. Lingua sbagliata selezionata
3. Filtri troppo restrittivi

**Soluzioni:**
- Prova con una parola più comune
- Verifica la lingua selezionata
- Rimuovi i filtri (⚙️ → Reset)

### "Risultati non pertinenti"

Claude/OpenAI possono occasionalmente dare risultati strani.

**Cosa fare:**
1. Rigenerafacendo click di nuovo su "Cerca"
2. Prova l'altro provider
3. Sii più specifico nell'input

---

## ⚖️ Note su Privacy e Costi

### Privacy
- Le tue ricerche sono inviate a Claude/OpenAI per l'elaborazione
- Nessun dato salvato su server Teofly
- Storico salvato solo localmente sul tuo Mac

### Costi API

**Stima per ricerca:**
- Input: ~100-200 tokens
- Output: ~300-500 tokens
- Costo medio: ~€0.002-0.005 per ricerca

Con 1000 ricerche: ~€2-5

**Consigli per risparmiare:**
- Riduci "Max Risultati" se non serve
- Disattiva "Includi definizioni" per query semplici
- Usa lo Storico per rivedere risultati passati

---

## 🚀 Shortcuts da Tastiera

| Azione | Shortcut |
|--------|----------|
| Cerca rime | ⏎ (Enter) |
| Cancella input | ⌘⌫ |
| Apri storico | ⌘H |
| Apri statistiche | ⌘I |
| Apri opzioni | ⌘, |
| Chiudi finestra | ⌘W |

---

## 📚 Esempi Pratici

### Esempio 1: Scrivere un Rap Verse

**Obiettivo:** Trovare rime per "strada"

```
Input: "strada"
Lingua: Italiano
Cerca: Solo Rime
Filtro Lunghezza: Corte

Risultati:
• spada ⚔️
• prada 👜  
• rada ⚓
• cada 💔
```

**Uso:**
```
Cammino per la strada (strada)
Con la mente come una spada (spada)
Il tempo passa e nulla accada (cada)
Questa vita sembra una rada (rada)
```

### Esempio 2: Ballata Romantica

**Obiettivo:** Rime per verso "Nel silenzio della sera"

```
Input: "Nel silenzio della sera"
Tipo: Verso
Lingua: Italiano
Cerca: Entrambe
Filtro: Lunghe

Risultati:
• sincera 💕
• atmosfera 🌟
• primavera 🌸
• sfera 🔮
```

**Uso:**
```
Nel silenzio della sera (sera)
Ti penso con voce sincera (sincera)
Come la dolce primavera (primavera)
Che avvolge ogni mia sfera (sfera)
```

### Esempio 3: Testo Bilingue (IT/EN)

**Per strofa IT:**
```
Input: "cuore"
Lingua: Italiano
→ amore, dolore, splendore
```

**Per strofa EN:**
```
Input: "heart"
Lingua: Inglese
→ start, art, part
```

**Uso nel ritornello mix:**
```
Il mio cuore (heart) vuole amare
This is just the start (start)
Non voglio più dolore
You're my work of art (art)
```

---

## 🎓 Best Practices

### Do's ✅

1. **Sii specifico** con il contesto (tipo: Verso/Strofa)
2. **Esplora provider diversi** per risultati vari
3. **Usa i filtri** per affinare la ricerca
4. **Salva** (manualmente) i migliori risultati
5. **Sperimenta** con lingue diverse

### Don'ts ❌

1. **Non** fare troppo affidamento su una singola ricerca
2. **Non** usare solo rime perfette (varia!)
3. **Non** ignorare le definizioni (aiutano il contesto)
4. **Non** cercare parole inventate o dialettali molto specifici
5. **Non** aspettarti rime per ogni input (alcune parole sono difficili)

---

## 🔮 Funzionalità Future

In sviluppo per versioni future:

- 🌟 **Preferiti**: Salva rime favorite
- 📱 **Export**: Esporta risultati in TXT/PDF
- 🎨 **Temi**: Ricerca per tema/mood
- 🔄 **Sync cloud**: Sincronizza storico su più dispositivi
- 🧠 **ML locale**: Suggerimenti senza API
- 🎤 **Pronunciation**: Guida alla pronuncia

---

## 📞 Supporto

### Hai domande?

- 📧 Email: matteo@arteni.it
- 📖 Documentazione: README.md
- 🐛 Bug Report: matteo@arteni.it

### Feedback Benvenuto!

Se hai suggerimenti per migliorare AI Rime, scrivi a:
**matteo@arteni.it** con oggetto "AI Rime Feedback"

---

**Sviluppato con ❤️ da Teofly**  
Powered by Claude AI (Anthropic) & OpenAI  
Copyright © 2025 Teofly - Tutti i diritti riservati

*AI Rime - L'assistente intelligente per songwriter e poeti* 🎨✨
