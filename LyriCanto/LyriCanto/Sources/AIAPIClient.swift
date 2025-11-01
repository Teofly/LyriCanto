//
//  AIAPIClient.swift
//  LyriCanto
//
//  API Client for AI providers (Claude, OpenAI)
//  Version 1.2.0 - Fixed to match LyricsGenerationParams
//

import Foundation

// MARK: - AI Provider Enum
enum AIProvider: String, CaseIterable, Codable {
    case claude = "claude"
    case openai = "openai"
    
    var displayName: String {
        switch self {
        case .claude:
            return "Claude (Anthropic)"
        case .openai:
            return "ChatGPT (OpenAI)"
        }
    }
    
    var iconName: String {
        switch self {
        case .claude:
            return "brain.head.profile"
        case .openai:
            return "sparkles"
        }
    }
    
    var modelName: String {
        switch self {
        case .claude:
            return "claude-sonnet-4-20250514"
        case .openai:
            return "gpt-4-turbo-preview"
        }
    }
}

// MARK: - AI API Client
class AIAPIClient {
    // Configuration
    private let claudeBaseURL = "https://api.anthropic.com/v1/messages"
    private let openaiBaseURL = "https://api.openai.com/v1/chat/completions"
    private let timeoutInterval: TimeInterval = 120
    
    var provider: AIProvider = .claude
    
    // MARK: - Rewrite Lyrics (used by LyriCantoViewModel)
    func rewriteLyrics(
        params: LyricsGenerationParams,
        apiKey: String
    ) async throws -> LyricsGenerationResult {
        let prompt = buildRewritePrompt(params: params)
        
        let response: [String: Any]
        
        switch provider {
        case .claude:
            response = try await callClaude(
                prompt: prompt,
                apiKey: apiKey,
                maxTokens: 4000
            )
        case .openai:
            response = try await callOpenAI(
                prompt: prompt,
                apiKey: apiKey,
                maxTokens: 4000
            )
        }
        
        // Parse response
        let rewrittenText = extractTextFromResponse(response, provider: provider)
        let tokensUsed = extractTokenUsage(response) ?? 0
        
        return LyricsGenerationResult(
            rewrittenText: rewrittenText,
            tokensUsed: tokensUsed,
            warnings: []
        )
    }
    
    // MARK: - Draft Translate (used by LyriCantoViewModel)
    func draftTranslate(
        text: String,
        targetLanguage: String,
        literalness: Double,
        apiKey: String
    ) async throws -> String {
        let style = literalness > 0.5 ? "letterale e precisa" : "idiomatica e naturale"
        
        let prompt = """
        Traduci il seguente testo in \(languageName(targetLanguage)) con uno stile \(style).
        
        Testo originale:
        \(text)
        
        Fornisci solo la traduzione, senza spiegazioni aggiuntive.
        """
        
        let response: [String: Any]
        
        switch provider {
        case .claude:
            response = try await callClaude(
                prompt: prompt,
                apiKey: apiKey,
                maxTokens: 2000
            )
        case .openai:
            response = try await callOpenAI(
                prompt: prompt,
                apiKey: apiKey,
                maxTokens: 2000
            )
        }
        
        return extractTextFromResponse(response, provider: provider)
    }
    
