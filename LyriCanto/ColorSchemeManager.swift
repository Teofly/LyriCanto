//
//  ColorSchemeManager.swift
//  LyriCanto
//
//  Color scheme management for UI customization
//

import SwiftUI
import AppKit

// MARK: - View Extensions for Easy Theme Application
extension View {
    func themedBackground(_ colorManager: ColorSchemeManager) -> some View {
        self.background(colorManager.currentScheme.background.color)
    }
    
    func themedSecondaryBackground(_ colorManager: ColorSchemeManager) -> some View {
        self.background(colorManager.currentScheme.secondaryBackground.color)
    }
    
    func themedForeground(_ colorManager: ColorSchemeManager) -> some View {
        self.foregroundColor(colorManager.currentScheme.text.color)
    }
    
    func themedSecondaryForeground(_ colorManager: ColorSchemeManager) -> some View {
        self.foregroundColor(colorManager.currentScheme.secondaryText.color)
    }
}

// MARK: - Color Scheme Definition
struct AppColorScheme: Codable, Equatable {
    var name: String
    var background: CodableColor
    var secondaryBackground: CodableColor
    var text: CodableColor
    var secondaryText: CodableColor
    var accent: CodableColor
    var buttonBackground: CodableColor
    var buttonText: CodableColor
    
    static let defaultLight = AppColorScheme(
    name: "Chiaro (Default)",
    background: CodableColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0),
    secondaryBackground: CodableColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0),
    text: CodableColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0),
    secondaryText: CodableColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0),
    accent: CodableColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),
    buttonBackground: CodableColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0),
    buttonText: CodableColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    )
    
    static let defaultDark = AppColorScheme(
        name: "Scuro",
        background: CodableColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0),
        secondaryBackground: CodableColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0),
        text: CodableColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        secondaryText: CodableColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0),
        accent: CodableColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),
        buttonBackground: CodableColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0),
        buttonText: CodableColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    )
    
    static let ocean = AppColorScheme(
        name: "Oceano",
        background: CodableColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0),
        secondaryBackground: CodableColor(red: 0.85, green: 0.92, blue: 0.98, alpha: 1.0),
        text: CodableColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0),
        secondaryText: CodableColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1.0),
        accent: CodableColor(red: 0.0, green: 0.5, blue: 0.8, alpha: 1.0),
        buttonBackground: CodableColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0),
        buttonText: CodableColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    )
    
    static let sunset = AppColorScheme(
        name: "Tramonto",
        background: CodableColor(red: 1.0, green: 0.95, blue: 0.9, alpha: 1.0),
        secondaryBackground: CodableColor(red: 0.98, green: 0.92, blue: 0.85, alpha: 1.0),
        text: CodableColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0),
        secondaryText: CodableColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0),
        accent: CodableColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0),
        buttonBackground: CodableColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0),
        buttonText: CodableColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    )
    
    static let forest = AppColorScheme(
        name: "Foresta",
        background: CodableColor(red: 0.95, green: 0.98, blue: 0.92, alpha: 1.0),
        secondaryBackground: CodableColor(red: 0.9, green: 0.95, blue: 0.88, alpha: 1.0),
        text: CodableColor(red: 0.15, green: 0.25, blue: 0.15, alpha: 1.0),
        secondaryText: CodableColor(red: 0.35, green: 0.45, blue: 0.35, alpha: 1.0),
        accent: CodableColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0),
        buttonBackground: CodableColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1.0),
        buttonText: CodableColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    )
}

// MARK: - Codable Color
struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    init(nsColor: NSColor) {
        let rgb = nsColor.usingColorSpace(.deviceRGB) ?? nsColor
        self.red = Double(rgb.redComponent)
        self.green = Double(rgb.greenComponent)
        self.blue = Double(rgb.blueComponent)
        self.alpha = Double(rgb.alphaComponent)
    }
    
    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    var nsColor: NSColor {
        NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}

// MARK: - Color Scheme Manager
class ColorSchemeManager: ObservableObject {
    static let shared = ColorSchemeManager()
    
    @Published var currentScheme: AppColorScheme {
        didSet {
            saveScheme()
        }
    }
    
    let presets: [AppColorScheme] = [
        .defaultDark,
        .defaultLight,
        .ocean,
        .sunset,
        .forest
    ]
    
    private init() {
        if let saved = UserDefaults.standard.data(forKey: "colorScheme"),
           let decoded = try? JSONDecoder().decode(AppColorScheme.self, from: saved) {
            self.currentScheme = decoded
        } else {
            self.currentScheme = .defaultDark
        }
    }
    
    func applyScheme(_ scheme: AppColorScheme) {
        currentScheme = scheme
        objectWillChange.send()
    }
    
    func createCustomScheme(from base: AppColorScheme) -> AppColorScheme {
        var custom = base
        custom.name = "Personalizzato"
        return custom
    }
    
    private func saveScheme() {
        if let encoded = try? JSONEncoder().encode(currentScheme) {
            UserDefaults.standard.set(encoded, forKey: "colorScheme")
        }
    }
}

// MARK: - View Extension
extension View {
    func themedBackground() -> some View {
        self.background(ColorSchemeManager.shared.currentScheme.background.color)
    }
    
    func themedSecondaryBackground() -> some View {
        self.background(ColorSchemeManager.shared.currentScheme.secondaryBackground.color)
    }
    
    func themedForeground() -> some View {
        self.foregroundColor(ColorSchemeManager.shared.currentScheme.text.color)
    }
    
    func themedAccent() -> some View {
        self.accentColor(ColorSchemeManager.shared.currentScheme.accent.color)
    }
}
