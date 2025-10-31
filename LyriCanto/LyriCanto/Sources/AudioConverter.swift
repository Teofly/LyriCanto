//
//  AudioConverter.swift
//  LyriCanto
//
//  Audio conversion service using api2convert.com API
//

import Foundation

// MARK: - Audio Converter Service
class AudioConverter: ObservableObject {
    
    @Published var isConverting = false
    @Published var conversionProgress: Double = 0.0
    @Published var conversionStatus = ""
    @Published var lastError: String?
    @Published var outputURL: URL?
    
    // NOTA: Verifica che l'API endpoint sia corretto
    // Documentazione: https://www.api2convert.com/api-documentation
    private let baseURL = "https://api.api2convert.com/v2"
    private var pollingTimer: Timer?
    
    // L'utente deve inserire la propria API key nelle impostazioni
    @Published var apiKey: String = "" {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "AudioConverterAPIKey")
        }
    }
    
    init() {
        // Carica API key salvata
        if let savedKey = UserDefaults.standard.string(forKey: "AudioConverterAPIKey") {
            self.apiKey = savedKey
        }
    }
    
    // MARK: - Test API Key
    func testAPIKey() async throws -> Bool {
        guard !apiKey.isEmpty else {
            throw ConversionError.missingAPIKey
        }
        
        // Prova a fare una richiesta semplice per verificare l'API key
        let url = URL(string: "\(baseURL)/jobs")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-Oc-Api-Key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        print("API Key Test Status: \(httpResponse.statusCode)")
        print("API Key Test Response: \(responseString)")
        
        // 200 o 401 ci diranno se l'API key è valida o no
        return httpResponse.statusCode != 401 && httpResponse.statusCode != 403
    }
    
    // MARK: - Main Conversion Method
    func convertAudio(
        inputURL: URL,
        targetFormat: AudioFormat = .mp3,
        options: ConversionOptions = ConversionOptions()
    ) async throws -> URL {
        // NOTA: ConversionOptions ora supporta solo audio_bitrate e audio_codec
        // Lascia le opzioni vuote per qualità automatica
        // Esempio con bitrate custom: ConversionOptions(audioBitrate: 320)
        
        guard !apiKey.isEmpty else {
            throw ConversionError.missingAPIKey
        }
        
        await MainActor.run {
            isConverting = true
            conversionProgress = 0.0
            conversionStatus = "Caricamento file..."
            lastError = nil
            outputURL = nil
        }
        
        do {
            // Step 1: Upload file o usa URL remoto
            let remoteURL: String
            if inputURL.isFileURL {
                remoteURL = try await uploadFile(inputURL)
                await updateStatus("File caricato. Avvio conversione...")
            } else {
                remoteURL = inputURL.absoluteString
                await updateStatus("Avvio conversione...")
            }
            
            // Step 2: Crea job di conversione
            let jobID = try await createConversionJob(
                remoteURL: remoteURL,
                targetFormat: targetFormat,
                options: options
            )
            
            await updateStatus("Conversione in corso...")
            await updateProgress(0.3)
            
            // Step 3: Polling dello stato
            let downloadURL = try await pollJobStatus(jobID: jobID)
            
            await updateStatus("Download file convertito...")
            await updateProgress(0.9)
            
            // Step 4: Download del file convertito
            let localURL = try await downloadConvertedFile(from: downloadURL, format: targetFormat)
            
            await updateStatus("✅ Conversione completata!")
            await updateProgress(1.0)
            
            await MainActor.run {
                self.outputURL = localURL
                self.isConverting = false
            }
            
            return localURL
            
        } catch {
            await MainActor.run {
                self.lastError = error.localizedDescription
                self.conversionStatus = "❌ Errore: \(error.localizedDescription)"
                self.isConverting = false
            }
            throw error
        }
    }
    
    // MARK: - Upload File (if local)
    private func uploadFile(_ fileURL: URL) async throws -> String {
        print("Uploading file: \(fileURL.lastPathComponent)")
        
        let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        print("File size: \(fileSize) bytes")
        
        // Prova prima con file.io
        do {
            return try await uploadToFileIO(fileURL)
        } catch {
            print("file.io upload failed: \(error)")
            print("Trying alternative upload service...")
            
            // Se file.io fallisce, prova con tmpfiles.org
            return try await uploadToTmpFiles(fileURL)
        }
    }
    
    // MARK: - Upload to file.io
    private func uploadToFileIO(_ fileURL: URL) async throws -> String {
        let uploadURL = URL(string: "https://file.io")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        // Add file data
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        
        let fileData = try Data(contentsOf: fileURL)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
        
        // Add expires parameter
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"expires\"\r\n\r\n".data(using: .utf8)!)
        data.append("1d\r\n".data(using: .utf8)!)
        
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        request.timeoutInterval = 60
        
        print("Uploading to file.io...")
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConversionError.uploadFailed
        }
        
        let responseString = String(data: responseData, encoding: .utf8) ?? ""
        print("File.io Status: \(httpResponse.statusCode)")
        print("File.io Response: \(responseString)")
        
        guard httpResponse.statusCode == 200 else {
            throw ConversionError.uploadFailed
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw ConversionError.uploadFailed
        }
        
        if let success = json["success"] as? Bool, !success {
            let message = json["message"] as? String ?? "Unknown error"
            throw ConversionError.apiError("Upload failed: \(message)")
        }
        
        guard let link = json["link"] as? String else {
            throw ConversionError.uploadFailed
        }
        
        print("File.io upload successful: \(link)")
        return link
    }
    
    // MARK: - Upload to tmpfiles.org
    private func uploadToTmpFiles(_ fileURL: URL) async throws -> String {
        let uploadURL = URL(string: "https://tmpfiles.org/api/v1/upload")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        
        let fileData = try Data(contentsOf: fileURL)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        request.timeoutInterval = 60
        
        print("Uploading to tmpfiles.org...")
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConversionError.uploadFailed
        }
        
        let responseString = String(data: responseData, encoding: .utf8) ?? ""
        print("TmpFiles Status: \(httpResponse.statusCode)")
        print("TmpFiles Response: \(responseString)")
        
        guard httpResponse.statusCode == 200 else {
            throw ConversionError.uploadFailed
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let data = json["data"] as? [String: Any],
              let url = data["url"] as? String else {
            throw ConversionError.uploadFailed
        }
        
        // tmpfiles.org restituisce URL come https://tmpfiles.org/12345/file.mp3
        // Dobbiamo convertirlo in https://tmpfiles.org/dl/12345/file.mp3 per il download diretto
        let downloadURL = url.replacingOccurrences(of: "tmpfiles.org/", with: "tmpfiles.org/dl/")
        
        print("TmpFiles upload successful: \(downloadURL)")
        return downloadURL
    }
    
    // MARK: - Create Conversion Job
    private func createConversionJob(
        remoteURL: String,
        targetFormat: AudioFormat,
        options: ConversionOptions
    ) async throws -> String {
        
        let url = URL(string: "\(baseURL)/jobs")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Oc-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "input": [[
                "type": "remote",
                "source": remoteURL
            ]],
            "conversion": [[
                "category": "audio",
                "target": targetFormat.rawValue,
                "options": options.toDictionary()
            ]]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        let payloadString = String(data: jsonData, encoding: .utf8) ?? ""
        print("API Request Payload: \(payloadString)")
        
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ConversionError.networkError
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        print("API Response Status: \(httpResponse.statusCode)")
        print("API Response Body: \(responseString)")
        
        guard httpResponse.statusCode == 201 else {
            throw ConversionError.apiError("Status \(httpResponse.statusCode): \(responseString)")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ConversionError.invalidResponse
        }
        
        guard let jobID = json["id"] as? String else {
            print("JSON keys: \(json.keys)")
            throw ConversionError.invalidResponse
        }
        
        return jobID
    }
    
    // MARK: - Poll Job Status
    private func pollJobStatus(jobID: String) async throws -> String {
        let maxAttempts = 60 // 5 minuti (ogni 5 secondi)
        var attempts = 0
        
        while attempts < maxAttempts {
            let url = URL(string: "\(baseURL)/jobs/\(jobID)")!
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "X-Oc-Api-Key")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                let responseString = String(data: data, encoding: .utf8) ?? ""
                print("Poll Job Error: \(responseString)")
                throw ConversionError.apiError("Failed to poll job status")
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print("Poll Job Response: \(responseString)")
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw ConversionError.invalidResponse
            }
            
            guard let status = json["status"] as? [String: Any],
                  let code = status["code"] as? String else {
                print("JSON structure: \(json)")
                throw ConversionError.invalidResponse
            }
            
            switch code {
            case "completed":
                guard let output = json["output"] as? [[String: Any]],
                      let firstOutput = output.first,
                      let uri = firstOutput["uri"] as? String else {
                    throw ConversionError.invalidResponse
                }
                return uri
                
            case "failed":
                let info = status["info"] as? String ?? "Unknown error"
                throw ConversionError.conversionFailed(info)
                
            case "processing", "waiting":
                // Aggiorna progress
                let progress = 0.3 + (Double(attempts) / Double(maxAttempts) * 0.6)
                await updateProgress(progress)
                
                // Aspetta 5 secondi prima del prossimo tentativo
                try await Task.sleep(nanoseconds: 5_000_000_000)
                attempts += 1
                
            default:
                // Stati sconosciuti, continua polling
                try await Task.sleep(nanoseconds: 5_000_000_000)
                attempts += 1
            }
        }
        
        throw ConversionError.timeout
    }
    
    // MARK: - Download Converted File
    private func downloadConvertedFile(from urlString: String, format: AudioFormat) async throws -> URL {
        guard let url = URL(string: urlString) else {
            throw ConversionError.invalidURL
        }
        
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        
        // Sposta in Downloads con nome appropriato
        let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "converted_\(timestamp).\(format.rawValue)"
        let destinationURL = downloadsDir.appendingPathComponent(filename)
        
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: tempURL, to: destinationURL)
        
        return destinationURL
    }
    
    // MARK: - Helper Methods
    @MainActor
    private func updateStatus(_ status: String) {
        self.conversionStatus = status
    }
    
    @MainActor
    private func updateProgress(_ progress: Double) {
        self.conversionProgress = progress
    }
}

