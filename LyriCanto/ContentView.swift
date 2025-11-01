//
//  ContentView.swift
//  LyriCanto
//
//  Main UI for LyriCanto application
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var colorScheme: ColorSchemeManager
    @StateObject private var viewModel = LyriCantoViewModel()
    @State private var showingLicenseAlert = false
    @State private var showingStyleGuidelinesSheet = false
    @State private var originalLyricsHeight: CGFloat = 200
    @State private var generatedLyricsHeight: CGFloat = 400
    
    // Collapse states for sections
    @State private var showAudioSection = true
    @State private var showPlayerSection = true
    @State private var showTrimmerSection = true
    @State private var showSearchSection = true
    @State private var showTranscriptionSection = true
    @State private var showLyricsSection = true
    @State private var showAnalysisSection = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Divider()
            
            // Main Content
            HSplitView {
                // Left Panel - Input
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        importSection
                        analysisSection
                    }
                    .padding()
                }
                .frame(minWidth: 400)
                
                // Right Panel - Output
                outputSection
                    .frame(minWidth: 600)
            }
            
            Divider()
            
            // Status Bar
            statusBar
        }
        .tint(colorScheme.currentScheme.accent.color)
        .alert("Licenza e Diritti", isPresented: $showingLicenseAlert) {
            Button("Annulla", role: .cancel) {}
            Button("Accetto e Procedi") {
                viewModel.hasLicense = true
                Task {
                    await viewModel.generateLyrics(apiKey: appState.getAPIKey(for: viewModel.aiProvider) ?? "")
                }
            }
        } message: {
            Text("Dichiari di avere tutti i diritti necessari per utilizzare questo audio e questi testi? LyriCanto non è responsabile per violazioni di copyright.")
        }
        .sheet(isPresented: $showingStyleGuidelinesSheet) {
            StyleGuidelinesView(viewModel: viewModel)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Prima riga: Titolo + Bottone
            HStack {
                HStack(spacing: 4) {
                    Text("🎵 LyriCanto Teofly")
                        .font(.title)
                        .bold()
                        .foregroundColor(colorScheme.currentScheme.text.color)
                    Text("by Teofly")
                        .font(.title3)
                        .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                }
                
                Spacer()
                
                Button("Linee Guida Stile") {
                    showingStyleGuidelinesSheet = true
                }
                .themedBorderedButton(colorScheme)
            }
            
            // Seconda riga: Campi configurazione
            HStack(spacing: 16) {
                // AI Provider
                VStack(alignment: .leading, spacing: 4) {
                    Text("Provider AI")
                        .font(.caption)
                        .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                    Picker("", selection: $viewModel.aiProvider) {
                        ForEach(AIProvider.allCases, id: \.self) { provider in
                            Text(provider.displayName).tag(provider)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 180)
                }
                
                // Song Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Titolo Canzone")
                        .font(.caption)
                        .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                    TextField("Es. La Mia Canzone", text: $viewModel.songTitle)
                        .themedTextFieldStyle(colorScheme)
                        .frame(width: 200)
                }
                
                // Target Language
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lingua Destinazione")
                        .font(.caption)
                        .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                    Picker("", selection: $viewModel.targetLanguage) {
                        Text("Italiano").tag("IT")
                        Text("English").tag("EN")
                        Text("Español").tag("ES")
                        Text("Français").tag("FR")
                        Text("Deutsch").tag("DE")
                        Text("Português").tag("PT")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                }
                
                // Topic/Theme
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tema/Argomento")
                        .font(.caption)
                        .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                    TextField("Es. viaggio a Trieste", text: $viewModel.topic)
                        .themedTextFieldStyle(colorScheme)
                        .frame(width: 200)
                }
                
                Spacer()
            }
            
            // Terza riga: Controlli generazione
            HStack(spacing: 20) {
                // Phonetic Similarity Slider
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Similarità Fonetica")
                            .font(.caption)
                            .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                        Text(String(format: "%.2f", viewModel.phoneticSimilarity))
                            .font(.caption)
                            .foregroundColor(colorScheme.currentScheme.accent.color)
                    }
                    Slider(value: $viewModel.phoneticSimilarity, in: 0...1)
                        .frame(width: 200)
                }
                
                // Preserve Rhyme Scheme Toggle
                Toggle("Preserva Schema Rime", isOn: $viewModel.preserveRhymeScheme)
                    .toggleStyle(.switch)
                
                Spacer()
                
                // Generate Button
                Button(action: {
                    if !viewModel.hasLicense {
                        showingLicenseAlert = true
                    } else {
                        Task {
                            await viewModel.generateLyrics(apiKey: appState.getAPIKey(for: viewModel.aiProvider) ?? "")
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isGenerating {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(viewModel.isGenerating ? "Generazione..." : "Genera Testo")
                    }
                }
                .themedProminentButton(colorScheme)
                .disabled(!viewModel.canGenerate || viewModel.isGenerating)
            }
        }
        .padding()
        .background(colorScheme.currentScheme.secondaryBackground.color)
    }
    
    // MARK: - Import Section
    private var importSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📥 Importa Audio e Testi")
                .font(.headline)
                .foregroundColor(colorScheme.currentScheme.text.color)
            
            // Audio Import
            DisclosureGroup(isExpanded: $showAudioSection) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button("Seleziona File Audio...") {
                            viewModel.selectAudioFile()
                        }
                        .themedBorderedButton(colorScheme)
                        
                        if let audioURL = viewModel.audioFileURL {
                            Text(audioURL.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                                .lineLimit(1)
                        }
                    }
                    
                    Text("Oppure trascina un file MP3/WAV/AIFF qui")
                        .font(.caption)
                        .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(colorScheme.currentScheme.background.color.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(colorScheme.currentScheme.secondaryText.color.opacity(0.5))
                        )
                        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
                            _ = viewModel.handleAudioDrop(providers: providers)
                            return true
                        }
                    
                    Divider()
                    
                    TextField("URL Fonte Audio (solo CC/licenziata)", text: $viewModel.audioURL)
                        .themedTextFieldStyle(colorScheme)
                    
                    if let duration = viewModel.audioDuration {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                            Text("Durata: \(formatDuration(duration))")
                                .font(.caption)
                                .foregroundColor(colorScheme.currentScheme.text.color)
                        }
                    }
                }
                .padding(10)
            } label: {
                Text("File Audio")
                    .font(.headline)
                    .foregroundColor(colorScheme.currentScheme.text.color)
            }
            
            // v1.5.0 - Audio Player
            if viewModel.audioFileURL != nil && viewModel.playerController.duration > 0 {
                DisclosureGroup(isExpanded: $showPlayerSection) {
                    AudioPlayerView(player: viewModel.playerController)
                        .environmentObject(colorScheme)
                        .padding(10)
                } label: {
                    Label("🎵 Player Audio", systemImage: "play.circle.fill")
                        .font(.headline)
                        .foregroundColor(colorScheme.currentScheme.text.color)
                }
            }
            
            // v1.5.0 - Audio Trimmer
            if viewModel.audioFileURL != nil && viewModel.audioTrimmer.duration > 0 {
                DisclosureGroup(isExpanded: $showTrimmerSection) {
                    AudioTrimmerView(
                        trimmer: viewModel.audioTrimmer,
                        player: viewModel.playerController,
                        bpm: viewModel.bpm,
                        songTitle: viewModel.songTitle
                    )
                    .padding(10)
                } label: {
                    Label("✂️ Trim Audio", systemImage: "scissors")
                        .font(.headline)
                        .foregroundColor(colorScheme.currentScheme.text.color)
                }
            }
            
            // v1.5.0 - Music Search
            DisclosureGroup(isExpanded: $showSearchSection) {
                MusicSearchView(search: viewModel.musicSearch)
                    .environmentObject(colorScheme)
                    .padding(10)
            } label: {
                Label("🔍 Ricerca Brano", systemImage: "magnifyingglass")
                    .font(.headline)
                    .foregroundColor(colorScheme.currentScheme.text.color)
            }
            
            // Transcription Button
            if viewModel.audioFileURL != nil {
                Button {
                    Task {
                        await viewModel.transcribeAudio(apiKey: appState.getAPIKey(for: .openai) ?? "")
                    }
                } label: {
                    HStack {
                        if viewModel.isTranscribing {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(systemName: "waveform.circle.fill")
                        }
                        Text(viewModel.isTranscribing ? viewModel.transcriptionProgress : "🎤 Trascrivi Audio con Whisper")
                    }
                }
                .themedProminentButton(colorScheme)
                .disabled(viewModel.isTranscribing || appState.openaiApiKey.isEmpty)
                .help(appState.openaiApiKey.isEmpty ? "Configura OpenAI API Key nelle Impostazioni" : "Trascrivi automaticamente il testo dall'audio")
            }
            
            // Lyrics Import
            DisclosureGroup(isExpanded: $showLyricsSection) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Testo Originale")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(colorScheme.currentScheme.text.color)
                    
                    TextEditor(text: $viewModel.originalLyrics)
                        .font(.system(.body, design: .monospaced))
                        .frame(height: originalLyricsHeight)
                        .textEditorBackground(colorScheme.currentScheme.background.color)
                        .border(colorScheme.currentScheme.secondaryText.color.opacity(0.3))
                    
                    // Resize handle
                    Rectangle()
                        .fill(colorScheme.currentScheme.secondaryText.color.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                        .overlay(
                            Rectangle()
                                .fill(colorScheme.currentScheme.secondaryText.color.opacity(0.6))
                                .frame(width: 40, height: 3)
                                .cornerRadius(1.5)
                        )
                        .onHover { hovering in
                            if hovering {
                                NSCursor.resizeUpDown.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newHeight = originalLyricsHeight + value.translation.height
                                    originalLyricsHeight = max(100, min(600, newHeight))
                                }
                        )
                    
                    HStack {
                        Button(action: {
                            Task {
                                await viewModel.fetchLyricsFromAPIAsync(apiKey: appState.getAPIKey(for: .openai) ?? "")
                            }
                        }) {
                            HStack {
                                if viewModel.isGenerating && !viewModel.generationProgress.isEmpty {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .frame(width: 16, height: 16)
                                }
                                Text(viewModel.generationProgress.isEmpty ? "Cerca Testi Online" : viewModel.generationProgress)
                            }
                        }
                        .themedBorderedButton(colorScheme)
                        .disabled(viewModel.musicSearch.searchResults.isEmpty || viewModel.isGenerating)
                        .help("Estrae automaticamente i testi da Genius e li incolla nell'editor")
                        
                        Button(action: {
                            NSApplication.shared.sendAction(Selector(("startDictation:")), to: nil, from: nil)
                        }) {
                            Label("Dettatura", systemImage: "mic.fill")
                        }
                        .themedBorderedButton(colorScheme)
                        .help("Attiva dettatura (o usa Fn Fn)")
                        
                        Spacer()
                        
                        if !viewModel.originalLyrics.isEmpty {
                            Text("\(viewModel.originalLyrics.components(separatedBy: .newlines).count) righe")
                                .font(.caption)
                                .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                        }
                    }
                }
                .padding(10)
            } label: {
                Text("Testi")
                    .font(.headline)
                    .foregroundColor(colorScheme.currentScheme.text.color)
            }
            
            // License Checkbox
            Toggle("✓ Dichiaro di avere i diritti/licenza per usare questo audio e questi testi", isOn: $viewModel.hasLicense)
                .toggleStyle(.checkbox)
                .foregroundColor(viewModel.hasLicense ? .green : .red)
        }
    }
    
    // MARK: - Analysis Section
    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔍 Analisi & Markers")
                .font(.headline)
                .foregroundColor(colorScheme.currentScheme.text.color)
            
            DisclosureGroup(isExpanded: $showAnalysisSection) {
                VStack(spacing: 10) {
                    // BPM Section
                    HStack {
                        Text("BPM:")
                            .foregroundColor(colorScheme.currentScheme.text.color)
                        TextField("120", value: $viewModel.bpm, formatter: NumberFormatter())
                            .themedTextFieldStyle(colorScheme)
                            .frame(width: 80)
                        
                        if viewModel.bpmConfidence > 0 {
                            Text("(\(Int(viewModel.bpmConfidence * 100))%)")
                                .font(.caption)
                                .foregroundColor(viewModel.bpmConfidence > 0.7 ? .green : .orange)
                        }
                        
                        Button(viewModel.isAnalyzingAudio ? viewModel.analysisProgress : "🎵 Analizza Audio") {
                            Task {
                                await viewModel.analyzeAudio()
                            }
                        }
                        .themedProminentButton(colorScheme)
                        .disabled(viewModel.audioFileURL == nil || viewModel.isAnalyzingAudio)
                        
                        Spacer()
                    }
                    
                    // Musical Key and Scale
                    if !viewModel.musicalKey.isEmpty {
                        Divider()
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tonalità")
                                    .font(.caption)
                                    .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                                Text("\(viewModel.musicalKey) \(viewModel.scale)")
                                    .font(.system(.body, design: .rounded))
                                    .bold()
                                    .foregroundColor(colorScheme.currentScheme.text.color)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Accordi Suggeriti")
                                    .font(.caption)
                                    .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                                HStack(spacing: 4) {
                                    ForEach(viewModel.suggestedChords.prefix(4), id: \.self) { chord in
                                        Text(chord)
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(colorScheme.currentScheme.accent.color.opacity(0.1))
                                            .cornerRadius(4)
                                            .foregroundColor(colorScheme.currentScheme.text.color)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Divider()
                    
                    // Sections Table
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sezioni")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(colorScheme.currentScheme.text.color)
                            Spacer()
                            Button("Aggiungi Sezione") {
                                viewModel.addSection()
                            }
                            .themedBorderedButton(colorScheme)
                        }
                        
                        ForEach($viewModel.sections) { $section in
                            HStack {
                                Picker("", selection: $section.type) {
                                    Text("Strofa").tag(SectionType.verse)
                                    Text("Ritornello").tag(SectionType.chorus)
                                    Text("Bridge").tag(SectionType.bridge)
                                    Text("Intro").tag(SectionType.intro)
                                    Text("Outro").tag(SectionType.outro)
                                }
                                .frame(width: 120)
                                
                                TextField("00:00", text: $section.startTime)
                                    .frame(width: 60)
                                    .themedTextFieldStyle(colorScheme)
                                
                                Text("→")
                                    .foregroundColor(colorScheme.currentScheme.text.color)
                                
                                TextField("00:30", text: $section.endTime)
                                    .frame(width: 60)
                                    .themedTextFieldStyle(colorScheme)
                                
                                Button(action: {
                                    viewModel.removeSection(section)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    
                    Divider()
                    
                    Button("Analizza Metrica") {
                        viewModel.analyzeMetrics()
                    }
                    .themedProminentButton(colorScheme)
                    .disabled(viewModel.originalLyrics.isEmpty)
                    
                    if let metricsReport = viewModel.metricsReport {
                        ScrollView {
                            Text(metricsReport)
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(colorScheme.currentScheme.secondaryBackground.color.opacity(0.5))
                                .cornerRadius(4)
                                .foregroundColor(colorScheme.currentScheme.text.color)
                        }
                        .frame(maxHeight: 150)
                    }
                }
                .padding(10)
            } label: {
                Text("Configurazione Timing")
                    .font(.headline)
                    .foregroundColor(colorScheme.currentScheme.text.color)
            }
        }
    }
    
    // MARK: - Output Section
    private var outputSection: some View {
        VStack(spacing: 0) {
            // Preview Header - Solo Testo Proposto
            HStack(spacing: 0) {
                Text("Testo Proposto")
                    .font(.headline)
                    .foregroundColor(colorScheme.currentScheme.text.color)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
            }
            .frame(height: 50)
            
            Divider()
            
            // Testo Proposto a tutta larghezza
            ScrollView {
                        if viewModel.isGenerating {
                            VStack {
                                ProgressView()
                                Text("Generazione in corso...")
                                    .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewModel.generatedLyrics != nil {
                            VStack(alignment: .leading, spacing: 12) {
                                // Pulsante per passare alla modalità editing
                                HStack {
                                    if viewModel.editableLines.isEmpty {
                                        Button("✏️ Modifica Righe") {
                                            viewModel.convertToEditableLines()
                                        }
                                        .themedBorderedButton(colorScheme)
                                    } else {
                                        Button("📄 Visualizza Testo") {
                                            viewModel.editableLines = []
                                            viewModel.selectedLineIDs.removeAll()
                                        }
                                        .themedBorderedButton(colorScheme)
                                        
                                        if !viewModel.selectedLineIDs.isEmpty {
                                            Button("🔄 Rigenera Selezionate (\(viewModel.selectedLineIDs.count))") {
                                                Task {
                                                    await viewModel.regenerateSelectedLines(apiKey: appState.getAPIKey(for: viewModel.aiProvider) ?? "")
                                                }
                                            }
                                            .themedProminentButton(colorScheme)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                Divider()
                                
                                // Visualizzazione righe modificabili o testo normale
                                if !viewModel.editableLines.isEmpty {
                                    // Modalità editing con checkbox
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(viewModel.editableLines) { line in
                                            HStack(alignment: .top, spacing: 8) {
                                                Toggle("", isOn: Binding(
                                                    get: { viewModel.selectedLineIDs.contains(line.id) },
                                                    set: { _ in viewModel.toggleLineSelection(line.id) }
                                                ))
                                                .toggleStyle(.checkbox)
                                                .frame(width: 20)
                                                
                                                Text("\(line.lineNumber)")
                                                    .font(.caption)
                                                    .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                                                    .frame(width: 30, alignment: .trailing)
                                                
                                                TextField("", text: Binding(
                                                    get: { line.text },
                                                    set: { newText in
                                                        viewModel.updateLineText(line.id, newText: newText)
                                                    }
                                                ), axis: .vertical)
                                                .textFieldStyle(.plain)
                                                .font(.system(.body, design: .monospaced))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 8)
                                                .background(
                                                    viewModel.selectedLineIDs.contains(line.id) ? colorScheme.currentScheme.accent.color.opacity(0.1) : colorScheme.currentScheme.secondaryBackground.color.opacity(0.5)
                                                )
                                                .cornerRadius(4)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(colorScheme.currentScheme.secondaryText.color.opacity(0.2), lineWidth: 1)
                                                )
                                            }
                                            .padding(.horizontal, 8)
                                        }
                                    }
                                } else {
                                    // Editor di testo libero completamente editabile
                                    VStack(alignment: .leading, spacing: 8) {
                                        TextEditor(text: Binding(
                                            get: { viewModel.generatedLyrics ?? "" },
                                            set: { newValue in
                                                viewModel.generatedLyrics = newValue
                                            }
                                        ))
                                        .font(.system(.body, design: .monospaced))
                                        .frame(height: generatedLyricsHeight)
                                        .textEditorBackground(colorScheme.currentScheme.background.color)
                                        .border(colorScheme.currentScheme.secondaryText.color.opacity(0.3))
                                        .padding(.horizontal)
                                        
                                        // Resize handle per TextEditor
                                        Rectangle()
                                            .fill(colorScheme.currentScheme.secondaryText.color.opacity(0.3))
                                            .frame(height: 4)
                                            .cornerRadius(2)
                                            .overlay(
                                                Rectangle()
                                                    .fill(colorScheme.currentScheme.secondaryText.color.opacity(0.6))
                                                    .frame(width: 40, height: 3)
                                                    .cornerRadius(1.5)
                                            )
                                            .padding(.horizontal)
                                            .onHover { hovering in
                                                if hovering {
                                                    NSCursor.resizeUpDown.push()
                                                } else {
                                                    NSCursor.pop()
                                                }
                                            }
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { value in
                                                        let newHeight = generatedLyricsHeight + value.translation.height
                                                        generatedLyricsHeight = max(200, min(800, newHeight))
                                                    }
                                            )
                                        
                                        // Info righe
                                        if let generated = viewModel.generatedLyrics {
                                            HStack {
                                                Spacer()
                                                Text("\(generated.components(separatedBy: .newlines).count) righe")
                                                    .font(.caption)
                                                    .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                                                    .padding(.horizontal)
                                            }
                                        }
                                    }
                                }
                                
                                // Score di compatibilità
                                if let score = viewModel.compatibilityScore {
                                    Divider()
                                    HStack {
                                        Text("Score Compatibilità:")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(colorScheme.currentScheme.text.color)
                                        Text(String(format: "%.2f", score))
                                            .font(.caption)
                                            .foregroundColor(score >= 0.85 ? .green : (score >= 0.7 ? .orange : .red))
                                        
                                        if score < 0.85 {
                                            Text("(alcune righe potrebbero necessitare raffinamento)")
                                                .font(.caption)
                                                .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                                        }
                                    }
                                    .padding(8)
                                    .background(colorScheme.currentScheme.secondaryBackground.color.opacity(0.5))
                                    .cornerRadius(4)
                                }
                            }
                            .padding()
                        } else {
                            Text("I testi generati appariranno qui...")
                                .foregroundColor(colorScheme.currentScheme.secondaryText.color)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
            
            Divider()
            
            // Export Section
            HStack {
                Text("Esporta:")
                    .font(.headline)
                    .foregroundColor(colorScheme.currentScheme.text.color)
                
                Button("TXT/MD") {
                    viewModel.exportAsText()
                }
                .themedBorderedButton(colorScheme)
                .disabled(viewModel.generatedLyrics == nil)
                
                Button("LRC") {
                    viewModel.exportAsLRC()
                }
                .themedBorderedButton(colorScheme)
                .disabled(viewModel.generatedLyrics == nil)
                
                Button("SRT") {
                    viewModel.exportAsSRT()
                }
                .themedBorderedButton(colorScheme)
                .disabled(viewModel.generatedLyrics == nil)
                
                Button("JSON") {
                    viewModel.exportAsJSON()
                }
                .themedBorderedButton(colorScheme)
                .disabled(viewModel.generatedLyrics == nil)
                
                Button("TXT Avanzato") {
                    viewModel.exportAsAdvancedText()
                }
                .themedProminentButton(colorScheme)
                .disabled(viewModel.generatedLyrics == nil)
                
                Spacer()
            }
            .padding()
            .background(colorScheme.currentScheme.secondaryBackground.color)
        }
    }
    
    // MARK: - Status Bar
    private var statusBar: some View {
        HStack {
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            } else if viewModel.isGenerating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("Elaborazione richiesta a Claude API...")
                        .font(.caption)
                        .foregroundColor(colorScheme.currentScheme.text.color)
                }
            } else {
                Text("Pronto")
                    .font(.caption)
                    .foregroundColor(colorScheme.currentScheme.secondaryText.color)
            }
            
            Spacer()
            
            if let tokens = viewModel.estimatedTokens {
                Text("Token stimati: ~\(tokens)")
                    .font(.caption)
                    .foregroundColor(colorScheme.currentScheme.secondaryText.color)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(colorScheme.currentScheme.secondaryBackground.color)
    }
    
    // MARK: - Helper Functions
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - TextEditor Background Modifier
struct TextEditorBackground: ViewModifier {
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(backgroundColor)
    }
}

// MARK: - Custom TextField Style
struct ThemedTextFieldStyle: TextFieldStyle {
    @ObservedObject var colorScheme: ColorSchemeManager
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(.plain)
            .padding(6)
            .background(colorScheme.currentScheme.background.color)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(colorScheme.currentScheme.secondaryText.color.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(colorScheme.currentScheme.text.color)
    }
}

extension View {
    func textEditorBackground(_ color: Color) -> some View {
        self.modifier(TextEditorBackground(backgroundColor: color))
    }
    
    func themedTextField(_ colorScheme: ColorSchemeManager) -> some View {
        self.foregroundColor(colorScheme.currentScheme.text.color)
    }
    
    func themedBorderedButton(_ colorScheme: ColorSchemeManager) -> some View {
        self.buttonStyle(ThemedBorderedButtonStyle(colorScheme: colorScheme))
    }
    
    func themedProminentButton(_ colorScheme: ColorSchemeManager) -> some View {
        self.buttonStyle(ThemedProminentButtonStyle(colorScheme: colorScheme))
    }
    
    func themedTextFieldStyle(_ colorScheme: ColorSchemeManager) -> some View {
        self.textFieldStyle(ThemedTextFieldStyle(colorScheme: colorScheme))
    }
}

// MARK: - Custom Button Styles
struct ThemedBorderedButtonStyle: ButtonStyle {
    @ObservedObject var colorScheme: ColorSchemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? 
                          colorScheme.currentScheme.buttonBackground.color.opacity(0.8) : 
                          colorScheme.currentScheme.buttonBackground.color)
            )
            .foregroundColor(colorScheme.currentScheme.buttonText.color)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(colorScheme.currentScheme.accent.color.opacity(0.5), lineWidth: 1)
            )
    }
}

struct ThemedProminentButtonStyle: ButtonStyle {
    @ObservedObject var colorScheme: ColorSchemeManager
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? 
                          colorScheme.currentScheme.accent.color.opacity(0.8) : 
                          colorScheme.currentScheme.accent.color)
            )
            .foregroundColor(.white)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(ColorSchemeManager.shared)
    }
}
