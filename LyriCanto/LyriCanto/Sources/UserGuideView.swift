//
//  UserGuideView.swift
//  LyriCanto
//
//  Comprehensive user guide
//

import SwiftUI

struct UserGuideView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedSection = 0
    
    let sections = [
        "Introduzione",
        "Importare Audio",
        "Player & Trimmer",
        "Ricerca Brani",
        "Inserire Testi",
        "Analisi Audio",
        "Generazione AI",
        "Export",
        "Schema Colori"
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            List(selection: $selectedSection) {
                ForEach(0..<sections.count, id: \.self) { index in
                    Text(sections[index])
                        .tag(index)
                }
            }
            .frame(width: 200)
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedSection {
                    case 0: introSection
                    case 1: audioImportSection
                    case 2: playerTrimmerSection
                    case 3: searchSection
                    case 4: lyricsSection
                    case 5: analysisSection
                    case 6: generationSection
                    case 7: exportSection
                    case 8: colorSchemeSection
                    default: introSection
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 900, height: 700)
    }
    
    // MARK: - Sections
    
    var introSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎵 LyriCanto by Teofly")
                .font(.largeTitle)
                .bold()
            
            Text("Versione 1.5.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Benvenuto!")
                .font(.title2)
                .bold()
            
            Text("""
            LyriCanto è uno strumento professionale per la creazione di testi musicali in diverse lingue, \
            mantenendo metrica, rime e struttura originale.
            
            **Funzionalità principali:**
            • Audio Player con waveform
            • Audio Trimmer per tagliare sezioni
            • Ricerca brani su Google
            • Trascrizione automatica (Whisper AI)
            • Analisi BPM, tonalità e accordi
            • Generazione testi AI (Claude & OpenAI)
            • Export in 4 formati (TXT, LRC, SRT, JSON)
            • Schemi colori personalizzabili
            
            **Workflow consigliato:**
            1. Importa file audio
            2. Usa Player/Trimmer per ascoltare
            3. Cerca info brano online (opzionale)
            4. Trascrivi o inserisci testi originali
            5. Analizza audio (BPM, tonalità)
            6. Genera nuovi testi con AI
            7. Esporta risultato
            """)
            .font(.body)
        }
    }
    
    var audioImportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📥 Importare Audio")
                .font(.title2)
                .bold()
            
            Text("""
            **Metodi per importare audio:**
            
            1. **Click su "Seleziona File Audio..."**
               • Formati supportati: MP3, WAV, AIFF, M4A
               • Max dimensione consigliata: 50 MB
            
            2. **Drag & Drop**
               • Trascina file nella zona tratteggiata
               • Il file verrà caricato automaticamente
            
            **Informazioni visualizzate:**
            • Nome file
            • Durata totale
            • Formato audio
            
            **Note importanti:**
            ⚠️ Assicurati di avere i diritti per usare l'audio
            ⚠️ Solo file audio da fonti legali (CC, licenziati, etc.)
            
            **URL Fonte Audio:**
            Inserisci l'URL da cui proviene l'audio per riferimento futuro.
            """)
            .font(.body)
        }
    }
    
    var playerTrimmerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎧 Player & Trimmer")
                .font(.title2)
                .bold()
            
            Text("Audio Player")
                .font(.headline)
            
            Text("""
            **Controlli disponibili:**
            • ▶️ Play/Pause
            • ⏹ Stop
            • ⏪⏩ Skip ±10 secondi
            • 🔊 Volume slider
            • 🔄 Loop mode
            • ⚡️ Velocità (0.5x - 2.0x)
            
            **Waveform:**
            • Visualizzazione forma d'onda
            • Click sulla waveform per saltare
            • Indicatore posizione in tempo reale
            """)
            .font(.body)
            
            Divider()
            
            Text("Audio Trimmer")
                .font(.headline)
            
            Text("""
            **Come usare il Trimmer:**
            
            1. **Imposta punti di taglio:**
               • Trascina i cursori blu sulla waveform
               • Oppure usa gli slider Inizio/Fine
            
            2. **Preview:**
               • Click "Preview Loop" per ascoltare solo la sezione
               • Affina i punti di taglio
            
            3. **Esporta:**
               • Click "💾 Salva Trimmed"
               • Scegli percorso di salvataggio
               • File salvato in formato M4A
            
            **Tips:**
            💡 Usa il loop per verificare che la sezione sia perfetta
            💡 Ideale per isolare strofe, ritornelli, intro, outro
            """)
            .font(.body)
        }
    }
    
    var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔍 Ricerca Brani")
                .font(.title2)
                .bold()
            
            Text("""
            **Come cercare un brano:**
            
            1. Inserisci nel campo ricerca:
               • Titolo + artista
               • Es: "Bohemian Rhapsody Queen"
            
            2. Click "🔍 Cerca"
            
            3. Risultati mostrati:
               • **Artista** e **Album**
               • **Anno** di pubblicazione
               • **Genere** musicale
               • **BPM** (battute per minuto)
               • **Tonalità** (key)
               • **Durata**
            
            **Link diretti disponibili:**
            • 🎥 YouTube
            • 🎵 Spotify
            • 🍎 Apple Music
            • 📝 Genius (testi)
            • 📚 Wikipedia
            
            **Preview testi:**
            Quando disponibili, vedrai un'anteprima dei primi versi del brano.
            
            **Uso dei dati:**
            • Le info BPM e tonalità vengono popolate automaticamente
            • Utile per validare le tue analisi audio
            • I link aiutano a trovare risorse aggiuntive
            """)
            .font(.body)
        }
    }
    
    var lyricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📝 Inserire Testi")
                .font(.title2)
                .bold()
            
            Text("""
            **Tre modi per inserire i testi:**
            
            1. **Trascrizione automatica (Whisper AI)**
               • Se hai caricato audio, click "Trascrivi con Whisper"
               • Attendi l'elaborazione (può richiedere 1-2 min)
               • Testi appaiono automaticamente
               • Rivedi e correggi eventuali errori
            
            2. **Digitazione manuale**
               • Scrivi o incolla testi nell'editor
               • Usa il TextEditor ridimensionabile
               • Trascina il bordo inferiore per espandere
            
            3. **Dettatura vocale** 🎤
               • Click sul pulsante "🎤 Dettatura"
               • Parla chiaramente nel microfono
               • macOS trascriverà le tue parole
               • Utile per bozze veloci
            
            **Formattazione testi:**
            • Una strofa per blocco
            • Lascia righe vuote tra le sezioni
            • Usa [Strofa], [Ritornello], [Ponte] per strutturare
            
            **Counter righe:**
            Vedrai il numero di righe in basso a destra.
            
            **⚠️ Dichiarazione diritti:**
            Prima di procedere, spunta la casella:
            "✓ Dichiaro di avere i diritti/licenza per usare questo audio e questi testi"
            
            Questo è obbligatorio per la generazione AI.
            """)
            .font(.body)
        }
    }
    
    var analysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔍 Analisi Audio")
                .font(.title2)
                .bold()
            
            Text("""
            **Analisi BPM e Tonalità:**
            
            1. **Analisi automatica:**
               • Click "🎵 Analizza Audio"
               • Attendere elaborazione (30-60 secondi)
               • Risultati popolati automaticamente
            
            2. **Risultati ottenuti:**
               • **BPM** (Beats Per Minute)
                 - Confidenza % mostrata
                 - Verde (>70%) = alta confidenza
                 - Arancio (<70%) = bassa confidenza
               
               • **Tonalità musicale**
                 - Es: "C Major", "Am", "F# Minor"
               
               • **Scala**
                 - Maggiore o Minore
               
               • **Accordi suggeriti**
                 - I primi 4 accordi della progressione
                 - Basati sulla tonalità rilevata
            
            **Inserimento manuale:**
            Puoi sempre inserire BPM manualmente se conosci il valore esatto.
            
            **Sezioni temporali:**
            • Click "Aggiungi Sezione" per definire parti del brano
            • Imposta nome (es: "Intro", "Strofa 1", "Ritornello")
            • Definisci Start Time e End Time (formato MM:SS)
            • Utile per sincronizzare testi con timing
            
            **Analisi metrica:**
            Click "Analizza Metrica" per un report su:
            • Sillabe per riga
            • Schema rime
            • Pattern ritmici
            """)
            .font(.body)
        }
    }
    
    var generationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🤖 Generazione AI")
                .font(.title2)
                .bold()
            
            Text("""
            **Provider AI disponibili:**
            • Claude Sonnet 4 (Anthropic)
            • GPT-4 Turbo (OpenAI)
            
            **Setup iniziale:**
            1. Menu → Settings (⌘,)
            2. Inserisci API key del provider scelto
            3. Salva
            
            **Parametri di generazione:**
            
            **1. Lingua target**
               • Scegli lingua di destinazione (Italiano, Inglese, etc.)
            
            **2. Registro**
               • Formale: linguaggio forbito
               • Informale: colloquiale
               • Poetico: artistico ed evocativo
            
            **3. Similarità fonetica** (0.0 - 1.0)
               • 0.0 = nessuna similarità fonetica
               • 1.0 = massima similarità sonora
               • Consigliato: 0.6 - 0.8
            
            **4. Preserva schema rime**
               • ✓ ON: mantiene pattern AABB, ABAB, etc.
               • ✗ OFF: più libertà creativa
            
            **Processo di generazione:**
            1. Verifica che tutti i dati siano inseriti
            2. Spunta checkbox diritti
            3. Click "✨ Genera Testo"
            4. Attendi 20-60 secondi
            5. Testo appare a destra nell'editor
            
            **Editing selettivo:**
            • Seleziona righe specifiche nel testo generato
            • Click "🔄 Rigenera Righe Selezionate"
            • Solo quelle righe verranno rigenerate
            • Perfetto per affinare dettagli
            
            **Tips:**
            💡 Più alto il BPM, più corte le sillabe consigliate
            💡 Usa Similarità fonetica alta per assonanze
            💡 Prova diversi registri per trovare il tone giusto
            """)
            .font(.body)
        }
    }
    
    var exportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💾 Export")
                .font(.title2)
                .bold()
            
            Text("""
            **Formati di export disponibili:**
            
            **1. TXT (Testo semplice)**
            • Testi puri senza timing
            • Ideale per: documentazione, social media, siti web
            
            **2. LRC (Lyrics)**
            • Formato con timestamp [MM:SS.xx]
            • Compatibile con: lettori musicali, karaoke
            • Include timing per ogni riga
            
            **3. SRT (Subtitles)**
            • Formato sottotitoli universale
            • Compatibile con: video editor, lettori video
            • Include numero blocco, timing, testo
            
            **4. JSON**
            • Formato strutturato per sviluppatori
            • Include: metadata, sezioni, timing, testi
            • Ideale per: app, database, analisi dati
            
            **Come esportare:**
            1. Scegli formato dal menu dropdown
            2. Click "💾 Esporta"
            3. Scegli percorso salvataggio
            4. Conferma
            
            **Contenuto incluso:**
            • Tutti i testi generati
            • Metadata (artista, titolo, BPM, tonalità)
            • Sezioni (se definite)
            • Timestamp (per formati LRC/SRT)
            
            **Tips:**
            💡 Usa LRC per sincronizzare con audio
            💡 Usa SRT per creare video con sottotitoli
            💡 Usa JSON per integrazioni custom
            💡 Usa TXT per condivisione veloce
            """)
            .font(.body)
        }
    }
    
    var colorSchemeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎨 Schema Colori")
                .font(.title2)
                .bold()
            
            Text("""
            **Personalizza l'interfaccia:**
            
            Menu → Schema Colori (⌘⇧K)
            
            **Temi predefiniti:**
            
            1. **Chiaro (Default)**
               • Sfondo bianco
               • Ideale per luce diurna
            
            2. **Scuro**
               • Sfondo nero/grigio scuro
               • Riduce affaticamento visivo
               • Ideale per sessioni serali
            
            3. **Oceano**
               • Tonalità blu/azzurre
               • Rilassante e professionale
            
            4. **Tramonto**
               • Tonalità calde arancio/rosa
               • Atmosfera calda e creativa
            
            5. **Foresta**
               • Tonalità verdi
               • Naturale e riposante
            
            **Editor personalizzato:**
            
            Click "Personalizza Colori..." per modificare:
            • Sfondo principale
            • Sfondo secondario (pannelli)
            • Colore testo primario
            • Colore testo secondario
            • Colore accento (pulsanti, link)
            • Sfondo pulsanti
            • Testo pulsanti
            
            **Come personalizzare:**
            1. Scegli un preset come base
            2. Click "Personalizza Colori..."
            3. Usa i color picker per ogni elemento
            4. Preview in tempo reale
            5. Click "Applica" per salvare
            
            **Schema salvato automaticamente:**
            Le tue preferenze vengono memorizzate e applicate al prossimo avvio.
            
            **Shortcut:**
            ⌘⇧K = Apri Schema Colori
            """)
            .font(.body)
        }
    }
}

#Preview {
    UserGuideView()
}
