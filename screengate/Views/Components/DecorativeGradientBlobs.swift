import SwiftUI

/// Decorative gradient blobs used as background decoration in onboarding screens
struct DecorativeGradientBlobs: View {
    private let appTheme = AppTheme.shared
    
    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 0) {
                    Circle()
                        .fill(appTheme.colors.primary.opacity(0.05))
                        .blur(radius: 120)
                        .frame(width: 320, height: 320)
                    Spacer()
                }
                .offset(x: 120, y: -100)
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Circle()
                        .fill(appTheme.colors.primary.opacity(0.08))
                        .blur(radius: 100)
                        .frame(width: 280, height: 280)
                }
                .offset(x: 80, y: 80)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        DecorativeGradientBlobs()
    }
}
