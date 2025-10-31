//
//  LyriCantoViewModel.swift
//  LyriCanto
//
//  ViewModel with business logic
//

import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

enum SectionType: String, Codable, CaseIterable {
    case verse = "Strofa"
    case chorus = "Ritornello"
    case bridge = "Bridge"
    case intro = "Intro"
    case outro = "Outro"
}

struct LyricSection: Identifiable, Codable {
    var id = UUID()
    var type: SectionType
    var startTime: String
    var endTime: String
}

struct EditableLine: Identifiable, Codable {
    var id = UUID()
    var text: String
    var lineNumber: Int
    var isSelected: Bool = false
}

@MainActor
class LyriCantoViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var songTitle: String = ""
    @Published var targetLanguage: String = "IT"
    @Published var topic: String = ""
    @Published var phoneticSimilarity: Double = 0.6
    @Published var preserveRhymeScheme: Bool = true
    @Published var aiProvider: AIProvider = .claude
    
    @Published var audioFileURL: URL?
    @Published var audioURL: String = ""
    @Published var audioDuration: TimeInterval?
    @Published var originalLyrics: String = ""
    @Published var hasLicense: Bool = false
    
    @Published var bpm: Int = 120
    @Published var sections: [LyricSection] = []
    @Published var metricsReport: String?
    
    // Audio Analysis Properties
    @Published var musicalKey: String = ""
    @Published var scale: String = ""
    @Published var suggestedChords: [String] = []
    @Published var bpmConfidence: Double = 0.0
    @Published var isAnalyzingAudio: Bool = false
    @Published var analysisProgress: String = ""
    
    @Published var generatedLyrics: String?
    @Published var editableLines: [EditableLine] = []
    @Published var compatibilityScore: Double?
    @Published var isGenerating: Bool = false
    @Published var isTranscribing: Bool = false
    @Published var errorMessage: String?
    @Published var estimatedTokens: Int?
    
    @Published var styleGuidelines: StyleGuidelines = StyleGuidelines()
    @Published var transcriptionProgress: String = ""
    @Published var generationProgress: String = ""
    @Published var selectedLineIDs: Set<UUID> = []
    
    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?
    private let aiClient = AIAPIClient()
    private let metricsValidator = MetricsValidator()
    private let audioAnalyzer = AudioAnalyzer()
    
    // v1.5.0 - New features
    let playerController = AudioPlayerController()
    let audioTrimmer = AudioTrimmer()
    let musicSearch = GoogleMusicSearch()
    
    // MARK: - Computed Properties
    var canGenerate: Bool {
        !originalLyrics.isEmpty &&
        !targetLanguage.isEmpty &&
        hasLicense
    }
    
    // MARK: - Audio Handling
    func selectAudioFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            UTType.mp3,
            UTType.wav,
            UTType(filenameExtension: "aiff")!
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                loadAudioFile(url)
            }
        }
    }
    
    func handleAudioDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            if let data = item as? Data,
               let url = URL(dataRepresentation: data, relativeTo: nil) {
                DispatchQueue.main.async {
                    self.loadAudioFile(url)
                }
            }
        }
        
        return true
    }
    
    private func loadAudioFile(_ url: URL) {
        audioFileURL = url
        
        // Get audio duration using modern async API
        Task {
            do {
                let asset = AVURLAsset(url: url)
                
                // Use async load for macOS 13.0+
                let duration = try await asset.load(.duration)
                await MainActor.run {
                    audioDuration = duration.seconds
                }
                
                // Try to load audio player
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                
                // Load new player controller and trimmer (v1.5.0)
                try await playerController.loadAudio(url: url)
                try await audioTrimmer.loadAudio(url: url)
                
            } catch {
                await MainActor.run {
                    errorMessage = "Errore nel caricamento audio: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func analyzeAudio() async {
        guard let audioURL = audioFileURL else {
            errorMessage = "Nessun file audio caricato"
            return
        }
        
        isAnalyzingAudio = true
        analysisProgress = "Analisi audio in corso..."
        errorMessage = nil
        
        do {
            analysisProgress = "Rilevamento BPM..."
            
            // Perform full audio analysis
            let result = try await audioAnalyzer.analyze(audioURL: audioURL)
            
            // Update all properties
            bpm = Int(round(result.bpm))
            bpmConfidence = result.confidence
            musicalKey = result.key.displayName
            scale = result.scale.rawValue
            suggestedChords = result.suggestedChords.map { $0.displayName }
            
            analysisProgress = "Completato!"
            
            // Show success message with details
            let confidencePercent = Int(result.confidence * 100)
            errorMessage = """
            ✅ Analisi completata con successo!
            
            BPM: \(bpm) (\(confidencePercent)% confidenza)
            Tonalità: \(musicalKey) \(scale)
            Accordi suggeriti: \(suggestedChords.prefix(4).joined(separator: ", "))
            """
            
        } catch {
            errorMessage = "Errore analisi audio: \(error.localizedDescription)"
            analysisProgress = ""
        }
        
        isAnalyzingAudio = false
    }
    
    // Legacy method for compatibility
    func estimateBPM() {
        Task {
            await analyzeAudio()
        }
    }
    
    // MARK: - Sections Management
    func addSection() {
        let newSection = LyricSection(
            type: .verse,
            startTime: "00:00",
            endTime: "00:30"
        )
        sections.append(newSection)
    }
    
    func removeSection(_ section: LyricSection) {
        sections.removeAll { $0.id == section.id }
    }
    
    // MARK: - Metrics Analysis
    func analyzeMetrics() {
        let analysis = metricsValidator.analyzeText(
            originalLyrics,
            language: "source",
            sections: sections
        )
        
        metricsReport = analysis.generateReport()
        estimatedTokens = metricsValidator.estimateTokenCount(originalLyrics)
    }
    
    // MARK: - Lyrics Generation
    func generateLyrics(apiKey: String) async {
        guard !apiKey.isEmpty else {
            errorMessage = "API Key mancante. Configurala nelle Impostazioni."
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            // Imposta il provider
            aiClient.provider = aiProvider
            
            // Analizza metriche prima della generazione
            let originalMetrics = metricsValidator.analyzeText(
                originalLyrics,
                language: targetLanguage,
                sections: sections
            )
            
            // Prepara parametri per AI
            let params = LyricsGenerationParams(
                originalLyrics: originalLyrics,
                targetLanguage: targetLanguage,
                topic: topic,
                phoneticSimilarityStrength: phoneticSimilarity,
                preserveRhymeScheme: preserveRhymeScheme,
                sectionMap: sections,
                syllableTargets: originalMetrics.syllableCounts,
                styleGuidelines: styleGuidelines
            )
            
            // Chiama AI API
            let result = try await aiClient.rewriteLyrics(
                params: params,
                apiKey: apiKey
            )
            
            generatedLyrics = result.rewrittenText
            
            // Rimuovi asterischi dagli indicatori di sezione per visualizzazione pulita
            if let cleanedText = generatedLyrics {
                generatedLyrics = cleanedText.replacingOccurrences(
                    of: #"\*+\[([^\]]+)\]\*+"#,
                    with: "[$1]",
                    options: .regularExpression
                )
            }
            
            // Valida compatibilità metrica
            let generatedMetrics = metricsValidator.analyzeText(
                result.rewrittenText,
                language: targetLanguage,
                sections: sections
            )
            
            compatibilityScore = metricsValidator.compareMetrics(
                original: originalMetrics,
                generated: generatedMetrics
            )
            
            estimatedTokens = result.tokensUsed
            
        } catch {
            errorMessage = "Errore generazione: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
    
    // MARK: - Draft Translation
    func draftTranslate(apiKey: String, literalness: Double = 0.5) async {
        isGenerating = true
        errorMessage = nil
        
        do {
            // Imposta il provider
            aiClient.provider = aiProvider
            
            let translated = try await aiClient.draftTranslate(
                text: originalLyrics,
                targetLanguage: targetLanguage,
                literalness: literalness,
                apiKey: apiKey
            )
            
            // Mostra la traduzione in una finestra separata o sostituisce temporaneamente
            originalLyrics = translated
            
        } catch {
            errorMessage = "Errore traduzione: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
    
    // MARK: - Audio Transcription with Whisper
    func transcribeAudio(apiKey: String) async {
        guard let audioURL = audioFileURL else {
            errorMessage = "Nessun file audio caricato"
            return
        }
        
        guard !apiKey.isEmpty else {
            errorMessage = "OpenAI API Key mancante"
            return
        }
        
        isTranscribing = true
        transcriptionProgress = "Preparazione audio..."
        errorMessage = nil
        
        do {
            // Verifica dimensione file (max 25MB per Whisper)
            let fileSize = try FileManager.default.attributesOfItem(atPath: audioURL.path)[.size] as? Int ?? 0
            let maxSize = 25 * 1024 * 1024 // 25 MB
            
            if fileSize > maxSize {
                throw NSError(
                    domain: "Transcription",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "File troppo grande. Whisper accetta max 25MB. Comprimi l'audio prima di caricare."]
                )
            }
            
            transcriptionProgress = "Invio audio a Whisper API..."
            
            // Prepara richiesta multipart/form-data
            let boundary = UUID().uuidString
            var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 300 // 5 minuti per upload
            
            // Costruisci body multipart
            var body = Data()
            
            // Aggiungi file audio
            let audioData = try Data(contentsOf: audioURL)
            let filename = audioURL.lastPathComponent
            let mimeType = getMimeType(for: audioURL)
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(audioData)
            body.append("\r\n".data(using: .utf8)!)
            
            // Aggiungi model
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
            body.append("whisper-1\r\n".data(using: .utf8)!)
            
            // Aggiungi lingua (opzionale ma migliora accuracy)
            if !targetLanguage.isEmpty {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(targetLanguage.lowercased())\r\n".data(using: .utf8)!)
            }
            
            // Chiudi boundary
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            transcriptionProgress = "Trascrizione in corso..."
            
            // Esegui richiesta
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "Transcription", code: -1, userInfo: [NSLocalizedDescriptionKey: "Risposta non valida"])
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Errore sconosciuto"
                throw NSError(
                    domain: "Transcription",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"]
                )
            }
            
            // Parse risposta
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let transcribedText = json["text"] as? String else {
                throw NSError(domain: "Transcription", code: -1, userInfo: [NSLocalizedDescriptionKey: "Formato risposta non valido"])
            }
            
            // Aggiorna il campo testi originali con post-processing
            transcriptionProgress = "Completato!"
            let structuredText = structureTranscribedLyrics(transcribedText.trimmingCharacters(in: .whitespacesAndNewlines))
            originalLyrics = structuredText
            
        } catch {
            errorMessage = "Errore trascrizione: \(error.localizedDescription)"
            transcriptionProgress = ""
        }
        
        isTranscribing = false
    }
    
    // MARK: - Lyrics Structure Analysis
    private func structureTranscribedLyrics(_ rawText: String) -> String {
        // Divide in frasi basandosi su punteggiatura e pause naturali
        let sentences = rawText.components(separatedBy: CharacterSet(charactersIn: ".,!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if sentences.isEmpty {
            return rawText
        }
        
        var structuredLines: [String] = []
        var currentSection = 1
        var verseLinesCount = 0
        let maxLinesPerVerse = 4 // Tipicamente 4 righe per strofa
        
        // Analizza quali frasi si ripetono (possibili ritornelli)
        let repeatedPhrases = findRepeatedPhrases(sentences)
        
        var i = 0
        while i < sentences.count {
            let sentence = sentences[i]
            
            // Controlla se è una frase ripetuta (possibile ritornello)
            if repeatedPhrases.contains(sentence) && verseLinesCount > 0 {
                // Chiudi strofa precedente se necessario
                if verseLinesCount > 0 {
                    structuredLines.append("")
                }
                
                // Aggiungi tag Chorus
                structuredLines.append("[Chorus]")
                
                // Aggiungi tutte le righe del ritornello
                var chorusLines = [sentence]
                var j = i + 1
                while j < sentences.count && repeatedPhrases.contains(sentences[j]) {
                    chorusLines.append(sentences[j])
                    j += 1
                }
                
                structuredLines.append(contentsOf: chorusLines)
                structuredLines.append("")
                
                i = j
                verseLinesCount = 0
                continue
            }
            
            // Nuova strofa
            if verseLinesCount == 0 {
                if !structuredLines.isEmpty {
                    structuredLines.append("")
                }
                structuredLines.append("[Verse \(currentSection)]")
                currentSection += 1
            }
            
            structuredLines.append(sentence)
            verseLinesCount += 1
            
            // Chiudi strofa se ha raggiunto il max righe
            if verseLinesCount >= maxLinesPerVerse {
                verseLinesCount = 0
            }
            
            i += 1
        }
        
        return structuredLines.joined(separator: "\n")
    }
    
    private func findRepeatedPhrases(_ sentences: [String]) -> Set<String> {
        var phraseCounts: [String: Int] = [:]
        
        for sentence in sentences {
            // Normalizza per confronto (lowercase, rimuovi spazi extra)
            let normalized = sentence.lowercased().trimmingCharacters(in: .whitespaces)
            phraseCounts[normalized, default: 0] += 1
        }
        
        // Frasi che appaiono almeno 2 volte sono probabili ritornelli
        let repeated = phraseCounts.filter { $0.value >= 2 }.keys
        
        // Mappa back alle frasi originali
        var result = Set<String>()
        for sentence in sentences {
            if repeated.contains(sentence.lowercased().trimmingCharacters(in: .whitespaces)) {
                result.insert(sentence)
            }
        }
        
        return result
    }
    
    // Helper per MIME type
    private func getMimeType(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "mp3": return "audio/mpeg"
        case "mp4", "m4a": return "audio/mp4"
        case "wav": return "audio/wav"
        case "webm": return "audio/webm"
        default: return "audio/mpeg"
        }
    }
    
    // MARK: - Line-by-Line Editing
    func convertToEditableLines() {
        guard let generated = generatedLyrics else { return }
        
        let lines = generated.components(separatedBy: .newlines)
        editableLines = lines.enumerated().map { index, line in
            EditableLine(
                text: line,
                lineNumber: index + 1,
                isSelected: false
            )
        }
    }
    
    func toggleLineSelection(_ lineID: UUID) {
        if selectedLineIDs.contains(lineID) {
            selectedLineIDs.remove(lineID)
        } else {
            selectedLineIDs.insert(lineID)
        }
        
        // Aggiorna anche lo stato nella lista editableLines
        if let index = editableLines.firstIndex(where: { $0.id == lineID }) {
            editableLines[index].isSelected.toggle()
        }
    }
    
    func updateLineText(_ lineID: UUID, newText: String) {
        if let index = editableLines.firstIndex(where: { $0.id == lineID }) {
            editableLines[index].text = newText
            
            // Aggiorna anche il testo generato completo
            generatedLyrics = editableLines.map { $0.text }.joined(separator: "\n")
        }
    }
    
    func regenerateSelectedLines(apiKey: String) async {
        guard !selectedLineIDs.isEmpty else {
            errorMessage = "Seleziona almeno una riga da rigenerare"
            return
        }
        
        guard !apiKey.isEmpty else {
            errorMessage = "API Key mancante"
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            // Imposta il provider
            aiClient.provider = aiProvider
            
            // Ottieni le righe selezionate
            let selectedLines = editableLines.filter { selectedLineIDs.contains($0.id) }
            let linesToRegenerate = selectedLines.map { $0.text }.joined(separator: "\n")
            
            // Crea prompt per rigenerare solo quelle righe
            let prompt = """
            Rigenera SOLO le seguenti righe del testo, mantenendo lo stile e il tema del resto:
            
            Testo originale completo:
            \(originalLyrics)
            
            Righe da rigenerare:
            \(linesToRegenerate)
            
            Lingua target: \(targetLanguage)
            Topic: \(topic.isEmpty ? "mantieni il tema" : topic)
            
            Fornisci SOLO le righe rigenerate, una per riga, senza numerazione o altro testo.
            """
            
            // Chiama l'AI
            let response: [String: Any]
            
            switch aiProvider {
            case .claude:
                response = try await aiClient.callClaude(
                    prompt: prompt,
                    apiKey: apiKey,
                    maxTokens: 1000
                )
            case .openai:
                response = try await aiClient.callOpenAI(
                    prompt: prompt,
                    apiKey: apiKey,
                    maxTokens: 1000
                )
            }
            
            let regeneratedText = aiClient.extractTextFromResponse(response, provider: aiProvider)
            let regeneratedLines = regeneratedText.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            // Sostituisci le righe selezionate con quelle rigenerate
            var lineIndex = 0
            for i in 0..<editableLines.count {
                if selectedLineIDs.contains(editableLines[i].id) {
                    if lineIndex < regeneratedLines.count {
                        editableLines[i].text = regeneratedLines[lineIndex]
                        editableLines[i].isSelected = false
                        lineIndex += 1
                    }
                }
            }
            
            // Aggiorna il testo generato completo
            generatedLyrics = editableLines.map { $0.text }.joined(separator: "\n")
            
            // Deseleziona tutte le righe
            selectedLineIDs.removeAll()
            
        } catch {
            errorMessage = "Errore rigenerazione righe: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
    
    // MARK: - Export Functions
    func exportAsText() {
        guard let lyrics = generatedLyrics else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText, UTType(filenameExtension: "md")!]
        panel.nameFieldStringValue = "\(songTitle.isEmpty ? "lyrics" : songTitle).txt"
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let content = formatTextExport(lyrics)
                try content.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                errorMessage = "Errore esportazione: \(error.localizedDescription)"
            }
        }
    }
    
    func exportAsLRC() {
        guard let lyrics = generatedLyrics else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "lrc")!]
        panel.nameFieldStringValue = "\(songTitle.isEmpty ? "lyrics" : songTitle).lrc"
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let lrcContent = LRCExporter.export(
                    lyrics: lyrics,
                    sections: sections,
                    metadata: LRCMetadata(
                        title: songTitle,
                        artist: "",
                        album: ""
                    )
                )
                try lrcContent.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                errorMessage = "Errore esportazione LRC: \(error.localizedDescription)"
            }
        }
    }
    
    func exportAsSRT() {
        guard let lyrics = generatedLyrics else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "srt")!]
        panel.nameFieldStringValue = "\(songTitle.isEmpty ? "lyrics" : songTitle).srt"
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let srtContent = SRTExporter.export(
                    lyrics: lyrics,
                    sections: sections
                )
                try srtContent.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                errorMessage = "Errore esportazione SRT: \(error.localizedDescription)"
            }
        }
    }
    
    func exportAsJSON() {
        guard let lyrics = generatedLyrics else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "\(songTitle.isEmpty ? "lyrics" : songTitle).json"
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let jsonData = try JSONExporter.export(
                    originalLyrics: originalLyrics,
                    generatedLyrics: lyrics,
                    sections: sections,
                    compatibilityScore: compatibilityScore,
                    metadata: ExportMetadata(
                        title: songTitle,
                        targetLanguage: targetLanguage,
                        topic: topic,
                        phoneticSimilarity: phoneticSimilarity,
                        preserveRhymeScheme: preserveRhymeScheme
                    )
                )
                try jsonData.write(to: url)
            } catch {
                errorMessage = "Errore esportazione JSON: \(error.localizedDescription)"
            }
        }
    }
    
    func exportAsAdvancedText() {
        guard let lyrics = generatedLyrics else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "\(songTitle.isEmpty ? "lyrics" : songTitle)_report.txt"
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                // Recupera le info Google se disponibili
                var googleInfo = ""
                if !musicSearch.searchResults.isEmpty {
                    let result = musicSearch.searchResults[0]
                    let artist = result.artist
                    let album = result.album ?? "N/A"
                    let year = result.year ?? "N/A"
                    googleInfo = "Artista: \(artist)\nAlbum: \(album)\nAnno: \(year)"
                }
                
                // Genera il report avanzato
                let advancedText = TXTAdvancedExporter.export(
                    originalTitle: audioFileURL?.lastPathComponent ?? "N/A",
                    userTitle: songTitle,
                    googleInfo: googleInfo,
                    musicalKey: musicalKey,
                    scale: scale,
                    suggestedChords: suggestedChords,
                    bpm: bpm,
                    originalLyrics: originalLyrics,
                    generatedLyrics: lyrics,
                    metricsReport: metricsReport
                )
                
                try advancedText.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                errorMessage = "Errore esportazione TXT Avanzato: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatTextExport(_ lyrics: String) -> String {
        var content = ""
        
        if !songTitle.isEmpty {
            content += "# \(songTitle)\n\n"
        }
        
        content += "**Lingua:** \(targetLanguage)\n"
        content += "**Tema:** \(topic)\n"
        
        if let score = compatibilityScore {
            content += "**Score Compatibilità:** \(String(format: "%.2f", score))\n"
        }
        
        content += "\n---\n\n"
        
        // Rimuovi asterischi dagli indicatori di sezione (es: ***[Coro]*** → [Coro])
        let cleanedLyrics = lyrics.replacingOccurrences(of: #"\*+\[([^\]]+)\]\*+"#, with: "[$1]", options: .regularExpression)
        content += cleanedLyrics
        
        return content
    }

// MARK: - Fetch Lyrics from API
    func fetchLyricsFromAPI(apiKey: String) {
        Task {
            await fetchLyricsFromAPIAsync(apiKey: apiKey)
        }
    }
    
    func fetchLyricsFromAPIAsync(apiKey: String) async {
        // Verifica se ci sono risultati di ricerca
        guard let result = musicSearch.searchResults.first else {
            errorMessage = "Nessuna ricerca effettuata. Cerca prima un brano."
            return
        }
        
        isGenerating = true
        generationProgress = "🔍 Cerco testi di '\(result.title)' su Genius..."
        errorMessage = nil
        
        do {
            // Estrai testi direttamente da Genius
            let lyrics = try await fetchLyricsFromGenius(
                title: result.title,
                artist: result.artist
            )
            
            // Aggiorna testi originali
            originalLyrics = lyrics
            generationProgress = "✓ Testi recuperati da Genius!"
            
            // Reset dopo 2 secondi
            try await Task.sleep(nanoseconds: 2_000_000_000)
            generationProgress = ""
            
        } catch {
            errorMessage = "Errore recupero testi: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
    
    // MARK: - Fetch Lyrics from Genius (Web Scraping)
    private func fetchLyricsFromGenius(title: String, artist: String) async throws -> String {
        // Approccio 1: Costruisci URL diretto basato su artista e titolo
        // Formato Genius: https://genius.com/Artist-name-song-title-lyrics
        
        let cleanArtist = cleanForURL(artist)
        let cleanTitle = cleanForURL(title)
        
        // Prova diverse combinazioni di URL
        let urlVariants = [
            "https://genius.com/\(cleanArtist)-\(cleanTitle)-lyrics",
            "https://genius.com/\(cleanArtist)-\(cleanTitle)-annotated",
            "https://genius.com/\(cleanTitle)-lyrics",
        ]
        
        // Prova ogni URL fino a trovarne uno valido
        for urlString in urlVariants {
            if let lyrics = try? await fetchLyricsFromURL(urlString) {
                if !lyrics.isEmpty && !lyrics.contains("Heaven's we haven't seen") {
                    // Controlla che non siano i testi generici/sbagliati
                    return lyrics
                }
            }
        }
        
        // Approccio 2: Usa API di ricerca di Genius (se disponibile)
        if let lyrics = try? await searchGeniusAPI(artist: artist, title: title) {
            return lyrics
        }
        
        throw NSError(domain: "GeniusError", code: 3, userInfo: [
            NSLocalizedDescriptionKey: "Brano '\(title)' di \(artist) non trovato su Genius.\n\nSuggerimento: Verifica che il brano esista su genius.com"
        ])
    }
    
    // MARK: - Clean String for URL
    private func cleanForURL(_ text: String) -> String {
        return text
            .lowercased()
            // Rimuovi featuring, feat, ft, etc
            .replacingOccurrences(of: " feat. ", with: " ", options: .caseInsensitive)
            .replacingOccurrences(of: " feat ", with: " ", options: .caseInsensitive)
            .replacingOccurrences(of: " ft. ", with: " ", options: .caseInsensitive)
            .replacingOccurrences(of: " ft ", with: " ", options: .caseInsensitive)
            .replacingOccurrences(of: " featuring ", with: " ", options: .caseInsensitive)
            // Rimuovi parentesi e contenuto
            .replacingOccurrences(of: "\\([^)]*\\)", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\[[^\\]]*\\]", with: "", options: .regularExpression)
            // Rimuovi apostrofi e virgolette
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "\"", with: "")
            // Sostituisci spazi e caratteri speciali con trattini
            .replacingOccurrences(of: " & ", with: "-and-")
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            // Rimuovi trattini multipli
            .replacingOccurrences(of: "-+", with: "-", options: .regularExpression)
            // Rimuovi trattini iniziali e finali
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
    
    // MARK: - Fetch Lyrics from Direct URL
    private func fetchLyricsFromURL(_ urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "GeniusError", code: 1, userInfo: [NSLocalizedDescriptionKey: "URL non valido"])
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Controlla che la risposta sia 200 OK
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "GeniusError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Pagina non trovata"])
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "GeniusError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Impossibile leggere la pagina"])
        }
        
        // Estrai i testi
        let lyrics = extractLyricsFromHTML(html)
        
        if lyrics.isEmpty {
            throw NSError(domain: "GeniusError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Testi non trovati"])
        }
        
        return lyrics
    }
    
    // MARK: - Search Genius API
    private func searchGeniusAPI(artist: String, title: String) async throws -> String? {
        let query = "\(artist) \(title)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let apiURL = "https://genius.com/api/search/multi?q=\(query)"
        
        guard let url = URL(string: apiURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let response = json["response"] as? [String: Any],
                  let sections = response["sections"] as? [[String: Any]] else {
                return nil
            }
            
            // Cerca la prima song
            for section in sections {
                if let type = section["type"] as? String, type == "song",
                   let hits = section["hits"] as? [[String: Any]],
                   let firstHit = hits.first,
                   let result = firstHit["result"] as? [String: Any],
                   let path = result["path"] as? String {
                    
                    let songURL = "https://genius.com\(path)"
                    return try? await fetchLyricsFromURL(songURL)
                }
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    // MARK: - Extract Lyrics from HTML
    private func extractLyricsFromHTML(_ html: String) -> String {
        var lyrics = ""
        
        // Pattern 1: data-lyrics-container="true" (formato attuale di Genius)
        let pattern1 = #"<div[^>]*data-lyrics-container="true"[^>]*>(.*?)</div>"#
        if let regex1 = try? NSRegularExpression(pattern: pattern1, options: [.dotMatchesLineSeparators]) {
            let nsString = html as NSString
            let matches = regex1.matches(in: html, range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                if match.numberOfRanges > 1 {
                    let contentRange = match.range(at: 1)
                    let content = nsString.substring(with: contentRange)
                    let cleanContent = cleanHTML(content)
                    lyrics += cleanContent + "\n\n"
                }
            }
        }
        
        // Se non trova nulla, prova Pattern 2: class="Lyrics__Container"
        if lyrics.isEmpty {
            let pattern2 = #"<div[^>]*class="[^"]*Lyrics__Container[^"]*"[^>]*>(.*?)</div>"#
            if let regex2 = try? NSRegularExpression(pattern: pattern2, options: [.dotMatchesLineSeparators]) {
                let nsString = html as NSString
                let matches = regex2.matches(in: html, range: NSRange(location: 0, length: nsString.length))
                
                for match in matches {
                    if match.numberOfRanges > 1 {
                        let contentRange = match.range(at: 1)
                        let content = nsString.substring(with: contentRange)
                        lyrics += cleanHTML(content) + "\n\n"
                    }
                }
            }
        }
        
        // Se ancora non trova nulla, prova Pattern 3: cerca nel JSON embedded
        if lyrics.isEmpty {
            // Genius spesso include i testi in JSON embedded nella pagina
            let pattern3 = #""lyrics":\s*\{\s*"plain":\s*"([^"]+)""#
            if let regex3 = try? NSRegularExpression(pattern: pattern3, options: [.dotMatchesLineSeparators]) {
                let nsString = html as NSString
                let matches = regex3.matches(in: html, range: NSRange(location: 0, length: nsString.length))
                
                if let firstMatch = matches.first, firstMatch.numberOfRanges > 1 {
                    let lyricsRange = firstMatch.range(at: 1)
                    let jsonLyrics = nsString.substring(with: lyricsRange)
                    // Decodifica escaped newlines e caratteri
                    lyrics = jsonLyrics
                        .replacingOccurrences(of: "\\n", with: "\n")
                        .replacingOccurrences(of: "\\/", with: "/")
                        .replacingOccurrences(of: "\\\"", with: "\"")
                }
            }
        }
        
        // Se ancora vuoto, prova Pattern 4: cerca section con ID lyrics
        if lyrics.isEmpty {
            let pattern4 = #"<div[^>]*id="lyrics"[^>]*>(.*?)</div>"#
            if let regex4 = try? NSRegularExpression(pattern: pattern4, options: [.dotMatchesLineSeparators]) {
                let nsString = html as NSString
                let matches = regex4.matches(in: html, range: NSRange(location: 0, length: nsString.length))
                
                for match in matches {
                    if match.numberOfRanges > 1 {
                        let contentRange = match.range(at: 1)
                        let content = nsString.substring(with: contentRange)
                        lyrics += cleanHTML(content) + "\n\n"
                    }
                }
            }
        }
        
        return lyrics.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Clean HTML
    private func cleanHTML(_ html: String) -> String {
        var clean = html
        
        // Sostituisci <br> con newline
        clean = clean.replacingOccurrences(of: "<br>", with: "\n", options: .caseInsensitive)
        clean = clean.replacingOccurrences(of: "<br/>", with: "\n", options: .caseInsensitive)
        clean = clean.replacingOccurrences(of: "<br />", with: "\n", options: .caseInsensitive)
        
        // Rimuovi tutti i tag HTML
        if let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: []) {
            let nsString = clean as NSString
            clean = regex.stringByReplacingMatches(
                in: clean,
                range: NSRange(location: 0, length: nsString.length),
                withTemplate: ""
            )
        }
        
        // Decodifica HTML entities esadecimali (&#x27; &#x2019; etc)
        clean = decodeHexEntities(clean)
        
        // Decodifica HTML entities decimali (&#39; &#8217; etc)
        clean = decodeDecimalEntities(clean)
        
        // Decodifica HTML entities named standard
        clean = clean.replacingOccurrences(of: "&amp;", with: "&")
        clean = clean.replacingOccurrences(of: "&lt;", with: "<")
        clean = clean.replacingOccurrences(of: "&gt;", with: ">")
        clean = clean.replacingOccurrences(of: "&quot;", with: "\"")
        clean = clean.replacingOccurrences(of: "&#39;", with: "'")
        clean = clean.replacingOccurrences(of: "&apos;", with: "'")
        clean = clean.replacingOccurrences(of: "&nbsp;", with: " ")
        clean = clean.replacingOccurrences(of: "&mdash;", with: "—")
        clean = clean.replacingOccurrences(of: "&ndash;", with: "–")
        clean = clean.replacingOccurrences(of: "&lsquo;", with: "'")
        clean = clean.replacingOccurrences(of: "&rsquo;", with: "'")
        clean = clean.replacingOccurrences(of: "&ldquo;", with: "\u{201C}")
        clean = clean.replacingOccurrences(of: "&rdquo;", with: "\u{201D}")
        clean = clean.replacingOccurrences(of: "&hellip;", with: "…")
        
        // Pulisci spazi multipli e linee vuote eccessive
        clean = clean.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        clean = clean.replacingOccurrences(of: "\n\n\n+", with: "\n\n", options: .regularExpression)
        
        return clean.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Decode Hexadecimal HTML Entities
    private func decodeHexEntities(_ text: String) -> String {
        // Pattern: &#x27; &#x2019; &#xHH; etc
        let pattern = "&#x([0-9A-Fa-f]+);"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }
        
        var result = text
        let nsString = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length)).reversed()
        
        for match in matches {
            if match.numberOfRanges == 2 {
                let hexRange = match.range(at: 1)
                let hexString = nsString.substring(with: hexRange)
                
                if let codePoint = Int(hexString, radix: 16),
                   let scalar = UnicodeScalar(codePoint) {
                    let character = String(scalar)
                    let fullRange = match.range(at: 0)
                    result = (result as NSString).replacingCharacters(in: fullRange, with: character)
                }
            }
        }
        
        return result
    }
    
    // MARK: - Decode Decimal HTML Entities
    private func decodeDecimalEntities(_ text: String) -> String {
        // Pattern: &#39; &#8217; &#DDD; etc (ma non &#x che è hex)
        let pattern = "&#([0-9]+);"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }
        
        var result = text
        let nsString = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length)).reversed()
        
        for match in matches {
            if match.numberOfRanges == 2 {
                let decRange = match.range(at: 1)
                let decString = nsString.substring(with: decRange)
                
                if let codePoint = Int(decString),
                   let scalar = UnicodeScalar(codePoint) {
                    let character = String(scalar)
                    let fullRange = match.range(at: 0)
                    result = (result as NSString).replacingCharacters(in: fullRange, with: character)
                }
            }
        }
        
        return result
    }
    
    // MARK: - Fetch and Structure Lyrics with AI (Direct Method)
    private func fetchAndStructureLyricsWithAI(title: String, artist: String, apiKey: String) async throws -> String {
        // Chiedi direttamente a OpenAI di recuperare e strutturare i testi
        // OpenAI conosce i testi della maggior parte dei brani famosi!
        
        let prompt = """
        Sei un esperto di musica. Il tuo compito è recuperare i testi COMPLETI e ORIGINALI del brano "\(title)" di \(artist) e strutturarli con etichette.
        
        PASSO 1 - RECUPERO TESTI:
        Cerca nei tuoi dati di training i testi COMPLETI e ORIGINALI di questo brano.
        Se il brano è:
        - Famoso/popolare: dovresti conoscere i testi completi
        - Meno conosciuto: fornisci quello che conosci
        - Sconosciuto: rispondi "BRANO_NON_TROVATO"
        
        PASSO 2 - STRUTTURAZIONE:
        Una volta recuperati i testi, aggiungI queste etichette in MAIUSCOLO:
        
        [INTRO] - introduzione strumentale o vocale
        [STROFA] - strofe (NON numerare, usa sempre [STROFA])
        [CORO] - ritornello/coro
        [BRIDGE] - ponte
        [FINALE] - chiusura/outro
        [STRUMENTALE] - parti strumentali
        
        REGOLE FONDAMENTALI:
        ✓ Usa i testi ORIGINALI esatti (non parafrasare)
        ✓ Mantieni l'ordine originale delle sezioni
        ✓ NON inventare testi se non li conosci
        ✓ Ogni strofa ha sempre l'etichetta [STROFA] (mai [STROFA 1] o [STROFA 2])
        ✓ Ritorna SOLO i testi strutturati (no commenti, no spiegazioni)
        
        ESEMPIO OUTPUT:
        [INTRO]
        (intro musicale)
        
        [STROFA]
        Prima strofa qui...
        
        [CORO]
        Ritornello qui...
        
        [STROFA]
        Seconda strofa qui...
        
        [CORO]
        Ritornello ripetuto...
        
        Ora recupera e struttura i testi di "\(title)" - \(artist):
        """
        
        do {
            let client = AIAPIClient()
            
            let response = try await client.callOpenAI(
                prompt: prompt,
                apiKey: apiKey,
                maxTokens: 3000  // Più token per testi completi
            )
            
            // Estrai il testo dalla risposta OpenAI
            guard let choices = response["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let text = message["content"] as? String else {
                throw NSError(domain: "OpenAIError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Risposta OpenAI non valida"])
            }
            
            let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Verifica se OpenAI ha trovato il brano
            if cleanedText.contains("BRANO_NON_TROVATO") {
                throw NSError(domain: "NotFoundError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Brano '\(title)' di \(artist) non trovato. OpenAI non conosce questo brano. Prova con un artista/titolo più famoso o incolla i testi manualmente."])
            }
            
            // Verifica lunghezza minima (almeno 100 caratteri)
            if cleanedText.count < 100 {
                throw NSError(domain: "TooShortError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Testi troppo corti (\(cleanedText.count) caratteri). Il brano potrebbe non essere nel database di OpenAI. Prova a incollare i testi manualmente."])
            }
            
            // Verifica che ci siano etichette strutturate
            let hasLabels = cleanedText.contains("[INTRO]") || 
                           cleanedText.contains("[STROFA]") || 
                           cleanedText.contains("[CORO]")
            
            if !hasLabels {
                // OpenAI ha risposto ma senza struttura - aggiungiamo almeno [STROFA]
                return "[STROFA]\n" + cleanedText
            }
            
            return cleanedText
            
        } catch let error as NSError where error.domain == "NotFoundError" || error.domain == "TooShortError" {
            // Errori specifici - propaga con messaggio originale
            throw error
        } catch {
            // Altri errori - messaggio generico
            throw NSError(domain: "APIError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Errore OpenAI: \(error.localizedDescription)"])
        }
    }
    
    // MARK: - Legacy Functions (Keep for backward compatibility)
    private func fetchLyricsFromGenius(url: String) async throws -> String {
        guard let geniusURL = URL(string: url) else {
            throw NSError(domain: "InvalidURL", code: 1)
        }
        
        let (data, _) = try await URLSession.shared.data(from: geniusURL)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "ParsingError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Impossibile leggere HTML"])
        }
        
        // Metodo 1: Cerca JSON con testi nel <script> tag
        if let jsonLyrics = extractLyricsFromJSON(html: html) {
            return jsonLyrics
        }
        
        // Metodo 2: Cerca nei container moderni di Genius
        if let modernLyrics = extractLyricsFromModernHTML(html: html) {
            return modernLyrics
        }
        
        // Metodo 3: Fallback per HTML classico
        if let classicLyrics = extractLyricsFromClassicHTML(html: html) {
            return classicLyrics
        }
        
        throw NSError(domain: "ParsingError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Impossibile estrarre testi dalla pagina"])
    }
    
    private func extractLyricsFromJSON(html: String) -> String? {
        // Genius inserisce i testi in un JSON dentro <script type="application/ld+json">
        let patterns = [
            "\"lyrics\"\\s*:\\s*\"([^\"]+)\"",
            "\"plain\"\\s*:\\s*\"([^\"]+)\"",
            "__PRELOADED_STATE__\\s*=\\s*({.+?});",
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
                let range = NSRange(html.startIndex..., in: html)
                if let match = regex.firstMatch(in: html, range: range) {
                    if let swiftRange = Range(match.range(at: 1), in: html) {
                        let extracted = String(html[swiftRange])
                        // Decodifica escape sequences
                        let cleaned = extracted
                            .replacingOccurrences(of: "\\n", with: "\n")
                            .replacingOccurrences(of: "\\r", with: "")
                            .replacingOccurrences(of: "\\\"", with: "\"")
                            .replacingOccurrences(of: "\\/", with: "/")
                        
                        if !cleaned.isEmpty && cleaned.count > 50 {
                            return cleaned
                        }
                    }
                }
            }
        }
        return nil
    }
    
    private func extractLyricsFromModernHTML(html: String) -> String? {
        // Genius ora usa div con attributi data-lyrics-container
        let modernPatterns = [
            "<div[^>]*data-lyrics-container[^>]*>(.+?)</div>",
            "<div[^>]*class=\"[^\"]*Lyrics__Container[^\"]*\"[^>]*>(.+?)</div>",
            "<div[^>]*class=\"[^\"]*lyrics[^\"]*\"[^>]*>(.+?)</div>"
        ]
        
        for pattern in modernPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) {
                let range = NSRange(html.startIndex..., in: html)
                var allLyrics = ""
                
                regex.enumerateMatches(in: html, range: range) { match, _, _ in
                    guard let match = match, let swiftRange = Range(match.range(at: 1), in: html) else { return }
                    let section = String(html[swiftRange])
                    allLyrics += cleanHTML(section) + "\n\n"
                }
                
                if !allLyrics.isEmpty && allLyrics.count > 50 {
                    return allLyrics.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        return nil
    }
    
    private func extractLyricsFromClassicHTML(html: String) -> String? {
        // Fallback per vecchie pagine
        if let range = html.range(of: "<div class=\"lyrics\">") {
            let startIndex = range.upperBound
            if let endRange = html[startIndex...].range(of: "</div>") {
                let lyricsHTML = String(html[startIndex..<endRange.lowerBound])
                return cleanHTML(lyricsHTML)
            }
        }
        return nil
    }
    
    private func structureLyricsWithAI(rawLyrics: String, title: String, artist: String, apiKey: String) async throws -> String {
        // Usa AI per strutturare i testi
        let prompt = """
        Struttura questi testi del brano "\(title)" di \(artist) aggiungendo le etichette delle sezioni.
        
        Usa ESATTAMENTE queste etichette:
        [INTRO] - per introduzione strumentale o vocale
        [STROFA] - per le strofe (usa [STROFA], [STROFA], ecc. senza numerazione)
        [CORO] - per il ritornello/coro
        [BRIDGE] - per il ponte
        [FINALE] - per la chiusura
        [STRUMENTALE] - per parti strumentali
        
        IMPORTANTE:
        - Usa SOLO le etichette elencate sopra
        - Le etichette devono essere in MAIUSCOLO e tra parentesi quadre
        - NON numerare le strofe
        - Analizza la struttura del brano e identifica correttamente ogni sezione
        
        Testi originali:
        \(rawLyrics)
        
        Ritorna SOLO i testi strutturati con le etichette corrette, senza commenti, spiegazioni o testo aggiuntivo.
        """
        
        // Se i testi sono troppo corti, ritornali direttamente
        if rawLyrics.count < 100 {
            return rawLyrics
        }
        
        // Usa il provider AI configurato
        do {
            let client = AIAPIClient()
            
            // Chiama AI in base al provider (usa OpenAI per recupero testi)
            let response = try await client.callOpenAI(
                prompt: prompt,
                apiKey: apiKey,
                maxTokens: 2000
            )
            
            // Estrai il testo dalla risposta OpenAI
            guard let choices = response["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let text = message["content"] as? String else {
                // Se non riesce a estrarre, ritorna testi grezzi
                return rawLyrics
            }
            
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            // In caso di errore AI, ritorna testi grezzi
            print("AI structuring failed: \(error). Returning raw lyrics.")
            return rawLyrics
        }
    }
}

// MARK: - Supporting Models
struct StyleGuidelines: Codable {
    var lexicon: String = ""
    var register: String = "neutral"
    var humor: Bool = false
    var additionalNotes: String = ""
}

struct LyricsGenerationParams {
    let originalLyrics: String
    let targetLanguage: String
    let topic: String
    let phoneticSimilarityStrength: Double
    let preserveRhymeScheme: Bool
    let sectionMap: [LyricSection]
    let syllableTargets: [Int]
    let styleGuidelines: StyleGuidelines
}

struct LyricsGenerationResult {
    let rewrittenText: String
    let tokensUsed: Int
    let warnings: [String]
}
