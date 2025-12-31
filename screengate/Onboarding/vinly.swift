import SwiftUI

// MD Vinyl Style - Groovy circular pattern with shine
struct MDVinylGradient: View {
    @State private var rotation: Double = 0
    @State private var shimmer: Double = 0
    
    var body: some View {
        ZStack {
            // Base dark color
            Color.black
                .ignoresSafeArea()
            
            // Vinyl grooves effect - multiple concentric circles
            ForEach(0..<12) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.15, blue: 0.2).opacity(0.6),
                                Color(red: 0.25, green: 0.25, blue: 0.35).opacity(0.4),
                                Color(red: 0.15, green: 0.15, blue: 0.2).opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: CGFloat(100 + i * 60))
                    .blur(radius: 2)
            }
            .rotationEffect(.degrees(rotation))
            
            // Vinyl shine/reflection effect
            RadialGradient(
                colors: [
                    Color.clear,
                    Color(red: 0.4, green: 0.45, blue: 0.6).opacity(0.3),
                    Color(red: 0.5, green: 0.55, blue: 0.7).opacity(0.5),
                    Color(red: 0.4, green: 0.45, blue: 0.6).opacity(0.3),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 400
            )
            .mask(
                Circle()
                    .frame(width: 800, height: 800)
            )
            .rotationEffect(.degrees(shimmer))
            .blur(radius: 20)
            
            // Center label area (lighter)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.12, green: 0.12, blue: 0.18),
                            Color(red: 0.08, green: 0.08, blue: 0.12)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.2, green: 0.2, blue: 0.3), lineWidth: 1)
                )
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                shimmer = 360
            }
        }
    }
}

// Subtle Vinyl - Less distracting for onboarding
struct SubtleMDVinylGradient: View {
    @State private var rotation: Double = 0
    @State private var shimmer: Double = 0
    @State private var glowPulse: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .ignoresSafeArea()
            
            // Subtle vinyl texture
            ForEach(0..<8) { i in
                Circle()
                    .stroke(
                        Color(red: 0.15, green: 0.15, blue: 0.22).opacity(0.3),
                        lineWidth: 2
                    )
                    .frame(width: CGFloat(120 + i * 70))
                    .blur(radius: 3)
            }
            .rotationEffect(.degrees(rotation))
            
            // Vinyl shine/reflection effect
            RadialGradient(
                colors: [
                    Color.clear,
                    Color(red: 0.35, green: 0.4, blue: 0.55).opacity(0.25),
                    Color(red: 0.45, green: 0.5, blue: 0.65).opacity(0.35),
                    Color(red: 0.35, green: 0.4, blue: 0.55).opacity(0.25),
                    Color.clear
                ],
                center: .center,
                startRadius: 80,
                endRadius: 350
            )
            .mask(
                Circle()
                    .frame(width: 700, height: 700)
            )
            .rotationEffect(.degrees(shimmer))
            .blur(radius: 30)
            
            // Soft glow at bottom
            VStack {
                Spacer()
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.35, green: 0.4, blue: 0.55).opacity(0.4),
                                Color(red: 0.25, green: 0.3, blue: 0.45).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .frame(height: 400)
                    .scaleEffect(glowPulse)
                    .blur(radius: 50)
                    .offset(y: 150)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                shimmer = 360
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                glowPulse = 1.15
            }
        }
    }
}

// Colorful Vinyl (Purple/Blue variant)
struct ColorfulVinylGradient: View {
    @State private var rotation: Double = 0
    @State private var shimmer: Double = 0
    
    var body: some View {
        ZStack {
            // Deep purple/blue base
            RadialGradient(
                colors: [
                    Color(red: 0.15, green: 0.1, blue: 0.25),
                    Color(red: 0.08, green: 0.05, blue: 0.15),
                    Color.black
                ],
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
            
            // Grooves with color
            ForEach(0..<10) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.2, blue: 0.5).opacity(0.5),
                                Color(red: 0.2, green: 0.3, blue: 0.6).opacity(0.4),
                                Color(red: 0.3, green: 0.2, blue: 0.5).opacity(0.5)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: CGFloat(110 + i * 65))
                    .blur(radius: 2)
            }
            .rotationEffect(.degrees(rotation))
            
