//
//  MainAppView.swift
//  LyriCanto
//
//  Main app wrapper with tabs for different features
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            // Tab 1: Editor Testi (vista originale)
            ContentView()
                .environmentObject(appState)
                .tabItem {
                    Label("Editor Testi", systemImage: "text.book.closed")
                }
            
            // Tab 2: Convertitore Audio
            AudioConverterView()
                .tabItem {
                    Label("Converti Audio", systemImage: "waveform.circle")
                }
            
            // Tab 3: Download Audio da YouTube
            YouTubeDownloaderView()
                .tabItem {
                    Label("Scarica Audio", systemImage: "play.circle")
                }
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
