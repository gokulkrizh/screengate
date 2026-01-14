import SwiftUI

/// Input field component with icon and placeholder for block names
struct BlockNameTextField: View {
    @Binding var text: String
    let icon: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 20, height: 20)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.4))
                }
        }
        .padding(16)
        .background(Color(red: 0.09, green: 0.16, blue: 0.12))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Helper extension for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        BlockNameTextField(
            text: .constant(""),
            icon: "timer",
            placeholder: "Block Name"
        )
        
        BlockNameTextField(
            text: .constant("Deep Work Session"),
            icon: "timer",
            placeholder: "Block Name"
        )
    }
    .padding()
    .background(Color(red: 0.06, green: 0.13, blue: 0.09))
    .preferredColorScheme(.dark)
}
