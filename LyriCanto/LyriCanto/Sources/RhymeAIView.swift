//
//  RhymeAIView.swift
//  LyriCanto
//
//  Main UI for AI-powered rhyme and phonetic similarity search
//  Tab 4: AI Rime & Assonanze
//

import SwiftUI

struct RhymeAIView: View {
    @StateObject private var viewModel = RhymeAIViewModel()
    @EnvironmentObject var appState: AppState
    
    @State private var showExportSheet = false
    @State private var exportFormat = "txt"
    @State private var exportedContent = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Divider()
            
            // Main Content
            HStack(spacing: 0) {
                // Left Panel - Configuration
                configurationPanel
                    .frame(width: 350)
                
                Divider()
                
                // Right Panel - Results
                resultsPanel
            }
            
            Divider()
            
            // Status Bar
            statusBar
        }
        .sheet(isPresented: $showExportSheet) {
            exportSheet
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text("🎵 AI Rime & Assonanze")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Trova rime perfette con intelligenza artificiale")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quick Stats
            if let response = viewModel.currentResponse {
                HStack(spacing: 16) {
                    StatBadge(
                        label: "Risultati",
                        value: "\(response.totalMatches)",
                        color: .blue
                    )
                    
                    StatBadge(
                        label: "Tempo",
                        value: String(format: "%.1fs", response.processingTime),
                        color: .green
                    )
                    
                    if let tokens = response.tokensUsed {
                        StatBadge(
                            label: "Token",
                            value: "\(tokens)",
                            color: .orange
                        )
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: { viewModel.showHistory.toggle() }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16))
                }
                .buttonStyle(.bordered)
                .popover(isPresented: $viewModel.showHistory) {
                    historyPopover
                }
                
                Button(action: { viewModel.showStatistics.toggle() }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16))
                }
                .buttonStyle(.bordered)
                .popover(isPresented: $viewModel.showStatistics) {
                    statisticsPopover
                }
                
                if viewModel.currentResponse != nil {
                    Button(action: { showExportSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { viewModel.clearResults() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Configuration Panel (Left)
    private var configurationPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Input Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Input")
                        .font(.headline)
                    
                    // Input Type Picker
                    Picker("Tipo Input", selection: $viewModel.inputType) {
                        ForEach(InputType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Text Input
                    if viewModel.inputType == .word {
                        TextField(
                            viewModel.inputType.placeholder,
                            text: $viewModel.inputText
                        )
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 16))
                    } else {
                        TextEditor(text: $viewModel.inputText)
                            .font(.system(size: 14))
                            .frame(height: 80)
                            .border(Color.gray.opacity(0.3), width: 1)
                            .cornerRadius(4)
                    }
                    
                    Text(viewModel.inputType.placeholder)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Search Type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipo di Ricerca")
                        .font(.headline)
                    
                    Picker("", selection: $viewModel.searchType) {
                        ForEach(RhymeSearchType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    
                    Text(viewModel.searchType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                
                // Language Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lingua")
                        .font(.headline)
                    
                    Picker("", selection: $viewModel.language) {
                        ForEach(RhymeLanguage.allCases, id: \.self) { lang in
                            Text("\(lang.rawValue) - \(lang.displayName)").tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Divider()
                
                // AI Provider Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Provider AI")
                        .font(.headline)
                    
                    Picker("Provider", selection: $appState.currentProvider) {
                        ForEach(AIProvider.allCases, id: \.rawValue) { provider in
                            HStack {
                                Image(systemName: provider.iconName)
                                Text(provider.displayName)
                            }
                            .tag(provider)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    
                    Text("Attuale: \(appState.currentProvider.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Advanced Options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Opzioni Avanzate")
                        .font(.headline)
                    
                    HStack {
                        Text("Max Risultati:")
                        Spacer()
                        Stepper("\(viewModel.maxResults)", value: $viewModel.maxResults, in: 10...50, step: 5)
                            .frame(width: 120)
                    }
                    
                    Toggle("Includi definizioni", isOn: $viewModel.includeDefinitions)
                }
                
                Spacer()
                
                // Search Button
                Button(action: performSearch) {
                    HStack {
                        if viewModel.isSearching {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                        Text(viewModel.isSearching ? "Ricerca in corso..." : "🔍 Cerca Rime")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isInputValid || viewModel.isSearching)
            }
            .padding()
        }
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Results Panel (Right)
    private var resultsPanel: some View {
        Group {
            if viewModel.isSearching {
                // Loading State
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text(viewModel.searchProgress)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("L'AI sta elaborando la tua richiesta...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let error = viewModel.errorMessage {
                // Error State
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    
                    Text("Errore")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(error)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Riprova") {
                        viewModel.errorMessage = nil
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if let response = viewModel.currentResponse {
                // Results Display
                VStack(spacing: 0) {
                    // Results Header
                    resultsHeader(response: response)
                    
                    Divider()
                    
                    // Length Filter Tabs
                    lengthFilterTabs(response: response)
                    
                    Divider()
                    
                    // Results List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredResults) { lengthGroup in
                                VStack(alignment: .leading, spacing: 8) {
                                    // Length Header
                                    HStack {
                                        Text("\(lengthGroup.syllableCount) Sillabe")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text("\(lengthGroup.matches.count) risultati")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                    
                                    // Matches
                                    ForEach(lengthGroup.sortedMatches) { match in
                                        matchCard(match: match)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
            } else {
                // Empty State
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("Nessuna ricerca effettuata")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("Inserisci una parola o frase e clicca 'Cerca Rime'")
                        .font(.body)
                        .foregroundColor(.secondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 Suggerimenti:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text("• Prova con parole comuni come 'amore', 'cuore', 'sole'")
                        Text("• Usa frasi per trovare rime multiple")
                        Text("• Sperimenta con lingue diverse")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
            }
        }
    }
    
    // MARK: - Results Header
    private func resultsHeader(response: RhymeSearchResponse) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Risultati per: \"\(response.originalInput)\"")
                    .font(.headline)
                
                Text("\(response.searchType.rawValue) • \(response.language.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Length Filter Tabs
    private func lengthFilterTabs(response: RhymeSearchResponse) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" button
                Button(action: { viewModel.selectedLengthFilter = nil }) {
                    Text("Tutte")
                        .font(.caption)
                        .fontWeight(viewModel.selectedLengthFilter == nil ? .bold : .regular)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            viewModel.selectedLengthFilter == nil
                                ? Color.blue
                                : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(
                            viewModel.selectedLengthFilter == nil
                                ? .white
                                : .primary
                        )
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
                
                // Length-specific buttons
                ForEach(response.resultsByLength.sorted(by: { $0.syllableCount < $1.syllableCount }), id: \.id) { lengthGroup in
                    Button(action: { viewModel.selectedLengthFilter = lengthGroup.syllableCount }) {
                        HStack(spacing: 4) {
                            Text("\(lengthGroup.syllableCount)")
                                .fontWeight(viewModel.selectedLengthFilter == lengthGroup.syllableCount ? .bold : .regular)
                            Text("(\(lengthGroup.matches.count))")
                                .font(.caption2)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            viewModel.selectedLengthFilter == lengthGroup.syllableCount
                                ? Color.blue
                                : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(
                            viewModel.selectedLengthFilter == lengthGroup.syllableCount
                                ? .white
                                : .primary
                        )
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Match Card
    private func matchCard(match: RhymeMatch) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Word and Quality
            HStack {
                Text(match.word)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(match.qualityIndicator)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
            
            // Scores
            HStack(spacing: 16) {
                ScoreBar(
                    label: "Fonetica",
                    value: match.phoneticSimilarity,
                    color: .blue
                )
                
                ScoreBar(
                    label: "Finale",
                    value: match.endingSimilarity,
                    color: .green
                )
            }
            
            // Definition (if available)
            if let definition = match.definition {
                Text(definition)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
// Examples
if !match.examples.isEmpty {
    VStack(alignment: .leading, spacing: 6) {
        ForEach(match.examples, id: \.self) { example in
            HStack(alignment: .top, spacing: 6) {
                Text("•")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16)) // opzionale
                Text(example)
                    .font(.system(size: 16)) // 🔹 aumenta qui la dimensione del testo
                    .foregroundColor(.secondary)
            }
        }
    }
}
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Status Bar
    private var statusBar: some View {
        HStack {
            if !viewModel.searchProgress.isEmpty {
                HStack(spacing: 8) {
                    if viewModel.isSearching {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    Text(viewModel.searchProgress)
                        .font(.caption)
                }
            } else {
                Text("Pronto")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let response = viewModel.currentResponse {
                Text("Elaborazione: \(String(format: "%.2f", response.processingTime))s")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let tokens = response.tokensUsed {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("Token: \(tokens)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Export Sheet
    private var exportSheet: some View {
        VStack(spacing: 20) {
            Text("Esporta Risultati")
                .font(.title2)
                .fontWeight(.bold)
            
            Picker("Formato", selection: $exportFormat) {
                Text("📄 Testo (TXT)").tag("txt")
                Text("📝 Markdown (MD)").tag("md")
                Text("💾 JSON").tag("json")
            }
            .pickerStyle(.radioGroup)
            
            HStack {
                Button("Annulla") {
                    showExportSheet = false
                }
                
                Spacer()
                
                Button("Esporta") {
                    exportedContent = viewModel.exportResults(format: exportFormat)
                    saveToFile()
                    showExportSheet = false
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(30)
        .frame(width: 400)
    }
    
    // MARK: - History Popover
    private var historyPopover: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Storico Ricerche")
                    .font(.headline)
                
                Spacer()
                
                if !viewModel.searchHistory.isEmpty {
                    Button("Cancella") {
                        viewModel.clearHistory()
                    }
                    .font(.caption)
                }
            }
            
            Divider()
            
            if viewModel.searchHistory.isEmpty {
                Text("Nessuna ricerca precedente")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.searchHistory) { item in
                            Button(action: {
                                viewModel.loadHistoryItem(item)
                                viewModel.showHistory = false
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.searchText)
                                            .font(.body)
                                            .lineLimit(1)
                                        
                                        HStack {
                                            Text(item.searchType.rawValue)
                                            Text("•")
                                            Text("\(item.resultCount) risultati")
                                            Text("•")
                                            Text(item.timeAgo)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .padding()
        .frame(width: 350)
    }
    
    // MARK: - Statistics Popover
    private var statisticsPopover: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistiche Utilizzo")
                .font(.headline)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                StatRow(
                    label: "Ricerche totali",
                    value: "\(viewModel.statistics.totalSearches)"
                )
                
                StatRow(
                    label: "Corrispondenze trovate",
                    value: "\(viewModel.statistics.totalMatchesFound)"
                )
                
                StatRow(
                    label: "Media per ricerca",
                    value: String(format: "%.1f", viewModel.statistics.averageMatchesPerSearch)
                )
                
                Divider()
                
                StatRow(
                    label: "Tipo preferito",
                    value: viewModel.statistics.favoriteSearchType.rawValue
                )
                
                StatRow(
                    label: "Lingua più usata",
                    value: viewModel.statistics.mostUsedLanguage.displayName
                )
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    // MARK: - Helper Functions
    private func performSearch() {
        guard let apiKey = appState.getAPIKey(for: appState.currentProvider),
              !apiKey.isEmpty else {
            viewModel.errorMessage = "API Key non configurata. Vai in Impostazioni per configurarla."
            return
        }
        
        Task {
            await viewModel.performSearch(
                apiKey: apiKey,
                provider: appState.currentProvider
            )
        }
    }
    
    private func saveToFile() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [exportFormat == "json" ? .json : .plainText]
        panel.nameFieldStringValue = "lyricanto_rime_\(Date().timeIntervalSince1970).\(exportFormat)"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? exportedContent.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ScoreBar: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value))
                }
            }
            .frame(height: 6)
            .cornerRadius(3)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
}
