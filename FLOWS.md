# ScreenGate User Flows Documentation

This document outlines all user flows in the ScreenGate digital wellness application for manual testing and verification.

## 📱 App Launch Flow

### 1. **Initial App Launch**
**Expected Behavior:**
- App launches with animated splash screen (ScreenGate logo with door icon) for 2.5 seconds
- After splash, app checks if user has completed 19-step onboarding
- If onboarding not completed → Show onboarding flow
- If onboarding completed → Show main TabView navigation

**Verification Steps:**
1. Launch the app
2. Observe splash screen animation (should last ~2.5 seconds)
3. Check that proper navigation occurs based on onboarding status

---

## 🔗 Deep Link Flow

### 2. **Shield Notification Deep Link**
**Expected Behavior:**
- When user taps shield notification → App opens and navigates directly to the intention assigned to that blocked app
- After intention completion → User can choose to complete or cancel
- If completed → App should unblock temporarily or show success state
- If cancelled → User returns to main app

**Verification Steps:**
1. Trigger app restriction (need to set up restriction first via App Selection View)
2. Attempt to open restricted app
3. Observe shield notification appears
4. Tap on notification
5. Verify app opens to intention screen
6. Complete intention and verify behavior

---

## 🏠 Main Navigation Flow

### 3. **TabView Navigation**
**Expected Behavior:**
- 4 main tabs: Dashboard, Restrictions, Intentions, Settings
- Blue accent color for selected tab
- Smooth transitions between tabs
- Persistent tab selection

**Verification Steps:**
1. Navigate between all 4 tabs
2. Verify tab persistence when switching
3. Check visual indication of active tab
4. Verify smooth animations

### 3.1 **Dashboard Tab**
**Expected Behavior:**
- Real-time restriction status overview
- Quick action buttons for common operations
- Statistics about usage and intention completion
- Visual indicators for active restrictions

**Verification Steps:**
1. View current restriction status
2. Test quick action buttons
3. Review statistics display
4. Check status indicators (green/yellow/red)

### 3.2 **Restrictions Tab**
**Expected Behavior:**
- App selection interface using FamilyActivityPicker
- View all currently selected apps for restriction
- Add/remove apps from restriction list
- Navigate to per-app configuration

**Verification Steps:**
1. Open FamilyActivityPicker
2. Select/deselect apps
3. Save selections
4. Verify apps appear in main list
5. Navigate to individual app configuration

### 3.3 **Intentions Tab**
**Expected Behavior:**
- Browse all available intentions organized by category
- Search and filter functionality
- View intention details and descriptions
- Favorite/unfavorite intentions
- Access to intention configuration

**Verification Steps:**
1. Browse all 5 categories (Breathing, Mindfulness, Reflection, Movement, Quick Breaks)
2. Test search functionality
3. Use category filters
4. Favorite/unfavorite intentions
5. View detailed information

### 3.4 **Settings Tab**
**Expected Behavior:**
- Screen Time authorization status and management
- Notification preferences
- Restriction settings
- App information and support links

**Verification Steps:**
1. Check Screen Time authorization status
2. Configure notification preferences
3. Review restriction settings (placeholder features)
4. Access app information

---

## 🎯 App Selection & Configuration Flow

### 4. **App Selection**
**Expected Behavior:**
- Native iOS FamilyActivityPicker interface
- Multi-selection capability
- Categories and individual apps
- Visual feedback for selections
- Save button to confirm selections

**Verification Steps:**
1. Tap "Add App to Restrict" button
2. Navigate FamilyActivityPicker interface
3. Select individual apps or categories
4. Observe selection indicators
5. Tap "Done" to save

### 5. **Per-App Configuration**
**Expected Behavior:**
- List of all restricted apps
- Each app shows: app name, assigned intention, schedule status
- Tap to configure individual app settings
- Remove option for each restriction
- Visual status indicators (orange/yellow/green)

**Verification Steps:**
1. Navigate from Restrictions tab to app configuration
2. View all restricted apps in list
3. Tap on individual app card
4. Verify status indicators
5. Test intention assignment
6. Test schedule configuration
7. Test removal functionality

