//
//  RhymeAIViewModel.swift
//  LyriCanto
//
//  ViewModel for AI Rhyme Search functionality
//  Handles API calls, state management, and result processing
//  
//  🆕 VERSIONE MODIFICATA - Supporto per FRASI che rimano con numero sillabe simile
//  Quando inputType=phrase e searchType=endingSimilar, restituisce FRASI COMPLETE
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
    @Published var exactEndingMatch: Bool = false
    
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
            // Build search request with NEW parameters
            let request = RhymeSearchRequest(
                inputText: inputText.trimmingCharacters(in: .whitespacesAndNewlines),
                inputType: inputType,
                searchType: searchType,
                language: language,
                maxResults: maxResults,
                includeDefinitions: includeDefinitions,
                exactEndingMatch: exactEndingMatch
            )
            
            // Show appropriate progress message
            if request.inputType == .phrase && request.searchType == .endingSimilar {
                searchProgress = "Cercando frasi che rimano con sillabe simili..."
            } else if exactEndingMatch, let ending = request.last3Letters {
                searchProgress = "Cercando parole che finiscono con '\(ending)'..."
            } else {
                searchProgress = "Invio richiesta a \(provider.displayName)..."
            }
            
            // Call AI API
            let response = try await searchForRhymes(request: request, apiKey: apiKey)
            
            // Update state
            currentResponse = response
            
            // Update statistics
            statistics.recordSearch(
                response: response,
                exactEndingUsed: request.exactEndingMatch
            )
            
            // Add to history
            let historyItem = RhymeSearchHistoryItem(
                searchText: request.inputText,
                searchType: searchType,
                language: language,
                resultsCount: response.totalMatches,
                exactEndingUsed: request.exactEndingMatch
            )
            searchHistory.insert(historyItem, at: 0)
            
            // Keep only last 50 searches
            if searchHistory.count > 50 {
                searchHistory = Array(searchHistory.prefix(50))
            }
            
            searchProgress = "✅ Trovate \(response.totalMatches) corrispondenze!"
            
            // Auto-clear progress after 3 seconds
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                searchProgress = ""
            }
            
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
    
    // MARK: - Prompt Building (🆕 COMPLETAMENTE AGGIORNATO)
    private func buildSearchPrompt(request: RhymeSearchRequest) -> String {
        let searchTypeInstruction: String
        
        // 🆕 NUOVA LOGICA: Gestione speciale per frasi con "finali simili"
        if request.inputType == .phrase && request.searchType == .endingSimilar {
            // Conta le sillabe approssimative della frase input
            let approximateSyllables = countApproximateSyllables(request.inputText)
            
            searchTypeInstruction = """
            🎯 MODALITÀ SPECIALE: FRASI CHE RIMANO
            
            Trova FRASI COMPLETE (non singole parole) che:
            1. RIMANO con l'ultima parola della frase input
            2. Hanno un numero di sillabe SIMILE alla frase input (±2 sillabe)
            3. Hanno senso compiuto e sono utilizzabili in canzoni/poesie
            
            FRASE INPUT: "\(request.inputText)"
            SILLABE APPROSSIMATIVE INPUT: \(approximateSyllables)
            
            TARGET: Frasi da \(max(approximateSyllables - 2, 6)) a \(approximateSyllables + 2) sillabe
            
            REQUISITI CRITICI:
            - Restituisci SOLO frasi complete, NON singole parole
            - Ogni frase deve fare RIMA con l'ultima parola della frase input
            - Varia lo stile: poetiche, colloquiali, creative, narrative
            - Le frasi devono avere senso logico e grammaticale
            - Usa linguaggio naturale e fluido
            
            ESEMPI DI OUTPUT CORRETTO:
            Se input è "andando per porti oscuri" (9 sillabe):
            - "cercando i tuoi dolci furi" (8 sillabe) ✓
            - "passando per luoghi sicuri" (9 sillabe) ✓
            - "sognando tesori più puri" (8 sillabe) ✓
            - "trovando orizzonti futuri" (10 sillabe) ✓
            
            ESEMPI DI OUTPUT SBAGLIATO:
            - "furi" ✗ (singola parola, non frase)
            - "oscuri" ✗ (singola parola, non frase)
            - "andando per mari e monti felici" ✗ (non rima con "oscuri")
            """
        } else {
            // Logica originale per parole singole
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
        }
        
        let inputTypeInstruction: String
        if request.inputType == .phrase && request.searchType == .endingSimilar {
            inputTypeInstruction = "Input: FRASE COMPLETA → Output: FRASI COMPLETE che rimano"
        } else if request.inputType == .word {
            inputTypeInstruction = "Input: PAROLA SINGOLA → Output: PAROLE che rimano"
        } else {
            inputTypeInstruction = "Input: FRASE COMPLETA → Output: PAROLE che rimano con le parole chiave"
        }
        
        let definitionInstruction = request.includeDefinitions
            ? "Includi una breve definizione/contesto (max 15 parole) per ogni risultato."
            : "NON includere definizioni."
        
        var prompt = """
        Sei un esperto linguista e poeta specializzato in metrica della lingua \(request.language.displayName).
        
        COMPITO:
        \(searchTypeInstruction)
        
        \(inputTypeInstruction)
        INPUT: "\(request.inputText)"
        
        REQUISITI:
        1. Trova ESATTAMENTE \(request.maxResults) risultati diversi
        2. Raggruppa per numero di sillabe (conta attentamente!)
        3. Valuta similarità fonetica (0.0 - 1.0)
        4. Valuta similarità finale (0.0 - 1.0)
        5. \(definitionInstruction)
        6. Fornisci 2-3 esempi d'uso contestuali
        """
        
        // Istruzione per exact ending se attivo
        if request.exactEndingMatch, let ending = request.last3Letters {
            prompt += """
            
            
            ⚠️ FILTRO OBBLIGATORIO - ENDING ESATTO ⚠️
            Restituisci SOLAMENTE risultati che finiscono esattamente con: '\(ending)'
            Questo requisito è CRITICO e non può essere ignorato.
            """
        }
        
        // Istruzione per traduzioni se non è italiano
        if request.language != .italian {
            prompt += """
            
            
            📝 TRADUZIONI IN ITALIANO
            Per OGNI risultato, fornisci la traduzione in italiano nel campo 'italian_translation'.
            """
        }
        
        // 🆕 Formato JSON diverso per frasi vs parole
        var jsonExample: String
        if request.inputType == .phrase && request.searchType == .endingSimilar {
            jsonExample = """
            
            
            FORMATO RISPOSTA (SOLO JSON VALIDO, NESSUN TESTO EXTRA):
            {
              "results_by_length": [
                {
                  "syllable_count": 8,
                  "matches": [
                    {
                      "word": "cercando i tuoi dolci furi",
                      "syllable_count": 8,
                      "phonetic_similarity": 0.85,
                      "ending_similarity": 0.95,
                      "definition": "Frase che esprime ricerca di momenti rubati",
                      "examples": [
                        "Uso in strofa: Cercando i tuoi dolci furi, nella notte senza paure",
                        "Perfetta per tema romantico/nostalgico"
                      ]
                    }
                  ]
                },
                {
                  "syllable_count": 9,
                  "matches": [
                    {
                      "word": "passando per luoghi sicuri",
                      "syllable_count": 9,
                      "phonetic_similarity": 0.80,
                      "ending_similarity": 0.90,
                      "definition": "Frase che descrive un percorso protetto",
                      "examples": [
                        "Uso narrativo: Passando per luoghi sicuri, evitando i pericoli",
                        "Adatta per testi di viaggio/avventura"
                      ]
                    }
                  ]
                }
              ]
            }
            
            IMPORTANTE: Il campo "word" contiene la FRASE COMPLETA, non una parola singola!
            """
        } else {
            jsonExample = """
            
            
            FORMATO RISPOSTA (SOLO JSON VALIDO, NESSUN TESTO EXTRA):
            {
              "results_by_length": [
                {
                  "syllable_count": 2,
                  "matches": [
                    {
                      "word": "parola",
                      "syllable_count": 2,
                      "phonetic_similarity": 0.85,
                      "ending_similarity": 0.90,
                      "definition": "breve definizione",
                      "examples": ["esempio 1", "esempio 2"]
            """
            
            if request.language != .italian {
                jsonExample += """
,
                      "italian_translation": "traduzione"
"""
            }
            
            jsonExample += """

                    }
                  ]
                }
              ]
            }
"""
        }
        
        prompt += """
        \(jsonExample)
        
        ⚠️ CRITICO: Rispondi SOLO con il JSON, senza alcun testo aggiuntivo prima o dopo.
        """
        
        return prompt
    }
    
    // 🆕 NUOVA FUNZIONE: Conta sillabe approssimative
    private func countApproximateSyllables(_ text: String) -> Int {
        let vowels = CharacterSet(charactersIn: "aeiouàèéìòùAEIOUÀÈÉÌÒÙ")
        var count = 0
        var previousWasVowel = false
        
        for char in text.unicodeScalars {
            let isVowel = vowels.contains(char)
            if isVowel && !previousWasVowel {
                count += 1
            }
            previousWasVowel = isVowel
        }
        
        return max(count, 1) // Minimo 1 sillaba
    }
    
    // MARK: - Response Parsing (invariato)
    private func parseAIResponse(response: [String: Any], originalRequest: RhymeSearchRequest) throws -> RhymeSearchResponse {
        // Extract text content based on provider
        var responseText: String
        
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
                let italianTranslation = matchDict["italian_translation"] as? String
                
                let match = RhymeMatch(
                    word: word,
                    syllableCount: syllCount,
                    phoneticSimilarity: phonetic,
                    endingSimilarity: ending,
                    definition: definition,
                    examples: examples,
                    italianTranslation: italianTranslation
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
        
        var finalResponse = RhymeSearchResponse(
            originalInput: originalRequest.inputText,
            searchType: originalRequest.searchType,
            language: originalRequest.language,
            resultsByLength: resultsByLength,
            processingTime: processingTime,
            tokensUsed: tokensUsed
        )
        
        // Applica filtro exact ending se richiesto
        if originalRequest.exactEndingMatch {
            finalResponse = finalResponse.filtered(byExactEnding: originalRequest.last3Letters)
        }
        
        return finalResponse
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
    
    // MARK: - Export Functions (invariati)
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
        """
        
        if exactEndingMatch, inputText.count >= 3 {
            let ending = String(inputText.suffix(3))
            output += "\nFILTRO ATTIVO: Solo terminazioni '\(ending)'"
        }
        
        output += """
        
        
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
                
                if let translation = match.italianTranslation {
                    output += "    IT: \(translation)\n"
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
        """
        
        if exactEndingMatch, inputText.count >= 3 {
            let ending = String(inputText.suffix(3))
            output += "\n**Filtro Attivo:** Solo terminazioni '\(ending)'"
        }
        
        output += """
        
        
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
                
                if let translation = match.italianTranslation {
                    output += "- Traduzione IT: **\(translation)**\n"
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
                includeDefinitions: includeDefinitions,
                exactEndingMatch: exactEndingMatch
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
        language = item.language
        exactEndingMatch = item.exactEndingUsed
    }
}
