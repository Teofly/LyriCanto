//
//  MetricsValidator.swift
//  LyriCanto
//
//  Syllable counting and metrics validation
//

import Foundation

struct MetricsAnalysis {
    let syllableCounts: [Int]
    let totalLines: Int
    let averageSyllables: Double
    let rhymeScheme: String?
    let warnings: [String]
    
    func generateReport() -> String {
        var report = "=== ANALISI METRICA ===\n\n"
        report += "Righe totali: \(totalLines)\n"
        report += "Media sillabe per riga: \(String(format: "%.1f", averageSyllables))\n\n"
        
        report += "Dettaglio per riga:\n"
        for (index, count) in syllableCounts.enumerated() {
            report += "Riga \(index + 1): \(count) sillabe\n"
        }
        
        if let scheme = rhymeScheme {
            report += "\nSchema rime rilevato: \(scheme)\n"
        }
        
        if !warnings.isEmpty {
            report += "\n⚠️ AVVERTIMENTI:\n"
            for warning in warnings {
                report += "- \(warning)\n"
            }
        }
        
        return report
    }
}

class MetricsValidator {
    
    // MARK: - Main Analysis Function
    func analyzeText(
        _ text: String,
        language: String,
        sections: [LyricSection]
    ) -> MetricsAnalysis {
        let lines = text.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        let syllableCounts = lines.map { countSyllables($0, language: language) }
        let totalLines = lines.count
        let averageSyllables = Double(syllableCounts.reduce(0, +)) / Double(max(totalLines, 1))
        
        let rhymeScheme = detectRhymeScheme(lines: lines, language: language)
        let warnings = generateWarnings(syllableCounts: syllableCounts)
        
        return MetricsAnalysis(
            syllableCounts: syllableCounts,
            totalLines: totalLines,
            averageSyllables: averageSyllables,
            rhymeScheme: rhymeScheme,
            warnings: warnings
        )
    }
    
    // MARK: - Syllable Counting
    func countSyllables(_ text: String, language: String) -> Int {
        let cleaned = text.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .trimmingCharacters(in: .whitespaces)
        
        switch language {
        case "IT", "ES", "PT":
            return countSyllablesRomance(cleaned)
        case "EN":
            return countSyllablesEnglish(cleaned)
        case "FR":
            return countSyllablesFrench(cleaned)
        case "DE":
            return countSyllablesGerman(cleaned)
        default:
            return countSyllablesRomance(cleaned)
        }
    }
    
    private func countSyllablesRomance(_ text: String) -> Int {
        // Italiano, Spagnolo, Portoghese: conteggio basato su vocali
        let vowels = CharacterSet(charactersIn: "aeiouàèéìòùáéíóúâêîôûäëïöüãõ")
        var count = 0
        var previousWasVowel = false
        
        for char in text.lowercased() {
            let isVowel = String(char).rangeOfCharacter(from: vowels) != nil
            
            if isVowel && !previousWasVowel {
                count += 1
            }
            
            previousWasVowel = isVowel
        }
        
        // Regole di dittongo (semplificato)
        let diphthongs = ["ia", "ie", "io", "iu", "ua", "ue", "ui", "uo"]
        for diphthong in diphthongs {
            let occurrences = text.components(separatedBy: diphthong).count - 1
            count -= occurrences
        }
        
        return max(count, 1)
    }
    
    private func countSyllablesEnglish(_ text: String) -> Int {
        // Regole semplificate per l'inglese
        let vowels = CharacterSet(charactersIn: "aeiouy")
        var count = 0
        var previousWasVowel = false
        
        for char in text.lowercased() {
            let isVowel = String(char).rangeOfCharacter(from: vowels) != nil
            
            if isVowel && !previousWasVowel {
                count += 1
            }
            
            previousWasVowel = isVowel
        }
        
        // Regola "silent e" finale
        if text.hasSuffix("e") || text.hasSuffix("es") || text.hasSuffix("ed") {
            count = max(count - 1, 1)
        }
        
        return max(count, 1)
    }
    
    private func countSyllablesFrench(_ text: String) -> Int {
        // Francese: simile alle lingue romanze ma con regole specifiche
        let vowels = CharacterSet(charactersIn: "aeiouyàâäéèêëïîôùûü")
        var count = 0
        var previousWasVowel = false
        
        for char in text.lowercased() {
            let isVowel = String(char).rangeOfCharacter(from: vowels) != nil
            
            if isVowel && !previousWasVowel {
                count += 1
            }
            
            previousWasVowel = isVowel
        }
        
        return max(count, 1)
    }
    
