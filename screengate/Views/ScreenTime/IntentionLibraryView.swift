import SwiftUI
import Combine

// MARK: - Intention Library View

struct IntentionLibraryView: View {
    @StateObject private var viewModel = IntentionLibraryViewModel()
    @State private var selectedCategory: IntentionCategory?
    @State private var searchText: String = ""
    @State private var showIntention = false
    @State private var selectedIntention: IntentionActivity?
    @State private var showConfiguration = false
    @State private var configurationIntention: IntentionActivity?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView

                // Search Bar
                searchBarView

                // Category Filter
                categoryFilterView

                // Intentions Grid
                intentionsGridView

                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear {
            loadIntentions()
        }
        .fullScreenCover(isPresented: $showIntention) {
            if let intention = selectedIntention {
                SimpleIntentionView(intention: intention) {
                    showIntention = false
                }
            } else {
                // Fallback view in case intention is nil
                Text("No intention selected")
                    .padding()
            }
        }
        .sheet(isPresented: $showConfiguration) {
            if let intention = configurationIntention {
                IntentionConfigurationView(intention: intention)
            }
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Intention Library")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Browse and customize your mindful activities")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }

    // MARK: - Search Bar View

    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search intentions...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Category Filter View

    private var categoryFilterView: some View {
        VStack(spacing: 16) {
            Text("Categories")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // All Categories
                    CategoryChip(
                        title: "All",
                        icon: "square.grid.2x2",
                        color: .gray,
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }

                    // Individual Categories
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
    }

    // MARK: - Intentions Grid View

    private var intentionsGridView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Available Intentions")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(filteredIntentions.count) intentions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if filteredIntentions.isEmpty {
                EmptyStateView(
                    icon: "brain.head.profile",
                    title: "No Intentions Found",
                    subtitle: "Try adjusting your search or category filter"
                )
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(filteredIntentions, id: \.id) { intention in
                        IntentionCard(
                            intention: intention,
                            isFavorite: viewModel.isFavorite(intention)
                        ) {
                            toggleFavorite(intention)
                        } onConfigure: {
                            configureIntention(intention)
                        } onStart: {
                            startIntention(intention)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredIntentions: [IntentionActivity] {
        var intentions = viewModel.allIntentions

        // Filter by category
        if let category = selectedCategory {
            intentions = intentions.filter { $0.category == category }
        }

        // Filter by search text
        if !searchText.isEmpty {
            intentions = intentions.filter { intention in
                intention.title.localizedCaseInsensitiveContains(searchText) ||
                intention.description.localizedCaseInsensitiveContains(searchText) ||
                intention.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return intentions
    }

    // MARK: - Helper Methods

    private func loadIntentions() {
        viewModel.refreshIntentions()
    }

    private func toggleFavorite(_ intention: IntentionActivity) {
        viewModel.toggleFavorite(intention)
    }

    private func startIntention(_ intention: IntentionActivity) {
        print("🧘 Starting intention: \(intention.title)")
        print("🧘 Intention ID: \(intention.id)")
        print("🧘 Intention category: \(intention.category)")
        print("🧘 Intention duration: \(intention.duration)")
        selectedIntention = intention
        showIntention = true
        print("🧘 Show intention set to: \(showIntention)")
    }

    private func configureIntention(_ intention: IntentionActivity) {
        print("⚙️ Configuring intention: \(intention.title)")
        configurationIntention = intention
        showConfiguration = true
    }
}

// MARK: - Supporting Views

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : color.opacity(0.1))
            .foregroundColor(isSelected ? .white : color)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IntentionCard: View {
    let intention: IntentionActivity
    let isFavorite: Bool
    let onFavorite: () -> Void
    let onConfigure: () -> Void
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Header with Favorite Button
            HStack {
                Image(systemName: intention.category.iconName)
                    .font(.title3)
                    .foregroundColor(intention.category.swiftUIColor)

                Spacer()

                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                }
            }

            // Title and Description
            VStack(alignment: .leading, spacing: 4) {
                Text(intention.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)

                Text(intention.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Duration
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(formatDuration(intention.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Tags (show first 2)
                if !intention.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(intention.tags.prefix(2)), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(4)
                        }
                    }
                }
            }

            // Action Buttons
            HStack(spacing: 12) {
                // Start Now Button
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.caption)

                        Text("Start Now")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(intention.category.swiftUIColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())

                // Configure Button
                Button(action: onConfigure) {
                    HStack {
                        Text("Configure")
                            .fontWeight(.medium)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(intention.category.swiftUIColor.opacity(0.1))
                    .foregroundColor(intention.category.swiftUIColor)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Intention Configuration View

struct IntentionConfigurationView: View {
    let intention: IntentionActivity
    @Environment(\.dismiss) private var dismiss
    @State private var customDuration: Double = 300 // Default 5 minutes
    @State private var customInstructions: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: intention.category.iconName)
                            .font(.system(size: 50))
                            .foregroundColor(intention.category.swiftUIColor)

                        Text(intention.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(intention.description)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // Configuration Options
                    VStack(spacing: 20) {
                        // Duration Configuration
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration")
                                .font(.title2)
                                .fontWeight(.semibold)

                            HStack {
                                Text("\(Int(customDuration / 60)) minutes")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Spacer()

                                Slider(value: $customDuration, in: 60...1800, step: 60)
                                    .frame(maxWidth: 150)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)

                        // Custom Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Custom Instructions (Optional)")
                                .font(.title2)
                                .fontWeight(.semibold)

                            TextField("Add your own focus message...", text: $customInstructions, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3, reservesSpace: true)
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)

                        // Current Settings
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Settings")
                                .font(.title2)
                                .fontWeight(.semibold)

                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)

                                Text("Default: \(formatDuration(intention.duration))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Spacer()
                            }

                            if !intention.tags.isEmpty {
                                HStack {
                                    Image(systemName: "tag")
                                        .foregroundColor(.secondary)

                                    Text("Tags: \(intention.tags.joined(separator: ", "))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Configure Intention")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveConfiguration()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(intention.category.swiftUIColor)
                }
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func saveConfiguration() {
        // TODO: Save custom configuration to UserDefaults or Core Data
        print("💾 Saving configuration for \(intention.title):")
        print("   - Duration: \(customDuration) seconds")
        print("   - Custom Instructions: '\(customInstructions)'")
    }
}

// MARK: - Simple Intention View

struct SimpleIntentionView: View {
    let intention: IntentionActivity
    let onClose: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: intention.category.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(intention.category.swiftUIColor)

                    Text(intention.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(intention.description)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Duration info
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    Text("Duration: \(formatDuration(intention.duration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Content based on category
                intentionContentView

                Spacer()

                // Start button
                Button(action: {
                    print("🧘 Starting simple intention exercise")
                    onClose()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Start Exercise")
                            .fontWeight(.semibold)
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(intention.category.swiftUIColor)
                    .cornerRadius(16)
                }
                .padding(.horizontal)

                // Close button
                Button("Close") {
                    onClose()
                    dismiss()
                }
                .foregroundColor(.secondary)
                .padding()
            }
            .navigationTitle("Intention")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onClose()
                        dismiss()
                    }
                }
            }
        }
    }

    private var intentionContentView: some View {
        VStack(spacing: 16) {
            Text("Instructions")
                .font(.headline)
                .foregroundColor(.primary)

            switch intention.content {
            case .breathing(let content):
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Find a comfortable position")
                    Text("• Follow the breathing pattern")
                    Text("• Focus on your breath")
                    Text("• Complete \(content.cycles) cycles")
                }
                .font(.body)
                .foregroundColor(.secondary)

            case .mindfulness(let content):
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Sit comfortably and close your eyes")
                    Text("• Focus on the present moment")
                    Text("• Notice your thoughts without judgment")
                    Text("• Return to your breath when distracted")
                }
                .font(.body)
                .foregroundColor(.secondary)

            case .reflection(let content):
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Take a moment to reflect")
                    Text("• Consider the prompts provided")
                    Text("• Write down your thoughts")
                    Text("• Be honest and compassionate with yourself")
                }
                .font(.body)
                .foregroundColor(.secondary)

            case .movement(let content):
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Find a safe space to move")
                    Text("• Follow the guided movements")
                    Text("• Listen to your body")
                    Text("• Move at your own pace")
                }
                .font(.body)
                .foregroundColor(.secondary)

            case .quickBreak(let content):
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Step away from your current activity")
                    Text("• Take a moment to rest")
                    Text("• Refresh your mind and body")
                    Text("• Return with renewed focus")
                }
                .font(.body)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    NavigationView {
        IntentionLibraryView()
            .navigationTitle("Intentions")
            .navigationBarTitleDisplayMode(.inline)
    }
}