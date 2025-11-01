//
//  RhymeAIViewModel.swift
//  LyriCanto
//
//  ViewModel for AI Rhyme Search functionality
//  Handles API calls, state management, and result processing
//

import Foundation
import SwiftUI

@MainActor
class RhymeAIViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // Input Configuration
    @Published var inputText: String = ""
    @Published var inputType: InputType = .word
    @Published var searchType: RhymeSearchType = .both
    @Published var language: RhymeLanguage = .italian
    @Published var maxResults: Int = 20
    @Published var includeDefinitions: Bool = false
    
    // State
    @Published var isSearching: Bool = false
    @Published var searchProgress: String = ""
    @Published var errorMessage: String?
    
    // Results
    @Published var currentResponse: RhymeSearchResponse?
    @Published var searchHistory: [RhymeSearchHistoryItem] = []
    @Published var statistics: RhymeStatistics = RhymeStatistics()
    
    // UI State
    @Published var selectedLengthFilter: Int? = nil
    @Published var showHistory: Bool = false
    @Published var showStatistics: Bool = false
    
    // MARK: - Private Properties
    private let apiClient = AIAPIClient()
    private var searchStartTime: Date?
    
    // MARK: - Configuration
    var isInputValid: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var filteredResults: [RhymeResultsByLength] {
        guard let response = currentResponse else { return [] }
        
        if let filter = selectedLengthFilter {
            return response.resultsByLength.filter { $0.syllableCount == filter }
        }
        return response.resultsByLength
    }
    
    // MARK: - Main Search Function
    func performSearch(apiKey: String, provider: AIProvider) async {
        guard isInputValid else {
            errorMessage = "Inserisci una parola o frase valida"
            return
        }
        
        isSearching = true
        errorMessage = nil
        searchProgress = "Preparazione richiesta..."
        searchStartTime = Date()
        
        // Configure API client
        apiClient.provider = provider
        
        do {
            // Build search request
            let request = RhymeSearchRequest(
                inputText: inputText.trimmingCharacters(in: .whitespacesAndNewlines),
                inputType: inputType,
                searchType: searchType,
                language: language,
                maxResults: maxResults,
                includeDefinitions: includeDefinitions
            )
            
            searchProgress = "Invio richiesta a \(provider.displayName)..."
            
            // Call AI API
            let response = try await searchForRhymes(request: request, apiKey: apiKey)
            
            // Update state
            currentResponse = response
            
            // Update statistics
            statistics.recordSearch(
                matches: response.totalMatches,
                searchType: searchType,
                language: language
            )
            
            // Add to history
            let historyItem = RhymeSearchHistoryItem(
                searchText: request.inputText,
                resultCount: response.totalMatches,
                searchType: searchType
            )
            searchHistory.insert(historyItem, at: 0)
            
            // Keep only last 50 searches
            if searchHistory.count > 50 {
                searchHistory = Array(searchHistory.prefix(50))
            }
            
            searchProgress = "✅ Trovate \(response.totalMatches) corrispondenze!"
            
        } catch {
            errorMessage = "Errore durante la ricerca: \(error.localizedDescription)"
            searchProgress = ""
        }
        
        isSearching = false
    }
    
    // MARK: - AI API Call
    private func searchForRhymes(request: RhymeSearchRequest, apiKey: String) async throws -> RhymeSearchResponse {
        let prompt = buildSearchPrompt(request: request)
        
        searchProgress = "Elaborazione AI in corso..."
        
        // Call API based on provider
        let response: [String: Any]
        
        switch apiClient.provider {
        case .claude:
            response = try await apiClient.callClaude(
                prompt: prompt,
                apiKey: apiKey,
                maxTokens: 3000
            )
        case .openai:
            response = try await apiClient.callOpenAI(
                prompt: prompt,
                apiKey: apiKey,
                maxTokens: 3000
            )
        }
        
        searchProgress = "Parsing risultati..."
        
        // Parse AI response
        let parsedResponse = try parseAIResponse(
            response: response,
            originalRequest: request
        )
        
        return parsedResponse
    }
    
    // MARK: - Prompt Building
    private func buildSearchPrompt(request: RhymeSearchRequest) -> String {
        let searchTypeInstruction: String
        
        switch request.searchType {
        case .phoneticSimilar:
            searchTypeInstruction = """
            Trova parole con FONETICA SIMILE (assonanza, consonanza, allitterazione).
            Focus su: suoni simili, stessa struttura consonantica/vocalica, ritmo simile.
            """
        case .endingSimilar:
            searchTypeInstruction = """
            Trova parole con FINALI SIMILI (rime perfette, rime imperfette, rime assonanti).
            Focus su: ultime 2-4 lettere simili, stessa desinenza, suono finale identico.
            """
        case .both:
            searchTypeInstruction = """
            Trova parole sia con FONETICA SIMILE che con FINALI SIMILI.
            Combina entrambi i criteri per risultati ottimali.
            """
        }
        
        let inputTypeInstruction = request.inputType == .word
            ? "Input: PAROLA SINGOLA"
            : "Input: FRASE COMPLETA (trova parole che rimano con le parole chiave della frase)"
        
        let definitionInstruction = request.includeDefinitions
            ? "Includi una breve definizione (max 10 parole) per ogni parola."
            : "NON includere definizioni."
        
        return """
        Sei un esperto linguista specializzato in fonetica e metrica della lingua \(request.language.displayName).
        
        COMPITO:
        \(searchTypeInstruction)
        
        \(inputTypeInstruction)
        INPUT: "\(request.inputText)"
        
        REQUISITI:
        1. Trova ESATTAMENTE \(request.maxResults) parole diverse
        2. Raggruppa per numero di sillabe (da 1 a 8+ sillabe)
        3. Per ogni parola fornisci:
           - La parola
           - Numero di sillabe
           - Punteggio similarità fonetica (0.0-1.0)
           - Punteggio similarità finale (0.0-1.0)
           \(request.includeDefinitions ? "- Breve definizione" : "")
           - 1-2 esempi d'uso in frasi brevi
        4. \(definitionInstruction)
        5. Ordina per qualità (score più alto prima)
        
        FORMATO OUTPUT RICHIESTO (JSON):
        {
          "results_by_length": [
            {
              "syllable_count": 2,
              "matches": [
                {
                  "word": "esempio",
                  "syllable_count": 2,
                  "phonetic_similarity": 0.85,
                  "ending_similarity": 0.92,
                  "definition": \(request.includeDefinitions ? "\"modello da seguire\"" : "null"),
                  "examples": ["Un esempio chiaro", "Segui questo esempio"]
                }
              ]
            }
          ]
        }
        
        IMPORTANTE:
        - Output SOLO JSON valido, nessun altro testo
        - Punteggi realistici basati su analisi fonetica vera
        - Parole esistenti e corrette in \(request.language.displayName)
        - Varietà di risultati (non solo varianti della stessa radice)
        
        Inizia ora la ricerca per: "\(request.inputText)"
        """
    }
    
    // MARK: - Response Parsing
    private func parseAIResponse(
        response: [String: Any],
        originalRequest: RhymeSearchRequest
    ) throws -> RhymeSearchResponse {
        // Extract text from AI response
        let responseText: String
        
        switch apiClient.provider {
        case .claude:
            guard let content = response["content"] as? [[String: Any]],
                  let firstContent = content.first,
                  let text = firstContent["text"] as? String else {
                throw NSError(
                    domain: "RhymeAI",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Formato risposta Claude non valido"]
                )
            }
            responseText = text
            
        case .openai:
            guard let choices = response["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let text = message["content"] as? String else {
                throw NSError(
                    domain: "RhymeAI",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Formato risposta OpenAI non valido"]
                )
            }
            responseText = text
        }
        
        // Clean JSON from markdown code blocks
        let cleanedJSON = responseText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Parse JSON
        guard let jsonData = cleanedJSON.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let resultsByLengthArray = parsed["results_by_length"] as? [[String: Any]] else {
            throw NSError(
                domain: "RhymeAI",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "JSON non valido nella risposta AI"]
            )
        }
        
        // Build RhymeResultsByLength objects
        var resultsByLength: [RhymeResultsByLength] = []
        
        for lengthGroup in resultsByLengthArray {
            guard let syllableCount = lengthGroup["syllable_count"] as? Int,
                  let matchesArray = lengthGroup["matches"] as? [[String: Any]] else {
                continue
            }
            
            var matches: [RhymeMatch] = []
            
            for matchDict in matchesArray {
                guard let word = matchDict["word"] as? String,
                      let syllCount = matchDict["syllable_count"] as? Int,
                      let phonetic = matchDict["phonetic_similarity"] as? Double,
                      let ending = matchDict["ending_similarity"] as? Double else {
                    continue
                }
                
                let definition = matchDict["definition"] as? String
                let examples = matchDict["examples"] as? [String] ?? []
                
                let match = RhymeMatch(
                    word: word,
                    syllableCount: syllCount,
                    phoneticSimilarity: phonetic,
                    endingSimilarity: ending,
                    definition: definition,
                    examples: examples
                )
                
                matches.append(match)
            }
            
            if !matches.isEmpty {
                let group = RhymeResultsByLength(
                    syllableCount: syllableCount,
                    matches: matches
                )
                resultsByLength.append(group)
            }
        }
        
        // Calculate processing time
        let processingTime = searchStartTime.map { Date().timeIntervalSince($0) } ?? 0
        
        // Extract token usage if available
        let tokensUsed = extractTokenUsage(from: response)
        
        return RhymeSearchResponse(
            originalInput: originalRequest.inputText,
            searchType: originalRequest.searchType,
            language: originalRequest.language,
            resultsByLength: resultsByLength,
            processingTime: processingTime,
            tokensUsed: tokensUsed
        )
    }
    
    private func extractTokenUsage(from response: [String: Any]) -> Int? {
        // Claude format
        if let usage = response["usage"] as? [String: Any],
           let inputTokens = usage["input_tokens"] as? Int,
           let outputTokens = usage["output_tokens"] as? Int {
            return inputTokens + outputTokens
        }
        
        // OpenAI format
        if let usage = response["usage"] as? [String: Any],
           let totalTokens = usage["total_tokens"] as? Int {
            return totalTokens
        }
        
        return nil
    }
    
    // MARK: - Export Functions
    func exportResults(format: String = "txt") -> String {
        guard currentResponse != nil else { return "" }
        
        switch format.lowercased() {
        case "json":
            return exportAsJSON()
        case "markdown", "md":
            return exportAsMarkdown()
        default:
            return exportAsTXT()
        }
    }
    
    private func exportAsTXT() -> String {
        guard let response = currentResponse else { return "" }
        
        var output = """
        ╔══════════════════════════════════════════════════════════════╗
        ║            LYRICANTO - RICERCA RIME AI                       ║
        ║              All Rights Reserved Teofly 2025                 ║
        ╚══════════════════════════════════════════════════════════════╝
        
        INPUT ORIGINALE: "\(response.originalInput)"
        TIPO RICERCA: \(response.searchType.rawValue)
        LINGUA: \(response.language.displayName)
        DATA: \(Date().formatted(date: .long, time: .shortened))
        
        ═══════════════════════════════════════════════════════════════
        STATISTICHE
        ═══════════════════════════════════════════════════════════════
        
        Totale corrispondenze trovate: \(response.totalMatches)
        Tempo elaborazione: \(String(format: "%.2f", response.processingTime))s
        Token utilizzati: \(response.tokensUsed.map { "\($0)" } ?? "N/A")
        
        ═══════════════════════════════════════════════════════════════
        RISULTATI PER LUNGHEZZA
        ═══════════════════════════════════════════════════════════════
        
        """
        
        for lengthGroup in response.resultsByLength {
            output += "\n📏 \(lengthGroup.syllableCount) SILLABE (\(lengthGroup.matches.count) risultati)\n"
            output += String(repeating: "─", count: 60) + "\n\n"
            
            for match in lengthGroup.sortedMatches {
                output += "  ✓ \(match.word.uppercased())\n"
                output += "    Fonetica: \(String(format: "%.0f", match.phoneticSimilarity * 100))% | "
                output += "Finale: \(String(format: "%.0f", match.endingSimilarity * 100))% | "
                output += "\(match.qualityIndicator)\n"
                
                if let definition = match.definition {
                    output += "    Def: \(definition)\n"
                }
                
                if !match.examples.isEmpty {
                    output += "    Es: \(match.examples.joined(separator: " / "))\n"
                }
                
                output += "\n"
            }
        }
        
        output += """
        
        ═══════════════════════════════════════════════════════════════
        © 2025 Teofly - LyriCanto
        matteo@arteni.it
        ═══════════════════════════════════════════════════════════════
        """
        
        return output
    }
    
    private func exportAsMarkdown() -> String {
        guard let response = currentResponse else { return "" }
        
        var output = """
        # LyriCanto - Ricerca Rime AI
        
        **Input:** "\(response.originalInput)"  
        **Tipo ricerca:** \(response.searchType.rawValue)  
        **Lingua:** \(response.language.displayName)  
        **Data:** \(Date().formatted(date: .long, time: .shortened))
        
        ---
        
        ## 📊 Statistiche
        
        - **Totale corrispondenze:** \(response.totalMatches)
        - **Tempo elaborazione:** \(String(format: "%.2f", response.processingTime))s
        - **Token utilizzati:** \(response.tokensUsed.map { "\($0)" } ?? "N/A")
        
        ---
        
        ## 🎯 Risultati
        
        """
        
        for lengthGroup in response.resultsByLength {
            output += "\n### 📏 \(lengthGroup.syllableCount) Sillabe\n\n"
            
            for match in lengthGroup.sortedMatches {
                output += "#### **\(match.word)**\n\n"
                output += "- Similarità fonetica: **\(String(format: "%.0f", match.phoneticSimilarity * 100))%**\n"
                output += "- Similarità finale: **\(String(format: "%.0f", match.endingSimilarity * 100))%**\n"
                output += "- Qualità: \(match.qualityIndicator)\n"
                
                if let definition = match.definition {
                    output += "- Definizione: *\(definition)*\n"
                }
                
                if !match.examples.isEmpty {
                    output += "- Esempi:\n"
                    for example in match.examples {
                        output += "  - \(example)\n"
                    }
                }
                
                output += "\n"
            }
        }
        
        output += "\n---\n\n*© 2025 Teofly - All Rights Reserved*\n"
        
        return output
    }
    
    private func exportAsJSON() -> String {
        guard let response = currentResponse else { return "{}" }
        
        let exportData = RhymeExportData(
            searchRequest: RhymeSearchRequest(
                inputText: response.originalInput,
                searchType: response.searchType,
                language: response.language,
                maxResults: maxResults,
                includeDefinitions: includeDefinitions
            ),
            searchResponse: response,
            exportFormat: "json"
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        guard let jsonData = try? encoder.encode(exportData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{}"
        }
        
        return jsonString
    }
    
    // MARK: - Utility Functions
    func clearResults() {
        currentResponse = nil
        errorMessage = nil
        searchProgress = ""
    }
    
    func clearHistory() {
        searchHistory.removeAll()
    }
    
    func loadHistoryItem(_ item: RhymeSearchHistoryItem) {
        inputText = item.searchText
        searchType = item.searchType
    }
}
