//
//  Exporters.swift
//  LyriCanto
//
//  Export functionality for various formats
//

import Foundation

// MARK: - LRC Exporter
struct LRCMetadata {
    let title: String
    let artist: String
    let album: String
}

struct LRCExporter {
    static func export(
        lyrics: String,
        sections: [LyricSection],
        metadata: LRCMetadata
    ) -> String {
        var lrc = ""
        
        // Metadata
        if !metadata.title.isEmpty {
            lrc += "[ti:\(metadata.title)]\n"
        }
        if !metadata.artist.isEmpty {
            lrc += "[ar:\(metadata.artist)]\n"
        }
        if !metadata.album.isEmpty {
            lrc += "[al:\(metadata.album)]\n"
        }
        lrc += "[by:LyriCanto]\n"
        lrc += "\n"
        
        // Lyrics with timestamps
        let lines = lyrics.components(separatedBy: .newlines)
        
        if sections.isEmpty {
            // Se non ci sono sezioni, usa timestamp approssimativi
            for (index, line) in lines.enumerated() {
                let timestamp = formatLRCTimestamp(seconds: Double(index) * 3.0)
                lrc += "[\(timestamp)]\(line)\n"
            }
        } else {
            // Usa i timestamp delle sezioni
            var lineIndex = 0
            
            for section in sections {
                let startSeconds = parseTimeString(section.startTime)
                let endSeconds = parseTimeString(section.endTime)
                let duration = endSeconds - startSeconds
                
                // Calcola quante righe appartengono a questa sezione (approssimazione)
                let sectionLines = max(1, Int(duration / 3.0))
                
                for i in 0..<sectionLines {
                    if lineIndex < lines.count {
                        let lineTime = startSeconds + (Double(i) * duration / Double(sectionLines))
                        let timestamp = formatLRCTimestamp(seconds: lineTime)
                        lrc += "[\(timestamp)]\(lines[lineIndex])\n"
                        lineIndex += 1
                    }
                }
            }
            
            // Aggiungi righe rimanenti
            while lineIndex < lines.count {
                let timestamp = formatLRCTimestamp(seconds: Double(lineIndex) * 3.0)
                lrc += "[\(timestamp)]\(lines[lineIndex])\n"
                lineIndex += 1
            }
        }
        
        return lrc
    }
    
    private static func formatLRCTimestamp(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let centiseconds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, secs, centiseconds)
    }
    
    private static func parseTimeString(_ timeString: String) -> Double {
        let components = timeString.components(separatedBy: ":")
        guard components.count == 2,
              let minutes = Double(components[0]),
              let seconds = Double(components[1]) else {
            return 0.0
        }
        return minutes * 60 + seconds
    }
}

// MARK: - SRT Exporter
struct SRTExporter {
    static func export(
        lyrics: String,
        sections: [LyricSection]
    ) -> String {
        var srt = ""
        let lines = lyrics.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        if sections.isEmpty {
            // Senza sezioni, usa timing approssimativo
            for (index, line) in lines.enumerated() {
                let startTime = Double(index) * 3.0
                let endTime = startTime + 3.0
                
                srt += "\(index + 1)\n"
                srt += "\(formatSRTTimestamp(startTime)) --> \(formatSRTTimestamp(endTime))\n"
                srt += "\(line)\n\n"
            }
        } else {
            // Con sezioni, distribuisci le righe
            var lineIndex = 0
            var subtitleIndex = 1
            
            for section in sections {
                let startSeconds = parseTimeString(section.startTime)
                let endSeconds = parseTimeString(section.endTime)
                let duration = endSeconds - startSeconds
                
                let sectionLines = max(1, Int(duration / 3.0))
                
                for i in 0..<sectionLines {
                    if lineIndex < lines.count {
                        let lineStartTime = startSeconds + (Double(i) * duration / Double(sectionLines))
                        let lineEndTime = lineStartTime + (duration / Double(sectionLines))
                        
                        srt += "\(subtitleIndex)\n"
                        srt += "\(formatSRTTimestamp(lineStartTime)) --> \(formatSRTTimestamp(lineEndTime))\n"
                        srt += "\(lines[lineIndex])\n\n"
                        
                        lineIndex += 1
                        subtitleIndex += 1
                    }
                }
            }
        }
        
        return srt
    }
    
