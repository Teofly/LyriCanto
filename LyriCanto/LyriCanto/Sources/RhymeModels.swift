//
//  RhymeModels.swift
//  LyriCanto
//
//  Models for AI-powered rhyme and phonetic similarity search
//  Created for Tab 4: AI Rime & Assonanze
//

import Foundation

// MARK: - Search Type
enum RhymeSearchType: String, CaseIterable, Codable {
    case phoneticSimilar = "Fonetica Simile"
    case endingSimilar = "Finali Simili"
    case both = "Entrambi"
    
    var description: String {
        switch self {
        case .phoneticSimilar:
            return "Trova parole con suoni simili (assonanza, consonanza)"
        case .endingSimilar:
            return "Trova parole che terminano in modo simile (rime)"
        case .both:
            return "Combina entrambe le ricerche"
        }
    }
}

// MARK: - Input Type
enum InputType: String, CaseIterable, Codable {
    case word = "Parola Singola"
    case phrase = "Frase"
    
    var placeholder: String {
        switch self {
        case .word:
            return "es. amore, libertà, sogno..."
        case .phrase:
            return "es. nel blu dipinto di blu..."
        }
    }
}

// MARK: - Language Support
enum RhymeLanguage: String, CaseIterable, Codable {
    case italian = "IT"
    case english = "EN"
    case spanish = "ES"
    case french = "FR"
    case german = "DE"
    case portuguese = "PT"
    
    var displayName: String {
        switch self {
        case .italian: return "Italiano"
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .portuguese: return "Português"
        }
    }
}

// MARK: - Search Request
struct RhymeSearchRequest: Codable {
    let inputText: String
    let inputType: InputType
    let searchType: RhymeSearchType
    let language: RhymeLanguage
    let maxResults: Int
    let includeDefinitions: Bool
    let exactEndingMatch: Bool // 🆕 Filtra solo parole con le stesse ultime 3 lettere
    
    init(
        inputText: String,
        inputType: InputType = .word,
        searchType: RhymeSearchType = .both,
        language: RhymeLanguage = .italian,
        maxResults: Int = 20,
        includeDefinitions: Bool = false,
        exactEndingMatch: Bool = false
    ) {
        self.inputText = inputText
        self.inputType = inputType
        self.searchType = searchType
        self.language = language
        self.maxResults = maxResults
        self.includeDefinitions = includeDefinitions
        self.exactEndingMatch = exactEndingMatch
    }
    
    // 🆕 Helper function per ottenere le ultime 3 lettere
    var last3Letters: String? {
        guard inputText.count >= 3 else { return nil }
        return String(inputText.suffix(3)).lowercased()
    }
}

// MARK: - Single Rhyme Result
struct RhymeMatch: Identifiable, Codable {
    let id: UUID
    let word: String
    let syllableCount: Int
    let phoneticSimilarity: Double // 0.0 - 1.0
    let endingSimilarity: Double // 0.0 - 1.0
    let definition: String?
    let examples: [String]
    let italianTranslation: String? // 🆕 Traduzione in italiano (solo per parole straniere)
    
    init(
        word: String,
        syllableCount: Int,
        phoneticSimilarity: Double,
        endingSimilarity: Double,
        definition: String? = nil,
        examples: [String] = [],
        italianTranslation: String? = nil
    ) {
        self.id = UUID()
        self.word = word
        self.syllableCount = syllableCount
        self.phoneticSimilarity = phoneticSimilarity
        self.endingSimilarity = endingSimilarity
        self.definition = definition
        self.examples = examples
        self.italianTranslation = italianTranslation
    }
    
    // Quality indicator based on similarities
    var qualityIndicator: String {
        let average = (phoneticSimilarity + endingSimilarity) / 2.0
        switch average {
        case 0.9...1.0: return "⭐⭐⭐⭐⭐ Eccellente"
        case 0.8..<0.9: return "⭐⭐⭐⭐ Ottimo"
        case 0.7..<0.8: return "⭐⭐⭐ Buono"
        case 0.6..<0.7: return "⭐⭐ Discreto"
        default: return "⭐ Accettabile"
        }
    }
    
    // 🆕 Verifica se la parola finisce con le stesse 3 lettere
    func hasExactEnding(_ ending: String) -> Bool {
        guard word.count >= 3 else { return false }
        return word.suffix(3).lowercased() == ending.lowercased()
    }
}

// MARK: - Results Grouped by Syllable Length
struct RhymeResultsByLength: Identifiable, Codable {
    let id: UUID
    let syllableCount: Int
    var matches: [RhymeMatch]
    
    init(syllableCount: Int, matches: [RhymeMatch]) {
        self.id = UUID()
        self.syllableCount = syllableCount
        self.matches = matches
    }
    
    // Sort matches by quality (phonetic + ending similarity)
    var sortedMatches: [RhymeMatch] {
        matches.sorted { match1, match2 in
            let avg1 = (match1.phoneticSimilarity + match1.endingSimilarity) / 2.0
            let avg2 = (match2.phoneticSimilarity + match2.endingSimilarity) / 2.0
            return avg1 > avg2
        }
    }
    
    // 🆕 Filtra solo le parole con ending esatto
    func filtered(byExactEnding ending: String?) -> RhymeResultsByLength {
        guard let ending = ending else { return self }
        let filteredMatches = matches.filter { $0.hasExactEnding(ending) }
        return RhymeResultsByLength(syllableCount: syllableCount, matches: filteredMatches)
    }
}

