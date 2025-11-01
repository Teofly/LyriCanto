//
//  GoogleMusicSearch.swift
//  LyriCanto
//
//  Google search integration for music information
//

import Foundation
import AppKit

// MARK: - Music Search Result
struct MusicSearchResult {
    let title: String
    let artist: String
    let album: String?
    let year: String?
    let genre: String?
    
    // Musical info
    let bpm: Int?
    let key: String?
    let duration: String?
    
    // Links
    let youtubeURL: String?
    let spotifyURL: String?
    let appleMusicURL: String?
    let lyricsURL: String?
    let wikipediaURL: String?
    
    // Lyrics preview
    let lyricsPreview: String?
    let hasFullLyrics: Bool
    
    // Additional info
    let coverImageURL: String?
    let popularity: Int?
}

// MARK: - Google Music Search
class GoogleMusicSearch: ObservableObject {
    
    @Published var searchResults: [MusicSearchResult] = []
    @Published var isSearching: Bool = false
    @Published var searchProgress: String = ""
    @Published var errorMessage: String?
    
    // MARK: - Search
    func search(query: String) async {
        await MainActor.run {
            isSearching = true
            searchProgress = "Ricerca in corso..."
            errorMessage = nil
            searchResults = []
        }
        
        do {
            // Multiple searches for comprehensive data
            async let basicInfo = searchBasicInfo(query: query)
            async let musicalInfo = searchMusicalInfo(query: query)
            async let links = searchLinks(query: query)
            async let lyrics = searchLyrics(query: query)
            
            let (basic, musical, linkResults, lyricsResult) = try await (basicInfo, musicalInfo, links, lyrics)
            
            // Combine results
            let result = MusicSearchResult(
                title: basic.title,
                artist: basic.artist,
                album: basic.album,
                year: basic.year,
                genre: basic.genre,
                bpm: musical.bpm,
                key: musical.key,
                duration: musical.duration,
                youtubeURL: linkResults.youtube,
                spotifyURL: linkResults.spotify,
                appleMusicURL: linkResults.appleMusic,
                lyricsURL: linkResults.lyrics,
                wikipediaURL: linkResults.wikipedia,
                lyricsPreview: lyricsResult.preview,
                hasFullLyrics: lyricsResult.hasFullLyrics,
                coverImageURL: basic.coverImage,
                popularity: musical.popularity
            )
            
            await MainActor.run {
                searchResults = [result]
                searchProgress = "✅ Ricerca completata!"
                isSearching = false
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Errore ricerca: \(error.localizedDescription)"
                searchProgress = ""
                isSearching = false
            }
        }
    }
    
