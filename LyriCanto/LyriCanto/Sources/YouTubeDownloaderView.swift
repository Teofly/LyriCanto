//
//  YouTubeDownloaderView.swift
//  LyriCanto
//
//  UI for downloading audio from YouTube using yt-dlp
//

import SwiftUI
import AppKit

struct YouTubeDownloaderView: View {
    @StateObject private var downloader = YouTubeDownloader()
    @State private var searchQuery: String = ""
    @State private var selectedVideo: YouTubeVideo?
    @State private var targetFormat: AudioDownloadFormat = .mp3
    @State private var showingInstallGuide = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                headerSection
                
                // yt-dlp Installation Warning (se non installato)
                if downloader.isCheckingInstallation {
                    checkingInstallationView
                } else if !downloader.ytDlpInstalled {
                    ytDlpWarning
                }
                
                // Search Section
                if downloader.ytDlpInstalled {
                    searchSection
                }
                
                // Search Results
                if !downloader.searchResults.isEmpty {
                    searchResultsSection
                }
                
                // Selected Video & Format
                if selectedVideo != nil {
                    selectedVideoSection
                    formatSelectionSection
                }
                
                // Download Button
                if selectedVideo != nil && downloader.ytDlpInstalled {
                    downloadButton
                }
                
                // Progress
                if downloader.isDownloading {
                    progressSection
                }
                
                // Result
                if let outputURL = downloader.outputURL {
                    resultSection(outputURL: outputURL)
                }
                
                // Error
                if let error = downloader.lastError {
                    errorSection(error: error)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(minWidth: 600, minHeight: 500)
        .sheet(isPresented: $showingInstallGuide) {
            installGuideSheet
        }
        .task {
            // Controlla l'installazione di yt-dlp quando la view appare
            // Questo viene eseguito in modo asincrono e non blocca il rendering
            await downloader.checkYtDlpInstallation()
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scarica Audio da YouTube")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Download gratuito e illimitato con yt-dlp")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if downloader.ytDlpInstalled {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            Divider()
        }
    }
    
    // MARK: - Checking Installation
    private var checkingInstallationView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
            
            Text("Controllo installazione yt-dlp...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - yt-dlp Warning
    private var ytDlpWarning: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("yt-dlp Non Installato")
                        .font(.headline)
                    
                    Text("yt-dlp è richiesto per scaricare audio da YouTube. È gratuito e open-source!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Installazione Rapida:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("1.")
                            .fontWeight(.bold)
                        Text("Apri Terminale")
                    }
                    .font(.caption)
                    
                    HStack {
                        Text("2.")
                            .fontWeight(.bold)
                        Text("Esegui:")
                            .font(.caption)
                        Text("brew install yt-dlp")
                            .font(.system(.caption, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    HStack {
                        Text("3.")
                            .fontWeight(.bold)
                        Text("Riavvia LyriCanto")
                    }
                    .font(.caption)
                }
                
                HStack {
                    Button("Mostra Guida Completa") {
                        showingInstallGuide = true
                    }
                    
                    Link("Sito yt-dlp →", destination: URL(string: "https://github.com/yt-dlp/yt-dlp")!)
                        .font(.caption)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cerca su YouTube")
                .font(.headline)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Inserisci titolo canzone, artista o URL YouTube...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        performSearch()
                    }
                
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Button(action: performSearch) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Cerca")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(searchQuery.isEmpty || downloader.isSearching)
            
            if downloader.isSearching {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Ricerca in corso...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Search Results
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risultati (\(downloader.searchResults.count))")
                .font(.headline)
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 12) {
                    ForEach(downloader.searchResults) { video in
                        VideoResultCard(
                            video: video,
                            isSelected: selectedVideo?.id == video.id,
                            onSelect: {
                                selectedVideo = video
                            }
                        )
                    }
                }
            }
            .frame(maxHeight: 400)
        }
    }
    
    // MARK: - Selected Video
    private var selectedVideoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Video Selezionato")
                .font(.headline)
            
