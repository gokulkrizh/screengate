import SwiftUI
import FamilyControls

struct AppListsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AppListManager.self) private var appListManager
    
    /// Selection mode: show only list cards for quick selection in block creation
    /// Management mode: show full CRUD UI with edit/delete actions
    var isSelectionMode: Bool = false
    var onSelect: ((AppList) -> Void)?
    
    @State private var showingManagement = false
    @State private var showingCreateList = false
    @State private var listToEdit: AppList?
    @State private var defaultListId: UUID?
    @State private var newlyCreatedListId: UUID?
    
    private let appTheme = AppTheme.shared
    
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.13, blue: 0.09)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    Text("App Lists")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Toggle management mode button (only in selection mode)
                    if isSelectionMode {
                        if showingManagement {
                            Button(action: { showingManagement = false }) {
                                Text("Done")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            .frame(width: 70)
                        } else {
                            Button(action: { showingManagement = true }) {
                                Text("Manage")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(appTheme.colors.primary)
                            }
                            .frame(width: 70)
                        }
                    } else {
                        Color.clear.frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                if appListManager.lists.isEmpty {
                    // Empty State
                    emptyStateView
                } else {
                    // List of app lists
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(appListManager.lists) { list in
                                AppListCard(
                                    list: list,
                                    isManagementMode: showingManagement || !isSelectionMode,
                                    isSelected: list.id == defaultListId,
                                    onSelect: {
                                        defaultListId = list.id
                                        try? appListManager.setAsDefault(list)
                                        onSelect?(list)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            dismiss()
                                        }
                                    },
                                    onEdit: {
                                        listToEdit = list
                                    }
                                )
                            }
                        }
                        .padding(20)
                    }
                    
                    // Create button (always visible)
                    Button(action: { showingCreateList = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text("New Block List")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(appTheme.colors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingCreateList) {
            CreateAppListView(appListManagerPassed: appListManager) { createdList in
                newlyCreatedListId = createdList.id
                try? appListManager.setAsDefault(createdList)
                onSelect?(createdList)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismiss()
                }
            }
        }
        .sheet(item: $listToEdit) { list in
            CreateAppListView(existingList: list, appListManagerPassed: appListManager)
        }
        .onAppear {
            // Load default list on appear
            if let defaultList = appListManager.lists.first(where: { $0.isDefault }) {
                defaultListId = defaultList.id
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Illustration
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 50))
                    .foregroundColor(appTheme.colors.primary)
            }
            
            // Title & Description
            VStack(spacing: 12) {
                Text("Create Your First App List")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Save time by creating reusable app groups. Select them quickly when creating blocks.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Create Button
            Button(action: { showingCreateList = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("New Block List")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(appTheme.colors.primary)
                .cornerRadius(27)
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
            
            Spacer()
        }
    }
}

// MARK: - App List Card

struct AppListCard: View {
    let list: AppList
    var isManagementMode: Bool = false
    var isSelected: Bool = false
    var onSelect: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    private let appTheme = AppTheme.shared
    
    var body: some View {
        Button(action: {
            if !isManagementMode {
                onSelect?()
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                Circle()
                    .fill(appTheme.colors.primary.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: list.icon)
                            .font(.system(size: 24))
                            .foregroundColor(appTheme.colors.primary)
                    )
                
                // Name & Badge
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(list.name)
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 8) {
                        // App icons preview
                        if list.hasApps {
                            HStack(spacing: -8) {
                                ForEach(Array(list.selection.applicationTokens).prefix(3), id: \.self) { _ in
                                    Circle()
                                        .fill(Color.blue.opacity(0.5))
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Image(systemName: "app.fill")
                                                .font(.system(size: 8))
                                                .foregroundColor(.white)
                                        )
                                        .overlay(Circle().stroke(Color(red: 0.09, green: 0.16, blue: 0.12), lineWidth: 1))
                                }
                            }
                        }
                        
                        // Category indicator
                        if list.hasCategories {
                            HStack(spacing: 4) {
                                Image(systemName: "square.stack.3d.up.fill")
                                    .font(.system(size: 12))
                                Text("Category")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Item count
                        Text("\(list.totalItemCount) item\(list.totalItemCount == 1 ? "" : "s")")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                if isManagementMode { 
                    // Edit button in management mode
                    Button(action: { onEdit?() }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18))
                            .foregroundColor(appTheme.colors.primary)
                    }
                } else {
                    // Radio button for selection
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? appTheme.colors.primary : Color.white.opacity(0.3))
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? appTheme.colors.primary : Color.clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
        }
    }
}

#Preview {
    AppListsView()
        .environment(AppListManager())
}