    private static func formatSRTTimestamp(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        let millis = Int((seconds.truncatingRemainder(dividingBy: 1)) * 1000)
        return String(format: "%02d:%02d:%02d,%03d", hours, minutes, secs, millis)
    }
    
    private static func parseTimeString(_ timeString: String) -> Double {
        let components = timeString.components(separatedBy: ":")
        guard components.count == 2,
              let minutes = Double(components[0]),
              let seconds = Double(components[1]) else {
            return 0.0
        }
        return minutes * 60 + seconds
    }
}

// MARK: - JSON Exporter
struct JSONExporter {
    static func export(
        originalLyrics: String,
        generatedLyrics: String,
        sections: [LyricSection],
        compatibilityScore: Double?,
        metadata: ExportMetadata
    ) throws -> Data {
        let originalLines = originalLyrics.components(separatedBy: .newlines)
        let generatedLines = generatedLyrics.components(separatedBy: .newlines)
        
        // Crea struttura JSON
        var jsonDict: [String: Any] = [
            "metadata": [
                "title": metadata.title,
                "targetLanguage": metadata.targetLanguage,
                "topic": metadata.topic,
                "phoneticSimilarity": metadata.phoneticSimilarity,
                "preserveRhymeScheme": metadata.preserveRhymeScheme,
                "exportDate": ISO8601DateFormatter().string(from: Date())
            ],
            "original": [
                "text": originalLyrics,
                "lines": originalLines,
                "lineCount": originalLines.count
            ],
            "generated": [
                "text": generatedLyrics,
                "lines": generatedLines,
                "lineCount": generatedLines.count
            ],
            "sections": sections.map { section in
                [
                    "type": section.type.rawValue,
                    "startTime": section.startTime,
                    "endTime": section.endTime
                ]
            }
        ]
        
        if let score = compatibilityScore {
            jsonDict["analysis"] = [
                "compatibilityScore": score,
                "metricsMatch": score >= 0.85 ? "excellent" : (score >= 0.7 ? "good" : "needs_refinement")
            ]
        }
        
        // Aggiungi conteggio sillabe per linea
        let validator = MetricsValidator()
        let originalSyllables = originalLines.map { validator.countSyllables($0, language: "source") }
        let generatedSyllables = generatedLines.map { validator.countSyllables($0, language: metadata.targetLanguage) }
        
        jsonDict["syllables"] = [
            "original": originalSyllables,
            "generated": generatedSyllables
        ]
        
        return try JSONSerialization.data(
            withJSONObject: jsonDict,
            options: [.prettyPrinted, .sortedKeys]
        )
    }
}

