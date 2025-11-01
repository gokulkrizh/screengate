import SwiftUI
import FamilyControls

// MARK: - Restriction Configuration View

struct RestrictionConfigurationView: View {
    @StateObject private var viewModel = RestrictionConfigurationViewModel()
    @State private var selectedApp: String?
    @State private var showingIntentionSelector = false
    @State private var showingScheduleConfig = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView

                    // Apps List
                    if !viewModel.restrictedApps.isEmpty {
                        appsConfigurationView
                    } else {
                        emptyStateView
                    }

                    // Add App Button
                    addAppButton

                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("App Restrictions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveConfiguration()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadConfiguration()
            }
            .sheet(isPresented: $showingIntentionSelector) {
                if let selectedApp = selectedApp {
                    IntentionSelectionView(
                        selectedAppIdentifier: selectedApp,
                        currentIntention: viewModel.getIntention(for: selectedApp)
                    ) { intention in
                        viewModel.setIntention(intention, for: selectedApp)
                    }
                }
            }
            .sheet(isPresented: $showingScheduleConfig) {
                if let selectedApp = selectedApp {
                    ScheduleConfigurationView(
                        selectedAppIdentifier: selectedApp,
                        currentScheduleId: viewModel.getScheduleId(for: selectedApp)
                    ) { scheduleId in
                        viewModel.setSchedule(scheduleId, for: selectedApp)
                    }
                }
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Configure App Restrictions")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Assign intentions and schedules to specific apps")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }

    // MARK: - Apps Configuration View

    private var appsConfigurationView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Restricted Apps")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(viewModel.restrictedApps.count) apps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVStack(spacing: 12) {
                ForEach(viewModel.restrictedApps, id: \.self) { appIdentifier in
                    AppRestrictionCard(
                        appIdentifier: appIdentifier,
                        intention: viewModel.getIntention(for: appIdentifier),
                        scheduleId: viewModel.getConfiguration(for: appIdentifier)?.scheduleId,
                        onTap: {
                            selectedApp = appIdentifier
                        },
                        onIntentionChange: {
                            selectedApp = appIdentifier
                            showingIntentionSelector = true
                        },
                        onScheduleChange: {
                            selectedApp = appIdentifier
                            showingScheduleConfig = true
                        },
                        onRemove: {
                            viewModel.removeRestriction(for: appIdentifier)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "app.badge.checkmark")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("No Restricted Apps")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add apps to restrict and assign intentions to help you pause mindfully")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 40)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Add App Button

    private var addAppButton: some View {
        Button(action: {
            // Navigate to app selection
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)

                Text("Add App to Restrict")
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helper Methods

    private func loadConfiguration() {
        viewModel.loadConfiguration()
    }

    private func saveConfiguration() {
        Task {
            await viewModel.saveConfiguration()
            dismiss()
        }
    }
}

// MARK: - App Restriction Card

struct AppRestrictionCard: View {
    let appIdentifier: String
    let intention: IntentionActivity?
    let scheduleId: String?
    let onTap: () -> Void
    let onIntentionChange: () -> Void
    let onScheduleChange: () -> Void
    let onRemove: () -> Void

    @State private var appName: String = "Unknown App"

    var body: some View {
        VStack(spacing: 16) {
            // App Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appName)
                        .font(.headline)
                        .fontWeight(.semibold)

                    if let intention = intention {
                        Text(intention.title)
                            .font(.caption)
                            .foregroundColor(intention.category.swiftUIColor)
                    }
                }

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }

            // Configuration Buttons
            HStack(spacing: 12) {
                // Intention Button
                Button(action: onIntentionChange) {
                    HStack(spacing: 6) {
                        Image(systemName: intention?.category.iconName ?? "brain.head.profile")
                            .font(.caption)

                        Text(intention?.title ?? "Assign Intention")
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((intention?.category.swiftUIColor ?? .gray).opacity(0.1))
                    .foregroundColor(intention?.category.swiftUIColor ?? .gray)
                    .cornerRadius(6)
                }

                Spacer()

                // Schedule Button
                Button(action: onScheduleChange) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)

                        Text(scheduleText)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(6)
                }
            }

            // Status Indicator
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if scheduleId != nil {
                    Text("Scheduled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onAppear {
            loadAppName()
        }
    }

    private var scheduleText: String {
        guard scheduleId != nil else {
            return "Always"
        }
        return "Scheduled"
    }

    private var statusColor: Color {
        if intention == nil {
            return .orange
        } else if scheduleId != nil {
            return .green
        } else {
            return .blue
        }
    }

    private var statusText: String {
        if intention == nil {
            return "Intention required"
        } else if scheduleId != nil {
            return "Restriction active"
        } else {
            return "Configured"
        }
    }

    private func loadAppName() {
        // In a real implementation, this would load the app name from the identifier
        // For now, we'll use a placeholder or extract from identifier
        appName = appIdentifier.isEmpty ? "Unknown App" : appIdentifier
    }
}

// MARK: - Intention Selection View

struct IntentionSelectionView: View {
    let selectedAppIdentifier: String
    let currentIntention: IntentionActivity?
    let onIntentionSelected: (IntentionActivity?) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedIntention: IntentionActivity?
    @State private var selectedCategory: IntentionCategory?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Select Intention")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Choose a mindful activity for when this app is blocked")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom)

                    // Category Filter
                    categoryFilterView

                    // Intentions List
                    intentionsListView

                    // No Intention Option
                    noIntentionOption
                }
                .padding()
            }
            .navigationTitle("Select Intention")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onIntentionSelected(selectedIntention)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedIntention = currentIntention
            }
        }
    }

    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    color: .gray,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(IntentionCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.displayName,
                        icon: category.iconName,
                        color: category.swiftUIColor,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var intentionsListView: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredIntentions, id: \.id) { intention in
                IntentionSelectionRow(
                    intention: intention,
                    isSelected: selectedIntention?.id == intention.id
                ) {
                    selectedIntention = intention
                }
            }
        }
    }

    private var noIntentionOption: some View {
        Button(action: {
            selectedIntention = nil
        }) {
            HStack {
                Image(systemName: "minus.circle")
                    .foregroundColor(.red)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text("No Intention")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Block the app without any mindfulness activity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if selectedIntention == nil {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var filteredIntentions: [IntentionActivity] {
        let allIntentions = IntentionLibraryManager.shared.getAllIntentions()

        if let category = selectedCategory {
            return allIntentions.filter { $0.category == category }
        } else {
            return allIntentions
        }
    }
}

// MARK: - Intention Selection Row

struct IntentionSelectionRow: View {
    let intention: IntentionActivity
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: intention.category.iconName)
                    .font(.title3)
                    .foregroundColor(intention.category.swiftUIColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(intention.title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(intention.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RestrictionConfigurationView()
}