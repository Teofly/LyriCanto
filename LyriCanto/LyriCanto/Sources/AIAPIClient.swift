//
//  AIAPIClient.swift (formerly ClaudeAPIClient.swift)
//  LyriCanto
//
//  Robust API client with support for Claude and OpenAI
//

import Foundation

enum AIProvider: String, CaseIterable {
    case claude = "Claude (Anthropic)"
    case openai = "ChatGPT (OpenAI)"
    
    var displayName: String { rawValue }
}

class AIAPIClient {
    // Claude configuration
    private let claudeBaseURL = "https://api.anthropic.com/v1/messages"
    private let claudeAPIVersion = "2023-06-01"
    private let claudeModel = "claude-sonnet-4-5-20250929"
    
    // OpenAI configuration
    private let openaiBaseURL = "https://api.openai.com/v1/chat/completions"
    private let openaiModel = "gpt-4-turbo-preview"
    
    private let maxRetries = 3
    private let timeoutInterval: TimeInterval = 120
    
    var provider: AIProvider = .claude
    
    // MARK: - Main Rewrite Function
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
        let tokensUsed = estimateTokens(rewrittenText)
        
        return LyricsGenerationResult(
            rewrittenText: rewrittenText,
            tokensUsed: tokensUsed,
            warnings: []
        )
    }
    
    // MARK: - Draft Translation
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
        let fewShotExamples = PromptLibrary.getFewShotExamples()
        
        var prompt = """
        Sei un esperto di riscrittura creativa di testi musicali. Il tuo compito è riscrivere i seguenti testi mantenendo:
        
        1. **Metrica e Sillabe**: Ogni verso deve avere approssimativamente lo stesso numero di sillabe dell'originale
        2. **Schema di Rime**: \(params.preserveRhymeScheme ? "Preserva lo schema di rime (ABAB, AABB, etc.)" : "Le rime sono facoltative")
        3. **Struttura**: Mantieni la divisione in strofe, ritornelli, bridge come indicato
        4. **Similarità Fonetica**: Con forza \(String(format: "%.1f", params.phoneticSimilarityStrength)), cerca di usare suoni e rime che richiamano foneticamente l'originale
        5. **Tema**: Il nuovo testo deve trattare di "\(params.topic)"
        6. **Lingua**: Scrivi interamente in \(languageName(params.targetLanguage))
        
        ESEMPI DI RIFERIMENTO:
        \(fewShotExamples)
        
        TESTO ORIGINALE DA RISCRIVERE:
        \(params.originalLyrics)
        
        SEZIONI IDENTIFICATE:
        \(formatSections(params.sectionMap))
        
        CONTEGGIO SILLABE TARGET PER VERSO:
        \(params.syllableTargets.enumerated().map { "Verso \($0.offset + 1): \($0.element) sillabe" }.joined(separator: "\n"))
        
        """
        
        // Add style guidelines if provided
        if !params.styleGuidelines.lexicon.isEmpty {
            prompt += "\nLESSICO PREFERITO: \(params.styleGuidelines.lexicon)"
        }
        
        if !params.styleGuidelines.register.isEmpty {
            prompt += "\nREGISTRO: \(params.styleGuidelines.register)"
        }
        
        if params.styleGuidelines.humor {
            prompt += "\nSTILE: Umoristico e giocoso"
        }
        
        if !params.styleGuidelines.additionalNotes.isEmpty {
            prompt += "\nNOTE AGGIUNTIVE: \(params.styleGuidelines.additionalNotes)"
        }
        
        prompt += """
        
        
        IMPORTANTE:
        - Fornisci SOLO il testo riscritto, senza spiegazioni o commenti
        - Mantieni la stessa struttura di strofe e righe
        - Usa una nuova riga per ogni verso
        - Separa le sezioni con una riga vuota
        
        TESTO RISCRITTO:
        """
        
        return prompt
    }
    
    // MARK: - Call Claude API
    func callClaude(
        prompt: String,
        apiKey: String,
        maxTokens: Int
    ) async throws -> [String: Any] {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await performClaudeRequest(
                    prompt: prompt,
                    apiKey: apiKey,
                    maxTokens: maxTokens
                )
            } catch let error as URLError {
                lastError = error
                if attempt < maxRetries {
                    let delay = Double(attempt) * 2.0
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            } catch {
                throw error
            }
        }
        
        throw lastError ?? NSError(
            domain: "ClaudeAPI",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Richiesta fallita dopo \(maxRetries) tentativi"]
        )
    }
    
    private func performClaudeRequest(
        prompt: String,
        apiKey: String,
        maxTokens: Int
    ) async throws -> [String: Any] {
        guard let url = URL(string: claudeBaseURL) else {
            throw NSError(
                domain: "ClaudeAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL non valido"]
            )
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutInterval
        
        // Headers
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(claudeAPIVersion, forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        // Body
        let body: [String: Any] = [
            "model": claudeModel,
            "max_tokens": maxTokens,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(
                domain: "ClaudeAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Risposta non valida"]
            )
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Errore sconosciuto"
            throw NSError(
                domain: "ClaudeAPI",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"]
            )
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(
                domain: "ClaudeAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "JSON non valido"]
            )
        }
        
        return json
    }
    
    // MARK: - Call OpenAI API
    func callOpenAI(
        prompt: String,
        apiKey: String,
        maxTokens: Int
    ) async throws -> [String: Any] {
        var lastError: Error?
        
        for attempt in 1...maxRetries {
            do {
                return try await performOpenAIRequest(
                    prompt: prompt,
                    apiKey: apiKey,
                    maxTokens: maxTokens
                )
            } catch let error as URLError {
                lastError = error
                if attempt < maxRetries {
                    let delay = Double(attempt) * 2.0
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            } catch {
                throw error
            }
        }
        
        throw lastError ?? NSError(
            domain: "OpenAI",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Richiesta fallita dopo \(maxRetries) tentativi"]
        )
    }
    
    private func performOpenAIRequest(
        prompt: String,
        apiKey: String,
        maxTokens: Int
    ) async throws -> [String: Any] {
        guard let url = URL(string: openaiBaseURL) else {
            throw NSError(
                domain: "OpenAI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL non valido"]
            )
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = timeoutInterval
        
        // Headers
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body
        let body: [String: Any] = [
            "model": openaiModel,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": maxTokens,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(
                domain: "OpenAI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Risposta non valida"]
            )
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Errore sconosciuto"
            throw NSError(
                domain: "OpenAI",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"]
            )
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(
                domain: "OpenAI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "JSON non valido"]
            )
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
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
            
        case .openai:
            guard let choices = response["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let text = message["content"] as? String else {
                return ""
            }
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func estimateTokens(_ text: String) -> Int {
        // Stima approssimativa: ~1 token ogni 4 caratteri
        return text.count / 4
    }
    
    private func languageName(_ code: String) -> String {
        switch code {
        case "IT": return "Italiano"
        case "EN": return "English"
        case "ES": return "Español"
        case "FR": return "Français"
        case "DE": return "Deutsch"
        case "PT": return "Português"
        default: return code
        }
    }
    
    private func formatSections(_ sections: [LyricSection]) -> String {
        sections.map { section in
            "\(section.type.rawValue): \(section.startTime) - \(section.endTime)"
        }.joined(separator: "\n")
    }
    
    // MARK: - Audio Transcription with Whisper
    func transcribeAudio(
        audioURL: URL,
        apiKey: String,
        language: String? = nil
    ) async throws -> String {
        let whisperURL = "https://api.openai.com/v1/audio/transcriptions"
        
        guard let url = URL(string: whisperURL) else {
            throw NSError(
                domain: "WhisperAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "URL non valido"]
            )
        }
        
        // Read audio file
        let audioData = try Data(contentsOf: audioURL)
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 300 // 5 minutes for audio processing
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add model parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        
        // Add language parameter if specified
        if let language = language {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(language)\r\n".data(using: .utf8)!)
        }
        
        // Add response_format parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n".data(using: .utf8)!)
        body.append("text\r\n".data(using: .utf8)!)
        
        // Add audio file
        let filename = audioURL.lastPathComponent
        let mimeType = getMimeType(for: audioURL.pathExtension)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(
                domain: "WhisperAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Risposta non valida"]
            )
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Errore sconosciuto"
            throw NSError(
                domain: "WhisperAPI",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"]
            )
        }
        
        // Whisper returns plain text with response_format=text
        guard let transcription = String(data: data, encoding: .utf8) else {
            throw NSError(
                domain: "WhisperAPI",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Impossibile decodificare la trascrizione"]
            )
        }
        
        return transcription.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func getMimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "mp3": return "audio/mpeg"
        case "mp4", "m4a": return "audio/mp4"
        case "wav": return "audio/wav"
        case "webm": return "audio/webm"
        case "flac": return "audio/flac"
        case "ogg": return "audio/ogg"
        default: return "audio/mpeg"
        }
    }
}