// MARK: - TXT Advanced Exporter
struct TXTAdvancedExporter {
    static func export(
        originalTitle: String,
        userTitle: String,
        googleInfo: String,
        musicalKey: String,
        scale: String,
        suggestedChords: [String],
        bpm: Int,
        originalLyrics: String,
        generatedLyrics: String,
        metricsReport: String?
    ) -> String {
        var txt = ""
        
        // Header
        txt += "═══════════════════════════════════════════════════════════════════\n"
        txt += "                        LYRICANTO - REPORT                          \n"
        txt += "═══════════════════════════════════════════════════════════════════\n\n"
        
        // Informazioni Brano
        txt += "📋 INFORMAZIONI BRANO\n"
        txt += "─────────────────────────────────────────────────────────────────\n"
        txt += "Nome Originale: \(originalTitle.isEmpty ? "N/A" : originalTitle)\n"
        txt += "Nome Assegnato: \(userTitle.isEmpty ? "N/A" : userTitle)\n"
        txt += "\n"
        
        // Google Info
        if !googleInfo.isEmpty {
            txt += "🔍 INFORMAZIONI GOOGLE\n"
            txt += "─────────────────────────────────────────────────────────────────\n"
            txt += "\(googleInfo)\n\n"
        }
        
        // Analisi Musicale
        txt += "🎵 ANALISI MUSICALE\n"
        txt += "─────────────────────────────────────────────────────────────────\n"
        txt += "Tonalità: \(musicalKey.isEmpty ? "N/A" : musicalKey)\n"
        txt += "Scala: \(scale.isEmpty ? "N/A" : scale)\n"
        txt += "BPM (Velocità): \(bpm)\n"
        
        if !suggestedChords.isEmpty {
            txt += "Accordi Suggeriti: \(suggestedChords.joined(separator: ", "))\n"
        } else {
            txt += "Accordi Suggeriti: N/A\n"
        }
        txt += "\n"
        
        // Metrica
        if let metrics = metricsReport {
            txt += "📊 ANALISI METRICA\n"
            txt += "─────────────────────────────────────────────────────────────────\n"
            txt += "\(metrics)\n\n"
        }
        
        // Testo Originale
        txt += "📝 TESTO ORIGINALE\n"
        txt += "═════════════════════════════════════════════════════════════════\n"
        txt += "\(originalLyrics)\n"
        txt += "═════════════════════════════════════════════════════════════════\n\n"
        
        // Testo Proposto
        txt += "✨ TESTO PROPOSTO\n"
        txt += "═════════════════════════════════════════════════════════════════\n"
        txt += "\(generatedLyrics)\n"
        txt += "═════════════════════════════════════════════════════════════════\n\n"
        
        // Comparazione riga per riga
        txt += "🔄 COMPARAZIONE TESTI (Riga per Riga)\n"
        txt += "═════════════════════════════════════════════════════════════════\n"
        txt += "Riga | Originale                          | Proposta\n"
        txt += "─────────────────────────────────────────────────────────────────\n"
        
        let originalLines = originalLyrics.components(separatedBy: .newlines)
        let generatedLines = generatedLyrics.components(separatedBy: .newlines)
        let maxLines = max(originalLines.count, generatedLines.count)
        
        for i in 0..<maxLines {
            let origLine = i < originalLines.count ? originalLines[i] : ""
            let genLine = i < generatedLines.count ? generatedLines[i] : ""
            
            // Formatta le righe per allinearle (max 35 caratteri per colonna)
            let origFormatted = origLine.isEmpty ? "(vuota)" : origLine
            let genFormatted = genLine.isEmpty ? "(vuota)" : genLine
            
            // Tronca se troppo lungo
            let origTrunc = origFormatted.count > 35 ? String(origFormatted.prefix(32)) + "..." : origFormatted
            let genTrunc = genFormatted.count > 35 ? String(genFormatted.prefix(32)) + "..." : genFormatted
            
            // Padding per allineamento
            let origPadded = origTrunc.padding(toLength: 35, withPad: " ", startingAt: 0)
            
            txt += "\(String(format: "%3d", i + 1))  | \(origPadded) | \(genTrunc)\n"
        }
        
        txt += "═════════════════════════════════════════════════════════════════\n\n"
        
        // Copyright
        txt += "📄 COPYRIGHT\n"
        txt += "─────────────────────────────────────────────────────────────────\n"
        txt += "All Rights Reserved Teofly 2025-2030 matteo@arteni.it\n"
        txt += "─────────────────────────────────────────────────────────────────\n"
        txt += "Generato da LyriCanto v1.1.0 - Powered by AI\n"
        txt += "Data: \(formatDate(Date()))\n"
        txt += "═══════════════════════════════════════════════════════════════════\n"
        
        return txt
    }
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
}

// MARK: - Export Metadata
struct ExportMetadata {
    let title: String
    let targetLanguage: String
    let topic: String
    let phoneticSimilarity: Double
    let preserveRhymeScheme: Bool
}
