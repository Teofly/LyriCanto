//
//  AudioConverterView.swift
//  LyriCanto
//
//  UI for audio file conversion
//

import SwiftUI
import AppKit

struct AudioConverterView: View {
    @StateObject private var converter = AudioConverter()
    @State private var selectedFile: URL?
    @State private var targetFormat: AudioFormat = .mp3
    @State private var showingFilePicker = false
    @State private var showingSettings = false
    @State private var showingResult = false
    
    // Conversion options - solo bitrate supportato
    @State private var bitrate: Int = 192
    @State private var useCustomBitrate: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                headerSection
                
                // API Key Section (se non configurata)
                if converter.apiKey.isEmpty {
                    apiKeyWarning
                }
                
                // File Selection
                fileSelectionSection
                
                // Format & Options
                if selectedFile != nil {
                    formatSelectionSection
                    optionsSection
                }
                
                // Convert Button
                if selectedFile != nil && !converter.apiKey.isEmpty {
                    convertButton
                }
                
                // Progress
                if converter.isConverting {
                    progressSection
                }
                
                // Result
                if let outputURL = converter.outputURL {
                    resultSection(outputURL: outputURL)
                }
                
                // Error
                if let error = converter.lastError {
                    errorSection(error: error)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(minWidth: 600, minHeight: 500)
        .sheet(isPresented: $showingSettings) {
            settingsSheet
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Convertitore Audio")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Converti file audio in vari formati")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
            }
            
            Divider()
        }
    }
    
    // MARK: - API Key Warning
    private var apiKeyWarning: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key Richiesta")
                    .font(.headline)
                
                Text("Configura la tua API key di api2convert.com nelle impostazioni")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Configura") {
                showingSettings = true
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - File Selection
    private var fileSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("File da Convertire")
                .font(.headline)
            
            if let file = selectedFile {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(file.lastPathComponent)
                            .font(.body)
                        
                        if let size = try? FileManager.default.attributesOfItem(atPath: file.path)[.size] as? Int64 {
                            Text(formatFileSize(size))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Cambia") {
                        selectFile()
                    }
                    .buttonStyle(.borderless)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            } else {
                Button(action: selectFile) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Seleziona File Audio")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    // MARK: - Format Selection
    private var formatSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Formato di Output")
                .font(.headline)
            
            Picker("Formato", selection: $targetFormat) {
                ForEach(AudioFormat.allCases) { format in
                    Text(format.displayName).tag(format)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Options (Semplificato)
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Opzioni")
                    .font(.headline)
                
                Spacer()
                
                Toggle("Personalizza Bitrate", isOn: $useCustomBitrate)
                    .toggleStyle(.switch)
            }
            
            if useCustomBitrate {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Bitrate Audio")
                        Spacer()
                        Text("\(bitrate) kbps")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(bitrate) },
                        set: { bitrate = Int($0) }
                    ), in: 64...320, step: 32)
                    
                    Text("Nota: Lascia disattivato per usare la qualità automatica")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Usa qualità automatica ottimale per il formato selezionato")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Convert Button
    private var convertButton: some View {
        Button(action: startConversion) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Avvia Conversione")
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(converter.isConverting)
    }
    
    // MARK: - Progress
    private var progressSection: some View {
        VStack(spacing: 12) {
            ProgressView(value: converter.conversionProgress) {
                HStack {
                    Text(converter.conversionStatus)
                    Spacer()
                    Text("\(Int(converter.conversionProgress * 100))%")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
            
            if converter.conversionProgress > 0 && converter.conversionProgress < 1 {
                Text("Questo potrebbe richiedere alcuni minuti...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Result
    private func resultSection(outputURL: URL) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Conversione Completata!")
                    .font(.headline)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(outputURL.lastPathComponent)
                        .font(.body)
                    
                    Text(outputURL.deletingLastPathComponent().path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Apri") {
                    NSWorkspace.shared.open(outputURL)
                }
                
                Button("Mostra nel Finder") {
                    NSWorkspace.shared.selectFile(outputURL.path, inFileViewerRootedAtPath: "")
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Error
    private func errorSection(error: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.title2)
            
            Text(error)
                .font(.body)
            
            Spacer()
            
            Button("Riprova") {
                converter.lastError = nil
                startConversion()
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Settings Sheet
    private var settingsSheet: some View {
        VStack(spacing: 20) {
            Text("Impostazioni Convertitore")
                .font(.title2)
                .fontWeight(.bold)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("API Key api2convert.com")
                    .font(.headline)
                
                Text("Ottieni la tua API key gratuita su api2convert.com")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                SecureField("Inserisci API Key", text: $converter.apiKey)
                    .textFieldStyle(.roundedBorder)
                
                Link("Ottieni API Key →", destination: URL(string: "https://www.api2convert.com/")!)
                    .font(.caption)
            }
            
            Spacer()
            
            Button("Chiudi") {
                showingSettings = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(width: 400, height: 300)
    }
    
    // MARK: - Actions
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.audio, .mpeg4Audio, .wav, .aiff, .mp3]
        panel.title = "Seleziona File Audio"
        
        if panel.runModal() == .OK {
            selectedFile = panel.url
        }
    }
    
    private func startConversion() {
        guard let file = selectedFile else { return }
        
        // Usa opzioni solo se l'utente ha personalizzato il bitrate
        let options = useCustomBitrate ? ConversionOptions(audioBitrate: bitrate) : ConversionOptions()
        
        Task {
            do {
                _ = try await converter.convertAudio(
                    inputURL: file,
                    targetFormat: targetFormat,
                    options: options
                )
            } catch {
                // L'errore è già gestito nel converter
            }
        }
    }
    
    // MARK: - Helpers
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct AudioConverterView_Previews: PreviewProvider {
    static var previews: some View {
        AudioConverterView()
    }
}
