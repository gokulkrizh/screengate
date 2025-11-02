import SwiftUI

// MARK: - Analytics View

struct AnalyticsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Analytics Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Track your digital wellness progress")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom)

                    // Placeholder for analytics content
                    VStack(spacing: 16) {
                        Text("Coming Soon")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)

                        Text("Detailed analytics and insights will be available in future updates. Track your intention completion rates, screen time patterns, and wellness progress.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)

                    // Mock stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        MockStatCard(
                            title: "Total Intentions",
                            value: "0",
                            icon: "brain.head.profile",
                            color: .purple
                        )

                        MockStatCard(
                            title: "Time Saved",
                            value: "0m",
                            icon: "clock.fill",
                            color: .orange
                        )

                        MockStatCard(
                            title: "Current Streak",
                            value: "0 days",
                            icon: "flame.fill",
                            color: .red
                        )

                        MockStatCard(
                            title: "Completion Rate",
                            value: "0%",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.vertical)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Mock Stat Card

struct MockStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(color).opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    AnalyticsView()
}