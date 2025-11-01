//
//  AudioPlayerView.swift
//  LyriCanto
//
//  Complete audio player UI with waveform
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var player: AudioPlayerController
    @EnvironmentObject var colorScheme: ColorSchemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Waveform with playhead
            waveformView
            
            // Time display
            timeDisplay
            
            // Seek bar
            seekBar
            
            // Controls
            controls
            
            // Advanced controls
            advancedControls
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme.currentScheme.secondaryBackground.color)
        )
    }
    
    // MARK: - Waveform
    private var waveformView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Waveform bars
                HStack(spacing: 1) {
                    ForEach(player.waveformSamples.indices, id: \.self) { index in
                        let sample = player.waveformSamples[index]
                        let height = CGFloat(sample) * geometry.size.height
                        
                        Rectangle()
                            .fill(colorScheme.currentScheme.accent.color.opacity(0.7))
                            .frame(width: max(1, geometry.size.width / CGFloat(player.waveformSamples.count) - 1))
                            .frame(height: height)
                            .frame(maxHeight: geometry.size.height, alignment: .center)
                    }
                }
                
                // Playhead
                if player.duration > 0 {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2)
                        .offset(x: CGFloat(player.currentTime / player.duration) * geometry.size.width)
                }
            }
        }
        .frame(height: 80)
        .background(colorScheme.currentScheme.background.color.opacity(0.5))
        .cornerRadius(8)
    }
    
    // MARK: - Time Display
    private var timeDisplay: some View {
        HStack {
            Text(formatTime(player.currentTime))
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(formatTime(player.duration))
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Seek Bar
    private var seekBar: some View {
        Slider(
            value: Binding(
                get: { player.currentTime },
                set: { player.seek(to: $0) }
            ),
            in: 0...max(0.1, player.duration)
        )
        .disabled(player.duration == 0)
    }
    
    // MARK: - Controls
    private var controls: some View {
        HStack(spacing: 20) {
            // Previous/Skip back
            Button(action: {
                player.seek(to: max(0, player.currentTime - 10))
            }) {
                Image(systemName: "gobackward.10")
                    .font(.title2)
            }
            .buttonStyle(.borderless)
            .disabled(player.duration == 0)
            
            Spacer()
            
            // Play/Pause
            Button(action: {
                if player.isPlaying {
                    player.pause()
                } else {
                    player.play()
                }
            }) {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.borderless)
            .disabled(player.duration == 0)
            
            Spacer()
            
            // Next/Skip forward
            Button(action: {
                player.seek(to: min(player.duration, player.currentTime + 10))
            }) {
                Image(systemName: "goforward.10")
                    .font(.title2)
            }
            .buttonStyle(.borderless)
            .disabled(player.duration == 0)
            
            // Stop
            Button(action: {
                player.stop()
            }) {
                Image(systemName: "stop.circle")
                    .font(.title2)
            }
            .buttonStyle(.borderless)
            .disabled(player.duration == 0)
        }
    }
    
    // MARK: - Advanced Controls
    private var advancedControls: some View {
        HStack(spacing: 16) {
            // Loop toggle
            Button(action: {
                player.toggleLoop()
            }) {
                Image(systemName: player.isLooping ? "repeat.circle.fill" : "repeat.circle")
                    .font(.title3)
                    .foregroundColor(player.isLooping ? .blue : .secondary)
            }
            .buttonStyle(.borderless)
            .help("Loop")
            
            // Speed control
            HStack(spacing: 4) {
                Image(systemName: "gauge")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: Binding(
                        get: { Double(player.playbackSpeed) },
                        set: { player.setSpeed(Float($0)) }
                    ),
                    in: 0.5...2.0,
                    step: 0.1
                )
                .frame(width: 100)
                
                Text(String(format: "%.1fx", player.playbackSpeed))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 40)
            }
            
            Spacer()
            
            // Volume control
            HStack(spacing: 4) {
                Image(systemName: "speaker.wave.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: Binding(
                        get: { Double(player.volume) },
                        set: { player.setVolume(Float($0)) }
                    ),
                    in: 0...1.0
                )
                .frame(width: 100)
                
                Text("\(Int(player.volume * 100))%")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 35)
            }
        }
    }
    
    // MARK: - Helpers
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