            // Colorful shine
            RadialGradient(
                colors: [
                    Color.clear,
                    Color(red: 0.5, green: 0.4, blue: 0.8).opacity(0.4),
                    Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.5),
                    Color(red: 0.5, green: 0.3, blue: 0.7).opacity(0.4),
                    Color.clear
                ],
                center: .center,
                startRadius: 80,
                endRadius: 380
            )
            .mask(
                Circle()
                    .frame(width: 760, height: 760)
            )
            .rotationEffect(.degrees(shimmer))
            .blur(radius: 25)
            
            // Center
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.2, green: 0.15, blue: 0.3),
                            Color(red: 0.1, green: 0.08, blue: 0.18)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                shimmer = 360
            }
        }
    }
}

// Holographic Vinyl Effect
struct HolographicVinylGradient: View {
    @State private var rotation: Double = 0
    @State private var hueRotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Grooves
            ForEach(0..<15) { i in
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(red: 0.3, green: 0.2, blue: 0.5),
                                Color(red: 0.2, green: 0.4, blue: 0.7),
                                Color(red: 0.5, green: 0.3, blue: 0.6),
                                Color(red: 0.3, green: 0.5, blue: 0.8),
                                Color(red: 0.3, green: 0.2, blue: 0.5)
                            ],
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: CGFloat(80 + i * 50))
                    .opacity(0.6)
                    .blur(radius: 3)
            }
            .rotationEffect(.degrees(rotation))
            .hueRotation(.degrees(hueRotation))
            
            // Holographic shimmer
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color.cyan.opacity(0.3),
                            Color.purple.opacity(0.3),
                            Color.pink.opacity(0.3),
                            Color.blue.opacity(0.3),
                            Color.cyan.opacity(0.3)
                        ],
                        center: .center
                    )
                )
                .frame(width: 700, height: 700)
                .blur(radius: 40)
                .rotationEffect(.degrees(-rotation * 0.5))
            
            // Center
            Circle()
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                .frame(width: 120, height: 120)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                hueRotation = 60
            }
        }
    }
}

// Static Vinyl Texture (No animation)
struct StaticVinylTexture: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.1),
                    Color(red: 0.1, green: 0.1, blue: 0.18),
                    Color(red: 0.15, green: 0.15, blue: 0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Static grooves pattern
            ForEach(0..<6) { i in
                Circle()
                    .stroke(
                        Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.2),
                        lineWidth: 2
                    )
                    .frame(width: CGFloat(150 + i * 80))
                    .blur(radius: 2)
            }
        }
    }
}

// Preview with demo content
struct VinylPreviewDemo: View {
    var gradientView: AnyView
    var title: String
    
    var body: some View {
        ZStack {
            gradientView
            
            VStack(spacing: 30) {
                Image(systemName: "opticaldisc")
                    .font(.system(size: 80))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 100)
                
                Text("What's your\nprimary goal?")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {}) {
                        Text("Option 1")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                    
                    Button(action: {}) {
                        Text("Option 2")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                            )
                    }
                }
                .padding(.horizontal, 30)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 30)
            }
        }
    }
}

struct ContentView_Previewsd: PreviewProvider {
    static var previews: some View {
        TabView {
            VinylPreviewDemo(
                gradientView: AnyView(MDVinylGradient()),
                title: "Classic Vinyl"
            )
            .tabItem { Label("Classic", systemImage: "1.circle") }
            
            VinylPreviewDemo(
                gradientView: AnyView(SubtleMDVinylGradient()),
                title: "Subtle (Recommended)"
            )
            .tabItem { Label("Subtle", systemImage: "2.circle") }
            
            VinylPreviewDemo(
                gradientView: AnyView(ColorfulVinylGradient()),
                title: "Colorful Vinyl"
            )
            .tabItem { Label("Colorful", systemImage: "3.circle") }
            
            VinylPreviewDemo(
                gradientView: AnyView(HolographicVinylGradient()),
                title: "Holographic"
            )
            .tabItem { Label("Holo", systemImage: "4.circle") }
            
            VinylPreviewDemo(
                gradientView: AnyView(StaticVinylTexture()),
                title: "Static Texture"
            )
            .tabItem { Label("Static", systemImage: "5.circle") }
        }
    }
}
