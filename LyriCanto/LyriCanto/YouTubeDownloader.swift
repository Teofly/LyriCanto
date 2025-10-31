//
//  YouTubeDownloader.swift
//  LyriCanto
//
//  YouTube audio download service using yt-dlp (local tool)
//

import Foundation

// MARK: - YouTube Downloader Service
class YouTubeDownloader: ObservableObject {
    
    @Published var isSearching = false
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0.0
    @Published var downloadStatus = ""
    @Published var lastError: String?
    @Published var outputURL: URL?
    @Published var searchResults: [YouTubeVideo] = []
    
    // yt-dlp non richiede API key!
    @Published var ytDlpInstalled: Bool = false
    @Published var isCheckingInstallation: Bool = false
    
    // Store the actual path to yt-dlp
    private var ytDlpPath: String?
    
    init() {
        // NON chiamare checkYtDlpInstallation() qui!
        // Deve essere chiamato dalla view con .task {} per evitare di bloccare il rendering
    }
    
    // MARK: - Check yt-dlp Installation
    func checkYtDlpInstallation() async {
        await MainActor.run {
            isCheckingInstallation = true
        }
        
        // Controlla i path comuni (veloce e sicuro)
        let commonPaths = [
            "/usr/local/bin/yt-dlp",
            "/opt/homebrew/bin/yt-dlp",
            "/usr/bin/yt-dlp",
            "/opt/local/bin/yt-dlp"
        ]
        
        for path in commonPaths {
            if FileManager.default.isExecutableFile(atPath: path) {
                await MainActor.run {
                    self.ytDlpPath = path
                    self.ytDlpInstalled = true
                    self.isCheckingInstallation = false
                }
                return
            }
        }
        
        // Se non trovato nei path comuni, usa 'which' in background
        let result = await Task.detached { () -> (Bool, String?) in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = ["which", "yt-dlp"]
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = Pipe()
            
            do {
                try process.run()
                process.waitUntilExit()
                if process.terminationStatus == 0 {
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                    return (true, path)
                }
                return (false, nil)
            } catch {
                return (false, nil)
            }
        }.value
        
        await MainActor.run {
            self.ytDlpInstalled = result.0
            self.ytDlpPath = result.1
            self.isCheckingInstallation = false
        }
    }
    
    // MARK: - Search YouTube (using yt-dlp with JSON output)
    func searchYouTube(query: String) async throws -> [YouTubeVideo] {
        guard ytDlpInstalled, let ytDlpPath = ytDlpPath else {
            throw DownloadError.ytDlpNotInstalled
        }
        
        await MainActor.run {
            isSearching = true
            lastError = nil
            searchResults = []
        }
        
        do {
            // Usa yt-dlp con --dump-json per output strutturato
            let process = Process()
            process.executableURL = URL(fileURLWithPath: ytDlpPath)
            process.arguments = [
                "--dump-json",
                "--skip-download",
                "--no-playlist",
                "--flat-playlist",
                "ytsearch10:\(query)"  // Cerca 10 risultati
            ]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = Pipe()
            
            try process.run()
            process.waitUntilExit()
            
            guard process.terminationStatus == 0 else {
                throw DownloadError.downloadFailed("Ricerca fallita con status \(process.terminationStatus)")
            }
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            // Parse JSON output - ogni linea è un oggetto JSON separato
            let videos = parseYtDlpJsonOutput(output)
            
            await MainActor.run {
                self.searchResults = videos
                self.isSearching = false
            }
            
            return videos
            
        } catch {
            await MainActor.run {
                self.lastError = error.localizedDescription
                self.isSearching = false
            }
            throw error
        }
    }
    
