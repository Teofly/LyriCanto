//
//  ColorSchemeSettingsView.swift
//  LyriCanto
//
//  Color scheme settings with proper dimensions and layout
//

import SwiftUI

struct ColorSchemeSettingsView: View {
    @ObservedObject var colorManager = ColorSchemeManager.shared
    @State private var customScheme: AppColorScheme?
    @State private var showingCustomEditor = false
    
    var body: some View {
        if showingCustomEditor, let scheme = customScheme {
            // Mostra direttamente l'editor invece di usare .sheet()
            CustomColorEditor(
                scheme: scheme,
                isPresented: $showingCustomEditor,
                colorManager: colorManager
            )
        } else {
            // Mostra la lista dei preset
            presetsView
        }
    }
    
    private var presetsView: some View {
        VStack(spacing: 20) {
            Text("Schema Colori")
                .font(.title2)
                .bold()
            
            // Preset schemes
            VStack(alignment: .leading, spacing: 12) {
                Text("Temi Predefiniti")
                    .font(.headline)
                
                ForEach(colorManager.presets, id: \.name) { scheme in
                    Button(action: {
                        colorManager.applyScheme(scheme)
                    }) {
                        HStack {
                            Circle()
                                .fill(scheme.accent.color)
                                .frame(width: 24, height: 24)
                            
                            Text(scheme.name)
                                .font(.body)
                            
                            Spacer()
                            
                            if colorManager.currentScheme == scheme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.body.bold())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    .background(colorManager.currentScheme == scheme ? 
                        Color.blue.opacity(0.15) : Color.clear)
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .padding(.vertical, 8)
            
            Button("Personalizza Colori...") {
                customScheme = colorManager.currentScheme
                showingCustomEditor = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .padding(24)
        .frame(width: 450, height: 520)
    }
}

struct CustomColorEditor: View {
    @State var scheme: AppColorScheme
    @Binding var isPresented: Bool
    @ObservedObject var colorManager: ColorSchemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                Button(action: {
                    isPresented = false
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Indietro")
                    }
                    .font(.body)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Colori Personalizzati")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("Applica") {
                    scheme.name = "Personalizzato"
                    colorManager.applyScheme(scheme)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Color pickers with scroll
            ScrollView {
                VStack(spacing: 24) {
                    // Sfondi
                    ColorPickerSection(title: "Sfondi") {
                        ColorPickerRow(title: "Sfondo Principale", color: $scheme.background)
                        ColorPickerRow(title: "Sfondo Secondario", color: $scheme.secondaryBackground)
                    }
                    
                    Divider()
                    
                    // Testi
                    ColorPickerSection(title: "Testi") {
                        ColorPickerRow(title: "Testo Principale", color: $scheme.text)
                        ColorPickerRow(title: "Testo Secondario", color: $scheme.secondaryText)
                    }
                    
                    Divider()
                    
                    // Accenti e Pulsanti
                    ColorPickerSection(title: "Accenti e Pulsanti") {
                        ColorPickerRow(title: "Colore Accento", color: $scheme.accent)
                        ColorPickerRow(title: "Sfondo Pulsanti", color: $scheme.buttonBackground)
                        ColorPickerRow(title: "Testo Pulsanti", color: $scheme.buttonText)
                    }
                    
                    Divider()
                    
                    // Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Anteprima")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            VStack(spacing: 10) {
                                Text("Testo Principale")
                                    .font(.title3)
                                    .foregroundColor(scheme.text.color)
                                
                                Text("Testo Secondario - Lorem ipsum dolor sit amet")
                                    .font(.body)
                                    .foregroundColor(scheme.secondaryText.color)
                                
                                Button("Pulsante di Esempio") {
                                    // Preview only
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(scheme.accent.color)
                                .controlSize(.large)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(scheme.secondaryBackground.color)
                            .cornerRadius(12)
                        }
                        .padding(20)
                        .background(scheme.background.color)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(24)
            }
            
            Divider()
            
            // Bottom buttons
            HStack(spacing: 12) {
                Button("Annulla") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Spacer()
                
                Button("Ripristina Default") {
                    scheme = .defaultLight
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button("Applica") {
                    scheme.name = "Personalizzato"
                    colorManager.applyScheme(scheme)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 650, height: 750)
    }
}

struct ColorPickerSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                content
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ColorPickerRow: View {
    let title: String
    @Binding var color: CodableColor
    
    var body: some View {
        HStack(spacing: 16) {
            // Label
            Text(title)
                .font(.body)
                .frame(width: 200, alignment: .leading)
            
            Spacer()
            
            // Color preview box
            RoundedRectangle(cornerRadius: 6)
                .fill(color.color)
                .frame(width: 60, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            
            // Color picker
            ColorPicker("", selection: Binding(
                get: { color.color },
                set: { newColor in
                    let nsColor = NSColor(newColor)
                    color = CodableColor(nsColor: nsColor)
                }
            ))
            .labelsHidden()
            .frame(width: 60)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

#Preview {
    ColorSchemeSettingsView()
}
