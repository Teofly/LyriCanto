//
//  LyriCantoApp.swift
//  LyriCanto
//
//  Main app entry point with AppState management
//  Version 1.2.0 - Fixed window management to prevent crashes
//

import SwiftUI

@main
struct LyriCantoApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var colorManager = ColorSchemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ThemedAppView()
                .environmentObject(appState)
                .environmentObject(colorManager)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appInfo) {
                Button("About LyriCanto") {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center
                    
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            .applicationName: "LyriCanto",
                            .applicationVersion: "1.2.0",
                            .version: "1.2.0",
                            .credits: NSAttributedString(
                                string: "© Teofly 2025 - All Rights Reserved\n\nProfessional music lyrics transcription and translation tool",
                                attributes: [
                                    .font: NSFont.systemFont(ofSize: 11),
                                    .foregroundColor: NSColor.secondaryLabelColor,
                                    .paragraphStyle: paragraphStyle
                                ]
                            )
                        ]
                    )
                }
            }
            
            // Menu Window - Schema Colori
            CommandGroup(after: .windowArrangement) {
                Button("Schema Colori") {
                    // Usa NotificationCenter per aprire la finestra in modo sicuro
                    NotificationCenter.default.post(name: .openColorScheme, object: nil)
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }
            
            CommandGroup(replacing: .help) {
                Button("Guida LyriCanto") {
                    // Usa NotificationCenter per aprire la finestra in modo sicuro
                    NotificationCenter.default.post(name: .openUserGuide, object: nil)
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
        
        // Additional Windows - Gestite da SwiftUI (non manualmente!)
        WindowGroup("Schema Colori", id: "colorScheme") {
            ColorSchemeSettingsView()
                .environmentObject(colorManager)
                .frame(width: 400, height: 500)
        }
        .defaultSize(width: 400, height: 500)
        
        WindowGroup("Guida LyriCanto", id: "userGuide") {
            UserGuideView()
                .frame(width: 900, height: 700)
        }
        .defaultSize(width: 900, height: 700)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let openColorScheme = Notification.Name("openColorScheme")
    static let openUserGuide = Notification.Name("openUserGuide")
}

// MARK: - Themed App View (Applica i colori)
struct ThemedAppView: View {
    @EnvironmentObject var colorManager: ColorSchemeManager
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        MainAppView()
            .background(colorManager.currentScheme.background.color)
            .foregroundColor(colorManager.currentScheme.text.color)
            .tint(colorManager.currentScheme.accent.color)
            .onReceive(NotificationCenter.default.publisher(for: .openColorScheme)) { _ in
                openWindow(id: "colorScheme")
            }
            .onReceive(NotificationCenter.default.publisher(for: .openUserGuide)) { _ in
                openWindow(id: "userGuide")
            }
    }
}

// MARK: - App State (COMPLETO - con AI Rime Extensions)
class AppState: ObservableObject {
    @Published var claudeApiKey: String = ""
    @Published var openaiApiKey: String = ""
    @Published var lastProjectPath: String?
    
    // AI Rime: Provider preference
    @Published var currentProvider: AIProvider = .claude
    
    private let providerPreferenceKey = "preferredAIProvider"
    
    init() {
        loadAPIKeys()
        loadProviderPreference()
    }
    
    // MARK: - Load API Keys
    func loadAPIKeys() {
        claudeApiKey = KeychainHelper.load(key: "claudeAPIKey") ?? ""
        openaiApiKey = KeychainHelper.load(key: "openaiAPIKey") ?? ""
    }
    
    // MARK: - Save API Keys
    func saveClaudeAPIKey(_ apiKey: String) {
        claudeApiKey = apiKey
        if apiKey.isEmpty {
            KeychainHelper.delete(key: "claudeAPIKey")
        } else {
            KeychainHelper.save(key: "claudeAPIKey", value: apiKey)
        }
    }
    
    func saveOpenAIAPIKey(_ apiKey: String) {
        openaiApiKey = apiKey
        if apiKey.isEmpty {
            KeychainHelper.delete(key: "openaiAPIKey")
        } else {
            KeychainHelper.save(key: "openaiAPIKey", value: apiKey)
        }
    }
    
    // MARK: - Get API Key for Provider
    func getAPIKey(for provider: AIProvider) -> String? {
        switch provider {
        case .claude:
            let key = KeychainHelper.load(key: "claudeAPIKey")
            return key?.isEmpty == false ? key : nil
        case .openai:
            let key = KeychainHelper.load(key: "openaiAPIKey")
            return key?.isEmpty == false ? key : nil
        }
    }
    
    // MARK: - Provider Preference
    func saveProviderPreference() {
        UserDefaults.standard.set(currentProvider.rawValue, forKey: providerPreferenceKey)
    }
    
    private func loadProviderPreference() {
        if let savedProvider = UserDefaults.standard.string(forKey: providerPreferenceKey),
           let provider = AIProvider(rawValue: savedProvider) {
            currentProvider = provider
        }
    }
}
