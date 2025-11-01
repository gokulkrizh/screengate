import SwiftUI

// MARK: - Intention Library View

struct IntentionLibraryView: View {
    @StateObject private var viewModel = IntentionLibraryViewModel()
    @State private var selectedCategory: IntentionCategory?
    @State private var searchText: String = ""

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
                            // Navigate to configuration
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


#Preview {
    NavigationView {
        IntentionLibraryView()
            .navigationTitle("Intentions")
            .navigationBarTitleDisplayMode(.inline)
    }
}