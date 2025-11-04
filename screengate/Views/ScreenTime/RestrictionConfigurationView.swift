import SwiftUI
import FamilyControls

// MARK: - Restriction Configuration View

struct RestrictionConfigurationView: View {
    // Use the same RestrictionViewModel from app selection
    @ObservedObject var viewModel: RestrictionViewModel
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
                    if !viewModel.restrictions.isEmpty {
                        appsConfigurationView
                    } else {
                        emptyStateView
                    }

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
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingIntentionSelector) {
                if let selectedApp = selectedApp {
                    IntentionSelectionView(
                        selectedAppIdentifier: selectedApp,
                        currentIntention: viewModel.restrictions.first { $0.bundleIdentifier == selectedApp }?.intentionAssignments.first
                    ) { intention in
                        // Update the intention for the selected app
                        if let index = viewModel.restrictions.firstIndex(where: { $0.bundleIdentifier == selectedApp }) {
                            if let intention = intention {
                                viewModel.restrictions[index].intentionAssignments = [intention]
                                viewModel.saveRestrictionsToSharedDefaults()
                            }
                        }
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

                Text("\(viewModel.restrictions.count) apps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVStack(spacing: 12) {
                ForEach(viewModel.restrictions, id: \.id) { restriction in
                    AppRestrictionCard(
                        appIdentifier: restriction.bundleIdentifier,
                        appName: restriction.name,
                        intention: restriction.intentionAssignments.first,
                        onTap: {
                            selectedApp = restriction.bundleIdentifier
                        },
                        onIntentionChange: {
                            selectedApp = restriction.bundleIdentifier
                            showingIntentionSelector = true
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

    }

// MARK: - App Restriction Card

struct AppRestrictionCard: View {
    let appIdentifier: String
    let appName: String
    let intention: IntentionActivity?
    let onTap: () -> Void
    let onIntentionChange: () -> Void

    
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
                    } else {
                        Text("No intention configured")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Intention Configuration Button
            Button(action: onIntentionChange) {
                HStack {
                    Image(systemName: intention?.category.iconName ?? "brain.head.profile")
                        .font(.caption)
                        .foregroundColor(intention?.category.swiftUIColor ?? .gray)

                    Text(intention?.title ?? "Configure Intention")
                        .font(.subheadline)
                        .foregroundColor(intention != nil ? .primary : .secondary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }

    private var statusColor: Color {
        if intention == nil {
            return .orange
        } else {
            return .green
        }
    }

    private var statusText: String {
        if intention == nil {
            return "Configure intention"
        } else {
            return "Intention configured"
        }
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
    RestrictionConfigurationView(viewModel: RestrictionViewModel())
}