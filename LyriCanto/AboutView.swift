//
//  AboutView.swift
//  LyriCanto
//
//  About window with version and credits
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // App Icon
            if let image = NSImage(named: "AppIcon") {
                Image(nsImage: image)
                    .resizable()
                    .frame(width: 128, height: 128)
                    .cornerRadius(16)
                    .shadow(radius: 4)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
            }
            
            // App Name
            Text("LyriCanto")
                .font(.system(size: 32, weight: .bold))
            
            // Version
            Text("Versione 1.2.0")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.horizontal, 40)
            
            // Description
            Text("Crea testi musicali professionali\nin diverse lingue mantenendo\nmetrica, rime e struttura")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.horizontal, 40)
            
            // Features
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "🎧", text: "Audio Player & Trimmer")
                FeatureRow(icon: "🔍", text: "Ricerca Brani Google")
                FeatureRow(icon: "🎤", text: "Trascrizione Whisper AI")
                FeatureRow(icon: "🎵", text: "Analisi BPM & Tonalità")
                FeatureRow(icon: "🤖", text: "Generazione AI Testi")
                FeatureRow(icon: "💾", text: "Export Multi-Formato")
            }
            .padding(.horizontal, 40)
            
            Divider()
                .padding(.horizontal, 40)
            
            // Copyright
            VStack(spacing: 4) {
                Text("© Teofly 2025 - All Rights Reserved")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Professional music lyrics transcription and translation tool")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            
            // Close button
            Button("Chiudi") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding(.top, 8)
        }
        .frame(width: 400)
        .padding(30)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.body)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
#Preview {
    AboutView()
}