    // MARK: - Build Rewrite Prompt
    private func buildRewritePrompt(params: LyricsGenerationParams) -> String {
        // Sections description
        let sectionsDescription = params.sectionMap.isEmpty
            ? "Non specificata"
            : params.sectionMap.map { "\($0.type.rawValue): \($0.startTime)-\($0.endTime)" }.joined(separator: ", ")
        
        // Syllable targets
        let syllableInfo = params.syllableTargets.isEmpty
            ? "Mantieni metrica simile all'originale"
            : "Target sillabe per riga: \(params.syllableTargets.map { "\($0)" }.joined(separator: ", "))"
        
        return """
        Sei un esperto paroliere e traduttore musicale. Il tuo compito è riscrivere/tradurre un testo musicale mantenendo metrica, rime e struttura.
        
        TESTO ORIGINALE:
        \(params.originalLyrics)
        
        REQUISITI:
        - Lingua target: \(params.targetLanguage)
        - Tema/argomento: \(params.topic.isEmpty ? "Mantieni il tema originale" : params.topic)
        - Struttura sezioni: \(sectionsDescription)
        - Preserva schema rime: \(params.preserveRhymeScheme ? "Sì" : "No")
        - Similarità fonetica: \(Int(params.phoneticSimilarityStrength * 100))%
        - \(syllableInfo)
        
        LINEE GUIDA STILISTICHE:
        - Lessico: \(params.styleGuidelines.lexicon.isEmpty ? "Naturale" : params.styleGuidelines.lexicon)
        - Registro: \(params.styleGuidelines.register)
        - Humor: \(params.styleGuidelines.humor ? "Sì" : "No")
        \(params.styleGuidelines.additionalNotes.isEmpty ? "" : "- Note aggiuntive: \(params.styleGuidelines.additionalNotes)")
        
        ISTRUZIONI:
        1. Mantieni lo stesso numero di righe
        2. Mantieni la stessa metrica sillabica per ogni riga (±1 sillaba)
        3. Preserva lo schema delle rime se richiesto
        4. Mantieni la struttura delle sezioni (strofe, ritornelli, bridge)
        5. Il testo deve essere naturale e cantabile
        6. Mantieni il significato emotivo e il messaggio del testo originale
        7. Usa suoni e terminazioni simili all'originale (similarità fonetica: \(Int(params.phoneticSimilarityStrength * 100))%)
        
        Fornisci solo il testo riscritto, senza commenti o spiegazioni aggiuntive.
        """
    }
    
    // MARK: - Helper: Language Name
    private func languageName(_ code: String) -> String {
        switch code.uppercased() {
        case "IT": return "Italiano"
        case "EN": return "Inglese"
        case "ES": return "Spagnolo"
        case "FR": return "Francese"
        case "DE": return "Tedesco"
        case "PT": return "Portoghese"
        default: return code
        }
    }
    
    // MARK: - Claude API Call
    func callClaude(prompt: String, apiKey: String, maxTokens: Int) async throws -> [String: Any] {
        guard let url = URL(string: claudeBaseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let body: [String: Any] = [
            "model": AIProvider.claude.modelName,
            "max_tokens": maxTokens,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.invalidJSON
        }
        
        return json
    }
    
    // MARK: - OpenAI API Call
    func callOpenAI(prompt: String, apiKey: String, maxTokens: Int) async throws -> [String: Any] {
        guard let url = URL(string: openaiBaseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": AIProvider.openai.modelName,
            "max_tokens": maxTokens,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.invalidJSON
        }
        
        return json
    }
    
    // MARK: - Helper Methods
    func extractTextFromResponse(_ response: [String: Any], provider: AIProvider) -> String {
        switch provider {
        case .claude:
            guard let content = response["content"] as? [[String: Any]],
                  let firstContent = content.first,
                  let text = firstContent["text"] as? String else {
                return ""
            }
            return text
            
        case .openai:
            guard let choices = response["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let text = message["content"] as? String else {
                return ""
            }
            return text
        }
    }
    
    func extractTokenUsage(_ response: [String: Any]) -> Int? {
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
}

// MARK: - API Errors
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidJSON
    case httpError(statusCode: Int, message: String)
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL non valido"
        case .invalidResponse:
            return "Risposta dal server non valida"
        case .invalidJSON:
            return "JSON non valido nella risposta"
        case .httpError(let statusCode, let message):
            return "Errore HTTP \(statusCode): \(message)"
        case .networkError(let error):
            return "Errore di rete: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Errore di decodifica: \(error.localizedDescription)"
        }
    }
}
