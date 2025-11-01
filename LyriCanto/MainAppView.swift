//
//  MainAppView.swift
//  LyriCanto
//
//  Main app view with tab navigation
//  Version 1.2.0 - Added AI Rime tab
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var colorScheme: ColorSchemeManager
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Scarica Audio
            YouTubeDownloaderView()
                .tabItem {
                    Label("Scarica Audio", systemImage: "play.circle")
                }
                .tag(0)

            // Tab 2: Converti Audio
            AudioConverterView()
                .tabItem {
                    Label("Converti Audio", systemImage: "waveform.circle")
                }
                .tag(1)
                        
             // Tab 3: Editor Testi
            ContentView()
                .environmentObject(appState)
                .environmentObject(colorScheme)
                .tabItem {
                    Label("Editor Testi", systemImage: "text.book.closed")
                }
                .tag(2)
            
           // Tab 4: AI Rime & Assonanze ⭐ NUOVO
            RhymeAIView()
                .tabItem {
                    Label("AI Rime", systemImage: "music.note.list")
                }
                .tag(3)
        }
        .frame(minWidth: 1000, minHeight: 700)
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
            .environmentObject(AppState())
    }
}
