//
//  AudioAnalyzer.swift
//  LyriCanto
//
//  Advanced audio analysis for BPM, key, and chord detection
//

import Foundation
import AVFoundation
import Accelerate

// MARK: - Audio Analysis Result
struct AudioAnalysisResult {
    let bpm: Double
    let confidence: Double
    let key: MusicalKey
    let scale: ScaleType
    let suggestedChords: [Chord]
}

enum ScaleType: String {
    case major = "Maggiore"
    case minor = "Minore"
    case unknown = "Sconosciuta"
}

struct MusicalKey {
    let note: String // C, C#, D, D#, E, F, F#, G, G#, A, A#, B
    let flatEquivalent: String? // Db, Eb, Gb, Ab, Bb
    
    var displayName: String {
        // Preferisci i bemolli per tonalità comuni
        if let flat = flatEquivalent, ["Db", "Eb", "Gb", "Ab", "Bb"].contains(flat) {
            return flat
        }
        return note
    }
}

struct Chord {
    let root: String
    let quality: ChordQuality
    
    var displayName: String {
        return "\(root)\(quality.symbol)"
    }
}

enum ChordQuality: String {
    case major = ""
    case minor = "m"
    case diminished = "dim"
    case augmented = "aug"
    case dominant7 = "7"
    case major7 = "maj7"
    case minor7 = "m7"
    
    var symbol: String { rawValue }
}

// MARK: - Audio Analyzer
class AudioAnalyzer {
    
    // Note frequencies (A4 = 440 Hz standard)
    private let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let flatNames = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
    
    // MARK: - Main Analysis Function
    func analyze(audioURL: URL) async throws -> AudioAnalysisResult {
        // Load audio file
        let audioFile = try AVAudioFile(forReading: audioURL)
        let format = audioFile.processingFormat
        let frameCount = UInt32(audioFile.length)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw AudioAnalysisError.bufferCreationFailed
        }
        
        try audioFile.read(into: buffer)
        
        // Analyze BPM
        let (bpm, confidence) = try await detectBPM(buffer: buffer, sampleRate: format.sampleRate)
        
        // Analyze Key and Scale
        let (key, scale) = try await detectKeyAndScale(buffer: buffer, sampleRate: format.sampleRate)
        
        // Suggest chords based on key and scale
        let chords = suggestChords(key: key, scale: scale)
        
