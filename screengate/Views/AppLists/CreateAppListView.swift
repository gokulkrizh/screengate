import SwiftUI
import FamilyControls

struct CreateAppListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppListManager.self) private var appListManager
    
    var existingList: AppList?
    var appListManagerPassed: AppListManager? = nil  // For explicit passing from parent
    
    @State private var listName = ""
    @State private var selectedIcon = "flame.fill"
    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    @State private var showActivityPicker = false
    @State private var showIconPicker = false
    @State private var showDeleteConfirmation = false
    @State private var error: String?
    @State private var isSaving = false
    
    private let appTheme = AppTheme.shared
    private var manager: AppListManager { appListManagerPassed ?? appListManager }
    
    // Common SF Symbols for app lists
    private let availableIcons = [
        "flame.fill", "star.fill", "heart.fill", "bolt.fill",
        "moon.fill", "sun.max.fill", "timer", "calendar",
        "app.fill", "square.stack.3d.up.fill", "tray.fill", "folder.fill"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.13, blue: 0.09)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text(existingList == nil ? "New Block List" : "Edit Block List")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Delete button (only in edit mode)
                            if existingList != nil {
                                Button(action: { showDeleteConfirmation = true }) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                            }
                            
                            Button(action: saveList) {
                                Text("Save")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(canSave ? appTheme.colors.primary : Color.white.opacity(0.3))
                            }
                            .disabled(!canSave || isSaving)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Icon Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Icon")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(.white)
                                
                                Button(action: { showIconPicker.toggle() }) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(appTheme.colors.primary.opacity(0.2))
                                            .frame(width: 48, height: 48)
                                            .overlay(
                                                Image(systemName: selectedIcon)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(appTheme.colors.primary)
                                            )
                                        
                                        Text("Choose Icon")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.white.opacity(0.3))
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                                
                                // Icon Picker Grid
                                if showIconPicker {
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                                        ForEach(availableIcons, id: \.self) { icon in
                                            Button(action: {
                                                selectedIcon = icon
                                                showIconPicker = false
                                            }) {
                                                Circle()
                                                    .fill(selectedIcon == icon ? appTheme.colors.primary.opacity(0.3) : Color.white.opacity(0.05))
                                                    .frame(width: 60, height: 60)
                                                    .overlay(
                                                        Image(systemName: icon)
                                                            .font(.system(size: 24))
                                                            .foregroundColor(selectedIcon == icon ? appTheme.colors.primary : .white)
                                                    )
                                            }
                                        }
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.03))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // List Name
                            VStack(alignment: .leading, spacing: 12) {
                                Text("List Name")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(.white)
                                
                                TextField("", text: $listName, prompt: Text("Social Media").foregroundColor(Color.white.opacity(0.3)))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(16)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                            }
                            
                            // Apps Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Apps")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(.white)
                                
                                Button(action: { showActivityPicker = true }) {
                                    HStack(spacing: 12) {
                                        // Stacked Icons from selection
                                        HStack(spacing: -12) {
                                            if !activitySelection.applicationTokens.isEmpty {
                                                ForEach(Array(activitySelection.applicationTokens).prefix(3), id: \.self) { _ in
                                                    Circle()
                                                        .fill(Color.blue.opacity(0.7))
                                                        .frame(width: 40, height: 40)
                                                        .overlay(
                                                            Image(systemName: "app.fill")
                                                                .font(.system(size: 16))
                                                                .foregroundColor(.white)
                                                        )
                                                        .overlay(Circle().stroke(Color(red: 0.09, green: 0.16, blue: 0.12), lineWidth: 2))
                                                }
                                                
                                                if activitySelection.applicationTokens.count > 3 {
                                                    Text("+\(activitySelection.applicationTokens.count - 3)")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.white.opacity(0.6))
                                                }
                                            } else {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(appTheme.colors.primary)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(activitySelection.applicationTokens.isEmpty ? "Select Apps" : "\(activitySelection.applicationTokens.count) apps selected")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            if activitySelection.applicationTokens.isEmpty {
                                                Text("Tap to choose apps to block")
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(Color.white.opacity(0.5))
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.white.opacity(0.3))
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Categories Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Categories")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(.white)
                                
                                Button(action: { showActivityPicker = true }) {
                                    HStack(spacing: 12) {
                                        // Category Icon
                                        HStack(spacing: -12) {
                                            if !activitySelection.categoryTokens.isEmpty {
                                                Image(systemName: "square.stack.3d.up.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(appTheme.colors.primary)
                                            } else {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 32))
                                                    .foregroundColor(appTheme.colors.primary)
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(activitySelection.categoryTokens.isEmpty ? "Select Categories" : "\(activitySelection.categoryTokens.count) categories selected")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            if activitySelection.categoryTokens.isEmpty {
                                                Text("Tap to choose categories to block")
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundColor(Color.white.opacity(0.5))
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color.white.opacity(0.3))
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Error Message
                            if let error = error {
                                Text(error)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(appTheme.colors.error)
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(appTheme.colors.error.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .sheet(isPresented: $showActivityPicker) {
                FamilyActivitySelectionView(selection: $activitySelection)
            }
            .onAppear {
                if let existing = existingList {
                    listName = existing.name
                    selectedIcon = existing.icon
                    activitySelection = existing.selection
                }
            }
        }
        .confirmationDialog("Delete Block List", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteList()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(existingList?.name ?? "")?\" This action cannot be undone.")
        }
    }
    
    // MARK: - Validation
    
    private var canSave: Bool {
        return !listName.trimmingCharacters(in: .whitespaces).isEmpty &&
               (!activitySelection.applicationTokens.isEmpty || !activitySelection.categoryTokens.isEmpty)
    }
    
    // MARK: - Save Action
    
    private func saveList() {
        guard canSave else { return }
        
        isSaving = true
        error = nil
        
        do {
            if let existing = existingList {
                // Update existing list
                var updatedList = existing
                updatedList.name = listName.trimmingCharacters(in: .whitespaces)
                updatedList.icon = selectedIcon
                updatedList.selection = activitySelection
                
                try manager.updateList(updatedList)
            } else {
                // Create new list
                let newList = AppList(
                    name: listName.trimmingCharacters(in: .whitespaces),
                    icon: selectedIcon,
                    selection: activitySelection
                )
                
                try manager.createList(newList)
            }
            
            dismiss()
        } catch {
            self.error = error.localizedDescription
            isSaving = false
        }
    }
    
    // MARK: - Delete Action
    
    private func deleteList() {
        guard let listToDelete = existingList else { return }
        
        do {
            try manager.deleteList(listToDelete)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

#Preview {
    CreateAppListView()
        .environment(AppListManager())
}
