# ScreenGate

A comprehensive iOS digital wellness application built with SwiftUI that helps users develop healthier phone usage habits through mindful intentions and Screen Time integration.

## 🌟 Features

### Core Functionality
- **Screen Time Integration**: Full iOS Screen Time API integration with Family Controls
- **Intention-Based Interventions**: 5 categories of mindful activities (Breathing, Mindfulness, Reflection, Movement, Quick Breaks)
- **Smart App Blocking**: Shield extensions with customizable intention assignments
- **Deep Link Navigation**: Seamless navigation from shield notifications to intention screens
- **Progress Tracking**: Comprehensive analytics and usage insights

### User Interface
- **Dashboard**: Real-time restriction status and quick actions
- **App Selection**: Native iOS FamilyActivityPicker for intuitive app management
- **Intention Library**: Browse and customize mindful activities
- **Settings**: Comprehensive preferences and permission management
- **19-Step Onboarding**: Guided setup flow with personalized insights

## 🏗️ Architecture

ScreenGate follows **MVVM (Model-View-ViewModel)** architecture with reactive state management:

```
screengate/
├── Models/                    # Data structures and business logic
│   ├── ContentModel.swift      # Main content data models
│   ├── OnboardingFlowModel.swift # 19-step onboarding flow
│   └── ScreenTime/             # Screen Time specific models
│       ├── IntentionActivityModel.swift
│       ├── IntentionCategoryModel.swift
│       ├── AppRestrictionModel.swift
│       └── ...
├── ViewModels/                # Business logic and state management
│   ├── ContentViewModel.swift
│   ├── OnboardingViewModel.swift
│   └── ScreenTime/             # Screen Time ViewModels
│       ├── RestrictionViewModel.swift
│       ├── IntentionViewModel.swift
│       ├── NotificationViewModel.swift
│       └── ...
├── Views/                     # SwiftUI views and components
│   ├── SplashView.swift        # Animated splash screen (2.5s)
│   ├── MainView.swift          # Main navigation controller
│   ├── ContentView.swift       # TabView navigation
│   ├── Onboarding/            # 19-step onboarding flow
│   ├── Intentions/            # Intention execution UI
│   └── ScreenTime/            # Screen Time specific views
│       ├── DashboardView.swift
│       ├── AppSelectionView.swift
│       ├── IntentionLibraryView.swift
│       ├── SettingsView.swift
│       └── ...
├── Services/                   # Business logic services
│   ├── ScreenTimeService.swift
│   ├── NotificationService.swift
│   └── IntentionSelectionService.swift
└── Extensions/                 # Utility extensions
    └── ScreenTime+Extensions.swift
```

## 🎯 Implementation Status

### ✅ **COMPLETED** (100% Core Implementation)

#### Phase 1: Foundation
- ✅ **Service Layer**: Complete Screen Time API management
- ✅ **Data Models**: Comprehensive model system with 5 intention categories
- ✅ **Deep Link System**: Shield notifications to intention navigation

#### Phase 2: Screen Time Extensions
- ✅ **ShieldConfigurationExtension**: Custom shield UI with intention hints
- ✅ **ShieldActionExtension**: Shield interaction handling
- ✅ **App Groups Communication**: Seamless data sharing between extensions

#### Phase 3: MVVM Architecture
- ✅ **ViewModels**: All ViewModels with @MainActor and @Published properties
- ✅ **State Management**: Reactive UI updates with Combine framework
- ✅ **Error Handling**: Comprehensive error handling across all components

#### Phase 4: Intention Execution Framework
- ✅ **All 5 Intention Types**: Complete UI implementations
  - BreathingExerciseView: Interactive breathing with animations
  - MindfulnessView: Guided mindfulness practices
  - ReflectionView: Journaling and reflection
  - MovementView: Physical exercise guidance
  - QuickBreakView: Quick break activities
- ✅ **Progress Tracking**: Timer management and completion tracking

#### Phase 5: User Interface
- ✅ **DashboardView**: Real-time stats and quick actions
- ✅ **AppSelectionView**: FamilyActivityPicker integration
- ✅ **IntentionLibraryView**: Browse and configure intentions
- ✅ **SettingsView**: Permissions and preferences management
- ✅ **ContentView**: TabView navigation with 4 main sections
- ✅ **MainView**: Deep link handling and navigation flow

#### Phase 6: Quality Assurance
- ✅ **Zero Compilation Errors**: All code compiles successfully
- ✅ **SwiftUI Best Practices**: Clean, maintainable code architecture
- ✅ **Type Safety**: Comprehensive error handling and type annotations

## 🚀 Build Instructions

### Prerequisites
- Xcode 15.0+
- iOS 18.0+ SDK
- Swift 5.0+