    // MARK: - Download Audio (using yt-dlp)
    func downloadAudio(videoId: String, title: String? = nil, format: AudioDownloadFormat) async throws -> URL {
        guard ytDlpInstalled, let ytDlpPath = ytDlpPath else {
            throw DownloadError.ytDlpNotInstalled
        }
        
        await MainActor.run {
            isDownloading = true
            downloadProgress = 0.0
            downloadStatus = "Preparazione download..."
            lastError = nil
            outputURL = nil
        }
        
        do {
            await updateStatus("Download in corso...")
            
            // Valida e pulisci il videoId
            let cleanedVideoId: String
            if videoId.starts(with: "http://") || videoId.starts(with: "https://") {
                // Se è già un URL completo, usalo direttamente
                cleanedVideoId = videoId
            } else if videoId.contains("/") || videoId.contains("&") || videoId.contains("%") || videoId.contains(" ") {
                // Se contiene caratteri strani, potrebbe essere un URL malformato o titolo
                throw DownloadError.invalidURL
            } else {
                // È un video ID valido (alfanumerico, underscore, trattino)
                cleanedVideoId = videoId
            }
            
            let videoURL = cleanedVideoId.starts(with: "http") ? cleanedVideoId : "https://www.youtube.com/watch?v=\(cleanedVideoId)"
            let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            let timestamp = Int(Date().timeIntervalSince1970)
            
            // Usa il titolo se fornito, altrimenti usa il videoId
            let baseFilename: String
            if let title = title {
                // Sanitizza il titolo per renderlo un nome file valido
                let sanitized = sanitizeFilename(title)
                baseFilename = sanitized.isEmpty ? "youtube_\(timestamp)" : sanitized
            } else {
                baseFilename = "youtube_\(timestamp)"
            }
            
            let filename = baseFilename
            let outputTemplate = downloadsDir.appendingPathComponent(filename).path
            
            // Configura formato audio
            let formatArg: String
            switch format {
            case .mp3:
                formatArg = "mp3"
            case .wav:
                formatArg = "wav"
            case .m4a:
                formatArg = "m4a"
            }
            
            let process = Process()
            process.executableURL = URL(fileURLWithPath: ytDlpPath)
            process.arguments = [
                "-x",                         // estrai solo l'audio
                "--audio-format", formatArg,  // mp3 | wav | m4a
                "--audio-quality", "0",       // migliore qualità
                "-o", "\(outputTemplate).%(ext)s",  // template con estensione automatica
                "--no-playlist",
                videoURL
            ]
            
            // Monitor progress and errors
            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe
            
            // Read stdout in background to update progress
            stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if let output = String(data: data, encoding: .utf8) {
                    // Parse progress from yt-dlp output
                    if let progress = self.parseProgress(from: output) {
                        Task { @MainActor in
                            self.downloadProgress = progress
                        }
                    }
                }
            }
            
            try process.run()
            
            // Update progress while running
            var currentProgress = 0.0
            while process.isRunning {
                try await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds
                currentProgress = min(currentProgress + 0.05, 0.9)
                await updateProgress(currentProgress)
            }
            
            process.waitUntilExit()
            
            // Clear handlers
            stdoutPipe.fileHandleForReading.readabilityHandler = nil
            
            // Read all stderr output after process ends
            let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: stderrData, encoding: .utf8) ?? ""
            
            guard process.terminationStatus == 0 else {
                let errorMsg = errorOutput.isEmpty ? "yt-dlp failed with status \(process.terminationStatus)" : errorOutput
                throw DownloadError.downloadFailed(errorMsg)
            }
            
            // Find downloaded file
            // Cerca il file con l'estensione corretta
            let expectedURL = downloadsDir.appendingPathComponent("\(filename).\(format.fileExtension)")
            
            // Se non trovato con l'estensione esatta, cerca tutti i file che iniziano con filename
            var finalURL = expectedURL
            if !FileManager.default.fileExists(atPath: expectedURL.path) {
                do {
                    let files = try FileManager.default.contentsOfDirectory(at: downloadsDir, includingPropertiesForKeys: nil)
                    if let found = files.first(where: { $0.lastPathComponent.hasPrefix(filename) }) {
                        finalURL = found
                    } else {
                        throw DownloadError.downloadFailed("File non trovato dopo il download. Cercato: \(filename)")
                    }
                } catch {
                    throw DownloadError.downloadFailed("Errore nella ricerca del file: \(error.localizedDescription)")
                }
            }
            
            await updateStatus("✅ Download completato!")
            await updateProgress(1.0)
            
            let downloadedURL = finalURL  // Copia locale per evitare warning Swift 6
            await MainActor.run {
                self.outputURL = downloadedURL
                self.isDownloading = false
            }
            
