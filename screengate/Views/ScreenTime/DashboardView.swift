import SwiftUI

// MARK: - Dashboard View

struct DashboardView: View {
    @StateObject private var restrictionViewModel = RestrictionViewModel()
    @StateObject private var intentionViewModel = IntentionViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()

    // Tab navigation control
    @Binding var selectedTab: Int

    // Analytics sheet state
    @State private var showAnalytics = false

    init(selectedTab: Binding<Int> = .constant(0)) {
        self._selectedTab = selectedTab
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView

                // Quick Stats
                quickStatsView

                // Active Restrictions
                activeRestrictionsView

                // Recent Activity
                recentActivityView

                // Quick Actions
                quickActionsView

                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear {
            loadData()
        }
        .sheet(isPresented: $showAnalytics) {
            AnalyticsView()
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Screen Time Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Manage your digital wellbeing")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }

    // MARK: - Quick Stats View

    private var quickStatsView: some View {
        VStack(spacing: 16) {
            Text("Today's Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                // Active Restrictions
                StatCard(
                    title: "Active Restrictions",
                    value: "\(restrictionViewModel.restrictions.count)",
                    icon: "shield.fill",
                    color: .blue,
                    trend: nil
                )

                // Current Intention Status
                StatCard(
                    title: "Current Intention",
                    value: intentionViewModel.currentIntention?.title ?? "None",
                    icon: "brain.head.profile",
                    color: .purple,
                    trend: nil
                )
            }

            HStack(spacing: 16) {
                // Time Saved (placeholder)
                StatCard(
                    title: "Time Saved",
                    value: "0m",
                    icon: "clock.fill",
                    color: .orange,
                    trend: nil
                )

                // Notification Status
                StatCard(
                    title: "Notifications",
                    value: notificationViewModel.isNotificationEnabled ? "On" : "Off",
                    icon: "bell.fill",
                    color: notificationViewModel.isNotificationEnabled ? .green : .red,
                    trend: nil
                )
            }
        }
    }

    // MARK: - Active Restrictions View

    private var activeRestrictionsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Active Restrictions")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button("Manage") {
                    selectedTab = 1 // Navigate to Restrictions tab
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            if restrictionViewModel.restrictions.isEmpty {
                EmptyStateView(
                    icon: "shield.slash",
                    title: "No Active Restrictions",
                    subtitle: "Start by selecting apps to restrict"
                )
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(Array(restrictionViewModel.restrictions.prefix(4)), id: \.id) { restriction in
                        RestrictionCard(restriction: restriction)
                    }
                }
            }
        }
    }

    // MARK: - Recent Activity View

    private var recentActivityView: some View {
        VStack(spacing: 16) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Show placeholder for recent activity since we don't have completed intentions tracking yet
            EmptyStateView(
                icon: "clock.arrow.circlepath",
                title: "Activity Tracking",
                subtitle: "Your intention activity will appear here as you use the app"
            )
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }

    // MARK: - Quick Actions View

    private var quickActionsView: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "Add Apps",
                    subtitle: "Select apps to restrict",
                    icon: "plus.app.fill",
                    color: .blue
                ) {
                    selectedTab = 1 // Navigate to Restrictions tab
                }

                QuickActionCard(
                    title: "Quick Intention",
                    subtitle: "Start a mindful break",
                    icon: "brain.head.profile",
                    color: .purple
                ) {
                    selectedTab = 2 // Navigate to Intentions tab
                }

                QuickActionCard(
                    title: "View Analytics",
                    subtitle: "See your progress",
                    icon: "chart.bar.fill",
                    color: .green
                ) {
                    showAnalytics = true // Show analytics sheet
                }

                QuickActionCard(
                    title: "Settings",
                    subtitle: "Manage preferences",
                    icon: "gearshape.fill",
                    color: .gray
                ) {
                    selectedTab = 3 // Navigate to Settings tab
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func loadData() {
        Task {
            // Load restrictions data
            restrictionViewModel.checkAuthorizationStatus()
            notificationViewModel.checkNotificationAuthorization()
        }
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()

                if let trend = trend {
                    Text(trend)
                        .font(.caption)
                        .foregroundColor(trend.hasPrefix("+") ? .green : .red)
                }
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(color).opacity(0.1))
        .cornerRadius(12)
    }
}

struct RestrictionCard: View {
    let restriction: AppRestriction

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "app.fill")
                .font(.title2)
                .foregroundColor(.blue)

            Text(restriction.bundleIdentifier)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Show placeholder for intention assignment since this property doesn't exist yet
            Text("Intention assigned")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let intention: IntentionActivity

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(intention.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Completed recently")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(color).opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    DashboardView()
}