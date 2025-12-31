import SwiftUI

struct AnimatedGradientView: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated Linear Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.5, blue: 0.9),
                    Color(red: 0.8, green: 0.3, blue: 0.7),
                    Color(red: 0.3, green: 0.8, blue: 0.6)
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(
                    .linear(duration: 3)
                    .repeatForever(autoreverses: true)
                ) {
                    animateGradient.toggle()
                }
            }
            
            VStack(spacing: 30) {
                Text("Animated Gradient")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Smooth color transitions")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// Alternative: Animated Radial Gradient
struct AnimatedRadialGradientView: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.6),
                    Color(red: 0.5, green: 0.3, blue: 0.9),
                    Color(red: 0.1, green: 0.1, blue: 0.3)
                ],
                center: animateGradient ? .bottomLeading : .bottomTrailing,
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
                ) {
                    animateGradient.toggle()
                }
            }
            
            VStack(spacing: 30) {
                Text("Radial Gradient")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Circular color spread")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// Alternative: Animated Mesh Gradient (iOS 18+)
@available(iOS 18.0, *)
struct AnimatedMeshGradientView: View {
    @State private var t: Float = 0
    
    var body: some View {
        ZStack {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5 + 0.1 * sin(t)], [0.5, 0.5], [1, 0.5 + 0.1 * cos(t)],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    .purple, .indigo, .blue,
                    .pink, .cyan, .mint,
                    .orange, .yellow, .green
                ]
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(
                    .linear(duration: 5)
                    .repeatForever(autoreverses: false)
                ) {
                    t = .pi * 2
                }
            }
            
            VStack(spacing: 30) {
                Text("Mesh Gradient")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text("iOS 18+ only")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// Variation 1: Moving Radial Gradient with Color Rotation
struct MovingRadialGradientView1: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.6),
                    Color(red: 0.5, green: 0.3, blue: 0.9),
                    Color(red: 0.1, green: 0.1, blue: 0.3)
                ],
                center: animateGradient ? .topLeading : .bottomTrailing,
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(animateGradient ? 45 : 0))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 9)
                    .repeatForever(autoreverses: true)
                ) {
                    animateGradient.toggle()
                }
            }
            
            Text("Moving + Hue Rotation")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
    }
}


// Variation 2: Pulsating Radial Gradient
struct PulsatingRadialGradientView1: View {
    @State private var pulsate = false
    
    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color(red: 0.2, green: 0.6, blue: 1.0),
                    Color(red: 0.9, green: 0.2, blue: 0.8),
                    Color(red: 0.1, green: 0.1, blue: 0.2)
                ],
                center: .center,
                startRadius: pulsate ? 10 : 100,
                endRadius: pulsate ? 600 : 400
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                ) {
                    pulsate.toggle()
                }
            }
            
            Text("Pulsating Effect")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// Variation 3: Multiple Overlapping Radial Gradients
struct MultipleRadialGradientsView1: View {
    @State private var animate1 = false
    @State private var animate2 = false
    @State private var animate3 = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.clear
                ],
                center: animate1 ? .topLeading : .bottomTrailing,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            .blendMode(.screen)
            
            RadialGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.clear
                ],
                center: animate2 ? .topTrailing : .bottomLeading,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            .blendMode(.screen)
            
            RadialGradient(
                colors: [
                    Color.pink.opacity(0.8),
                    Color.clear
                ],
                center: animate3 ? .center : .bottom,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()
            .blendMode(.screen)
            
            Text("Multiple Overlapping")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animate1.toggle()
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(0.5)) {
                animate2.toggle()
            }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true).delay(1)) {
                animate3.toggle()
            }
        }
    }
}

// Variation 4: Spinning Radial Gradient
struct SpinningRadialGradientView1: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color.cyan,
                    Color.purple,
                    Color.orange,
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    scale = 1.3
                }
            }
            
            Text("Spinning & Scaling")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// Variation 5: Wandering Radial Gradient
struct WanderingRadialGradientView1: View {
    @State private var position: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var hue: Double = 0
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.15)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                RadialGradient(
                    colors: [
                        Color(hue: hue, saturation: 0.8, brightness: 1.0),
                        Color(hue: hue + 0.2, saturation: 0.9, brightness: 0.8),
                        Color(hue: hue + 0.4, saturation: 0.7, brightness: 0.5),
                        Color.clear
                    ],
                    center: UnitPoint(x: position.x, y: position.y),
                    startRadius: 20,
                    endRadius: 350
                )
                .ignoresSafeArea()
            }
            
            Text("Wandering Colors")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            startWandering()
        }
    }
    
    func startWandering() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2)) {
                position.x = CGFloat.random(in: 0.2...0.8)
                position.y = CGFloat.random(in: 0.2...0.8)
                hue = Double.random(in: 0...1)
            }
        }
    }
}

