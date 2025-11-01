# Screen Time API Integration Plan for ScreenGate

## Overview

This document outlines the comprehensive integration of Apple's Screen Time APIs into the ScreenGate iOS application. The implementation will leverage existing project capabilities including Family Control entitlement, Push Notifications, Shield Configuration Extension, and Shield Action Extension targets. The system will provide app/website restrictions with configurable intention activities that users can personalize based on their preferences.

## Architecture Overview

### Multi-Target Architecture
- **Main App Target**: MVVM architecture, UI components, business logic, intention library
- **Shield Configuration Extension**: Custom shield UI with intention hints
- **Shield Action Extension**: Shield interaction handling and notification triggering
- **App Groups**: Shared data container for seamless communication between targets

### Core Frameworks Integration
- **Family Controls**: App selection and authorization management
- **Managed Settings**: Shield implementation and restriction enforcement
- **Device Activity**: Usage monitoring and schedule management
- **UserNotifications**: Shield-to-app communication via notifications

## Phase 1: Core Screen Time Infrastructure

### 1.1 Service Layer Creation

#### Main App Services
```
screengate/Services/
├── ScreenTimeService.swift
├── NotificationService.swift
└── IntentionSelectionService.swift
```

**ScreenTimeService.swift**
- Centralized API management for Screen Time operations
- Authorization request handling via `AuthorizationCenter`
- App selection and restriction management
- Communication with extensions via App Groups

**NotificationService.swift**
- Handle shield-triggered notifications
- Deep linking from notifications to intention screens
- Dynamic notification content based on selected intentions
- Context passing (app, intention type, duration, etc.)

**IntentionSelectionService.swift**
- Choose appropriate intention based on user preferences
- Time-based intention selection logic
- Previous intention history analysis
- Randomization within preferred categories

### 1.2 Permission Management

#### Enhanced Permission Flow
- Extend existing `ScreenTimePermissionView` with actual `AuthorizationCenter` requests
- Real-time permission status monitoring with reactive updates
- Comprehensive error handling for denied permissions
- User-friendly retry mechanisms

#### Permission Implementation
```swift
// Key Components to Implement
- AuthorizationCenter.shared.requestAuthorization()
- AuthorizationCenter.shared.authorizationStatus
- Reactive permission status monitoring
- Error handling for restricted/failed states
```

## Phase 2: App & Website Selection System

### 2.1 Data Models

#### Selection Models Structure
```
screengate/Models/ScreenTime/
├── AppRestrictionModel.swift
├── WebsiteRestrictionModel.swift
├── RestrictionScheduleModel.swift
├── IntentionActivityModel.swift
├── IntentionCategoryModel.swift
└── UserIntentionPreferenceModel.swift
```

**AppRestrictionModel.swift**
- Store selected apps/categories from `FamilyActivityPicker`
- Restriction configuration per app
- Associated intention assignments
- Schedule-specific restrictions

**WebsiteRestrictionModel.swift**
- Blocked domains and website categories
- Web restriction rules and configurations
- Time-based website restrictions
- Intentions for website categories

**RestrictionScheduleModel.swift**
- Time-based restriction rules
- Recurring schedule patterns
- Temporary restriction overrides
- Holiday and exception handling

### 2.2 Selection Interface

#### App Selection Components
- Integrate `FamilyActivityPicker` for native app/category selection
- Custom website/domain selection interface
- Batch selection capabilities
- Visual restriction configuration UI

## Phase 3: Configurable Intention System

### 3.1 Intention Activity Models

#### Intention Library Structure
The intention system will support multiple categories of activities:

**Breathing Exercises**
- Box Breathing (4-4-4-4 pattern)
- 4-7-8 Breathing Technique
- Diaphragmatic Breathing
- Progressive Muscle Relaxation Breathing

**Mindfulness Practices**
- Body Scan Meditation
- Sensory Awareness Exercise
- Present Moment Awareness
- Five Senses Grounding

**Reflection Activities**
- Journaling Prompts
- Gratitude Practice
- Goal Check-in
- Values Reflection

**Physical Movement**
- Desk Stretches
- Eye Exercises
- Posture Correction
- Quick Energy Movements

**Quick Breaks**
- Water Reminder
- Walk Around Break
- Look Away From Screen
- Quick Mental Reset

### 3.2 Intention Configuration System

#### User Personalization Features
- Per-app intention assignments
- Time-based intention preferences
- Duration customization per intention type
- Intention variety settings
- Mood-based intention suggestions

#### Configuration Interface Components
```
screengate/Views/ScreenTime/
├── IntentionLibraryView.swift
├── IntentionConfigurationView.swift
├── IntentionAssignmentView.swift
└── IntentionPreviewView.swift
```

