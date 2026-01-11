import SwiftUI

struct SetCustomDurationModal: View {
    @Binding var isPresented: Bool
    @State private var minutes: Int = 10
    @State private var seconds: Int = 30
    var onSetDuration: (Int) -> Void
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle
                VStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 5)
                }
                .frame(height: 20)
                
                // Header
                HStack(spacing: 0) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(width: 40, height: 40)
                    
                    Spacer()
                    
                    Text("Set custom duration")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Time Picker
                        ZStack {
                            // Highlight background
                            RoundedRectangle(cornerRadius: 12)
                                .fill(appTheme.colors.primary.opacity(0.08))
                                .frame(height: 80)
                                .border(appTheme.colors.primary.opacity(0.2), width: 1)
                            
                            HStack(spacing: 16) {
                                // Minutes Picker
                                VStack(spacing: 0) {
                                    TimePickerColumn(
                                        value: $minutes,
                                        range: 0...59,
                                        label: "min"
                                    )
                                }
                                
                                // Separator
                                Text(":")
                                    .font(.system(size: 36, weight: .bold, design: .default))
                                    .foregroundColor(.white.opacity(0.4))
                                
                                // Seconds Picker
                                VStack(spacing: 0) {
                                    TimePickerColumn(
                                        value: $seconds,
                                        range: 0...59,
                                        label: "sec"
                                    )
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        .frame(height: 200)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        
                        // Description
                        Text("Custom breaks allow you to fine-tune your focus cycles.")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                let totalSeconds = minutes * 60 + seconds
                                onSetDuration(totalSeconds)
                                isPresented = false
                            }) {
                                Text("Set Duration")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                                    .background(appTheme.colors.primary)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: { isPresented = false }) {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
    }
}

// MARK: - Time Picker Column
struct TimePickerColumn: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        VStack(spacing: 8) {
            // Scrollable column
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Padding for scroll effect
                        ForEach(range, id: \.self) { num in
                            Text(String(format: "%02d", num))
                                .font(.system(size: num == value ? 48 : 28, weight: num == value ? .bold : .semibold, design: .default))
                                .foregroundColor(num == value ? appTheme.colors.primary : .white.opacity(0.3))
                                .scaleEffect(num == value ? 1.2 : 0.8)
                                .id(num)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        value = num
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 40)
                }
                .onAppear {
                    proxy.scrollTo(value, anchor: .center)
                }
                .onChange(of: value) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            
            // Label
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold, design: .default))
                .tracking(0.5)
                .foregroundColor(appTheme.colors.primary.opacity(0.6))
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    return ZStack {
        Color(red: 0.06, green: 0.13, blue: 0.09).ignoresSafeArea()
        
        VStack {
            Spacer()
            
            SetCustomDurationModal(
                isPresented: $isPresented,
                onSetDuration: { duration in }
            )
        }
    }
}
