//
//  AudioPlayerController.swift
//  LyriCanto
//
//  Advanced audio player with waveform visualization
//

import Foundation
import AVFoundation
import Accelerate

// MARK: - Audio Player Controller
class AudioPlayerController: NSObject, ObservableObject {
    
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackSpeed: Float = 1.0
    @Published var isLooping: Bool = false
    @Published var waveformSamples: [Float] = []
    @Published var volume: Float = 1.0
    
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CVDisplayLink?
    private var updateTimer: Timer?
    
    // MARK: - Load Audio
    func loadAudio(url: URL) async throws {
        let player = try AVAudioPlayer(contentsOf: url)
        player.delegate = self
        player.prepareToPlay()
        player.enableRate = true
        player.volume = volume
        
        await MainActor.run {
            self.audioPlayer = player
            self.duration = player.duration
            self.currentTime = 0
        }
        
        // Generate waveform
        let samples = try await generateWaveform(url: url)
        await MainActor.run {
            self.waveformSamples = samples
        }
    }
    
    // MARK: - Playback Controls
    func play() {
        guard let player = audioPlayer else { return }
        player.rate = playbackSpeed
        player.play()
        isPlaying = true
        startTimeUpdates()
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimeUpdates()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
        stopTimeUpdates()
    }
    
    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = max(0, min(time, duration))
        currentTime = player.currentTime
    }
    
    func setSpeed(_ speed: Float) {
        playbackSpeed = max(0.5, min(2.0, speed))
        if isPlaying, let player = audioPlayer {
            player.rate = playbackSpeed
        }
    }
    
    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1.0, newVolume))
        audioPlayer?.volume = volume
    }
    
    func toggleLoop() {
        isLooping.toggle()
        audioPlayer?.numberOfLoops = isLooping ? -1 : 0
    }
    
    // MARK: - Time Updates
    private func startTimeUpdates() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }
    
    private func stopTimeUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - Waveform Generation
    private func generateWaveform(url: URL) async throws -> [Float] {
        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        let frameCount = UInt32(file.length)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw AudioError.bufferCreationFailed
        }
        
        try file.read(into: buffer)
        
        guard let channelData = buffer.floatChannelData?[0] else {
            throw AudioError.invalidAudioData
        }
        
        let samples = Array(UnsafeBufferPointer(start: channelData, count: Int(frameCount)))
        
        // Downsample to ~500 points for visualization
        let targetSamples = 500
        let samplesPerPoint = max(1, samples.count / targetSamples)
        
        var waveform: [Float] = []
        for i in stride(from: 0, to: samples.count, by: samplesPerPoint) {
            let end = min(i + samplesPerPoint, samples.count)
            let chunk = samples[i..<end]
            
            // RMS (Root Mean Square) for better visualization
            let rms = sqrt(chunk.map { $0 * $0 }.reduce(0, +) / Float(chunk.count))
            waveform.append(rms)
        }
        
        // Normalize
        if let maxValue = waveform.max(), maxValue > 0 {
            waveform = waveform.map { $0 / maxValue }
        }
        
        return waveform
    }
    
    deinit {
        stopTimeUpdates()
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayerController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !isLooping {
            isPlaying = false
            currentTime = 0
            stopTimeUpdates()
        }
    }
}

// MARK: - Errors
enum AudioError: LocalizedError {
    case bufferCreationFailed
    case invalidAudioData
    
    var errorDescription: String? {
        switch self {
        case .bufferCreationFailed:
            return "Impossibile creare buffer audio"
        case .invalidAudioData:
            return "Dati audio non validi"
        }
    }
}
