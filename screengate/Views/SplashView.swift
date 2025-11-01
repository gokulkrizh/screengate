//
//  SplashView.swift
//  screengate
//
//  Created by gokul on 01/11/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Blue background
            Color.blue
                .ignoresSafeArea()

            // Door icon with animation
            VStack(spacing: 20) {
                Image(systemName: "door.left.right.open")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Text("ScreenGate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    SplashView()
}