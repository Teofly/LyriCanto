//
//  UserGuideView.swift
//  LyriCanto
//
//  Comprehensive user guide
//  Version 1.2.0 - Added AI Rime section
//

import SwiftUI

struct UserGuideView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedSection = 0
    
    let sections = [
        "Introduzione",
        "Importare Audio",
        "Player & Trimmer",
        "🆕 AI Rime",
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
                    case 3: rhymeAISection
                    case 4: searchSection
                    case 5: lyricsSection
                    case 6: analysisSection
                    case 7: generationSection
                    case 8: exportSection
                    case 9: colorSchemeSection
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
            
            Text("Versione 1.2.0")
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
            • 🎨 AI Rime - Assistente intelligente per ricerca rime (NUOVO v1.2.0!)
            • 🎵 Audio Player con waveform
            • ✂️ Audio Trimmer per tagliare sezioni
            • 🔍 Ricerca brani su Google
            • 🎤 Trascrizione automatica (Whisper AI)
            • 🎚️ Analisi BPM, tonalità e accordi
            • 🤖 Generazione testi AI (Claude & OpenAI)
            • 💾 Export in 4 formati (TXT, LRC, SRT, JSON)
            • 🎨 Schemi colori personalizzabili
            
            **Workflow consigliato:**
            1. Importa file audio
            2. Usa Player/Trimmer per ascoltare
            3. Cerca info brano online (opzionale)
            4. Trascrivi o inserisci testi originali
            5. Usa AI Rime per trovare alternative (NUOVO!)
            6. Analizza audio (BPM, tonalità)
            7. Genera nuovi testi con AI
            8. Esporta risultato
            
            **Novità v1.2.0:**
            • 🎨 AI Rime: Trova rime, assonanze e alternative
            • 🤖 Dual Provider: Scegli tra Claude e OpenAI
            • 📚 Storico ricerche AI Rime
            • 📊 Statistiche d'uso
            • 🌍 6 lingue supportate (IT, EN, ES, FR, DE, PT)
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
    
    var rhymeAISection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎨 AI Rime (NUOVO v1.2.0)")
                .font(.title2)
                .bold()
            
            Text("""
            **Cos'è AI Rime?**
            
            Un assistente intelligente che ti aiuta a trovare rime, assonanze e parole alternative \
            per i tuoi testi usando Claude o OpenAI.
            
            **Come accedere:**
            • Barra laterale → 🎨 AI Rime
            
            **Funzionalità principali:**
            
            1. **Ricerca Rime Intelligente**
               • Inserisci una parola o un verso completo
               • L'AI suggerisce rime perfette, imperfette e assonanze
               • Ogni suggerimento include definizione e score di compatibilità
            
            2. **Multi-Lingua**
               • Italiano 🇮🇹
               • Inglese 🇬🇧
               • Spagnolo 🇪🇸
               • Francese 🇫🇷
               • Tedesco 🇩🇪
               • Portoghese 🇵🇹
            
            3. **Filtri Avanzati**
               • Filtra per lunghezza parola (corte/medie/lunghe)
               • Scegli tipo: solo rime, solo assonanze, o entrambe
               • Numero risultati configurabile (10-50)
               • Includi/escludi definizioni
            
            4. **Dual Provider**
               • Scegli tra Claude (Anthropic) o OpenAI
               • Claude: Più creativo, ottimo per testi poetici
               • OpenAI: Più veloce, ottimo per testi pop
            
            5. **Storico Ricerche**
               • Tutte le ricerche salvate automaticamente
               • Visualizza, riesegui o elimina ricerche passate
               • Click 📚 Storico per accedere
            
            6. **Statistiche**
               • Totale ricerche effettuate
               • Rime trovate
               • Lingue più usate
               • Provider preferito
               • Click 📊 Statistiche per vedere
            
            **Esempio d'uso:**
            
            1. Scrivi "amore" nel campo input
            2. Seleziona lingua: Italiano
            3. Click "🔍 Cerca Rime"
            4. Vedi risultati con score:
               • cuore (9/10) 💙
               • dolore (8/10) 😢
               • splendore (7/10) ✨
            5. Usa le parole nei tuoi testi!
            
            **Tips Pro:**
            
            💡 Usa il tipo "Verso" per cercare rime contestuali
            💡 Combina con la riscrittura AI per risultati ottimali
            💡 Prova entrambi i provider per variare i suggerimenti
            💡 Usa i filtri per parole specifiche (es. solo corte per rap)
            
            **Shortcut:**
            • ⏎ (Enter) = Cerca rime
            • ⌘H = Apri storico
            • ⌘I = Apri statistiche
            
            **Note:**
            • Richiede API key configurata (Claude o OpenAI)
            • Costo medio: ~€0.002-0.005 per ricerca
            • Storico salvato solo localmente (privacy garantita)
            
            Per la guida completa, vedi: GUIDA_AI_RIME.md
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
            
            3. **Cerca online**
               • Click "Cerca Testi"
               • Inserisci titolo e artista
               • I testi vengono popolati automaticamente (se disponibili)
            
            **Strumenti editor:**
            • 🗑️ Elimina righe vuote
            • 🎤 Dettatura vocale (Fn Fn)
            • ↔️ Ridimensiona editor
            
            **Tips:**
            💡 Mantieni una riga vuota tra strofe per migliore struttura
            💡 Usa la trascrizione Whisper se non hai i testi
            💡 Correggi sempre eventuali errori prima di generare
            """)
            .font(.body)
        }
    }
    
    var analysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔍 Analisi Audio & Metrica")
                .font(.title2)
                .bold()
            
            Text("Analisi Audio Automatica")
                .font(.headline)
            
            Text("""
            Quando carichi un file audio, LyriCanto analizza automaticamente:
            
            **BPM (Battute Per Minuto):**
            • Rilevamento automatico del tempo
            • Confidence score (affidabilità)
            • Modificabile manualmente se necessario
            
            **Tonalità (Musical Key):**
            • Chiave musicale rilevata (es: C Major, A Minor)
            • Scala (Major/Minor)
            • Utile per suggerire accordi compatibili
            
            **Accordi Suggeriti:**
            • Lista accordi comuni per quella tonalità
            • Basata su progressioni standard
            • Utile per musicisti e compositori
            """)
            .font(.body)
            
            Divider()
            
            Text("Analisi Metrica Testi")
                .font(.headline)
            
            Text("""
            **Click "Analizza Metrica" per:**
            
            1. **Conteggio Sillabe**
               • Ogni riga viene analizzata
               • Conteggio preciso per lingua selezionata
               • Supporto regole italiane (sinalefe, etc.)
            
            2. **Schema di Rime**
               • Rilevamento automatico (AABB, ABAB, ABBA, etc.)
               • Evidenzia parole che rimano
               • Utile per preservare struttura
            
            3. **Warnings**
               • Irregolarità metriche
               • Righe troppo lunghe/corte
               • Suggerimenti miglioramento
            
            **Report generato include:**
            • Sillabe per ogni riga
            • Schema rime identificato
            • Score compatibilità testo-musica
            • Warnings e suggerimenti
            
            **Tips:**
            💡 Analizza sempre prima di generare con AI
            💡 Se score < 0.70, considera di rivedere i parametri
            💡 Usa lo score come guida, non come regola assoluta
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
            **Configurazione parametri:**
            
            1. **Lingua Target**
               • IT, EN, ES, FR, DE, PT
               • Lingua del testo riscritto
            
            2. **Tema**
               • Descrivi il nuovo tema in dettaglio
               • Più specifico = risultati migliori
               • Es: "viaggio a New York, libertà, grattacieli illuminati"
            
            3. **Similarità Fonetica (0.0-1.0)**
               • 0.0-0.3: Creatività massima
               • 0.4-0.6: Bilanciato (raccomandato)
               • 0.7-1.0: Conservativo (simile a originale)
            
            4. **Preserva Rime**
               • ON: Mantiene schema rime originale
               • OFF: Libertà creativa maggiore
            
            5. **Provider AI (v1.2.0)**
               • Claude: Più creativo, testi poetici
               • OpenAI: Più veloce, testi pop
            
            **Linee Guida Stile (Opzionali):**
            
            Click "Linee Guida Stile" per configurare:
            • **Lessico**: poetico, tecnico, informale
            • **Registro**: formale, neutrale, colloquiale
            • **Tono**: umoristico, serio, romantico, nostalgico
            • **Note custom**: Qualsiasi altra indicazione
            
            **Processo di generazione:**
            
            1. Click "Genera Testo"
            2. Attendi elaborazione (10-60 secondi)
            3. Vedi risultato nel pannello destro
            4. Confronta con originale (side-by-side)
            5. Controlla score di compatibilità
            6. Se necessario, rigenera con parametri diversi
            
            **Score di Compatibilità:**
            • 0.90-1.00: Eccellente ✅
            • 0.80-0.89: Molto buono ✅
            • 0.70-0.79: Buono ⚠️
            • < 0.70: Da migliorare ❌
            
            **Tips:**
            💡 Prova entrambi i provider (Claude e OpenAI) per variare
            💡 Se score basso, aumenta similarità fonetica
            💡 Descrivi il tema in modo molto dettagliato
            💡 Usa AI Rime per trovare alternative prima di generare
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
            **Formati disponibili:**
            
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
            
            **5. TXT Avanzato (v1.1.0+)**
            • Report completo con comparazione riga per riga
            • Include analisi musicale completa
            • Metadata brano e artista
            • Copyright Teofly 2025-2030
            
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
            • Score compatibilità
            
            **Tips:**
            💡 Usa LRC per sincronizzare con audio
            💡 Usa SRT per creare video con sottotitoli
            💡 Usa JSON per integrazioni custom
            💡 Usa TXT Avanzato per report professionale
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
