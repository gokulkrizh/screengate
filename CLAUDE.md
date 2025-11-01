# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ScreenGate is an iOS SwiftUI application that implements a simple content/task management system. The app displays a list of items that users can mark as completed, add new items, and delete existing ones. It serves as a foundation for a screening/filtering tool with a clean MVVM architecture.

## Architecture

The project follows **MVVM (Model-View-ViewModel)** architecture:

- **Models** (`screengate/Models/`): Data structures following Swift best practices
- **ViewModels** (`screengate/ViewModels/`): Business logic with `@MainActor` and `@Published` properties for reactive UI updates
- **Views** (`screengate/Views/`): SwiftUI views with clear separation of concerns
- **Main App**: Entry point in `screengateApp.swift` using SwiftUI's `@main` attribute

### Key Architectural Patterns
- SwiftUI navigation with `NavigationView` and `List`
- Reactive state management using Combine framework
- Thread safety with `@MainActor` annotation on ViewModels
- Component-based UI with reusable views like `ContentItemView`

## Build and Development Commands

### Building the Project
```bash
# Build for iOS Simulator (recommended for development)
xcodebuild -scheme screengate -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Build for device
xcodebuild -scheme screengate -configuration Debug
```

### Running the Application
```bash
# Install and run on simulator
xcodebuild -scheme screengate -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcrun simctl install booted ./DerivedData/Build/Products/Debug-iphonesimulator/screengate.app
xcrun simctl launch booted com.gia.screengate
```

### Available Schemes and Configurations
- **Scheme**: `screengate`
- **Configurations**: `Debug`, `Release`
- **Target**: `screengate`
- **Bundle Identifier**: `com.gia.screengate`

## Project Structure

```
screengate/
├── Models/              # Data models (ContentModel)
├── ViewModels/          # Business logic and state management
├── Views/               # SwiftUI views and components
├── Assets.xcassets/     # App icons, colors, and visual assets
└── screengateApp.swift  # App entry point
```

## Development Notes

### Data Flow
- `ContentViewModel` manages `@Published` properties for reactive UI updates
- Views use `@StateObject` to maintain ViewModel lifecycle
- UI actions call ViewModel methods, which update state and trigger view refreshes

### Current Limitations
- No data persistence (data is stored in memory only)
- No networking or external data sources
- No testing infrastructure implemented
- Mock data loading with simulated async operations

### Code Style Requirements
- Use `@MainActor` for ViewModels to ensure UI thread safety
- Follow SwiftUI best practices for view composition
- Implement proper error handling and loading states
- Use `@Published` properties for reactive state management

## Dependencies

- **iOS SDK**: 26.0 (future/test target)
- **Swift Version**: 5.0
- **Frameworks**: SwiftUI, Foundation, Combine
- **No external dependencies**: Uses only native iOS frameworks

## Common Development Patterns

When adding new features:
1. Define data models in `Models/` directory
2. Create/extend ViewModels in `ViewModels/` directory
3. Implement UI components in `Views/` directory
4. Ensure proper error handling and loading states
5. Maintain MVVM separation (no business logic in Views)