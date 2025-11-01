//
//  ContentView.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)

            // Restrictions Tab
            AppSelectionView()
                .tabItem {
                    Label("Restrictions", systemImage: "shield.fill")
                }
                .tag(1)

            // Intentions Tab
            IntentionLibraryView()
                .tabItem {
                    Label("Intentions", systemImage: "brain.head.profile")
                }
                .tag(2)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
