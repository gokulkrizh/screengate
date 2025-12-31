//
//  jelly.swift
//  screendiet
//
//  Created by gokul on 30/12/25.
//

import SwiftUI

struct NeonJellyfishView: View {
    let color: Color
    let size: CGFloat
    let glowIntensity: CGFloat
    
    @State private var animateWave = false
    @State private var animatePulse = false
    
    init(color: Color = .cyan, size: CGFloat = 200, glowIntensity: CGFloat = 1.0) {
        self.color = color
        self.size = size
        self.glowIntensity = glowIntensity
    }
    
    var body: some View {
        ZStack {
            // Tentacles (drawn behind the bell)
            ForEach(0..<12, id: \.self) { index in
                WavyTentacle(
                    phase: Double(index) * 0.5,
                    animationOffset: animateWave ? 1.0 : 0.0
                )
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0.9),
                            color.opacity(0.6),
                            color.opacity(0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: size * 0.02
                )
                .shadow(color: color.opacity(0.8 * glowIntensity), radius: 8)
                .shadow(color: color.opacity(0.6 * glowIntensity), radius: 15)
                .rotationEffect(.degrees(Double(index) * 30))
                .frame(width: size, height: size * 1.8)
            }
            
            // Jellyfish Bell
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.8),
                                color.opacity(0.4),
                                color.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: size * 0.15,
                            endRadius: size * 0.35
                        )
                    )
                    .frame(width: size * 0.7, height: size * 0.7)
                    .blur(radius: 20)
                    .shadow(color: color.opacity(0.8 * glowIntensity), radius: 30)
                    .shadow(color: color.opacity(0.6 * glowIntensity), radius: 50)
                
                // Main bell body
                BellShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.6),
                                color.opacity(0.4),
                                color.opacity(0.2)
                            ],
                            center: .top,
                            startRadius: 0,
                            endRadius: size * 0.3
                        )
                    )
                    .frame(width: size * 0.6, height: size * 0.5)
                    .shadow(color: color.opacity(0.6 * glowIntensity), radius: 15)
                
                // Inner patterns/spots
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(color.opacity(0.4))
                        .frame(width: size * 0.04, height: size * 0.04)
                        .offset(
                            x: cos(Double(index) * .pi / 4) * size * 0.15,
                            y: sin(Double(index) * .pi / 4) * size * 0.1 - size * 0.05
                        )
                        .blur(radius: 2)
                }
                
                // Highlight on top
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.35, height: size * 0.15)
                    .offset(y: -size * 0.15)
                    .blur(radius: 3)
            }
            .scaleEffect(animatePulse ? 1.05 : 1.0)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                animateWave = true
            }
            
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                animatePulse = true
            }
        }
    }
}

// Custom bell shape for the jellyfish
struct BellShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: 0))
        
        // Top curve
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.6),
            control1: CGPoint(x: width * 0.9, y: height * 0.1),
            control2: CGPoint(x: width * 1.0, y: height * 0.4)
        )
        
        // Right side curve inward
        path.addCurve(
            to: CGPoint(x: width * 0.7, y: height),
            control1: CGPoint(x: width * 0.95, y: height * 0.8),
            control2: CGPoint(x: width * 0.8, y: height * 0.95)
        )
        
        // Bottom curve
        path.addQuadCurve(
            to: CGPoint(x: width * 0.3, y: height),
            control: CGPoint(x: width * 0.5, y: height * 1.1)
        )
        
        // Left side curve inward
        path.addCurve(
            to: CGPoint(x: 0, y: height * 0.6),
            control1: CGPoint(x: width * 0.2, y: height * 0.95),
            control2: CGPoint(x: width * 0.05, y: height * 0.8)
        )
        
        // Left top curve
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: 0),
            control1: CGPoint(x: 0, y: height * 0.4),
            control2: CGPoint(x: width * 0.1, y: height * 0.1)
        )
        
        return path
    }
}

// Wavy tentacle path
struct WavyTentacle: Shape {
    var phase: Double
    var animationOffset: Double
    
    var animatableData: Double {
        get { animationOffset }
        set { animationOffset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let startX = rect.midX
        let startY = rect.height * 0.25
        let endY = rect.height * 0.9
        
        path.move(to: CGPoint(x: startX, y: startY))
        
        let segments = 8
        let segmentHeight = (endY - startY) / CGFloat(segments)
        
        for i in 0...segments {
            let y = startY + segmentHeight * CGFloat(i)
            let progress = CGFloat(i) / CGFloat(segments)
            
            // Create wave effect with animation
            let waveAmplitude = rect.width * 0.08 * (1 + progress * 0.5)
            let frequency = 2.0 + phase
            let x = startX + sin(frequency * progress * .pi * 2 + animationOffset * .pi * 2) * waveAmplitude
            
            if i == 0 {
                path.move(to: CGPoint(x: startX, y: startY))
            } else {
                let prevY = startY + segmentHeight * CGFloat(i - 1)
                let prevProgress = CGFloat(i - 1) / CGFloat(segments)
                let prevX = startX + sin(frequency * prevProgress * .pi * 2 + animationOffset * .pi * 2) * waveAmplitude * (1 + prevProgress * 0.5) / (1 + progress * 0.5) * (rect.width * 0.08)
                
                path.addQuadCurve(
                    to: CGPoint(x: x, y: y),
                    control: CGPoint(x: (x + prevX) / 2, y: (y + prevY) / 2)
                )
            }
        }
        
        return path
    }
}

// Preview with multiple color options
struct NeonJellyfishView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                HStack(spacing: 30) {
                    NeonJellyfishView(color: .pink, size: 150, glowIntensity: 1.2)
                    NeonJellyfishView(color: .purple, size: 150, glowIntensity: 1.2)
                    NeonJellyfishView(color: .cyan, size: 150, glowIntensity: 1.2)
                }
                
                HStack(spacing: 30) {
                    NeonJellyfishView(color: .orange, size: 150, glowIntensity: 1.2)
                    NeonJellyfishView(color: Color(red: 0.7, green: 1.0, blue: 0.3), size: 150, glowIntensity: 1.2)
                    NeonJellyfishView(color: .green, size: 150, glowIntensity: 1.2)
                }
            }
        }
    }
}
