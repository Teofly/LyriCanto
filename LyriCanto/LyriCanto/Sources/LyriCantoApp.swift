//
//  LyriCantoApp.swift
//  LyriCanto
//
//  Created by LyriCanto Team
//  Copyright © 2025 LyriCanto. All rights reserved.
//

import SwiftUI

@main
struct LyriCantoApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var colorManager = ColorSchemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(appState)
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
                            .applicationVersion: "1.1.0",
                            .version: "1.1.0",
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
            
            CommandGroup(after: .windowArrangement) {
                // WindowGroup con id appaiono automaticamente nel menu Window
                // Non serve fare nulla qui, macOS gestisce tutto
            }
            
            CommandGroup(replacing: .help) {
                Button("Guida LyriCanto") {
                    // Le WindowGroup appaiono nel menu Window automaticamente
                    // L'utente può aprirle da lì
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
        
        // Additional Windows
        WindowGroup("Schema Colori", id: "colorScheme") {
            ColorSchemeSettingsView()
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

// MARK: - App State
class AppState: ObservableObject {
    @Published var claudeApiKey: String = ""
    @Published var openaiApiKey: String = ""
    @Published var lastProjectPath: String?
    
    init() {
        loadAPIKeys()
    }
    
    func loadAPIKeys() {
        // Carica Claude API key
        if let key = KeychainHelper.load(key: "CLAUDE_API_KEY") {
            claudeApiKey = key
        } else if let envKey = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] {
            claudeApiKey = envKey
        }
        
        // Carica OpenAI API key
        if let key = KeychainHelper.load(key: "OPENAI_API_KEY") {
            openaiApiKey = key
        } else if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            openaiApiKey = envKey
        }
    }
    
    func saveClaudeAPIKey(_ key: String) {
        claudeApiKey = key
        KeychainHelper.save(key: "CLAUDE_API_KEY", value: key)
    }
    
    func saveOpenAIAPIKey(_ key: String) {
        openaiApiKey = key
        KeychainHelper.save(key: "OPENAI_API_KEY", value: key)
    }
    
    func getAPIKey(for provider: AIProvider) -> String {
        switch provider {
        case .claude:
            return claudeApiKey
        case .openai:
            return openaiApiKey
        }
    }
}