// MARK: - Prompt Library
struct PromptLibrary {
    static func getFewShotExamples() -> String {
        """
        ESEMPIO 1 - Mantenimento Metrica (Italiano):
        
        Originale (8 sillabe per verso):
        "Nel blu dipinto di blu" (8)
        "Felice di stare quassù" (8)
        
        Riscritto (tema: tecnologia, 8 sillabe):
        "Nel web connesso in 5G" (8)
        "Navigo veloce da qui" (8)
        
        ESEMPIO 2 - Schema Rime ABAB (Inglese → Italiano):
        
        Originale:
        "I see trees of green" (A)
        "Red roses too" (B)
        "I see them bloom" (A)
        "For me and you" (B)
        
        Riscritto (tema: viaggio, ABAB):
        "Vedo città lontane" (A - 7 sillabe)
        "Strade da scoprir" (B - 6 sillabe)
        "Con valigie in mano" (A - 7 sillabe, rima con "lontane")
        "Pronto a partir" (B - 5 sillabe, rima con "scoprir")
        
        ESEMPIO 3 - Similarità Fonetica Alta (0.8+):
        
        Originale EN: "Shake it off, shake it off" (suoni: /ʃeɪk/)
        Riscritto IT: "Scuoti via, scuoti via" (suoni simili: /sku/)
        
        Nota: Cerca allitterazioni e assonanze che richiamino i suoni originali
        """
    }
}
