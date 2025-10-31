//
//  ColorSchemeSettingsView.swift
//  LyriCanto
//

import SwiftUI

struct ColorSchemeSettingsView: View {
    @ObservedObject var colorManager = ColorSchemeManager.shared
    @State private var customScheme: AppColorScheme?
    @State private var showingCustomEditor = false
    
    var body: some View {
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
                                .frame(width: 20, height: 20)
                            Text(scheme.name)
                            Spacer()
                            if colorManager.currentScheme == scheme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                    .background(colorManager.currentScheme == scheme ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(8)
                }
            }
            
            Divider()
            
            Button("Personalizza Colori...") {
                customScheme = colorManager.currentScheme
                showingCustomEditor = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 400, height: 500)
        .sheet(isPresented: $showingCustomEditor) {
            if let scheme = customScheme {
                CustomColorEditor(scheme: scheme, isPresented: $showingCustomEditor)
            }
        }
    }
}

struct CustomColorEditor: View {
    @State var scheme: AppColorScheme
    @Binding var isPresented: Bool
    @ObservedObject var colorManager = ColorSchemeManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Colori Personalizzati")
                .font(.title2)
                .bold()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ColorPickerRow(title: "Sfondo", color: $scheme.background)
                    ColorPickerRow(title: "Sfondo Secondario", color: $scheme.secondaryBackground)
                    ColorPickerRow(title: "Testo", color: $scheme.text)
                    ColorPickerRow(title: "Testo Secondario", color: $scheme.secondaryText)
                    ColorPickerRow(title: "Accento", color: $scheme.accent)
                    ColorPickerRow(title: "Pulsanti Sfondo", color: $scheme.buttonBackground)
                    ColorPickerRow(title: "Pulsanti Testo", color: $scheme.buttonText)
                }
                .padding()
            }
            
            HStack {
                Button("Annulla") {
                    isPresented = false
                }
                Spacer()
                Button("Applica") {
                    scheme.name = "Personalizzato"
                    colorManager.applyScheme(scheme)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
        .padding()
    }
}

struct ColorPickerRow: View {
    let title: String
    @Binding var color: CodableColor
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 150, alignment: .leading)
            ColorPicker("", selection: Binding(
                get: { color.color },
                set: { newColor in
                    let nsColor = NSColor(newColor)
                    color = CodableColor(nsColor: nsColor)
                }
            ))
            .labelsHidden()
        }
    }
}