## Phase 4: Shield Integration System

### 4.1 Shield Configuration Extension

#### Extension Implementation
```
ShieldConfiguration/
├── ShieldConfigurationViewController.swift
├── ShieldUIManager.swift
└── Resources/
    └── ShieldAssets.xcassets
```

**Key Features**
- Custom shield appearance with app branding
- Display intention type hints ("Breathing exercise ready")
- Personalized messaging based on user preferences
- Clear call-to-action buttons

### 4.2 Shield Action Extension

#### Extension Implementation
```
ShieldAction/
├── ShieldActionViewController.swift
├── ShieldActionHandler.swift
└── NotificationManager.swift
```

**Key Features**
- Handle shield button tap events
- Trigger contextual notifications with intention data
- Pass restriction context to main app
- User interaction tracking

## Phase 5: Dynamic Intention Delivery

### 5.1 Intention Selection Algorithm

#### Selection Logic Factors
1. **User Preferences**: Configured intentions per app/category
2. **Time Patterns**: Different intentions for different times
3. **Usage History**: Previous intention completion rates
4. **Variety Logic**: Prevent repetition of recent intentions
5. **Context Awareness**: Current time, day, usage patterns

#### Smart Selection Features
- Weighted randomization within preferred categories
- Time-based intention recommendations
- Learning from user completion patterns
- Adaptive difficulty progression

### 5.2 Intention Screen Framework

#### Dynamic Intention Container
```
screengate/Views/Intentions/
├── IntentionContainerView.swift
├── BreathingExerciseView.swift
├── MindfulnessView.swift
├── ReflectionView.swift
└── MovementView.swift
```

**IntentionContainerView.swift**
- Dynamic container that displays different intention types
- Handles navigation between intention activities
- Manages timer and progress tracking
- Provides completion flow options

## Phase 6: Scheduling & Automation

### 6.1 Schedule Management

#### Schedule ViewModel Features
- Time-based restriction enforcement
- Recurring schedule patterns
- Holiday and exception handling
- Intention-specific scheduling rules

### 6.2 Notification Integration

#### Smart Notification System
- Scheduled restriction start/end notifications
- Personalized intention reminders
- Progress and achievement notifications
- Intention variety recommendations

## Phase 7: MVVM Architecture Integration

### 7.1 ViewModels Structure

#### Main App ViewModels
```
screengate/ViewModels/
├── RestrictionViewModel.swift
├── ScheduleViewModel.swift
├── IntentionViewModel.swift
├── IntentionLibraryViewModel.swift
└── NotificationViewModel.swift
```

**RestrictionViewModel.swift**
- Manage app and website restrictions
- Handle restriction configuration
- Monitor restriction status
- Integration with Managed Settings

**IntentionViewModel.swift**
- Manage intention activities and states
- Handle intention completion tracking
- Coordinate with IntentionSelectionService
- Provide intention analytics

**IntentionLibraryViewModel.swift**
- Manage intention library and configuration
- Handle user preference updates
- Provide intention recommendations
- Track intention usage statistics

### 7.2 State Management

#### Reactive Architecture
- Use `@Published` properties for reactive UI updates
- Ensure thread safety with `@MainActor` annotation
- Implement proper error handling and loading states
- Maintain clean separation of concerns

## Technical Implementation Details

### Communication Flow

#### Complete User Journey
1. **User Configuration**: User sets up restrictions and intentions in main app
2. **Restriction Trigger**: User opens restricted app → Shield appears
3. **Shield Interaction**: Shield shows intention hint + CTA button
4. **Notification Trigger**: Button tap → Shield Action Extension sends notification
5. **App Deep Link**: User taps notification → Opens main app with context
6. **Intention Selection**: `IntentionSelectionService` chooses appropriate intention
7. **Intention Display**: Main app shows selected intention activity
8. **Completion Flow**: User completes intention → Restriction management options

#### Data Sharing Strategy
- **App Groups**: Shared UserDefaults for restriction and intention data
- **Core Data**: Persistent storage for schedules, intentions, and analytics
- **NotificationCenter**: Real-time extension-to-app communication
- **Keychain**: Secure storage for sensitive configuration data

### Data Models Specifications

#### Core Data Entities
```swift
// Core Models
- AppRestriction: appToken, intentionAssignments, schedules
- WebsiteRestriction: domain, category, intentionRules
- IntentionActivity: type, category, duration, content
- UserPreference: intentionMappings, timePreferences
- UsageAnalytics: completionRates, timePatterns, preferences
```

### API Integration Details

