//
//  MusicSearchView.swift
//  LyriCanto
//
//  Google music search UI
//

import SwiftUI

struct MusicSearchView: View {
    @ObservedObject var search: GoogleMusicSearch
    @State private var searchQuery: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("🔍 Ricerca Brano")
                .font(.headline)
            
            // Search bar
            HStack {
                TextField("Es: Artist - Song Title", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        performSearch()
                    }
                
                Button(action: {
                    performSearch()
                }) {
                    Label("Cerca", systemImage: "magnifyingglass")
                }
                .buttonStyle(.borderedProminent)
                .disabled(searchQuery.isEmpty || search.isSearching)
            }
            
            if search.isSearching {
                ProgressView(search.searchProgress)
                    .padding()
            }
            
            if let error = search.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // Results
            if !search.searchResults.isEmpty {
                ScrollView {
                    ForEach(search.searchResults.indices, id: \.self) { index in
                        resultCard(search.searchResults[index])
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.windowBackgroundColor))
        )
    }
    
    // MARK: - Result Card
    private func resultCard(_ result: MusicSearchResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Basic info
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.title3)
                    .bold()
                
                Text(result.artist)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let album = result.album {
                    HStack {
                        Image(systemName: "music.note.list")
                            .font(.caption)
                        Text(album)
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }
                
                if let year = result.year {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(year)
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Musical info
            if result.bpm != nil || result.key != nil || result.duration != nil {
                VStack(alignment: .leading, spacing: 6) {
                    Text("📊 Info Musicali")
                        .font(.subheadline)
                        .bold()
                    
                    HStack(spacing: 16) {
                        if let bpm = result.bpm {
                            VStack(alignment: .leading) {
                                Text("BPM")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(bpm)")
                                    .font(.body)
                                    .bold()
                            }
                        }
                        
                        if let key = result.key {
                            VStack(alignment: .leading) {
                                Text("Tonalità")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(key)
                                    .font(.body)
                                    .bold()
                            }
                        }
                        
                        if let duration = result.duration {
                            VStack(alignment: .leading) {
                                Text("Durata")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(duration)
                                    .font(.body)
                                    .bold()
                            }
                        }
                    }
                }
                
                Divider()
            }
            
            // Links
            VStack(alignment: .leading, spacing: 8) {
                Text("🔗 Link Utili")
                    .font(.subheadline)
                    .bold()
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                    if let youtube = result.youtubeURL {
                        linkButton("YouTube", icon: "play.rectangle.fill", url: youtube, color: .red)
                    }
                    
                    if let spotify = result.spotifyURL {
                        linkButton("Spotify", icon: "music.note", url: spotify, color: .green)
                    }
                    
                    if let appleMusic = result.appleMusicURL {
                        linkButton("Apple Music", icon: "music.note.list", url: appleMusic, color: .pink)
                    }
                    
                    if let lyrics = result.lyricsURL {
                        linkButton("Testi", icon: "doc.text", url: lyrics, color: .orange)
                    }
                    
                    if let wikipedia = result.wikipediaURL {
                        linkButton("Wikipedia", icon: "book", url: wikipedia, color: .blue)
                    }
                }
            }
            
            // Lyrics preview
            if let preview = result.lyricsPreview {
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("📝 Testi")
                        .font(.subheadline)
                        .bold()
                    
                    Text(preview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor))
        )
    }
    
    // MARK: - Link Button
    private func linkButton(_ title: String, icon: String, url: String, color: Color) -> some View {
        Button(action: {
            search.openURL(url)
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(color.opacity(0.1))
            .cornerRadius(6)
        }
        .buttonStyle(.borderless)
        .foregroundColor(color)
    }
    
    // MARK: - Search
    private func performSearch() {
        guard !searchQuery.isEmpty else { return }
        Task {
            await search.search(query: searchQuery)
        }
    }
}
