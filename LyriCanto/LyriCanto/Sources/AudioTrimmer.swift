//
//  AudioTrimmer.swift
//  LyriCanto
//
//  Audio trimming with waveform visualization
//

import Foundation
import AVFoundation

// MARK: - Audio Trimmer
class AudioTrimmer: ObservableObject {
    
    @Published var startTime: TimeInterval = 0
    @Published var endTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isTrimming: Bool = false
    @Published var trimProgress: String = ""
    
    private var audioURL: URL?
    
    // MARK: - Load Audio
    func loadAudio(url: URL) async throws {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        
        await MainActor.run {
            self.audioURL = url
            self.duration = duration.seconds
            self.startTime = 0
            self.endTime = duration.seconds
        }
    }
    
    // MARK: - Trim Controls
    func setStartTime(_ time: TimeInterval) {
        startTime = max(0, min(time, endTime - 0.1))
    }
    
    func setEndTime(_ time: TimeInterval) {
        endTime = max(startTime + 0.1, min(time, duration))
    }
    
    func resetTrim() {
        startTime = 0
        endTime = duration
    }
    
    var trimmedDuration: TimeInterval {
        return endTime - startTime
    }
    
    // MARK: - Export Trimmed Audio
    func exportTrimmedAudio(outputURL: URL, bpm: Int? = nil, songTitle: String? = nil) async throws {
        guard let sourceURL = audioURL else {
            throw TrimError.noAudioLoaded
        }
        
        await MainActor.run {
            isTrimming = true
            trimProgress = "Preparazione export..."
        }
        
        let asset = AVURLAsset(url: sourceURL)
        
        // Create export session
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            throw TrimError.exportSessionFailed
        }
        
        // Set time range
        let startTimeCM = CMTime(seconds: startTime, preferredTimescale: 600)
        let endTimeCM = CMTime(seconds: endTime, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startTimeCM, end: endTimeCM)
        
        exportSession.timeRange = timeRange
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        
        // Add metadata if BPM available
        if let bpm = bpm {
            exportSession.metadata = createBPMMetadata(bpm: bpm, title: songTitle)
        }
        
        await MainActor.run {
            trimProgress = "Export in corso..."
        }
        
        // Export
        await exportSession.export()
        
        let finalStatus = exportSession.status
        await MainActor.run {
            isTrimming = false
            
            switch finalStatus {
            case .completed:
                if let bpm = bpm {
                    trimProgress = "✅ Export completato! (BPM: \(bpm))"
                } else {
                    trimProgress = "✅ Export completato!"
                }
            case .failed:
                trimProgress = "❌ Export fallito"
            case .cancelled:
                trimProgress = "⚠️ Export cancellato"
            default:
                trimProgress = ""
            }
        }
        
        if finalStatus != .completed {
            throw TrimError.exportFailed(exportSession.error?.localizedDescription ?? "Unknown error")
        }
    }
    
    // MARK: - Create BPM Metadata
    private func createBPMMetadata(bpm: Int, title: String?) -> [AVMetadataItem] {
        var metadata: [AVMetadataItem] = []
        
        // iTunes BPM (standard format)
        let iTunesBPM = AVMutableMetadataItem()
        iTunesBPM.keySpace = .iTunes
        iTunesBPM.key = "tempo" as NSString
        iTunesBPM.value = bpm as NSNumber
        metadata.append(iTunesBPM)
        
        // Common description
        let descItem = AVMutableMetadataItem()
        descItem.identifier = .commonIdentifierDescription
        descItem.value = "BPM: \(bpm)" as NSString
        descItem.extendedLanguageTag = "und"
        metadata.append(descItem)
        
        // Title if provided
        if let title = title, !title.isEmpty {
            let titleItem = AVMutableMetadataItem()
            titleItem.identifier = .commonIdentifierTitle
            titleItem.value = title as NSString
            titleItem.extendedLanguageTag = "und"
            metadata.append(titleItem)
        }
        
        // Creator
        let creatorItem = AVMutableMetadataItem()
        creatorItem.identifier = .commonIdentifierCreator
        creatorItem.value = "LyriCanto - Trimmed Audio" as NSString
        creatorItem.extendedLanguageTag = "und"
        metadata.append(creatorItem)
        
        return metadata
    }
    
    // MARK: - Fade Effects (Optional)
    func exportWithFades(
        outputURL: URL,
        fadeInDuration: TimeInterval = 0,
        fadeOutDuration: TimeInterval = 0
    ) async throws {
        guard let sourceURL = audioURL else {
            throw TrimError.noAudioLoaded
        }
        
        let asset = AVURLAsset(url: sourceURL)
        let composition = AVMutableComposition()
        
        // Add audio track
        guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first,
              let compositionTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
              ) else {
            throw TrimError.trackCreationFailed
        }
        
        let startTimeCM = CMTime(seconds: startTime, preferredTimescale: 600)
        let endTimeCM = CMTime(seconds: endTime, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startTimeCM, end: endTimeCM)
        
        try compositionTrack.insertTimeRange(
            timeRange,
            of: audioTrack,
            at: .zero
        )
        
        // Add audio mix with fades
        let audioMix = AVMutableAudioMix()
        let audioMixParam = AVMutableAudioMixInputParameters(track: compositionTrack)
        
        if fadeInDuration > 0 {
            audioMixParam.setVolumeRamp(
                fromStartVolume: 0.0,
                toEndVolume: 1.0,
                timeRange: CMTimeRange(
                    start: .zero,
                    duration: CMTime(seconds: fadeInDuration, preferredTimescale: 600)
                )
            )
        }
        
        if fadeOutDuration > 0 {
            let fadeOutStart = CMTimeSubtract(
                compositionTrack.timeRange.duration,
                CMTime(seconds: fadeOutDuration, preferredTimescale: 600)
            )
            audioMixParam.setVolumeRamp(
                fromStartVolume: 1.0,
                toEndVolume: 0.0,
                timeRange: CMTimeRange(
                    start: fadeOutStart,
                    duration: CMTime(seconds: fadeOutDuration, preferredTimescale: 600)
                )
            )
        }
        
        audioMix.inputParameters = [audioMixParam]
        
        // Export with audio mix
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            throw TrimError.exportSessionFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        exportSession.audioMix = audioMix
        
        await MainActor.run {
            isTrimming = true
            trimProgress = "Export con fade in corso..."
        }
        
        await exportSession.export()
        
        let finalStatus = exportSession.status
        await MainActor.run {
            isTrimming = false
            trimProgress = finalStatus == .completed ? "✅ Completato!" : "❌ Fallito"
        }
        
        if finalStatus != .completed {
            throw TrimError.exportFailed(exportSession.error?.localizedDescription ?? "Unknown")
        }
    }
}

// MARK: - Errors
enum TrimError: LocalizedError {
    case noAudioLoaded
    case exportSessionFailed
    case trackCreationFailed
    case exportFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noAudioLoaded:
            return "Nessun audio caricato"
        case .exportSessionFailed:
            return "Impossibile creare sessione export"
        case .trackCreationFailed:
            return "Impossibile creare traccia audio"
        case .exportFailed(let reason):
            return "Export fallito: \(reason)"
        }
    }
}
