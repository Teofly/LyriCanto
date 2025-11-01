//
//  AudioTrimmerView.swift
//  LyriCanto
//
//  Audio trimmer UI with waveform and handles
//

import SwiftUI

struct AudioTrimmerView: View {
    @ObservedObject var trimmer: AudioTrimmer
    @ObservedObject var player: AudioPlayerController
    var bpm: Int?
    var songTitle: String?
    @State private var previewLooping = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("✂️ Trim Audio")
                .font(.headline)
            
            // Waveform with trim handles
            waveformWithHandles
            
            // Time display
            timeRangeDisplay
            
            // Trim sliders
            trimSliders
            
            // Export info (BPM, duration, title)
            exportInfo
            
            // Controls
            controls
            
            if !trimmer.trimProgress.isEmpty {
                Text(trimmer.trimProgress)
                    .font(.caption)
                    .foregroundColor(trimmer.isTrimming ? .orange : .green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.windowBackgroundColor))
        )
        .disabled(trimmer.duration == 0)
    }
    
    // MARK: - Waveform with Handles
    private var waveformWithHandles: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Full waveform (dimmed)
                HStack(spacing: 1) {
                    ForEach(player.waveformSamples.indices, id: \.self) { index in
                        let sample = player.waveformSamples[index]
                        let height = CGFloat(sample) * geometry.size.height
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: max(1, geometry.size.width / CGFloat(player.waveformSamples.count) - 1))
                            .frame(height: height)
                            .frame(maxHeight: geometry.size.height, alignment: .center)
                    }
                }
                
                // Selected region overlay
                let startX = CGFloat(trimmer.startTime / trimmer.duration) * geometry.size.width
                let endX = CGFloat(trimmer.endTime / trimmer.duration) * geometry.size.width
                let regionWidth = endX - startX
                
                Rectangle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: regionWidth)
                    .offset(x: startX)
                
                // Start handle
                VStack {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 4)
                    
                    Text("▶")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
                .offset(x: startX - 2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newTime = (value.location.x / geometry.size.width) * trimmer.duration
                            trimmer.setStartTime(newTime)
                        }
                )
                
                // End handle
                VStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 4)
                    
                    Text("◀")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                .offset(x: endX - 2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newTime = (value.location.x / geometry.size.width) * trimmer.duration
                            trimmer.setEndTime(newTime)
                        }
                )
            }
        }
        .frame(height: 100)
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Time Range Display
    private var timeRangeDisplay: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Inizio")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatTime(trimmer.startTime))
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Durata")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatTime(trimmer.trimmedDuration))
                    .font(.system(.body, design: .monospaced))
                    .bold()
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Fine")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatTime(trimmer.endTime))
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Trim Sliders
    private var trimSliders: some View {
        VStack(spacing: 8) {
            // Start slider
            HStack {
                Text("▶ Inizio")
                    .font(.caption)
                    .foregroundColor(.green)
                    .frame(width: 60, alignment: .leading)
                
                Slider(
                    value: Binding(
                        get: { trimmer.startTime },
                        set: { trimmer.setStartTime($0) }
                    ),
                    in: 0...max(0, trimmer.endTime - 0.1)
                )
            }
            
            // End slider
            HStack {
                Text("◀ Fine")
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(width: 60, alignment: .leading)
                
                Slider(
                    value: Binding(
                        get: { trimmer.endTime },
                        set: { trimmer.setEndTime($0) }
                    ),
                    in: max(0, trimmer.startTime + 0.1)...trimmer.duration
                )
            }
        }
    }
    
    // MARK: - Export Info
    private var exportInfo: some View {
        HStack(spacing: 20) {
            // Duration
            VStack(alignment: .leading, spacing: 2) {
                Text("Durata")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatTime(trimmer.trimmedDuration))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
            }
            
            if let bpm = bpm, bpm > 0 {
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Velocità")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(bpm) BPM")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            if let title = songTitle, !title.isEmpty {
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Titolo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor))
        )
    }
    
    // MARK: - Controls
    private var controls: some View {
        HStack(spacing: 12) {
            // Preview loop
            Button(action: {
                if previewLooping {
                    player.pause()
                    previewLooping = false
                } else {
                    player.seek(to: trimmer.startTime)
                    player.toggleLoop()
                    player.play()
                    previewLooping = true
                    
                    // Monitor and loop back to start
                    Task {
                        while previewLooping {
                            if player.currentTime >= trimmer.endTime {
                                player.seek(to: trimmer.startTime)
                            }
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
                        }
                        player.toggleLoop()
                    }
                }
            }) {
                Label(previewLooping ? "Stop Preview" : "🔁 Preview Loop", systemImage: previewLooping ? "stop.circle" : "arrow.triangle.2.circlepath")
            }
            .buttonStyle(.bordered)
            
            // Reset
            Button(action: {
                trimmer.resetTrim()
            }) {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            // Save trimmed
            Button(action: {
                saveTrimmedAudio()
            }) {
                Label("💾 Salva Trimmed", systemImage: "scissors")
            }
            .buttonStyle(.borderedProminent)
            .disabled(trimmer.isTrimming)
        }
    }
    
    // MARK: - Save Trimmed
    private func saveTrimmedAudio() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.audio]
        
        // Nome file suggerito con titolo se disponibile
        if let title = songTitle, !title.isEmpty {
            savePanel.nameFieldStringValue = "\(title)_trimmed.m4a"
        } else {
            savePanel.nameFieldStringValue = "trimmed_audio.m4a"
        }
        
        savePanel.canCreateDirectories = true
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                Task {
                    do {
                        try await trimmer.exportTrimmedAudio(
                            outputURL: url,
                            bpm: bpm,
                            songTitle: songTitle
                        )
                    } catch {
                        print("Export error: \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let millis = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", minutes, seconds, millis)
    }
}