// Variation 6: Aurora Effect
struct AuroraRadialGradientView1: View {
    @State private var animate = false
    @State private var hueRotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color.green.opacity(0.6),
                    Color.blue.opacity(0.5),
                    Color.purple.opacity(0.4),
                    Color.clear
                ],
                center: animate ? UnitPoint(x: 0.3, y: 0.3) : UnitPoint(x: 0.7, y: 0.7),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
            .blendMode(.plusLighter)
            .hueRotation(.degrees(hueRotation))
            
            Text("Aurora Effect")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                hueRotation = 360
            }
        }
    }
}

// Wave from Bottom
struct WaveFromBottomView: View {
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                Wave(offset: waveOffset, percent: 0.6)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.5, blue: 1.0),
                                Color(red: 0.6, green: 0.3, blue: 0.9),
                                Color(red: 0.9, green: 0.4, blue: 0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .ignoresSafeArea()
                    .opacity(0.8)
                
                Wave(offset: waveOffset + 200, percent: 0.65)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.6),
                                Color.blue.opacity(0.6),
                                Color.cyan.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .ignoresSafeArea()
                    .blendMode(.screen)
                
                VStack {
                    Spacer()
                    Text("Wave from Bottom")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                waveOffset = 400
            }
        }
    }
}

// Wave from Left
struct WaveFromLeftView: View {
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.15)
                    .ignoresSafeArea()
                
                HorizontalWave(offset: waveOffset, percent: 0.5, fromRight: false)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.8, blue: 0.6),
                                Color(red: 0.4, green: 0.6, blue: 0.9),
                                Color(red: 0.7, green: 0.4, blue: 0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
                    .opacity(0.9)
                
                HorizontalWave(offset: waveOffset + 150, percent: 0.55, fromRight: false)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(0.5),
                                Color.blue.opacity(0.5),
                                Color.purple.opacity(0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
                    .blendMode(.screen)
                
                HStack {
                    Spacer()
                    Text("Wave from Left")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.trailing, 30)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                waveOffset = 400
            }
        }
    }
}

// Wave from Right
struct WaveFromRightView: View {
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.1, green: 0.05, blue: 0.15)
                    .ignoresSafeArea()
                
                HorizontalWave(offset: waveOffset, percent: 0.5, fromRight: true)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.5, blue: 0.3),
                                Color(red: 0.9, green: 0.3, blue: 0.7),
                                Color(red: 0.6, green: 0.4, blue: 0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
                    .opacity(0.85)
                
                HorizontalWave(offset: waveOffset + 180, percent: 0.55, fromRight: true)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.pink.opacity(0.6),
                                Color.purple.opacity(0.6),
                                Color.blue.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
                    .blendMode(.screen)
                
                HStack {
                    Text("Wave from Right")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 30)
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                waveOffset = 400
            }
        }
    }
}

// Multi-directional Waves
struct MultiDirectionalWavesView: View {
    @State private var waveOffset1: CGFloat = 0
    @State private var waveOffset2: CGFloat = 0
    @State private var waveOffset3: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Bottom wave
            Wave(offset: waveOffset1, percent: 0.5)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .ignoresSafeArea()
                .blendMode(.screen)
            
            // Left wave
            HorizontalWave(offset: waveOffset2, percent: 0.4, fromRight: false)
                .fill(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.5), Color.blue.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
                .blendMode(.screen)
            
            // Right wave
            HorizontalWave(offset: waveOffset3, percent: 0.45, fromRight: true)
                .fill(
                    LinearGradient(
                        colors: [Color.pink.opacity(0.5), Color.purple.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
                .blendMode(.screen)
            
            Text("Multi-Directional")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                waveOffset1 = 400
            }
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                waveOffset2 = 400
            }
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                waveOffset3 = 400
            }
        }
    }
}

// Wave Shape (from bottom)
struct Wave: Shape {
    var offset: CGFloat
    var percent: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let waveHeight: CGFloat = 30
        let yOffset = height * (1 - percent)
        
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: yOffset))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / 50
            let sine = sin(relativeX + offset * 0.02)
            let y = yOffset + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

// Horizontal Wave Shape (from left or right)
struct HorizontalWave: Shape {
    var offset: CGFloat
    var percent: CGFloat
    var fromRight: Bool
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let waveWidth: CGFloat = 30
        let xOffset = fromRight ? width * (1 - percent) : width * percent
        
