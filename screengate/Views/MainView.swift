//
//  MainView.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI

struct MainView: View {
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else {
                ContentView()
            }
        }
        .onAppear {
            // Show splash screen for 2.5 seconds, then transition to main content
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    MainView()
}