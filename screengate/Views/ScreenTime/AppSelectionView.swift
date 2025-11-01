import SwiftUI
import FamilyControls

// MARK: - App Selection View

struct AppSelectionView: View {
    @StateObject private var viewModel = RestrictionViewModel()
    @State private var showFamilyActivityPicker = false
    @State private var selectedApps = FamilyActivitySelection()
    @State private var showingConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView

                // Current Selection
                currentSelectionView

                // Selection Actions
                selectionActionsView

                // Instructions
                instructionsView

                Spacer(minLength: 50)
            }
            .padding()
        }
        .sheet(isPresented: $showFamilyActivityPicker) {
            FamilyActivityPicker(
                selection: $selectedApps
            )
        }
        .alert("Confirm App Selection", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) {
                showingConfirmation = false
            }
            Button("Save Selection") {
                saveSelection()
                showingConfirmation = false
            }
        } message: {
            Text("Are you sure you want to restrict \(selectedApps.applicationTokens.count + selectedApps.categoryTokens.count) selected apps/categories?")
        }
        .onAppear {
            loadCurrentSelection()
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Select Apps to Restrict")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Choose which apps and categories you'd like to manage with Screen Time")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }

    // MARK: - Current Selection View

    private var currentSelectionView: some View {
        VStack(spacing: 16) {
            Text("Current Selection")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            if hasNoSelection {
                EmptyStateView(
                    icon: "app.badge.plus",
                    title: "No Apps Selected",
                    subtitle: "Tap 'Browse Apps' to start selecting apps and categories"
                )
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    // Apps Summary
                    if !selectedApps.applicationTokens.isEmpty {
                        HStack {
                            Image(systemName: "apps.iphone")
                                .foregroundColor(.blue)

                            Text("\(selectedApps.applicationTokens.count) apps selected")
                                .font(.subheadline)

                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Categories Summary
                    if !selectedApps.categoryTokens.isEmpty {
                        HStack {
                            Image(systemName: "square.stack.3d.up")
                                .foregroundColor(.green)

                            Text("\(selectedApps.categoryTokens.count) categories selected")
                                .font(.subheadline)

                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }

                    // Preview of Selected Items
                    if hasSelection {
                        Button("View Selected Items") {
                            // Show detailed view of selected items
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    // MARK: - Selection Actions View

    private var selectionActionsView: some View {
        VStack(spacing: 16) {
            Text("Actions")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                Button(action: {
                    showFamilyActivityPicker = true
                }) {
                    HStack {
                        Image(systemName: "square.grid.2x2")
                            .font(.title3)

                        Text("Browse Apps")
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

                Button(action: {
                    clearSelection()
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.title3)

                        Text("Clear Selection")
                            .fontWeight(.medium)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(hasNoSelection)

                Button(action: {
                    showingConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.shield")
                            .font(.title3)

                        Text("Save & Configure Restrictions")
                            .fontWeight(.medium)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(hasNoSelection)
            }
        }
    }

    // MARK: - Instructions View

    private var instructionsView: some View {
        VStack(spacing: 16) {
            Text("How It Works")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                InstructionStep(
                    number: 1,
                    title: "Select Apps & Categories",
                    description: "Choose which specific apps and app categories you want to manage"
                )

                InstructionStep(
                    number: 2,
                    title: "Configure Intentions",
                    description: "Assign personalized mindful activities that appear when you try to access restricted apps"
                )

                InstructionStep(
                    number: 3,
                    title: "Set Schedules",
                    description: "Define when restrictions should be active and for how long"
                )

                InstructionStep(
                    number: 4,
                    title: "Track Progress",
                    description: "Monitor your screen time habits and intention completion rates"
                )
            }
        }
    }

    // MARK: - Helper Properties

    private var hasNoSelection: Bool {
        selectedApps.applicationTokens.isEmpty && selectedApps.categoryTokens.isEmpty
    }

    private var hasSelection: Bool {
        !hasNoSelection
    }

    // MARK: - Helper Methods

    
    private func loadCurrentSelection() {
        // Load current selection from ViewModels
        Task {
            viewModel.loadRestrictions()
            // Convert existing restrictions to FamilyActivitySelection if needed
        }
    }

    private func saveSelection() {
        Task {
            viewModel.saveSelection(selectedApps)
            print("✅ Saved app selection with \(selectedApps.applicationTokens.count) apps and \(selectedApps.categoryTokens.count) categories")
        }
    }

    private func clearSelection() {
        selectedApps = FamilyActivitySelection()
    }
}

// MARK: - Supporting Views

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step Number
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.blue)
                .clipShape(Circle())

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        AppSelectionView()
            .navigationTitle("App Selection")
            .navigationBarTitleDisplayMode(.inline)
    }
}