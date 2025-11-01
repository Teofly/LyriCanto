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
    
    init(
        inputText: String,
        inputType: InputType = .word,
        searchType: RhymeSearchType = .both,
        language: RhymeLanguage = .italian,
        maxResults: Int = 20,
        includeDefinitions: Bool = false
    ) {
        self.inputText = inputText
        self.inputType = inputType
        self.searchType = searchType
        self.language = language
        self.maxResults = maxResults
        self.includeDefinitions = includeDefinitions
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
    
    init(
        word: String,
        syllableCount: Int,
        phoneticSimilarity: Double,
        endingSimilarity: Double,
        definition: String? = nil,
        examples: [String] = []
    ) {
        self.id = UUID()
        self.word = word
        self.syllableCount = syllableCount
        self.phoneticSimilarity = phoneticSimilarity
        self.endingSimilarity = endingSimilarity
        self.definition = definition
        self.examples = examples
    }
    
    // Overall quality score
    var overallScore: Double {
        (phoneticSimilarity + endingSimilarity) / 2.0
    }
    
    // Quality indicator
    var qualityIndicator: String {
        if overallScore >= 0.85 {
            return "🟢 Eccellente"
        } else if overallScore >= 0.65 {
            return "🟡 Buono"
        } else {
            return "🟠 Accettabile"
        }
    }
}

// MARK: - Results Grouped by Length
struct RhymeResultsByLength: Identifiable, Codable {
    let id: UUID
    let syllableCount: Int
    let matches: [RhymeMatch]
    
    init(syllableCount: Int, matches: [RhymeMatch]) {
        self.id = UUID()
        self.syllableCount = syllableCount
        self.matches = matches
    }
    
    var sortedMatches: [RhymeMatch] {
        matches.sorted { $0.overallScore > $1.overallScore }
    }
}

// MARK: - Complete Search Response
struct RhymeSearchResponse: Codable {
    let originalInput: String
    let searchType: RhymeSearchType
    let language: RhymeLanguage
    let resultsByLength: [RhymeResultsByLength]
    let totalMatches: Int
    let processingTime: TimeInterval
    let tokensUsed: Int?
    
    init(
        originalInput: String,
        searchType: RhymeSearchType,
        language: RhymeLanguage,
        resultsByLength: [RhymeResultsByLength],
        processingTime: TimeInterval,
        tokensUsed: Int? = nil
    ) {
        self.originalInput = originalInput
        self.searchType = searchType
        self.language = language
        self.resultsByLength = resultsByLength.sorted { $0.syllableCount < $1.syllableCount }
        self.totalMatches = resultsByLength.reduce(0) { $0 + $1.matches.count }
        self.processingTime = processingTime
        self.tokensUsed = tokensUsed
    }
    
    // Get all matches flattened
    var allMatches: [RhymeMatch] {
        resultsByLength.flatMap { $0.matches }
    }
    
    // Get best matches across all lengths
    var topMatches: [RhymeMatch] {
        allMatches.sorted { $0.overallScore > $1.overallScore }.prefix(10).map { $0 }
    }
}

// MARK: - Export Format
struct RhymeExportData: Codable {
    let timestamp: Date
    let searchRequest: RhymeSearchRequest
    let searchResponse: RhymeSearchResponse
    let exportFormat: String
    
    init(
        searchRequest: RhymeSearchRequest,
        searchResponse: RhymeSearchResponse,
        exportFormat: String = "txt"
    ) {
        self.timestamp = Date()
        self.searchRequest = searchRequest
        self.searchResponse = searchResponse
        self.exportFormat = exportFormat
    }
}

// MARK: - Search History Item
struct RhymeSearchHistoryItem: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let searchText: String
    let resultCount: Int
    let searchType: RhymeSearchType
    
    init(
        searchText: String,
        resultCount: Int,
        searchType: RhymeSearchType
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.searchText = searchText
        self.resultCount = resultCount
        self.searchType = searchType
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

// MARK: - Statistics
struct RhymeStatistics: Codable {
    var totalSearches: Int = 0
    var totalMatchesFound: Int = 0
    var averageMatchesPerSearch: Double {
        guard totalSearches > 0 else { return 0 }
        return Double(totalMatchesFound) / Double(totalSearches)
    }
    var favoriteSearchType: RhymeSearchType = .both
    var mostUsedLanguage: RhymeLanguage = .italian
    
    mutating func recordSearch(matches: Int, searchType: RhymeSearchType, language: RhymeLanguage) {
        totalSearches += 1
        totalMatchesFound += matches
        favoriteSearchType = searchType
        mostUsedLanguage = language
    }
}
