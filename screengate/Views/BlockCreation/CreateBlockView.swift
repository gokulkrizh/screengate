import SwiftUI

struct CreateBlockView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(BlockManager.self) var blockManager
    @State private var selectedBlockType: BlockType = .scheduled
    private let appTheme = AppTheme.shared
    
    let onScheduled: () -> Void
    let onOpenLimit: () -> Void
    let onAppTimeLimit: () -> Void
    let onBlockNow: () -> Void
    
    enum BlockType: String {
        case scheduled
        case openLimit = "open_limit"
        case appTimeLimit = "app_time_limit"
        case blockNow = "block_now"
    }
    
    /// Check if a blockNow is already active
    private var isBlockNowActive: Bool {
        blockManager.blocks.contains { block in
            block.type == .blockNow && block.isActive && !block.isPaused
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)
                }
                
                Spacer()
                
                Text("New Block")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Spacer for alignment
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 12)
            
            // Main Content
            VStack(alignment: .leading, spacing: 20) {
                // Headline
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 0) {
                        Text("Choose your")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    Text("discipline strategy")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(appTheme.colors.primary)
                    
                    Text("Select how you want to limit your screen time today.")
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.5))
                        .lineSpacing(2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Selection Cards
                VStack(spacing: 12) {
                    blockTypeCard(
                        icon: "calendar",
                        title: "Scheduled",
                        subtitle: "Plan ahead. Set fixed times.",
                        type: .scheduled
                    )
                    
                    blockTypeCard(
                        icon: "hourglass",
                        title: "Open Limit",
                        subtitle: "Set a usage cap for the day.",
                        type: .openLimit
                    )
                    
                    blockTypeCard(
                        icon: "app.badge.checkmark",
                        title: "App Time Limit",
                        subtitle: "Limit specific apps individually.",
                        type: .appTimeLimit
                    )
                    
                    blockTypeCard(
                        icon: "bolt.fill",
                        title: "Block Now",
                        subtitle: "Emergency. Lock instantly.",
                        type: .blockNow,
                        isEmphasis: true,
                        isDisabled: isBlockNowActive
                    )
                }
                .padding(.horizontal, 20)
                
             //   Spacer()
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                switch selectedBlockType {
                case .scheduled:
                    onScheduled()
                case .openLimit:
                    onOpenLimit()
                case .appTimeLimit:
                    onAppTimeLimit()
                case .blockNow:
                    onBlockNow()
                }
            }) {
                HStack {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.06, green: 0.13, blue: 0.09))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(appTheme.colors.primary)
                .cornerRadius(12)
                .shadow(color: appTheme.colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(red: 0.06, green: 0.13, blue: 0.09))
        .onAppear {
            // Reload blocks from UserDefaults when view appears
            // This ensures we pick up changes made by the extension
            blockManager.reloadFromUserDefaults()
        }
    }
    
    // MARK: - Block Type Card
    private func blockTypeCard(
        icon: String,
        title: String,
        subtitle: String,
        type: BlockType,
        isEmphasis: Bool = false,
        isDisabled: Bool = false
    ) -> some View {
        Button(action: { selectedBlockType = type }) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    if isEmphasis && !isDisabled {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(appTheme.colors.primary.opacity(0.1))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(isDisabled ? 0.02 : 0.05))
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(
                            isDisabled ? .white.opacity(0.3) :
                            isEmphasis ? appTheme.colors.primary : .white.opacity(0.7)
                        )
                }
                .frame(width: 44, height: 44)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(isDisabled ? .white.opacity(0.4) : .white)
                        
                        if isDisabled {
                            Text("(active)")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(isDisabled ? 0.3 : 0.5))
                }
                
                Spacer()
                
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(
                            selectedBlockType == type ? appTheme.colors.primary : Color.white.opacity(isDisabled ? 0.1 : 0.2),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if selectedBlockType == type {
                        Circle()
                            .fill(appTheme.colors.primary)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(16)
            .background(Color(red: 0.09, green: 0.16, blue: 0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedBlockType == type ? appTheme.colors.primary : Color.white.opacity(isDisabled ? 0.02 : 0.05),
                        lineWidth: selectedBlockType == type ? 2 : 1
                    )
            )
            .cornerRadius(16)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    CreateBlockView(
        onScheduled: {},
        onOpenLimit: {},
        onAppTimeLimit: {},
        onBlockNow: {}
    )
}
