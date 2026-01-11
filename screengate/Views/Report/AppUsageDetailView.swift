import SwiftUI

struct AppUsageDetailView: View {
    @Environment(\.dismiss) private var dismiss
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Instagram")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        
                        Text("Social & Entertainment")
                            .font(.system(size: 11, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Edit Limit")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(appTheme.colors.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(red: 0.06, green: 0.13, blue: 0.09).opacity(0.95))
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 0.5),
                    alignment: .bottom
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Icon and Total Time
                        VStack(spacing: 8) {
                            // App Icon with Badge
                            ZStack(alignment: .bottomTrailing) {
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.pink, Color.orange]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(width: 80, height: 80)
                                .cornerRadius(20)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                )
                                
                                Text("SOCIAL")
                                    .font(.system(size: 9, weight: .bold, design: .default))
                                    .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(appTheme.colors.primary)
                                    .cornerRadius(8)
                                    .offset(x: 4, y: 4)
                            }
                            .padding(.top, 24)
                            
                            // Total Time
                            Text("2h 14m")
                                .font(.system(size: 56, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .padding(.top, 8)
                            
                            // Change Indicator
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.down.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(appTheme.colors.primary)
                                
                                Text("12% less than yesterday")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(20)
                            
                            // Daily Average
                            Text("Daily Average: 1h 45m")
                                .font(.system(size: 11, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 4)
                        }
                        
                        // Hourly Activity Chart
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(appTheme.colors.primary)
                                    
                                    Text("Hourly Activity")
                                        .font(.system(size: 18, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                // Date Selector
                                HStack(spacing: 4) {
                                    Button(action: {}) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.5))
                                            .frame(width: 24, height: 24)
                                    }
                                    
                                    VStack(spacing: 0) {
                                        Text("OCT 24")
                                            .font(.system(size: 9, weight: .medium, design: .default))
                                            .foregroundColor(.white.opacity(0.5))
                                            .tracking(0.5)
                                        
                                        Text("Today")
                                            .font(.system(size: 12, weight: .bold, design: .default))
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 50)
                                    
                                    Button(action: {}) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.3))
                                            .frame(width: 24, height: 24)
                                    }
                                    .disabled(true)
                                }
                                .padding(4)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                )
                            }
                            
                            // Bar Chart
                            HStack(alignment: .bottom, spacing: 6) {
                                hourlyBar(hour: "6a", height: 0.20)
                                hourlyBar(hour: "9a", height: 0.65, isHighlight: true)
                                hourlyBar(hour: "12p", height: 0.40)
                                hourlyBar(hour: "3p", height: 0.30)
                                hourlyBar(hour: "6p", height: 0.85, isHighlight: true)
                                hourlyBar(hour: "9p", height: 0.50)
                                hourlyBar(hour: "12a", height: 0.15)
                            }
                            .frame(height: 192)
                        }
                        .padding(20)
                        .background(Color(red: 0.11, green: 0.18, blue: 0.13))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            statCard(icon: "hand.tap.fill", value: "42", label: "Pickups", color: .white.opacity(0.5))
                            statCard(icon: "nosign", value: "5", label: "Blocked Attempts", color: .red)
                            statCard(icon: "timer", value: "35m", label: "Longest Session", color: .white.opacity(0.5))
                            
                            // Progress Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "flag.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white.opacity(0.5))
                                        .frame(width: 32, height: 32)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(8)
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(Color.white.opacity(0.1), lineWidth: 3)
                                            .frame(width: 32, height: 32)
                                        
                                        Circle()
                                            .trim(from: 0, to: 0.75)
                                            .stroke(appTheme.colors.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                            .frame(width: 32, height: 32)
                                            .rotationEffect(.degrees(-90))
                                    }
                                }
                                
                                Text("75%")
                                    .font(.system(size: 32, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                
                                Text("Of Daily Limit")
                                    .font(.system(size: 12, weight: .medium, design: .default))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 128)
                            .background(Color(red: 0.11, green: 0.18, blue: 0.13))
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // This Week vs Last Week
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(appTheme.colors.primary)
                                
                                Text("This Week vs Last Week")
                                    .font(.system(size: 18, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 12) {
                                weekComparisonBar(day: "Mon", thisWeek: 0.6, lastWeek: 1.0, time: "2h 10m")
                                weekComparisonBar(day: "Tue", thisWeek: 0.45, lastWeek: 1.0, time: "1h 30m")
                                weekComparisonBar(day: "Wed", thisWeek: 0.8, lastWeek: 0.95, time: "2h 14m", isToday: true)
                            }
                            
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Text("View Full History")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(.white.opacity(0.4))
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(20)
                        .background(Color(red: 0.11, green: 0.18, blue: 0.13))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Block App Now Button
                        Button(action: {}) {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 18))
                                
                                Text("Block App Now")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func hourlyBar(hour: String, height: CGFloat, isHighlight: Bool = false) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(isHighlight ? appTheme.colors.primary : appTheme.colors.primary.opacity(0.3))
                .frame(height: 192 * height)
                .shadow(color: isHighlight ? appTheme.colors.primary.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 0)
            
            Text(hour)
                .font(.system(size: 10, weight: isHighlight ? .bold : .medium, design: .default))
                .foregroundColor(isHighlight ? .white : .white.opacity(0.4))
        }
    }
    
    private func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color == .red ? Color.red.opacity(0.2) : Color.white.opacity(0.05))
                .cornerRadius(8)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 128)
        .background(Color(red: 0.11, green: 0.18, blue: 0.13))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
    
    private func weekComparisonBar(day: String, thisWeek: CGFloat, lastWeek: CGFloat, time: String, isToday: Bool = false) -> some View {
        HStack(spacing: 12) {
            Text(day)
                .font(.system(size: 14, weight: isToday ? .bold : .medium, design: .default))
                .foregroundColor(isToday ? .white : .white.opacity(0.4))
                .frame(width: 32, alignment: .leading)
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(appTheme.colors.primary)
                        .frame(width: geometry.size.width * 0.4 * thisWeek)
                        .shadow(color: isToday ? appTheme.colors.primary.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 0)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: geometry.size.width * 0.4 * lastWeek)
                        .padding(.leading, 4)
                }
            }
            .frame(height: 8)
            
            Text(time)
                .font(.system(size: 12, weight: isToday ? .bold : .medium, design: .default))
                .foregroundColor(isToday ? appTheme.colors.primary : .white)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

#Preview {
    AppUsageDetailView()
}