// MARK: - Complete Search Response
struct RhymeSearchResponse: Identifiable, Codable {
    let id: UUID
    let originalInput: String
    let searchType: RhymeSearchType
    let language: RhymeLanguage
    let resultsByLength: [RhymeResultsByLength]
    let processingTime: Double
    let tokensUsed: Int?
    let timestamp: Date
    
    init(
        originalInput: String,
        searchType: RhymeSearchType,
        language: RhymeLanguage,
        resultsByLength: [RhymeResultsByLength],
        processingTime: Double,
        tokensUsed: Int? = nil
    ) {
        self.id = UUID()
        self.originalInput = originalInput
        self.searchType = searchType
        self.language = language
        self.resultsByLength = resultsByLength
        self.processingTime = processingTime
        self.tokensUsed = tokensUsed
        self.timestamp = Date()
    }
    
    var totalMatches: Int {
        resultsByLength.reduce(0) { $0 + $1.matches.count }
    }
    
    // 🆕 Applica il filtro exact ending a tutti i risultati
    func filtered(byExactEnding ending: String?) -> RhymeSearchResponse {
        guard let ending = ending else { return self }
        let filteredResults = resultsByLength
            .map { $0.filtered(byExactEnding: ending) }
            .filter { !$0.matches.isEmpty }
        
        return RhymeSearchResponse(
            originalInput: originalInput,
            searchType: searchType,
            language: language,
            resultsByLength: filteredResults,
            processingTime: processingTime,
            tokensUsed: tokensUsed
        )
    }
}

// MARK: - Search History Item
struct RhymeSearchHistoryItem: Identifiable, Codable {
    let id: UUID
    let searchText: String
    let searchType: RhymeSearchType
    let language: RhymeLanguage
    let timestamp: Date
    let resultsCount: Int  // 🆕 Nome aggiornato
    let exactEndingUsed: Bool // 🆕 Indica se è stato usato il filtro exact ending
    
    init(
        searchText: String,
        searchType: RhymeSearchType,
        language: RhymeLanguage,
        resultsCount: Int,
        exactEndingUsed: Bool = false
    ) {
        self.id = UUID()
        self.searchText = searchText
        self.searchType = searchType
        self.language = language
        self.timestamp = Date()
        self.resultsCount = resultsCount
        self.exactEndingUsed = exactEndingUsed
    }
    
    // 🔄 Computed property per retrocompatibilità con View vecchia
    var resultCount: Int {
        return resultsCount
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Statistics
struct RhymeStatistics: Codable {
    var totalSearches: Int = 0
    var totalMatches: Int = 0
    var averageProcessingTime: Double = 0.0
    var totalTokensUsed: Int = 0
    var searchesByLanguage: [String: Int] = [:]
    var searchesByType: [String: Int] = [:]
    var exactEndingSearches: Int = 0 // 🆕 Contatore per ricerche con filtro exact ending
    
    // 🔄 Proprietà per retrocompatibilità con View
    var totalMatchesFound: Int {
        return totalMatches
    }
    
    var averageMatchesPerSearch: Double {
        guard totalSearches > 0 else { return 0 }
        return Double(totalMatches) / Double(totalSearches)
    }
    
    var favoriteSearchType: RhymeSearchType {
        let mostUsedTypeKey = searchesByType.max(by: { $0.value < $1.value })?.key ?? RhymeSearchType.both.rawValue
        return RhymeSearchType(rawValue: mostUsedTypeKey) ?? .both
    }
    
    var mostUsedLanguage: RhymeLanguage {
        let mostUsedLangKey = searchesByLanguage.max(by: { $0.value < $1.value })?.key ?? RhymeLanguage.italian.rawValue
        return RhymeLanguage(rawValue: mostUsedLangKey) ?? .italian
    }
    
    mutating func recordSearch(
        response: RhymeSearchResponse,
        exactEndingUsed: Bool = false
    ) {
        totalSearches += 1
        totalMatches += response.totalMatches
        
        // Update average processing time
        averageProcessingTime = ((averageProcessingTime * Double(totalSearches - 1)) + response.processingTime) / Double(totalSearches)
        
        // Update token usage
        if let tokens = response.tokensUsed {
            totalTokensUsed += tokens
        }
        
        // Update language statistics
        let langKey = response.language.rawValue
        searchesByLanguage[langKey, default: 0] += 1
        
        // Update type statistics
        let typeKey = response.searchType.rawValue
        searchesByType[typeKey, default: 0] += 1
        
        // 🆕 Aggiorna contatore exact ending
        if exactEndingUsed {
            exactEndingSearches += 1
        }
    }
}

// MARK: - Export Data
struct RhymeExportData: Codable {
    let searchRequest: RhymeSearchRequest
    let searchResponse: RhymeSearchResponse
    let exportDate: Date
    let exportFormat: String
    
    init(
        searchRequest: RhymeSearchRequest,
        searchResponse: RhymeSearchResponse,
        exportFormat: String
    ) {
        self.searchRequest = searchRequest
        self.searchResponse = searchResponse
        self.exportDate = Date()
        self.exportFormat = exportFormat
    }
}
