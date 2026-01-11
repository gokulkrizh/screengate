import SwiftUI

struct ReportView: View {
    @State private var selectedPeriod = "Daily"
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Report")
                        .font(.system(size: 36, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Period Selector
                    HStack(spacing: 0) {
                        periodButton("Daily")
                        periodButton("Weekly")
                        periodButton("Monthly")
                    }
                    .padding(6)
                    .background(Color(red: 0.11, green: 0.18, blue: 0.13))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // Total Screen Time Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TOTAL SCREEN TIME")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(1)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("4")
                                .font(.system(size: 56, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            Text("h")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                            Text(" 12")
                                .font(.system(size: 56, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            Text("m")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(appTheme.colors.primary)
                                
                                Text("12%")
                                    .font(.system(size: 14, weight: .bold, design: .default))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(appTheme.colors.primary.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(appTheme.colors.primary.opacity(0.2), lineWidth: 1)
                            )
                            
                            Text("vs last week")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .padding(24)
                    .background(Color(red: 0.11, green: 0.18, blue: 0.13))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Activity Chart
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Activity")
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 8) {
                                    Text("DAILY AVG")
                                        .font(.system(size: 10, weight: .bold, design: .default))
                                        .foregroundColor(.white.opacity(0.4))
                                        .tracking(0.5)
                                    
                                    Text("3h 20m")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        
                        // Bar Chart
                        HStack(alignment: .bottom, spacing: 12) {
                            barItem(day: "MON", height: 0.45, isToday: false)
                            barItem(day: "TUE", height: 0.62, isToday: false)
                            barItem(day: "WED", height: 0.30, isToday: false)
                            barItem(day: "THU", height: 0.85, isToday: true)
                            barItem(day: "FRI", height: 0.55, isToday: false)
                            barItem(day: "SAT", height: 0.75, isToday: false)
                            barItem(day: "SUN", height: 0.40, isToday: false)
                        }
                        .frame(height: 200)
                    }
                    .padding(24)
                    .background(Color(red: 0.11, green: 0.18, blue: 0.13))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Focus Streak
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Focus Streak")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(appTheme.colors.primary)
                                
                                Text("12 Days")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(appTheme.colors.primary.opacity(0.1))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(appTheme.colors.primary.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Calendar Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                            ForEach(0..<35) { index in
                                streakDay(index: index)
                            }
                        }
                        
                        // Legend
                        HStack {
                            Text("Contribution")
                                .font(.system(size: 11, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                legendItem(color: Color(red: 0.16, green: 0.25, blue: 0.19), label: "Off")
                                legendItem(color: appTheme.colors.primary.opacity(0.5), label: "Good")
                                legendItem(color: appTheme.colors.primary, label: "Perfect")
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .background(Color(red: 0.11, green: 0.18, blue: 0.13))
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Top Apps
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Top Apps")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            NavigationLink(destination: AppUsageDetailView()) {
                                appCard(
                                    icon: "camera.fill",
                                    gradient: [Color.purple, Color.pink],
                                    name: "Instagram",
                                    category: "Social",
                                    time: "1h 30m",
                                    change: "+15%",
                                    isIncrease: true,
                                    progress: 0.65
                                )
                            }
                            
                            appCard(
                                icon: "play.fill",
                                gradient: [Color.red, Color(red: 0.8, green: 0.2, blue: 0.2)],
                                name: "YouTube",
                                category: "Entertainment",
                                time: "45m",
                                change: "-5%",
                                isIncrease: false,
                                progress: 0.35
                            )
                            
                            appCard(
                                icon: "envelope.fill",
                                gradient: [Color.blue, Color(red: 0.3, green: 0.5, blue: 0.9)],
                                name: "Mail",
                                category: "Productivity",
                                time: "20m",
                                change: "+12%",
                                isIncrease: true,
                                progress: 0.20
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func periodButton(_ period: String) -> some View {
        Button(action: { selectedPeriod = period }) {
            Text(period)
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundColor(selectedPeriod == period ? appTheme.colors.primary : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(selectedPeriod == period ? Color(red: 0.16, green: 0.25, blue: 0.19) : Color.clear)
                .cornerRadius(10)
        }
    }
    
    private func barItem(day: String, height: CGFloat, isToday: Bool) -> some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(isToday ? appTheme.colors.primary : appTheme.colors.primary.opacity(0.6))
                .frame(height: 200 * height)
                .shadow(color: isToday ? appTheme.colors.primary.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 0)
            
            Text(day)
                .font(.system(size: 10, weight: .bold, design: .default))
                .foregroundColor(isToday ? appTheme.colors.primary : .white.opacity(0.4))
                .tracking(0.5)
        }
    }
    
    private func streakDay(index: Int) -> some View {
        let patterns: [Color?] = [
            Color(red: 0.16, green: 0.25, blue: 0.19), appTheme.colors.primary.opacity(0.4), appTheme.colors.primary,
            Color(red: 0.16, green: 0.25, blue: 0.19), appTheme.colors.primary.opacity(0.6), appTheme.colors.primary, appTheme.colors.primary,
            appTheme.colors.primary, appTheme.colors.primary, Color(red: 0.16, green: 0.25, blue: 0.19),
            Color(red: 0.16, green: 0.25, blue: 0.19), appTheme.colors.primary.opacity(0.3), appTheme.colors.primary.opacity(0.8), appTheme.colors.primary,
            appTheme.colors.primary, Color(red: 0.16, green: 0.25, blue: 0.19), appTheme.colors.primary, appTheme.colors.primary,
            appTheme.colors.primary, Color(red: 0.16, green: 0.25, blue: 0.19), Color(red: 0.16, green: 0.25, blue: 0.19),
            appTheme.colors.primary.opacity(0.5), appTheme.colors.primary, appTheme.colors.primary,
            Color(red: 0.16, green: 0.25, blue: 0.19), appTheme.colors.primary.opacity(0.2), appTheme.colors.primary,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
        ]
        
        return RoundedRectangle(cornerRadius: 6)
            .fill(patterns[index] ?? Color.clear)
            .frame(height: 32)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(patterns[index] == nil ? Color.white.opacity(0.1) : Color.clear, lineWidth: 1)
                    .opacity(patterns[index] == nil ? 0.3 : 0)
            )
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.4))
        }
    }
    
    private func appCard(icon: String, gradient: [Color], name: String, category: String, time: String, change: String, isIncrease: Bool, progress: CGFloat) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(width: 48, height: 48)
                        .cornerRadius(16)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                // Name and Category
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Text(category)
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                // Time and Change
                VStack(alignment: .trailing, spacing: 4) {
                    Text(time)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 2) {
                        Image(systemName: isIncrease ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isIncrease ? .red : appTheme.colors.primary)
                        
                        Text(change)
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .foregroundColor(isIncrease ? .red : appTheme.colors.primary)
                    }
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.2))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(appTheme.colors.primary)
                        .frame(width: geometry.size.width * progress, height: 10)
                        .shadow(color: appTheme.colors.primary.opacity(0.5), radius: 8, x: 0, y: 0)
                }
            }
            .frame(height: 10)
        }
        .padding(20)
        .background(Color(red: 0.11, green: 0.18, blue: 0.13))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    ReportView()
}