        if fromRight {
            path.move(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: xOffset, y: 0))
            
            for y in stride(from: 0, through: height, by: 1) {
                let relativeY = y / 50
                let sine = sin(relativeY + offset * 0.02)
                let x = xOffset + sine * waveWidth
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: width, y: height))
        } else {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: xOffset, y: 0))
            
            for y in stride(from: 0, through: height, by: 1) {
                let relativeY = y / 50
                let sine = sin(relativeY + offset * 0.02)
                let x = xOffset + sine * waveWidth
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: 0, y: height))
        }
        
        path.closeSubpath()
        return path
    }
}

// Replicate the smooth gradient from the image
struct SmoothGradientView: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base gradient matching the image
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12), // Very dark blue at top
                    Color(red: 0.08, green: 0.08, blue: 0.18),
                    Color(red: 0.15, green: 0.15, blue: 0.35),
                    Color(red: 0.25, green: 0.25, blue: 0.55),
                    Color(red: 0.35, green: 0.35, blue: 0.75),
                    Color(red: 0.45, green: 0.45, blue: 0.95)  // Bright blue at bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle glow overlay at the bottom
            VStack {
                Spacer()
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.5, green: 0.5, blue: 1.0).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .frame(height: 400)
                    .blur(radius: 50)
                    .offset(y: 150)
            }
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 30) {
                Image(systemName: "target")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.4, green: 0.5, blue: 1.0),
                                Color(red: 0.5, green: 0.4, blue: 0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 100)
                
                Text("What's your\nprimary goal?")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {}) {
                        Text("Lose weight")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                    
                    Button(action: {}) {
                        Text("Daily activity")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white)
                            )
                    }
                }
                .padding(.horizontal, 30)
                
                Button(action: {}) {
                    Text("Next")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white)
                        )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

// Animated version with subtle movement
struct AnimatedSmoothGradientView: View {
    @State private var animateGradient = false
    @State private var glowScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Animated gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color(red: 0.08, green: 0.08, blue: 0.18),
                    Color(red: 0.15, green: 0.15, blue: 0.35),
                    Color(red: 0.25, green: 0.25, blue: 0.55),
                    Color(red: 0.35, green: 0.35, blue: 0.75),
                    Color(red: 0.45, green: 0.45, blue: 0.95)
                ],
                startPoint: animateGradient ? .topLeading : .top,
                endPoint: animateGradient ? .bottomTrailing : .bottom
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(animateGradient ? 5 : 0))
            
            // Animated glow
            VStack {
                Spacer()
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.5, green: 0.5, blue: 1.0).opacity(0.4),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 300
                        )
                    )
                    .frame(height: 400)
                    .blur(radius: 50)
                    .scaleEffect(glowScale)
                    .offset(y: 150)
            }
            .ignoresSafeArea()
            
            Text("Animated Smooth Gradient")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowScale = 1.2
            }
        }
    }
}

// Pulsing gradient variation
struct PulsingGradientView: View {
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color(red: 0.1, green: 0.1, blue: 0.25),
                    Color(red: 0.2, green: 0.2, blue: 0.45),
                    Color(red: 0.3, green: 0.3, blue: 0.65),
                    Color(red: 0.4, green: 0.4, blue: 0.85),
                    Color(red: 0.5, green: 0.5, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .brightness(pulse ? 0.05 : 0)
            
            // Multiple glows for depth
            VStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.blue.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 250
                            )
                        )
                        .frame(height: 400)
                        .blur(radius: 40)
                        .scaleEffect(pulse ? 1.3 : 1.0)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.5, blue: 1.0).opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(height: 350)
                        .blur(radius: 60)
                        .scaleEffect(pulse ? 1.1 : 1.2)
                }
                .offset(y: 150)
            }
            .ignoresSafeArea()
            
            Text("Pulsing Gradient")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }
}

// Flowing gradient with color shifts
struct FlowingGradientView: View {
    @State private var hueRotation: Double = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.2, blue: 0.5),
                    Color(red: 0.3, green: 0.3, blue: 0.7),
                    Color(red: 0.4, green: 0.4, blue: 0.9),
                    Color(red: 0.5, green: 0.5, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .hueRotation(.degrees(hueRotation))
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.blue.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 350
                        )
                    )
                    .frame(height: 500)
                    .blur(radius: 70)
                    .offset(y: offset)
            }
            .ignoresSafeArea()
            
            Text("Flowing Colors")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                hueRotation = 30
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                offset = 50
            }
        }
    }
}