// MARK: - Audio Formats
enum AudioFormat: String, CaseIterable, Identifiable {
    case mp3 = "mp3"
    case wav = "wav"
    case aac = "aac"
    case flac = "flac"
    case ogg = "ogg"
    case m4a = "m4a"
    case wma = "wma"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .mp3: return "MP3"
        case .wav: return "WAV"
        case .aac: return "AAC"
        case .flac: return "FLAC"
        case .ogg: return "OGG Vorbis"
        case .m4a: return "M4A"
        case .wma: return "WMA"
        }
    }
}

// MARK: - Conversion Options
struct ConversionOptions {
    var audioBitrate: Int? = nil  // kbps - lascia nil per qualità automatica
    var audioCodec: String? = nil
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // Invia solo audio_bitrate se specificato
        if let bitrate = audioBitrate {
            dict["audio_bitrate"] = "\(bitrate)k"
        }
        
        // Invia solo audio_codec se specificato
        if let codec = audioCodec {
            dict["audio_codec"] = codec
        }
        
        return dict
    }
}

// MARK: - Errors
enum ConversionError: LocalizedError {
    case missingAPIKey
    case uploadFailed
    case networkError
    case apiError(String)
    case invalidResponse
    case jsonParsingError(String)
    case conversionFailed(String)
    case timeout
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key mancante. Inseriscila nelle impostazioni."
        case .uploadFailed:
            return "Caricamento file fallito"
        case .networkError:
            return "Errore di rete"
        case .apiError(let message):
            return "Errore API: \(message)"
        case .invalidResponse:
            return "Risposta API non valida o formato JSON inatteso"
        case .jsonParsingError(let details):
            return "Errore parsing JSON: \(details)"
        case .conversionFailed(let reason):
            return "Conversione fallita: \(reason)"
        case .timeout:
            return "Timeout: la conversione ha impiegato troppo tempo"
        case .invalidURL:
            return "URL non valido"
        }
    }
}