---

## 🧘 Intention Assignment Flow

### 6. **Intention Selection**
**Expected Behavior:**
- Browse intentions by category or search
- View intention details including title, description, duration, category
- Assign intention to restricted app
- "No Intention" option available
- Confirmation after selection

**Verification Steps:**
1. From app configuration, tap intention assignment
2. Browse available intentions
3. Test category filtering
4. Search for specific intentions
5. Select intention
6. Confirm assignment
7. Verify app card updates

### 7. **Intention Execution**
**Expected Behavior:**
- Full-screen intention interface
- Category-specific UI and interactions
- Timer display and progress tracking
- Complete/Cancel options
- Smooth animations and transitions

**Verification Steps:**
1. Trigger shield notification for app with assigned intention
2. Observe intention screen opens
3. Test category-specific features:
   - **Breathing**: Animated breathing guide, timer
   - **Mindfulness**: Guided meditation, progress tracking
   - **Reflection**: Journal interface, prompt display
   - **Movement**: Exercise guidance, timer
   - **Quick Break**: Quick activity options, timer
4. Test timer functionality
5. Test completion behavior
6. Test cancellation behavior

---

## ⏰ Schedule Configuration Flow

### 8. **Schedule Management**
**Expected Behavior:**
- Enable/disable scheduling per app
- Weekday selection with visual chips
- Time range management with add/edit/delete
- Quick template selection
- Duration settings
- Visual time range display

**Verification Steps:**
1. From app configuration, tap schedule configuration
2. Toggle schedule on/off
3. Select active weekdays
4. Add time ranges
5. Test time range editor
6. Apply quick templates (Work Hours, After Hours, Weekend, Morning Focus)
7. Set duration
8. Save schedule
9. Verify app card shows schedule status

### 8.1 **Time Range Editor**
**Expected Behavior:**
- Visual time picker interface
- Start and end time selection
- Duration calculation and display
- Quick time templates
- Validation (minimum 15 minutes, maximum 24 hours)
- Real-time preview

**Verification Steps:**
1. Tap "Add Time Range" or edit existing range
2. Use visual time pickers for start/end times
3. Observe duration calculation
4. Test quick time templates
5. Validate time constraints
6. Save time range
7. Verify time range appears in schedule list

---

## 🔐 Settings & Permissions Flow

### 9. **Screen Time Authorization**
**Expected Behavior:**
- Display current authorization status
- Request Screen Time access if not authorized
- Visual status indicators (green/yellow/red)
- Error handling for denied requests
- Instructions for manual authorization

**Verification Steps:**
1. Check initial authorization status
2. If not authorized, tap "Request Access"
3. Follow system prompts for Screen Time authorization
4. Verify status updates to "Authorized"
5. Test error handling for denied access

### 9.1 **Notification Settings**
**Expected Behavior:**
- Notification authorization status
- Toggle switches for different notification types
- Visual feedback for enabled/disabled states
- Request access if needed

**Verification Steps:**
1. Check notification authorization status
2. Test toggle switches:
   - Intention Reminders
   - Daily Digest
   - Progress Updates
3. Request notification access if needed
4. Verify toggle states persist

### 9.2 **Restriction Settings**
**Expected Behavior:**
- Placeholder settings for future features
- Toggle switches (currently non-functional)
- Informational descriptions
- Visual feedback

**Verification Steps:**
1. Review available settings
2. Note placeholder status
3. Test toggle behavior (should show informational messages)

---

## 📊 Data Persistence Flow

### 10. **Configuration Saving**
**Expected Behavior:**
- All configurations persist to app storage
- Changes survive app restart
- Proper error handling for save failures
- Loading of previous configurations on app launch

**Verification Steps:**
1. Make configuration changes
2. Close and restart app
3. Verify configurations persist
4. Test across app restart cycles

### 10.1 **State Management**
**Expected Behavior:**
- Real-time UI updates
- Proper state synchronization
- Consistent data across views
- Error state handling

**Verification Steps:**
1. Make simultaneous changes in multiple views
2. Verify real-time updates
3. Test error recovery
4. Verify data consistency