            return finalURL
            
        } catch {
            await MainActor.run {
                self.lastError = error.localizedDescription
                self.downloadStatus = "❌ Errore: \(error.localizedDescription)"
                self.isDownloading = false
            }
            throw error
        }
    }
    
    // MARK: - Parse yt-dlp JSON Output
    private func parseYtDlpJsonOutput(_ output: String) -> [YouTubeVideo] {
        var videos: [YouTubeVideo] = []
        
        // Ogni linea è un oggetto JSON separato
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        for line in lines {
            guard let jsonData = line.data(using: .utf8) else { continue }
            
            do {
                let decoder = JSONDecoder()
                let videoInfo = try decoder.decode(YtDlpVideoInfo.self, from: jsonData)
                
                let video = YouTubeVideo(
                    id: videoInfo.id,
                    title: videoInfo.title,
                    thumbnail: videoInfo.thumbnail,
                    duration: formatDuration(videoInfo.duration),
                    channel: videoInfo.channel ?? videoInfo.uploader ?? "YouTube"
                )
                
                videos.append(video)
            } catch {
                print("Errore parsing JSON video: \(error)")
                continue
            }
        }
        
        return videos
    }
    
    // MARK: - Format Duration
    private func formatDuration(_ seconds: Int?) -> String? {
        guard let seconds = seconds else { return nil }
        
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    // MARK: - Parse Progress
    private func parseProgress(from output: String) -> Double? {
        // Look for patterns like "[download] 45.2% of ~3.5MiB at 1.2MiB/s ETA 00:02"
        if let range = output.range(of: #"\[download\]\s+(\d+\.?\d*)%"#, options: .regularExpression) {
            let percentString = output[range].components(separatedBy: " ")[1].replacingOccurrences(of: "%", with: "")
            if let percent = Double(percentString) {
                return percent / 100.0
            }
        }
        return nil
    }
    
    // MARK: - Install yt-dlp
    func installYtDlp() async throws {
        await MainActor.run {
            downloadStatus = "Installazione yt-dlp in corso..."
        }
        
        // Use Homebrew to install yt-dlp
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["brew", "install", "yt-dlp"]
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw DownloadError.installationFailed
        }
        
        await MainActor.run {
            ytDlpInstalled = true
            downloadStatus = "✅ yt-dlp installato con successo!"
        }
    }
    
    // MARK: - Helper Methods
    @MainActor
    private func updateStatus(_ status: String) {
        self.downloadStatus = status
    }
    
    @MainActor
    private func updateProgress(_ progress: Double) {
        self.downloadProgress = progress
    }
    
    // MARK: - Sanitize Filename
    private func sanitizeFilename(_ filename: String) -> String {
        // Caratteri non validi per i nomi file
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        
        // Rimuovi caratteri invalidi e sostituisci con underscore
        var sanitized = filename.components(separatedBy: invalidCharacters).joined(separator: "_")
        
        // Rimuovi spazi multipli e trailing/leading spaces
        sanitized = sanitized.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Sostituisci spazi con underscore (opzionale, puoi rimuovere questa riga se preferisci mantenere gli spazi)
        sanitized = sanitized.replacingOccurrences(of: " ", with: "_")
        
        // Limita lunghezza a 100 caratteri
        if sanitized.count > 100 {
            sanitized = String(sanitized.prefix(100))
        }
        
        return sanitized
    }
}

// MARK: - yt-dlp JSON Response Model
private struct YtDlpVideoInfo: Decodable {
    let id: String
    let title: String
    let thumbnail: String?
    let duration: Int?
    let channel: String?
    let uploader: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case thumbnail
        case duration
        case channel
        case uploader
    }
}

// MARK: - YouTube Video Model
struct YouTubeVideo: Identifiable, Hashable {
    let id: String
    let title: String
    let thumbnail: String?
    let duration: String?
    let channel: String
}

// MARK: - Download Formats
enum AudioDownloadFormat: String, CaseIterable, Identifiable {
    case mp3 = "mp3"
    case wav = "wav"
    case m4a = "m4a"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .mp3: return "MP3"
        case .wav: return "WAV"
        case .m4a: return "M4A"
        }
    }
    
    var fileExtension: String {
        rawValue
    }
}

// MARK: - Errors
enum DownloadError: LocalizedError {
    case ytDlpNotInstalled
    case networkError
    case apiError(String)
    case invalidResponse
    case downloadFailed(String)
    case invalidURL
    case installationFailed
    
    var errorDescription: String? {
        switch self {
        case .ytDlpNotInstalled:
            return "yt-dlp non è installato. Installalo con: brew install yt-dlp"
        case .networkError:
            return "Errore di rete"
        case .apiError(let message):
            return "Errore API: \(message)"
        case .invalidResponse:
            return "Risposta non valida"
        case .downloadFailed(let reason):
            return "Download fallito: \(reason)"
        case .invalidURL:
            return "Video ID non valido. Deve essere un ID YouTube valido (es: M_nXXsyj_w0), non un URL o titolo"
        case .installationFailed:
            return "Installazione yt-dlp fallita"
        }
    }
}
