import SwiftUI

/// Bottom gradient fade container with content, typically used for buttons at bottom of screen
struct BottomGradientContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color(red: 0.06, green: 0.13, blue: 0.09),
                    Color(red: 0.06, green: 0.13, blue: 0.09)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            
            content
                .background(Color(red: 0.06, green: 0.13, blue: 0.09))
        }
        .zIndex(20)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09)
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            BottomGradientContainer {
                VStack(spacing: 8) {
                    PrimaryButton(title: "Continue") {
                        print("Tapped")
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
