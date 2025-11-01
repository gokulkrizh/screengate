//
//  MainView.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI

struct MainView: View {
    @State private var showSplash = true
    @State private var showOnboarding = false

    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else if showOnboarding || !OnboardingViewModel.hasCompletedOnboarding() {
                OnboardingView {
                    showOnboarding = false
                }
            } else {
                ContentView()
            }
        }
        .onAppear {
            // Show splash screen for 2.5 seconds, then check onboarding status
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showSplash = false
                    if !OnboardingViewModel.hasCompletedOnboarding() {
                        showOnboarding = true
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}