#### Family Controls Integration
```swift
// Key APIs
- FamilyActivityPicker for app selection
- AuthorizationCenter for permission management
- FamilyActivitySelection for storing selections
- ManagedSettingsStore for applying restrictions
```

#### Device Activity Integration
```swift
// Monitoring and Scheduling
- DeviceActivityCenter for schedule management
- DeviceActivitySchedule for time-based rules
- ActivityToken for app tracking
- CategoryToken for category monitoring
```

## Implementation Status - Current Progress

### ✅ COMPLETED COMPONENTS (65-70% Complete)

#### Phase 1: Foundation - ✅ COMPLETE
- ✅ **Service Layer**: All core services implemented and functional
  - `ScreenTimeService.swift`: Complete Screen Time API management
  - `NotificationService.swift`: Full notification system with deep linking
  - `IntentionSelectionService.swift`: Sophisticated intention selection algorithm
- ✅ **Data Models**: Comprehensive model system implemented
  - All intention activity models with 5 categories and content types
  - Complete restriction and scheduling models
  - User preference and analytics models
- ✅ **Permission Management**: Basic authorization handling implemented

#### Phase 2: Core Functionality - ✅ COMPLETE
- ✅ **Shield Extensions**: Fully functional with App Groups communication
  - `ShieldConfigurationExtension.swift`: Custom shield UI with intention hints
  - `ShieldActionExtension.swift`: Shield interaction handling and notification triggering
- ✅ **Notification System**: Complete deep linking and context passing
- ✅ **App Integration**: Deep link manager and notification handling in main app
- ✅ **Extensions**: Comprehensive utility extensions for Screen Time APIs

### ❌ MISSING CRITICAL COMPONENTS (30-35% Remaining)

#### Phase 3: Intention System - ⚠️ PARTIAL
- ❌ **Intention Execution UI**: No user interface for completing intentions
- ❌ **Intention Library Management**: No UI for browsing/configuring intentions
- ❌ **User Configuration Interface**: No screens for user preferences

#### Phase 4: Advanced Features - ❌ NOT STARTED
- ❌ **ViewModels**: Entire MVVM presentation layer missing
- ❌ **Screen Time Views**: No user interface components
- ❌ **Navigation Integration**: Deep links have nowhere to navigate
- ❌ **Scheduling UI**: No interface for configuring restriction schedules

#### Phase 5: Testing & Optimization - ❌ NOT STARTED
- ❌ **Integration Testing**: Cannot test end-to-end flow without UI
- ❌ **User Experience Testing**: Missing UI prevents user testing

## Updated Implementation Phases

### Phase 1: Core UI Foundation (Week 1-2) - **HIGH PRIORITY**
**Missing ViewModels for MVVM Architecture:**
- `RestrictionViewModel.swift` - Manage app/website restrictions and UI state
- `ScheduleViewModel.swift` - Handle restriction scheduling and time management
- `IntentionViewModel.swift` - Manage intention activities and completion tracking
- `IntentionLibraryViewModel.swift` - Handle intention library and configuration
- `NotificationViewModel.swift` - Manage notification preferences and scheduling

**Missing ScreenTime Views Structure:**
- Create `Views/ScreenTime/` directory structure
- `AppSelectionView.swift` - FamilyActivityPicker integration interface
- `IntentionContainerView.swift` - Dynamic intention display framework
- `RestrictionConfigurationView.swift` - Configure app/website restrictions

### Phase 2: Intention Execution Framework (Week 2-3) - **CRITICAL**
**Missing Intention UI Components:**
- Create `Views/Intentions/` directory structure
- `BreathingExerciseView.swift` - Interactive breathing exercise interface
- `MindfulnessView.swift` - Mindfulness practice guidance interface
- `ReflectionView.swift` - Journaling and reflection interface
- `MovementView.swift` - Physical activity guidance interface
- `QuickBreakView.swift` - Quick break activity interface
- Implement deep link navigation from shield notifications to intention screens
- Add completion tracking and user feedback collection

### Phase 3: Configuration & Management (Week 3-4) - **HIGH PRIORITY**
**User Management Interfaces:**
- `IntentionLibraryView.swift` - Browse and configure intention activities
- `IntentionConfigurationView.swift` - Set up user preferences and mappings
- `IntentionAssignmentView.swift` - Assign intentions to apps/categories
- `ScheduleConfigurationView.swift` - Set up restriction schedules
- `AnalyticsView.swift` - User insights and progress dashboard

### Phase 4: Integration & Navigation (Week 4-5) - **MEDIUM PRIORITY**
**App Integration:**
- Integrate Screen Time setup into existing onboarding flow
- Build main navigation structure for Screen Time features
- Add comprehensive error handling and user guidance
- Implement settings and preference management screens
- Connect shield notifications to intention UI through deep linking