        return AudioAnalysisResult(
            bpm: bpm,
            confidence: confidence,
            key: key,
            scale: scale,
            suggestedChords: chords
        )
    }
    
    // MARK: - BPM Detection
    private func detectBPM(buffer: AVAudioPCMBuffer, sampleRate: Double) async throws -> (bpm: Double, confidence: Double) {
        guard let channelData = buffer.floatChannelData else {
            throw AudioAnalysisError.invalidAudioData
        }
        
        let frameLength = Int(buffer.frameLength)
        let audioData = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
        
        // Calculate energy envelope for onset detection
        let windowSize = 2048
        let hopSize = 512
        var energyEnvelope: [Float] = []
        
        for i in stride(from: 0, to: frameLength - windowSize, by: hopSize) {
            let window = Array(audioData[i..<min(i + windowSize, frameLength)])
            let energy = window.map { $0 * $0 }.reduce(0, +) / Float(window.count)
            energyEnvelope.append(sqrt(energy))
        }
        
        // Detect onsets (peaks in energy)
        let onsets = detectOnsets(energyEnvelope: energyEnvelope)
        
        // Calculate inter-onset intervals
        var intervals: [Double] = []
        for i in 1..<onsets.count {
            let interval = Double(onsets[i] - onsets[i-1]) * Double(hopSize) / sampleRate
            intervals.append(interval)
        }
        
        guard !intervals.isEmpty else {
            return (120.0, 0.3) // Default fallback
        }
        
        // Find most common interval (autocorrelation)
        let bpmEstimates = intervals.map { 60.0 / $0 }
        let bpm = medianBPM(from: bpmEstimates)
        
        // Calculate confidence based on consistency
        let deviation = standardDeviation(bpmEstimates)
        let confidence = max(0.0, min(1.0, 1.0 - (deviation / bpm)))
        
        return (bpm, confidence)
    }
    
    private func detectOnsets(energyEnvelope: [Float]) -> [Int] {
        var onsets: [Int] = []
        let threshold: Float = 0.3
        
        // Calculate spectral flux
        var flux: [Float] = [0]
        for i in 1..<energyEnvelope.count {
            let diff = max(0, energyEnvelope[i] - energyEnvelope[i-1])
            flux.append(diff)
        }
        
        // Find peaks above threshold
        let meanFlux = flux.reduce(0, +) / Float(flux.count)
        let adaptiveThreshold = meanFlux * threshold
        
        for i in 1..<(flux.count - 1) {
            if flux[i] > adaptiveThreshold &&
               flux[i] > flux[i-1] &&
               flux[i] > flux[i+1] {
                onsets.append(i)
            }
        }
        
        return onsets
    }
    
    private func medianBPM(from estimates: [Double]) -> Double {
        // Filter outliers (BPM typically 60-180)
        let filtered = estimates.filter { $0 >= 60 && $0 <= 180 }
        guard !filtered.isEmpty else {
            return estimates.reduce(0, +) / Double(estimates.count)
        }
        
        let sorted = filtered.sorted()
        let count = sorted.count
        
        if count % 2 == 0 {
            return (sorted[count/2 - 1] + sorted[count/2]) / 2.0
        } else {
            return sorted[count/2]
        }
    }
    
    private func standardDeviation(_ values: [Double]) -> Double {
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }
    
    // MARK: - Key and Scale Detection
    private func detectKeyAndScale(buffer: AVAudioPCMBuffer, sampleRate: Double) async throws -> (MusicalKey, ScaleType) {
        guard let channelData = buffer.floatChannelData else {
            throw AudioAnalysisError.invalidAudioData
        }
        
        let frameLength = Int(buffer.frameLength)
        let audioData = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
        
        // Use Chromagram (Pitch Class Profile) for key detection
        let chromagram = calculateChromagram(audioData: audioData, sampleRate: sampleRate)
        
        // Normalize chromagram
        let totalEnergy = chromagram.reduce(0, +)
        let normalizedChroma = chromagram.map { $0 / totalEnergy }
        
        // Compare with major and minor key profiles
        let (bestKey, bestScale) = findBestKeyMatch(chromagram: normalizedChroma)
        
        return (bestKey, bestScale)
    }
    
    private func calculateChromagram(audioData: [Float], sampleRate: Double) -> [Float] {
        let fftSize = 4096
        var chromagram = [Float](repeating: 0, count: 12)
        
        // Process audio in chunks
        for i in stride(from: 0, to: audioData.count - fftSize, by: fftSize / 2) {
            let chunk = Array(audioData[i..<min(i + fftSize, audioData.count)])
            
            // Apply Hann window
            let windowed = applyHannWindow(chunk)
            
            // Perform FFT
            let fftResult = performFFT(windowed)
            
            // Map frequencies to pitch classes
            for (bin, magnitude) in fftResult.enumerated() {
                let frequency = Double(bin) * sampleRate / Double(fftSize)
                if frequency > 20 && frequency < 5000 {
                    let pitchClass = frequencyToPitchClass(frequency)
                    chromagram[pitchClass] += magnitude
                }
            }
        }
        
        return chromagram
    }
    
    private func applyHannWindow(_ signal: [Float]) -> [Float] {
        let n = signal.count
        return signal.enumerated().map { (i, sample) in
            let window = 0.5 * (1 - cos(2 * .pi * Float(i) / Float(n - 1)))
            return sample * window
        }
    }
    
    private func performFFT(_ input: [Float]) -> [Float] {
        let log2n = vDSP_Length(log2(Float(input.count)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            return []
        }
        defer { vDSP_destroy_fftsetup(fftSetup) }
        
        var realp = [Float](repeating: 0, count: input.count / 2)
        var imagp = [Float](repeating: 0, count: input.count / 2)
        var magnitudes = [Float](repeating: 0, count: input.count / 2)
        
        // Use withUnsafeMutableBufferPointer for proper memory management
        realp.withUnsafeMutableBufferPointer { realPtr in
            imagp.withUnsafeMutableBufferPointer { imagPtr in
                var output = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                
                // Convert input to split complex format
                input.withUnsafeBytes { inputBytes in
                    let inputFloats = inputBytes.bindMemory(to: Float.self)
                    inputFloats.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: input.count / 2) { complexPtr in
                        vDSP_ctoz(complexPtr, 2, &output, 1, vDSP_Length(input.count / 2))
                    }
                }
                
                // Perform FFT
                vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))
                
                // Calculate magnitudes directly into separate array
                magnitudes.withUnsafeMutableBufferPointer { magPtr in
                    vDSP_zvabs(&output, 1, magPtr.baseAddress!, 1, vDSP_Length(input.count / 2))
                }
            }
        }
        
        return magnitudes
    }
    
    private func frequencyToPitchClass(_ frequency: Double) -> Int {
        // A4 = 440 Hz is pitch class 9 (A)
        let semitonesFromA4 = 12 * log2(frequency / 440.0)
        let pitchClass = (Int(round(semitonesFromA4)) + 9) % 12
        return (pitchClass + 12) % 12 // Ensure positive
    }
    
    private func findBestKeyMatch(chromagram: [Float]) -> (MusicalKey, ScaleType) {
        // Krumhansl-Schmuckler key profiles
        let majorProfile: [Float] = [6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88]
        let minorProfile: [Float] = [6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17]
        
        var bestCorrelation: Float = -1
        var bestKey = 0
        var bestScale = ScaleType.major
        
        // Try all 12 major keys
        for key in 0..<12 {
            let rotatedProfile = rotateArray(majorProfile, by: key)
            let correlation = pearsonCorrelation(chromagram, rotatedProfile)
            if correlation > bestCorrelation {
                bestCorrelation = correlation
                bestKey = key
                bestScale = .major
            }
        }
        
        // Try all 12 minor keys
        for key in 0..<12 {
            let rotatedProfile = rotateArray(minorProfile, by: key)
            let correlation = pearsonCorrelation(chromagram, rotatedProfile)
            if correlation > bestCorrelation {
                bestCorrelation = correlation
                bestKey = key
                bestScale = .minor
            }
        }
        
        let noteName = noteNames[bestKey]
        let flatName = flatNames[bestKey]
        
        return (MusicalKey(note: noteName, flatEquivalent: flatName != noteName ? flatName : nil), bestScale)
    }
    
    private func rotateArray<T>(_ array: [T], by positions: Int) -> [T] {
        let count = array.count
        let normalizedPositions = ((positions % count) + count) % count
        return Array(array[normalizedPositions...] + array[..<normalizedPositions])
    }
    
    private func pearsonCorrelation(_ x: [Float], _ y: [Float]) -> Float {
        let n = Float(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)
        let sumY2 = y.map { $0 * $0 }.reduce(0, +)
        
        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))
        
        return denominator == 0 ? 0 : numerator / denominator
    }
    
    // MARK: - Chord Suggestion
    private func suggestChords(key: MusicalKey, scale: ScaleType) -> [Chord] {
        let rootIndex = noteNames.firstIndex(of: key.note) ?? 0
        
        switch scale {
        case .major:
            // I - IV - V - vi progression (most common in pop)
            return [
                Chord(root: noteNames[rootIndex], quality: .major),                    // I
                Chord(root: noteNames[(rootIndex + 5) % 12], quality: .major),         // IV
                Chord(root: noteNames[(rootIndex + 7) % 12], quality: .major),         // V
                Chord(root: noteNames[(rootIndex + 9) % 12], quality: .minor),         // vi
                Chord(root: noteNames[(rootIndex + 2) % 12], quality: .minor),         // ii
                Chord(root: noteNames[(rootIndex + 4) % 12], quality: .minor)          // iii
            ]
            
        case .minor:
            // i - iv - V - VI progression
            return [
                Chord(root: noteNames[rootIndex], quality: .minor),                    // i
                Chord(root: noteNames[(rootIndex + 5) % 12], quality: .minor),         // iv
                Chord(root: noteNames[(rootIndex + 7) % 12], quality: .major),         // V
                Chord(root: noteNames[(rootIndex + 8) % 12], quality: .major),         // VI
                Chord(root: noteNames[(rootIndex + 3) % 12], quality: .major),         // III
                Chord(root: noteNames[(rootIndex + 10) % 12], quality: .major)         // VII
            ]
            
        case .unknown:
            return []
        }
    }
}

// MARK: - Errors
enum AudioAnalysisError: LocalizedError {
    case bufferCreationFailed
    case invalidAudioData
    case analysisTimeout
    
    var errorDescription: String? {
        switch self {
        case .bufferCreationFailed:
            return "Impossibile creare buffer audio"
        case .invalidAudioData:
            return "Dati audio non validi"
        case .analysisTimeout:
            return "Timeout analisi audio"
        }
    }
}