    // MARK: - Search Basic Info
    private func searchBasicInfo(query: String) async throws -> (
        title: String,
        artist: String,
        album: String?,
        year: String?,
        genre: String?,
        coverImage: String?
    ) {
        // Use MusicBrainz API for structured music data
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://musicbrainz.org/ws/2/recording/?query=\(encodedQuery)&fmt=json&limit=1"
        
        guard let url = URL(string: urlString) else {
            throw SearchError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("LyriCanto/1.2.0 (contact@example.com)", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let recordings = json?["recordings"] as? [[String: Any]],
              let first = recordings.first else {
            throw SearchError.noResults
        }
        
        let title = first["title"] as? String ?? query
        let artistCredit = first["artist-credit"] as? [[String: Any]]
        let artist = artistCredit?.first?["name"] as? String ?? "Unknown"
        
        // Get release info
        let releases = first["releases"] as? [[String: Any]]
        let album = releases?.first?["title"] as? String
        let date = releases?.first?["date"] as? String
        let year = date?.prefix(4).description
        
        return (
            title: title,
            artist: artist,
            album: album,
            year: year,
            genre: nil, // Would need additional API call
            coverImage: nil // Would need Cover Art Archive API
        )
    }
    
    // MARK: - Search Musical Info
    private func searchMusicalInfo(query: String) async throws -> (
        bpm: Int?,
        key: String?,
        duration: String?,
        popularity: Int?
    ) {
        // Use GetSongBPM API or similar
        // Note: This would require an API key
        // For now, return nil values (user can analyze locally)
        _ = query // Silence unused parameter warning
        return (bpm: nil, key: nil, duration: nil, popularity: nil)
    }
    
    // MARK: - Search Links
    private func searchLinks(query: String) async throws -> (
        youtube: String?,
        spotify: String?,
        appleMusic: String?,
        lyrics: String?,
        wikipedia: String?
    ) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Generate search URLs (user can click to open)
        let youtube = "https://www.youtube.com/results?search_query=\(encodedQuery)"
        let spotify = "https://open.spotify.com/search/\(encodedQuery)"
        let appleMusic = "https://music.apple.com/search?term=\(encodedQuery)"
        let lyrics = "https://genius.com/search?q=\(encodedQuery)"
        let wikipedia = "https://en.wikipedia.org/w/index.php?search=\(encodedQuery)"
        
        return (
            youtube: youtube,
            spotify: spotify,
            appleMusic: appleMusic,
            lyrics: lyrics,
            wikipedia: wikipedia
        )
    }
    
    // MARK: - Search Lyrics
    private func searchLyrics(query: String) async throws -> (
        preview: String?,
        hasFullLyrics: Bool
    ) {
        // Search for lyrics using Google search
        let searchQuery = "\(query) lyrics"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Use Google Custom Search (or web scraping approach)
        // Note: This is a simplified implementation that searches lyrics sites
        let lyricsURLs = [
            "https://www.google.com/search?q=\(encodedQuery)+site:genius.com",
            "https://www.google.com/search?q=\(encodedQuery)+site:azlyrics.com",
            "https://www.google.com/search?q=\(encodedQuery)+site:lyrics.com"
        ]
        
        // Try to fetch lyrics from popular lyrics sites
        for _ in lyricsURLs {
            if let lyrics = try? await fetchLyricsFromSearch(query: searchQuery) {
                return (preview: lyrics, hasFullLyrics: true)
            }
        }
        
        // Fallback: return search instruction
        let fallbackPreview = "Nessun testo trovato. Cerca manualmente su Google: \(searchQuery)"
        return (preview: fallbackPreview, hasFullLyrics: false)
    }
    
    // MARK: - Fetch Lyrics from Search
    private func fetchLyricsFromSearch(query: String) async throws -> String? {
        // Search for lyrics on Genius (public data)
        let searchQuery = "\(query) site:genius.com"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        _ = "https://www.google.com/search?q=\(encodedQuery)" // Google search URL (for reference)
        
        // Note: This is a simplified approach
        // In production, you would use Google Custom Search API or a lyrics API
        
        // Try common lyrics sites with direct search
        let geniusSearchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let geniusSearchURL = "https://genius.com/api/search/multi?q=\(geniusSearchQuery)"
        
        guard let url = URL(string: geniusSearchURL) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            // Parse Genius search results
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let response = json["response"] as? [String: Any],
               let sections = response["sections"] as? [[String: Any]] {
                
                // Find the hits section
                for section in sections {
                    if let hits = section["hits"] as? [[String: Any]],
                       let firstHit = hits.first,
                       let result = firstHit["result"] as? [String: Any] {
                        
                        // Get song title and artist
                        let title = result["title"] as? String ?? ""
                        let artist = (result["primary_artist"] as? [String: Any])?["name"] as? String ?? ""
                        
                        // Return preview info (Genius doesn't provide full lyrics in API)
                        let preview = """
                        🎵 Trovato su Genius:
                        Titolo: \(title)
                        Artista: \(artist)
                        
                        Per i testi completi, clicca sul link 'Testi' qui sotto.
                        """
                        
                        return preview
                    }
                }
            }
        } catch {
            // If Genius fails, return nil to try other sources
            return nil
        }
        
        return nil
    }
    
    // MARK: - Open URL
    func openURL(_ urlString: String?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return
        }
        
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}

// MARK: - Search Error
enum SearchError: LocalizedError {
    case invalidURL
    case noResults
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL non valido"
        case .noResults:
            return "Nessun risultato trovato"
        case .apiError(let message):
            return "Errore API: \(message)"
        }
    }
}