### Phase 5: Testing & Optimization (Week 5-6) - **MEDIUM PRIORITY**
- Comprehensive testing across all targets
- Performance optimization for intention loading and execution
- User experience testing and refinement
- Bug fixes and stability improvements

## Critical Missing Functionality

### 🚨 BLOCKERS FOR END-TO-END FUNCTIONALITY
Without these components, users cannot:
1. **Select apps/websites for restriction** - No configuration UI
2. **Complete intentions when shields are triggered** - No execution UI
3. **Configure preferences or view analytics** - No management interface
4. **Navigate from shield notifications to intention screens** - Missing navigation

### 📋 MINIMUM VIABLE PRODUCT REQUIREMENTS
**Phase 1 & 2 components are essential for basic functionality:**
- ViewModels for reactive UI state management
- Intention execution views for completing shield-triggered activities
- Basic app selection interface for configuring restrictions
- Deep link navigation from notifications to intention screens

## Technical Specifications for Missing Components

### ViewModels Architecture
```swift
// Required ViewModels with @MainActor and @Published properties
@MainActor
class RestrictionViewModel: ObservableObject {
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @Published var isAuthorized: Bool = false
    @Published var restrictions: [AppRestriction] = []
    // ... authorization and restriction management
}

@MainActor
class IntentionViewModel: ObservableObject {
    @Published var currentIntention: IntentionActivity?
    @Published var isIntentionActive: Bool = false
    @Published var completionProgress: Double = 0.0
    // ... intention execution state management
}
```

### View Structure
```
screengate/Views/
├── ScreenTime/
│   ├── AppSelectionView.swift
│   ├── RestrictionConfigurationView.swift
│   ├── ScheduleConfigurationView.swift
│   ├── IntentionLibraryView.swift
│   └── IntentionConfigurationView.swift
└── Intentions/
    ├── IntentionContainerView.swift
    ├── BreathingExerciseView.swift
    ├── MindfulnessView.swift
    ├── ReflectionView.swift
    ├── MovementView.swift
    └── QuickBreakView.swift
```

### Navigation Integration
- Deep link routing from shield notifications to intention screens
- Integration with existing MainView navigation structure
- Screen Time section in main app navigation
- Onboarding flow integration for initial setup

## Benefits & Outcomes

### User Experience Benefits
- **Personalized Experience**: Users can configure intentions that resonate with them
- **Variety & Engagement**: Multiple intention types prevent monotony
- **Flexible Restrictions**: Granular control over app and website access
- **Mindful Technology Use**: Promotes conscious device usage

### Technical Benefits
- **MVVM Architecture**: Clean, maintainable code structure
- **Multi-Target Design**: Proper separation of concerns
- **Scalable System**: Easy to add new intention types and features
- **Privacy-First**: Leverages Apple's Screen Time privacy framework

### Business Value
- **Unique Value Proposition**: Configurable intention system differentiates from competitors
- **User Retention**: Personalized experience increases engagement
- **Platform Leverage**: Full utilization of Apple's Screen Time APIs
- **Future-Proof**: Architecture supports additional features and integrations

## Success Metrics

### Technical Metrics
- API integration success rate: >99%
- Shield-to-app notification delivery: <2 second latency
- Intention loading time: <1 second
- Extension communication reliability: >99%

### User Experience Metrics
- Intention completion rate: Target >70%
- User configuration engagement: Target >60% of users customize intentions
- Daily active usage: Target >40% of configured users
- User satisfaction: Target >4.5/5 rating

## Risk Mitigation

### Technical Risks
- **Extension Communication**: Implement robust App Groups communication
- **Permission Management**: Handle all authorization states gracefully
- **Performance**: Optimize Core Data queries and notification handling
- **Compatibility**: Test across iOS versions and device types

### User Experience Risks
- **Complexity**: Provide guided onboarding for intention configuration
- **Intrusion**: Balance restriction effectiveness with user autonomy
- **Variety**: Ensure sufficient intention diversity to prevent fatigue

## Conclusion

This comprehensive Screen Time API integration plan will transform ScreenGate into a powerful digital wellbeing tool with a unique configurable intention system. The implementation leverages Apple's native Screen Time APIs while maintaining clean MVVM architecture and providing a highly personalized user experience.

The multi-phase approach ensures manageable development cycles while delivering immediate value to users. The architecture is designed for scalability, allowing for future enhancements and additional features without major refactoring.

The configurable intention system sets ScreenGate apart from competitors by allowing users to personalize their mindful breaks, creating a more engaging and effective digital wellbeing experience.