// Option 1: Fixed position at bottom only (recommended)
struct BottomGradientBackground: View {
    @State private var glowScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Static dark background
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .ignoresSafeArea()
            
            // Gradient only at bottom third
            VStack {
                Spacer()
                RadialGradient(
                    colors: [
                        Color(red: 0.35, green: 0.4, blue: 0.55).opacity(0.6),
                        Color(red: 0.2, green: 0.25, blue: 0.4).opacity(0.4),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 400
                )
                .frame(height: 400)
                .scaleEffect(glowScale)
                .blur(radius: 30)
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                ) {
                    glowScale = 1.15
                }
            }
        }
    }
}

// Option 2: Subtle vertical gradient (no animation)
struct SubtleVerticalGradient: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.08, blue: 0.12),
                Color(red: 0.12, green: 0.15, blue: 0.22),
                Color(red: 0.18, green: 0.22, blue: 0.35),
                Color(red: 0.25, green: 0.3, blue: 0.45)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// Option 3: Slow horizontal wave (stays away from center)
struct HorizontalWaveGradient: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.1)
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.3, blue: 0.45).opacity(0.4),
                    Color(red: 0.15, green: 0.2, blue: 0.35).opacity(0.3),
                    Color.clear
                ],
                startPoint: animateGradient ? .leading : .trailing,
                endPoint: animateGradient ? .trailing : .leading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 6)
                    .repeatForever(autoreverses: true)
                ) {
                    animateGradient.toggle()
                }
            }
        }
    }
}

// Option 4: Corner glow (stays in corners)
struct CornerGlowGradient: View {
    @State private var animateTop = false
    @State private var animateBottom = false
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .ignoresSafeArea()
            
            // Top corner glow
            VStack {
                HStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.35, blue: 0.5).opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                        .blur(radius: 40)
                        .offset(x: -100, y: -100)
                        .opacity(animateTop ? 0.6 : 0.3)
                    
                    Spacer()
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            // Bottom corner glow
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.35, green: 0.4, blue: 0.55).opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 250
                            )
                        )
                        .frame(width: 350, height: 350)
                        .blur(radius: 50)
                        .offset(x: 100, y: 100)
                        .opacity(animateBottom ? 0.7 : 0.4)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 4)
                .repeatForever(autoreverses: true)
            ) {
                animateTop.toggle()
            }
            withAnimation(
                .easeInOut(duration: 3.5)
                .repeatForever(autoreverses: true)
                .delay(0.5)
            ) {
                animateBottom.toggle()
            }
        }
    }
}

// Option 5: Ambient particles (very subtle)
struct AmbientParticlesGradient: View {
    @State private var particle1 = false
    @State private var particle2 = false
    @State private var particle3 = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.1),
                    Color(red: 0.1, green: 0.12, blue: 0.2),
                    Color(red: 0.15, green: 0.18, blue: 0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle floating orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.4, green: 0.45, blue: 0.6).opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 30)
                .offset(
                    x: particle1 ? 100 : -100,
                    y: particle1 ? -50 : 50
                )
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.35, green: 0.4, blue: 0.55).opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 40)
                .offset(
                    x: particle2 ? -80 : 80,
                    y: particle2 ? 100 : -100
                )
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.3, green: 0.35, blue: 0.5).opacity(0.18),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)
                .blur(radius: 35)
                .offset(
                    x: particle3 ? 120 : -120,
                    y: particle3 ? -80 : 80
                )
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
            ) {
                particle1.toggle()
            }
            withAnimation(
                .easeInOut(duration: 10)
                .repeatForever(autoreverses: true)
                .delay(1)
            ) {
                particle2.toggle()
            }
            withAnimation(
                .easeInOut(duration: 9)
                .repeatForever(autoreverses: true)
                .delay(2)
            ) {
                particle3.toggle()
            }
        }
    }
}

// Option 6: Breathing background (minimal movement)
struct BreathingGradient: View {
    @State private var breathe = false
    
    var body: some View {
        RadialGradient(
            colors: [
                Color(red: 0.15, green: 0.18, blue: 0.25),
                Color(red: 0.1, green: 0.12, blue: 0.18),
                Color(red: 0.05, green: 0.05, blue: 0.1)
            ],
            center: .center,
            startRadius: breathe ? 100 : 50,
            endRadius: breathe ? 600 : 500
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 5)
                .repeatForever(autoreverses: true)
            ) {
                breathe.toggle()
            }
        }
    }
}


// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingGradient()
    }
}
