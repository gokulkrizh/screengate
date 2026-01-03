import SwiftUI

/// Reusable Hero Image View Component
/// Displays an image with rounded corners and proper sizing
struct HeroImageView: View {
    private let appTheme = AppTheme.shared
    
    let imageName: String
    let height: CGFloat
    
    init(
        imageName: String,
        height: CGFloat = 280
    ) {
        self.imageName = imageName
        self.height = height
    }
    
    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(.all)
        }
        .frame(height: height)
        .cornerRadius(24)
        .padding(.horizontal, appTheme.spacing.large)
        .padding(.bottom, appTheme.spacing.large)
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        VStack {
            HeroImageView(imageName: "welcomScreen")
            Spacer()
        }
    }
}