    private func countSyllablesGerman(_ text: String) -> Int {
        // Tedesco: regole semplificate
        let vowels = CharacterSet(charactersIn: "aeiouäöü")
        var count = 0
        var previousWasVowel = false
        
        for char in text.lowercased() {
            let isVowel = String(char).rangeOfCharacter(from: vowels) != nil
            
            if isVowel && !previousWasVowel {
                count += 1
            }
            
            previousWasVowel = isVowel
        }
        
        return max(count, 1)
    }
    
    // MARK: - Rhyme Detection
    private func detectRhymeScheme(lines: [String], language: String) -> String? {
        guard lines.count >= 4 else { return nil }
        
        var scheme = ""
        var rhymeMap: [String: String] = [:]
        var currentLetter: Character = "A"
        
        for line in lines.prefix(8) {
            let ending = getLineEnding(line)
            
            if let existingLetter = rhymeMap[ending] {
                scheme += existingLetter
            } else {
                rhymeMap[ending] = String(currentLetter)
                scheme += String(currentLetter)
                currentLetter = Character(UnicodeScalar(currentLetter.unicodeScalars.first!.value + 1)!)
            }
        }
        
        return scheme.isEmpty ? nil : scheme
    }
    
    private func getLineEnding(_ line: String) -> String {
        let cleaned = line.lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .trimmingCharacters(in: .whitespaces)
        
        let words = cleaned.components(separatedBy: .whitespaces)
        guard let lastWord = words.last, lastWord.count >= 2 else { return "" }
        
        // Prendi le ultime 2-3 lettere come "firma" della rima
        let endIndex = lastWord.index(lastWord.endIndex, offsetBy: -min(3, lastWord.count))
        return String(lastWord[endIndex...])
    }
    
    // MARK: - Comparison
    func compareMetrics(original: MetricsAnalysis, generated: MetricsAnalysis) -> Double {
        guard original.syllableCounts.count == generated.syllableCounts.count else {
            return 0.0
        }
        
        var totalScore = 0.0
        
        for (origCount, genCount) in zip(original.syllableCounts, generated.syllableCounts) {
            let diff = abs(origCount - genCount)
            let lineScore = max(0.0, 1.0 - (Double(diff) / Double(max(origCount, 1))))
            totalScore += lineScore
        }
        
        return totalScore / Double(original.syllableCounts.count)
    }
    
    // MARK: - Warnings
    private func generateWarnings(syllableCounts: [Int]) -> [String] {
        var warnings: [String] = []
        
        if syllableCounts.isEmpty {
            warnings.append("Nessuna riga da analizzare")
            return warnings
        }
        
        let avg = Double(syllableCounts.reduce(0, +)) / Double(syllableCounts.count)
        let variance = syllableCounts.map { pow(Double($0) - avg, 2) }.reduce(0, +) / Double(syllableCounts.count)
        
        if variance > 10 {
            warnings.append("Alta varianza nel conteggio sillabe - potrebbe indicare metri irregolari")
        }
        
        for (index, count) in syllableCounts.enumerated() {
            if count > 15 {
                warnings.append("Riga \(index + 1) molto lunga (\(count) sillabe)")
            }
            if count < 3 {
                warnings.append("Riga \(index + 1) molto corta (\(count) sillabe)")
            }
        }
        
        return warnings
    }
    
    // MARK: - Token Estimation
    func estimateTokenCount(_ text: String) -> Int {
        // Stima approssimativa basata su caratteri e parole
        let charCount = text.count
        let wordCount = text.components(separatedBy: .whitespaces).count
        
        // ~1 token ogni 4 caratteri, o 0.75 token per parola
        return max(charCount / 4, Int(Double(wordCount) * 0.75))
    }
}

// MARK: - Phonetic Similarity Helper
struct PhoneticHelper {
    static func calculatePhoneticSimilarity(_ text1: String, _ text2: String) -> Double {
        // Implementazione semplificata: confronta le ultime lettere
        let ending1 = String(text1.suffix(3)).lowercased()
        let ending2 = String(text2.suffix(3)).lowercased()
        
        var matches = 0
        for (char1, char2) in zip(ending1, ending2) {
            if char1 == char2 {
                matches += 1
            }
        }
        
        return Double(matches) / 3.0
    }
    
    static func getPhoneticFeatures(_ text: String) -> [String] {
        // Identifica caratteristiche fonetiche principali
        var features: [String] = []
        
        let vowels = "aeiou"
        let consonants = "bcdfghlmnpqrstvz"
        
        for char in text.lowercased() {
            if vowels.contains(char) {
                features.append("V")
            } else if consonants.contains(char) {
                features.append("C")
            }
        }
        
        return features
    }
}