---

## 🎯 User Experience Flows

### 11. **Complete Setup Flow**
**Expected Behavior:**
1. Launch app → Splash screen → Onboarding (19 steps)
2. Complete onboarding → Main navigation
3. Select apps to restrict → FamilyActivityPicker
4. Assign intentions to restricted apps → IntentionSelectionView
5. Configure schedules (optional) → ScheduleConfigurationView
6. Begin using app → Restrictions active

**Verification Steps:**
1. Complete full 19-step onboarding process
2. Set up initial app restrictions
3. Assign intentions to multiple apps
4. Configure schedules for different times
5. Test actual app blocking behavior

### 12. **Daily Usage Flow**
**Expected Behavior:**
1. Check Dashboard for overview
2. View restrictions status
3. Monitor progress and achievements
4. Receive notifications for intentions
5. Review settings as needed

**Verification Steps:**
1. Daily app interactions
2. Monitor restriction effectiveness
3. Test notification delivery
4. Review progress tracking

### 13. **Troubleshooting Flow**
**Expected Behavior:**
- Clear error messages for common issues
- Links to support resources
- Settings for authorization problems
- Visual indicators for system status

**Verification Steps:**
1. Intentionally test error conditions
2. Verify error message clarity
3. Test recovery mechanisms
4. Verify support accessibility

---

## 🔍 Technical Verification Checklist

### Build & Compilation
- [ ] App builds successfully without errors
- [ ] All views compile without warnings
- [ ] No memory leaks detected
- [ ] Proper ARC memory management

### Performance
- [ ] Smooth animations and transitions
- [ ] No UI lag on main interactions
- [ ] Fast app launch time
- [ ] Efficient memory usage

### Data Integrity
- [ ] Configurations persist correctly
- [ ] State synchronization works
- [ ] Error recovery handles gracefully
- [ ] Data validation prevents corruption

### iOS Integration
- [ ] Screen Time API integration works
- - FamilyActivityPicker functions properly
- - Shield extensions communicate correctly
- - Deep linking functions as expected
- [ ] Notification permissions work
- [ ] App Groups communication functional

### User Experience
- [ ] Intuitive navigation flow
- [ ] Clear visual feedback
- [ ] Consistent design patterns
- [ ] Helpful error messages
- [ ] Accessible interface elements

---

## 🐛 Bug Report Template

**Date:**
**iOS Version:**
**Device:**
**Build Version:**

### Issue Description:
*Describe the bug clearly and concisely*

### Steps to Reproduce:
1.
2.
3.

### Expected Behavior:
*What should happen*

### Actual Behavior:
*What actually happened*

### Additional Context:
*Any relevant screenshots or logs*

### Frequency:
*How often does this occur?*

### Severity:
*Critical/Major/Minor/Trivial*

---

## ✅ Testing Completion Checklist

After verifying each flow, check the box:

### App Launch & Navigation
- [ ] Splash screen animation (2.5 seconds)
- [ ] Onboarding flow navigation
- [ ] TabView navigation (4 tabs)
- [ ] Deep link navigation to intentions

### Core Features
- [ ] App selection via FamilyActivityPicker
- [ ] Per-app restriction configuration
- [ ] Intention assignment system
- [ ] Schedule configuration
- [ ] Time range management

### User Interface
- [ ] All views render correctly
- [ ] Animations are smooth
- [ ] Color scheme consistent
- [ ] Typography proper
- [ ] Icons display correctly

### Data Management
- [ ] Configurations persist
- [ ] State updates in real-time
- [ ] Error handling works
- [ ] Data validation prevents corruption

### iOS Integration
- [ ] Screen Time API authorization
- [ ] Shield extensions function
- [ ] Notification system
- [ ] Deep linking capabilities
- [ ] App Groups communication

### User Experience
- [ ] Intuitive navigation
- [ ] Clear visual feedback
- [ ] Helpful error messages
- [ ] Consistent design
- [ ] Accessible interface

---

**Notes:**
*Add any additional observations or special conditions found during testing*
*Document any workarounds needed*