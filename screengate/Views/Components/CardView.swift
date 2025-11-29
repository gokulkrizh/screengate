import SwiftUI

/// Container view with card styling
struct CardView<Content: View>: View {
    let content: Content
    var backgroundColor: Color = .focusCard
    var shadowColor: Color = .black.opacity(0.15)
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .cardStyle()
    }
}

/// Minimal card variant without shadow
struct MinimalCardView<Content: View>: View {
    let content: Content
    var backgroundColor: Color = .focusCard
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(FocusClubSpacing.base)
            .background(backgroundColor)
            .cornerRadius(FocusClubSpacing.cardCornerRadius)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Card Title")
                    .titleStyle()
                Text("This is card content")
                    .bodyStyle()
                    .foregroundColor(.focusTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        MinimalCardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Minimal Card")
                    .titleStyle()
                Text("Without shadow")
                    .bodyStyle()
                    .foregroundColor(.focusTextSecondary)
            }
        }
    }
    .screenBackground()
    .screenHorizontalPadding()
}
