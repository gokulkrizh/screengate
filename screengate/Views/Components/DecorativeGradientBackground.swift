import SwiftUI

/// Reusable Decorative Gradient Background Component
/// Adds animated gradient blobs to the background
struct DecorativeGradientBackground: View {
    private let appTheme = AppTheme.shared
    
    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 0) {
                    Circle()
                        .fill(appTheme.colors.primary.opacity(0.2))
                        .blur(radius: 100)
                        .frame(width: 300, height: 300)
                    Spacer()
                }
                .offset(x: 150, y: -60)
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Circle()
                        .fill(appTheme.colors.primary.opacity(0.1))
                        .blur(radius: 80)
                        .frame(width: 250, height: 250)
                }
                .offset(x: 100, y: 50)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        DecorativeGradientBackground()
    }
}
