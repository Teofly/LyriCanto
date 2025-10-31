//
//  KeychainHelper.swift
//  LyriCanto
//
//  Secure storage for API keys
//

import Foundation
import Security

struct KeychainHelper {
    static func save(key: String, value: String) {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete old value if exists
        SecItemDelete(query as CFDictionary)
        
        // Add new value
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

//
//  SettingsView.swift
//  LyriCanto
//
//  Settings interface
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var claudeApiKeyInput: String = ""
    @State private var openaiApiKeyInput: String = ""
    @State private var showingClaudeSuccess = false
    @State private var showingOpenAISuccess = false
    
    var body: some View {
        Form {
            Section {
                Text("Configurazione API Claude (Anthropic)")
                    .font(.headline)
                
                SecureField("Claude API Key", text: $claudeApiKeyInput)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Button("Salva Claude Key") {
                        appState.saveClaudeAPIKey(claudeApiKeyInput)
                        showingClaudeSuccess = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showingClaudeSuccess = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if showingClaudeSuccess {
                        Text("✓ Salvata!")
                            .foregroundColor(.green)
                    }
                }
                
                Text("Ottieni la tua API key da: https://console.anthropic.com")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Text("Configurazione API OpenAI (ChatGPT)")
                    .font(.headline)
                
                SecureField("OpenAI API Key", text: $openaiApiKeyInput)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Button("Salva OpenAI Key") {
                        appState.saveOpenAIAPIKey(openaiApiKeyInput)
                        showingOpenAISuccess = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showingOpenAISuccess = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if showingOpenAISuccess {
                        Text("✓ Salvata!")
                            .foregroundColor(.green)
                    }
                }
                
                Text("Ottieni la tua API key da: https://platform.openai.com/api-keys")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("La stessa chiave OpenAI viene usata per:")
                    .font(.caption)
                    .bold()
                VStack(alignment: .leading, spacing: 4) {
                    Text("• ChatGPT (GPT-4) - Generazione testi")
                    Text("• Whisper - Trascrizione audio (~$0.006/minuto)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Section {
                Text("Informazioni")
                    .font(.headline)
                
                HStack {
                    Text("Versione:")
                    Spacer()
                    Text("1.5.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Modelli AI:")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Claude Sonnet 4.5")
                            .foregroundColor(.secondary)
                        Text("GPT-4 Turbo")
                            .foregroundColor(.secondary)
                        Text("Whisper (trascrizione)")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
            }
            
            Section {
                Text("Note Legali")
                    .font(.headline)
                
                Text("LyriCanto è uno strumento per la riscrittura creativa di testi. L'utente è responsabile di verificare di avere tutti i diritti necessari sui contenuti utilizzati. LyriCanto non fornisce strumenti per scaricare contenuti protetti da copyright.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 500)
        .onAppear {
            claudeApiKeyInput = appState.claudeApiKey
            openaiApiKeyInput = appState.openaiApiKey
        }
    }
}

//
//  StyleGuidelinesView.swift
//  LyriCanto
//
//  Modal for style customization
//

struct StyleGuidelinesView: View {
    @ObservedObject var viewModel: LyriCantoViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Linee Guida di Stile")
                .font(.title)
                .bold()
            
            Form {
                Section("Lessico") {
                    TextField("Es. informale, tecnico, poetico...", text: $viewModel.styleGuidelines.lexicon)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("Specifica il tipo di vocabolario da usare")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Registro") {
                    Picker("Registro linguistico", selection: $viewModel.styleGuidelines.register) {
                        Text("Formale").tag("formal")
                        Text("Neutrale").tag("neutral")
                        Text("Informale").tag("informal")
                        Text("Colloquiale").tag("colloquial")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Tono") {
                    Toggle("Umoristico/Giocoso", isOn: $viewModel.styleGuidelines.humor)
                        .toggleStyle(.switch)
                }
                
                Section("Note Aggiuntive") {
                    TextEditor(text: $viewModel.styleGuidelines.additionalNotes)
                        .frame(minHeight: 100)
                        .border(Color.gray.opacity(0.3))
                    
                    Text("Qualsiasi altro dettaglio stilistico o vincolo creativo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Annulla") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Applica") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
        .padding()
    }
}