            if let video = selectedVideo {
                HStack(spacing: 12) {
                    // Thumbnail
                    AsyncImage(url: URL(string: video.thumbnail ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "play.rectangle.fill")
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(width: 120, height: 67)
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(video.title)
                            .font(.body)
                            .lineLimit(2)
                        
                        HStack {
                            Text(video.channel)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let duration = video.duration {
                                Text("•")
                                    .foregroundColor(.secondary)
                                Text(duration)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button("Cambia") {
                        selectedVideo = nil
                    }
                    .buttonStyle(.borderless)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Format Selection
    private var formatSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formato Audio")
                .font(.headline)
            
            Picker("Formato", selection: $targetFormat) {
                ForEach(AudioDownloadFormat.allCases) { format in
                    Text(format.displayName).tag(format)
                }
            }
            .pickerStyle(.segmented)
            
            // Format info
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                Text(formatInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var formatInfo: String {
        switch targetFormat {
        case .mp3:
            return "Compresso, file piccoli, compatibile ovunque"
        case .wav:
            return "Non compresso, massima qualità, file grandi"
        case .m4a:
            return "Alta qualità, dimensioni medie, formato Apple"
        }
    }
    
    // MARK: - Download Button
    private var downloadButton: some View {
        Button(action: startDownload) {
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                Text("Scarica Audio")
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(downloader.isDownloading)
    }
    
    // MARK: - Progress
    private var progressSection: some View {
        VStack(spacing: 12) {
            ProgressView(value: downloader.downloadProgress) {
                HStack {
                    Text(downloader.downloadStatus)
                    Spacer()
                    Text("\(Int(downloader.downloadProgress * 100))%")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
            
            if downloader.downloadProgress > 0 && downloader.downloadProgress < 1 {
                Text("Download in corso...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Result
    private func resultSection(outputURL: URL) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Download Completato!")
                    .font(.headline)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(outputURL.lastPathComponent)
                        .font(.body)
                    
                    Text(outputURL.deletingLastPathComponent().path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Apri") {
                    NSWorkspace.shared.open(outputURL)
                }
                
                Button("Mostra nel Finder") {
                    NSWorkspace.shared.selectFile(outputURL.path, inFileViewerRootedAtPath: "")
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Error
    private func errorSection(error: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.title2)
            
            Text(error)
                .font(.body)
            
            Spacer()
            
            Button("Chiudi") {
                downloader.lastError = nil
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Install Guide Sheet
    private var installGuideSheet: some View {
        VStack(spacing: 20) {
            Text("Guida Installazione yt-dlp")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Cos'è yt-dlp?")
                            .font(.headline)
                        
                        Text("yt-dlp è un tool open-source gratuito per scaricare video e audio da YouTube e altri siti. È completamente legale e sicuro.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Installazione con Homebrew")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. Apri l'app Terminale (Command + Spazio, poi digita 'Terminale')")
                                .font(.caption)
                            
                            Text("2. Se non hai Homebrew, installalo prima:")
                                .font(.caption)
                            
                            Text("/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
                                .font(.system(.caption, design: .monospaced))
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                            
                            Text("3. Installa yt-dlp:")
                                .font(.caption)
                            
                            Text("brew install yt-dlp")
                                .font(.system(.caption, design: .monospaced))
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                            
                            Text("4. Verifica l'installazione:")
                                .font(.caption)
                            
                            Text("yt-dlp --version")
                                .font(.system(.caption, design: .monospaced))
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                            
                            Text("5. Riavvia LyriCanto")
                                .font(.caption)
                        }
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Perché yt-dlp?")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Completamente gratuito", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Label("Nessun limite di download", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Label("Nessuna API key richiesta", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Label("Massima qualità audio", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Label("Open-source e sicuro", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Link("Documentazione Homebrew", destination: URL(string: "https://brew.sh/")!)
                    .font(.caption)
                
                Spacer()
                
                Link("GitHub yt-dlp", destination: URL(string: "https://github.com/yt-dlp/yt-dlp")!)
                    .font(.caption)
            }
            
            Button("Chiudi") {
                showingInstallGuide = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(width: 500, height: 600)
    }
    
    // MARK: - Actions
    private func performSearch() {
        guard !searchQuery.isEmpty else { return }
        
        // Se è un URL YouTube, estrailo l'ID del video direttamente
        if searchQuery.contains("youtube.com") || searchQuery.contains("youtu.be") {
            // Estrai video ID dall'URL e crea un risultato diretto
            if let videoId = extractVideoId(from: searchQuery) {
                let video = YouTubeVideo(
                    id: videoId,
                    title: "Video da URL",
                    thumbnail: "https://img.youtube.com/vi/\(videoId)/mqdefault.jpg",
                    duration: nil,
                    channel: "YouTube"
                )
                downloader.searchResults = [video]
                selectedVideo = video
                return
            }
        }
        
        Task {
            do {
                _ = try await downloader.searchYouTube(query: searchQuery)
            } catch {
                // L'errore è già gestito nel downloader
            }
        }
    }
    
    private func startDownload() {
        guard let video = selectedVideo else { return }
        
        Task {
            do {
                _ = try await downloader.downloadAudio(videoId: video.id, format: targetFormat)
            } catch {
                // L'errore è già gestito nel downloader
            }
        }
    }
    
    private func extractVideoId(from url: String) -> String? {
        // Pattern per youtube.com/watch?v=VIDEO_ID
        if let range = url.range(of: "v=([a-zA-Z0-9_-]+)", options: .regularExpression) {
            let videoId = String(url[range]).replacingOccurrences(of: "v=", with: "")
            return videoId
        }
        
        // Pattern per youtu.be/VIDEO_ID
        if let range = url.range(of: "youtu.be/([a-zA-Z0-9_-]+)", options: .regularExpression) {
            let videoId = String(url[range]).replacingOccurrences(of: "youtu.be/", with: "")
            return videoId
        }
        
        return nil
    }
}

// MARK: - Video Result Card
struct VideoResultCard: View {
    let video: YouTubeVideo
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Thumbnail
                AsyncImage(url: URL(string: video.thumbnail ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                        )
                }
                .frame(width: 120, height: 67)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.body)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(video.channel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let duration = video.duration {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(duration)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct YouTubeDownloaderView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubeDownloaderView()
    }
}
