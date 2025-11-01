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
    @EnvironmentObject var deepLinkManager: DeepLinkManager

    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else if showOnboarding || !OnboardingViewModel.hasCompletedOnboarding() {
                OnboardingView {
                    showOnboarding = false
                }
            } else if deepLinkManager.shouldShowIntention {
                // Show intention screen when deep link is received
                IntentionContainerView(
                    intention: deepLinkManager.currentIntention,
                    sourceAppInfo: deepLinkManager.sourceAppInfo
                )
                .onDisappear {
                    // Reset deep link state after completion
                    deepLinkManager.shouldShowIntention = false
                    deepLinkManager.currentIntention = nil
                    deepLinkManager.sourceAppInfo = nil
                }
            } else {
                // Show main Screen Time navigation
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
        .onChange(of: deepLinkManager.shouldShowIntention) {
            print("🔗 Deep link navigation: \(deepLinkManager.shouldShowIntention ? "Showing intention" : "Showing main app")")
        }
    }
}

#Preview {
    MainView()
        .environmentObject(DeepLinkManager())
}