### Building the Project

```bash
# Clone the repository
git clone <repository-url>
cd screengate

# Build for iOS Simulator
xcodebuild -scheme screengate -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Build for device
xcodebuild -scheme screengate -configuration Debug
```

### Running on Simulator

```bash
# Install and run on simulator
xcodebuild -scheme screengate -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcrun simctl install booted ./DerivedData/Build/Products/Debug-iphonesimulator/screengate.app
xcrun simctl launch booted com.gia.screengate
```

## 📱 App Permissions

ScreenGate requires the following permissions:

- **Screen Time**: Required for app restrictions and usage monitoring
- **Notifications**: For intention reminders and shield notifications
- **App Groups**: For communication between main app and extensions

## 🔧 Development Notes

### Key Technical Features
- **@MainActor** ViewModels for UI thread safety
- **@Published** properties for reactive state management
- **Combine framework** for data binding
- **Family Controls API** for Screen Time integration
- **Shield extensions** for app blocking functionality
- **Deep linking** for navigation from shields to intentions

### App Launch Flow
1. **Splash Screen** (2.5 seconds): Animated ScreenGate logo
2. **Onboarding Check**: Determines if user completed 19-step onboarding
3. **Main Navigation**: TabView with Dashboard, Restrictions, Intentions, Settings
4. **Deep Link Handling**: Shield notifications → Intention screens

### Screen Time Integration
- **FamilyActivityPicker**: Native iOS app selection interface
- **Managed Settings**: Configuration for app restrictions
- **Device Activity**: Usage monitoring and scheduling
- **Shield Extensions**: Custom blocking interface with intention triggers

## 🎨 UI Components

### Reusable Components
- **SettingRow**: Standard setting display with actions
- **ToggleSettingRow**: Toggle-based setting controls
- **StatCard**: Dashboard statistics display
- **IntentionCard**: Intention activity cards
- **CategoryChip**: Category selection chips

### Design System
- **Color Palette**: Consistent color scheme across all views
- **Typography**: System fonts with proper hierarchy
- **Spacing**: Consistent spacing and padding patterns
- **Animations**: Smooth transitions and micro-interactions

## 📊 Analytics & Insights

### Tracked Metrics
- **Intention Completion Rates**: Track mindfulness activity engagement
- **Screen Time Reduction**: Monitor digital wellness progress
- **App Usage Patterns**: Insights into phone usage habits
- **Daily/Weekly Trends**: Progress tracking over time

### Progress Features
- **Achievement System**: Milestones and accomplishments
- **Streak Tracking**: Consistency encouragement
- **Personal Insights**: AI-powered recommendations
- **Progress Visualization**: Charts and progress indicators

## 🔒 Privacy & Security

### Data Protection
- **Local Storage**: All user data stored locally on device
- **No Analytics Tracking**: No external analytics or data collection
- **Screen Time API**: Uses official iOS Screen Time framework
- **Secure Communication**: Encrypted App Groups communication

### Privacy Features
- **On-device Processing**: All intention selection happens locally
- **No Personal Data Collection**: No user behavior tracking
- **Transparent Permissions**: Clear explanation of all required permissions
- **User Control**: Full control over data and settings

## 🛠️ Troubleshooting

### Common Issues

#### Build Errors
- Ensure Xcode 15.0+ and iOS 18.0+ SDK
- Clean build folder: `Product → Clean Build Folder`
- Restart Xcode and try again

#### Screen Time Permissions
- Go to Settings → Screen Time → Privacy & Restrictions
- Enable Screen Time access for ScreenGate
- Restart the app after granting permissions

#### Shield Extensions Not Working
- Ensure App Groups are enabled in both extensions
- Check that Family Controls capability is added
- Verify extension signing and provisioning profiles

### Debug Information
- Enable logging: Check Xcode console for detailed logs
- Screen Time API debugging: Use Family Controls debug tools
- Extension debugging: Attach debugger to shield extensions

## 🤝 Contributing

### Development Guidelines
- Follow Swift and SwiftUI best practices
- Maintain MVVM architecture separation
- Use @MainActor for all ViewModels
- Implement proper error handling
- Write comprehensive unit tests

### Code Style
- Follow Swift naming conventions
- Use meaningful variable and function names
- Add documentation comments for complex logic
- Maintain consistent code formatting

## 📄 License

This project is proprietary and confidential.

## 📞 Support

For technical support or questions:
- Check the troubleshooting section above
- Review the implementation documentation
- Contact the development team

---

**ScreenGate** - Transforming digital habits through mindful intentions and intelligent Screen Time integration.

*Built with ❤️ using SwiftUI and iOS Screen Time APIs*