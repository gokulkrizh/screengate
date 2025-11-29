# Focus Club Development Todo

**Start Date:** November 29, 2025  
**Target Launch:** 9-10 weeks  
**Current Branch:** goclub  

---

## Phase 0: Project Setup & Architecture (Week 0)
- [ ] Create Xcode project structure
  - [ ] Main app target: `screengate` (or rename to `FocusClub`)
  - [ ] Extensions: `DeviceActivityMonitorExtension`, `ShieldActionExtension`, `ShieldConfigurationExtension`
  - [ ] Shared framework for data models
  - [ ] App groups identifier: `group.com.gokulkrizh.focusclub`

- [ ] Configure entitlements & capabilities
  - [ ] FamilyControls framework (main app + extensions)
  - [ ] Screen Time API (iOS 15+)
  - [ ] App Groups (for sharing data with extensions)
  - [ ] Push notifications (UserNotifications)
  - [ ] HealthKit (optional, for future screen time integration)

- [ ] Git & documentation setup
  - [ ] Initialize .gitignore (ignore certificates, API keys, derived data)
  - [ ] Create README with setup instructions
  - [ ] Set up CI/CD with GitHub Actions (optional but recommended)
  - [ ] Tag: `v0.1-setup-complete`

---

## Phase 1: Design System Implementation (Week 1)
**Location:** `screengate/` > `Theme/`, `Views/Components/`

### Colors & Styling
- [ ] Create `Theme/Colors.swift`
  - [ ] Dark base: #0A0E27
  - [ ] Card background: #1A1F3A
  - [ ] Accent (focus): #6C63FF
  - [ ] Success: #4ECDC4
  - [ ] Warning: #FFB347
  - [ ] Destructive: #FF6B9D
  - [ ] Text primary: #FFFFFF
  - [ ] Text secondary: #B8B8D0
  - [ ] Create ColorScheme enum for easy access

- [ ] Create `Theme/Typography.swift`
  - [ ] Display style (34pt, bold, SF Pro)
  - [ ] Headline style (28pt, bold, SF Pro)
  - [ ] Title style (20pt, semibold, SF Pro)
  - [ ] Body style (16pt, regular, SF Pro)
  - [ ] Caption style (14pt, medium, SF Pro)
  - [ ] Button style (18pt, semibold, SF Pro)
  - [ ] Create Font extensions for reusability

- [ ] Create `Theme/Spacing.swift`
  - [ ] Define spacing constants: 4, 8, 12, 16, 20, 24, 32px
  - [ ] Safe area padding defaults
  - [ ] Card margins & padding

### Reusable Components
- [ ] Create `Views/Components/PrimaryButton.swift`
  - [ ] Gradient background (purple)
  - [ ] 56pt height, 28pt corner radius (pill shape)
  - [ ] States: default, pressed (scale 0.95, opacity 0.8), disabled (gray)
  - [ ] Shadow effect
  - [ ] Haptic feedback on tap

- [ ] Create `Views/Components/CardView.swift`
  - [ ] 16px corner radius
  - [ ] Dark card background
  - [ ] 16px padding inside
  - [ ] Drop shadow (0px 4px 20px)
  - [ ] Reusable for all card layouts

- [ ] Create `Views/Components/StatsCard.swift`
  - [ ] Large number display (48pt bold)
  - [ ] Label (14pt medium, secondary color)
  - [ ] Icon support (32x32px)
  - [ ] Accent color tint on icon

- [ ] Create `Views/Components/ProgressRing.swift`
  - [ ] Circular progress indicator
  - [ ] Animated stroke draw
  - [ ] Configurable colors & thickness
  - [ ] Used for session timer

- [ ] Create `Views/Components/TabBar.swift`
  - [ ] 3 tabs: Shield, Stats, Settings
  - [ ] Active/inactive colors (#6C63FF / #6B7089)
  - [ ] Icons from SF Symbols
  - [ ] Blur effect background

- [ ] Create `Views/Components/ToggleSwitch.swift`
  - [ ] iOS native appearance
  - [ ] On color: #6C63FF
  - [ ] Off color: #2A2F4A
  - [ ] Haptic feedback

### Animations & Modifiers
- [ ] Create `Theme/Animations.swift`
  - [ ] Page transition: slide + fade (300ms, ease-out)
  - [ ] Button press: scale (100ms, ease-in-out)
  - [ ] Card reveal: fade + slide up (400ms, ease-out)
  - [ ] Modal appearance: spring (500ms, 0.6 stiffness, 0.8 damping)
  - [ ] Breathing circle: loop (4000ms, ease-in-out)

- [ ] Create `Theme/ViewModifiers.swift`
  - [ ] `.cardStyle()` - padding, background, shadow, corner radius
  - [ ] `.primaryButton()` - gradient, height, corner radius
  - [ ] `.screenBackground()` - dark gradient background
  - [ ] `.blur(radius)` - conditional blur effect

**Deliverable:** Design system ready for use in all views

---

## Phase 2: Core Data & Models (Week 1-2)
**Location:** `screengate/Shared/` or new `Models/` folder

### Core Data Models
- [ ] Create `Models/User.swift` (NSManagedObject)
  - [ ] id: UUID
  - [ ] name: String
  - [ ] createdAt: Date
  - [ ] isPremium: Bool
  - [ ] trialEndsAt: Date?
  - [ ] emergencyBypassLimit: Int16
  - [ ] defaultProtectionBehavior: String (enum: "block", "delay", "ask")
  - [ ] Relationship: one-to-many with ProtectedApp, FocusSession, InterventionLog

- [ ] Create `Models/ProtectedApp.swift` (NSManagedObject)
  - [ ] bundleID: String (primary key)
  - [ ] name: String
  - [ ] appIcon: Data? (cached icon)
  - [ ] behavior: String (enum: "block", "delay", "ask")
  - [ ] delayDuration: Int16 (seconds, 5-60)
  - [ ] isScheduled: Bool
  - [ ] scheduleStartHour: Int16? (0-23)
  - [ ] scheduleEndHour: Int16? (0-23)
  - [ ] scheduleDays: String? ("0000000" for weekdays, 1=Monday-7=Sunday)
  - [ ] isPremiumOnly: Bool (for feature gates)

- [ ] Create `Models/FocusSession.swift` (NSManagedObject)
  - [ ] id: UUID
  - [ ] startTime: Date
  - [ ] endTime: Date?
  - [ ] duration: Int32 (seconds)
  - [ ] isCompleted: Bool
  - [ ] template: String (enum: "work", "study", "deep_work", "custom")
  - [ ] customDuration: Int32? (for custom sessions)
  - [ ] blockedAppsCount: Int16
  - [ ] attemptsCount: Int16
  - [ ] intensityLevel: String (enum: "easy", "moderate", "hardcore")
  - [ ] bypassesUsed: Int16
  - [ ] breaksTaken: Int16

- [ ] Create `Models/InterventionLog.swift` (NSManagedObject)
  - [ ] id: UUID
  - [ ] timestamp: Date
  - [ ] appBundleID: String
  - [ ] appName: String
  - [ ] interventionType: String (enum: "block", "delay", "ask")
  - [ ] userDecision: String (enum: "opened", "resisted", "bypassed")
  - [ ] attemptNumber: Int16 (during session)
  - [ ] sessionID: UUID? (if during active session)

- [ ] Create `Models/DailyStat.swift` (NSManagedObject)
  - [ ] date: Date (unique key)
  - [ ] timesSaved: Int32 (resisted temptation)
  - [ ] timesOpened: Int32 (gave in)
  - [ ] totalFocusTime: Int32 (seconds)
  - [ ] focusSessionsCount: Int16
  - [ ] bypassesUsed: Int16
  - [ ] mostBlockedAppID: String?

- [ ] Create `Models/Milestone.swift` (NSManagedObject)
  - [ ] id: String (enum: "first_session", "10_saves", "7_day_streak", etc.)
  - [ ] unlockedAt: Date?
  - [ ] isCompleted: Bool
  - [ ] progress: Int32 (current/total for locked milestones)

### Data Managers
- [ ] Create `Managers/CoreDataManager.swift`
  - [ ] Singleton pattern
  - [ ] Load persistent container
  - [ ] CRUD operations (create, read, update, delete)
  - [ ] Batch operations (performance optimization)
  - [ ] Migration support

- [ ] Create `Managers/UserManager.swift`
  - [ ] Get/update current user
  - [ ] Check premium status & trial expiration
  - [ ] Update onboarding state

- [ ] Create `Managers/ProtectedAppManager.swift`
  - [ ] Add/remove protected apps
  - [ ] Get all protected apps
  - [ ] Count protected apps (for free tier limit)
  - [ ] Update app behavior rules
  - [ ] Get app icon by bundleID

- [ ] Create `Managers/SessionManager.swift`
  - [ ] Start new focus session
  - [ ] End active session (early or completed)
  - [ ] Get active session
  - [ ] Log session attempt
  - [ ] Calculate session completion rate

- [ ] Create `Managers/StatsManager.swift`
  - [ ] Get today's stats
  - [ ] Get weekly stats
  - [ ] Calculate "times saved" (resisted)
  - [ ] Calculate success rate
  - [ ] Find most blocked app
  - [ ] Update daily stats at midnight

- [ ] Create `Managers/MilestoneManager.swift`
  - [ ] Check if milestone unlocked
  - [ ] Get all milestones with progress
  - [ ] Unlock milestone (with celebration)

**Deliverable:** All data models, relationships, and managers working

---

## Phase 3: Device Activity & Extensions (Week 2)
**Location:** Extensions folder

### Screen Time Integration
- [ ] Create `Managers/DeviceActivityManager.swift` (main app)
  - [ ] Request FamilyControls authorization
  - [ ] Check if authorized
  - [ ] Get list of installed apps
  - [ ] Filter apps by category (social media, entertainment, etc.)

- [ ] Create `DeviceActivityMonitorExtension.swift` (extension)
  - [ ] Implement DeviceActivityMonitor subclass
  - [ ] Handle `eventDidOccur()` for app launches
  - [ ] Log intervention attempt to Core Data (via shared container)
  - [ ] Update attempt count during session
  - [ ] Calculate "times saved" in real-time

- [ ] Create `ShieldConfigurationExtension.swift` (extension)
  - [ ] Implement ShieldConfiguration subclass
  - [ ] Show message for delay intervention: "Take a breath... (10s remaining)"
  - [ ] Show message for block intervention: "Instagram is blocked"
  - [ ] Custom text based on intervention type

- [ ] Create `ShieldActionExtension.swift` (extension)
  - [ ] Handle action buttons from shield
  - [ ] "Unlock" button → trigger emergency bypass
  - [ ] "Settings" button → open main app

### Shared Container Communication
- [ ] Create `Managers/SharedContainerManager.swift`
  - [ ] Write intervention logs to shared container (UserDefaults + App Groups)
  - [ ] Sync between extensions and main app
  - [ ] Handle race conditions (extension & main app writing simultaneously)

**Deliverable:** Device Activity monitoring working on physical device

---

## Phase 4: Authentication & Onboarding (Week 2-3)
**Location:** `Views/Onboarding/`

### User State Management
- [ ] Create `Models/OnboardingState.swift`
  - [ ] Enum for onboarding stage (welcome, problem, select_apps, choose_behavior, etc.)
  - [ ] Track which screen user is on
  - [ ] Store selected apps list
  - [ ] Store chosen protection behavior
  - [ ] Track permissions granted

### Onboarding Screens

#### Screen 1: Welcome/Problem Statement
- [ ] Create `OnboardingScreen1.swift`
  - [ ] Full screen dark gradient background
  - [ ] Animated emoji transition: 📱 → 🧠
  - [ ] Headline: "You unlock your phone 150+ times per day"
  - [ ] Subtext: "Most of those times? You don't even remember doing it."
  - [ ] Primary button: "Next"
  - [ ] Auto-advance after 3 seconds
  - [ ] Haptic feedback on button tap

#### Screen 2: Solution Introduction
- [ ] Create `OnboardingScreen2.swift`
  - [ ] Phone icon transforms to shield icon (animation)
  - [ ] Soft glow effect around shield
  - [ ] Headline: "Focus Club catches you BEFORE you start scrolling"
  - [ ] Subtext: "No willpower needed. Just automatic protection."
  - [ ] Primary button: "Show me how"

#### Screen 3: Select Distracting Apps
- [ ] Create `OnboardingScreen3.swift`
  - [ ] Grid layout (2 columns)
  - [ ] Popular apps: Instagram, TikTok, Twitter, YouTube, Snapchat, Reddit, Facebook, WhatsApp
  - [ ] "Show more apps" expandable section
  - [ ] Checkbox selection with purple border on selected apps
  - [ ] Minimum 2 apps required
  - [ ] Primary button: "Continue" (disabled until 2+ selected)

#### Screen 4: Choose Protection Style (CRITICAL)
- [ ] Create `OnboardingScreen4.swift`
  - [ ] Three large cards for behavior options:
    - [ ] Block Immediately (⚡)
    - [ ] Make Me Wait First (⏱️) - default selected
    - [ ] Ask Me Every Time (💬)
  - [ ] Preview animation below cards showing behavior in action
  - [ ] Selected card: purple border + background glow
  - [ ] Primary button: "Continue"

#### Screen 5: Focus Sessions Introduction
- [ ] Create `OnboardingScreen5.swift`
  - [ ] Split screen animation (timer left, locked apps right)
  - [ ] Headline: "Need serious focus time?"
  - [ ] Subtext: "Start a Focus Session to hard-block all distracting apps"
  - [ ] Toggle: "Enable Focus Sessions" (default: ON)
  - [ ] Primary button: "Continue"

#### Screen 6: Apple Screen Time Permission
- [ ] Create `OnboardingScreen6.swift`
  - [ ] Shield icon with checkmark
  - [ ] Three benefit bullets:
    - ✓ Block apps you select
    - ✓ Track your daily habits
    - ✓ Show you real progress
  - [ ] Trust message: "We never see what you do inside apps"
  - [ ] Primary button: "Grant Permission"
  - [ ] Tapping button triggers native iOS Screen Time permission modal

#### Screen 7: iOS Screen Time Modal
- [ ] Handle system permission response
  - [ ] If "Don't Allow" → show error screen with retry button
  - [ ] If "Allow" → proceed to Screen 8

#### Screen 8: Setup Complete / Trial Start
- [ ] Create `OnboardingScreen8.swift`
  - [ ] Success animation (confetti + sparkles)
  - [ ] Large checkmark or shield icon
  - [ ] Headline: "✨ You're protected!"
  - [ ] Subtext: "Your distracting apps are now under your control"
  - [ ] CTA text: "Try opening Instagram right now and see what happens"
  - [ ] Primary button: "Start Free Trial" (7 days free)
  - [ ] Secondary link: "Already Premium? Restore"
  - [ ] Button taps → main app (Screen 9)

### Onboarding Flow Manager
- [ ] Create `OnboardingCoordinator.swift`
  - [ ] Navigate between screens
  - [ ] Save state after each screen
  - [ ] Handle back navigation (allow on screens 2-7)
  - [ ] Save selected apps to Core Data
  - [ ] Save chosen behavior to ProtectedApp records
  - [ ] Mark onboarding complete
  - [ ] Trigger trial start

**Deliverable:** Complete onboarding flow working, trial timer started

---

## Phase 5: Main App - Shield Tab (Week 3-4)
**Location:** `Views/Shield/`

### Models
- [ ] Create `Models/ShieldState.swift`
  - [ ] Track active session (if any)
  - [ ] Track protected apps list
  - [ ] Track today's stats
  - [ ] Observable/StateObject pattern

### Shield Home (No Active Session)
- [ ] Create `ShieldHomeView.swift` (Screen 9)
  - [ ] Header: "🛡️ Protection Active"
  - [ ] Card: "No Active Session"
    - [ ] Primary button: "Start Focus Session"
  - [ ] Card: "Protected Apps (3)"
    - [ ] List of protected apps with behavior icons (⏱️, 🚫, 💬)
    - [ ] "Add More Apps" button (if <3 on free tier)
  - [ ] Card: "Today's Stats"
    - [ ] "Times Saved: 12"
    - [ ] "Most Blocked: Instagram (7x)"
    - [ ] "View Details →" link to Stats tab

### Shield Home (Active Session)
- [ ] Create `ActiveSessionView.swift` (Screen 10)
  - [ ] Background image (mountains/forests, rotates every 10 min)
  - [ ] Large timer display (48pt font, minutes:seconds)
  - [ ] Circular progress ring (animated)
  - [ ] "Blocked Apps (3)" section with locked icons
  - [ ] "End Session" small text link
  - [ ] Confirmation dialog when ending early
  - [ ] Update timer every second

### Focus Session Templates
- [ ] Create `SessionTemplatesView.swift` (Screen 11)
  - [ ] Modal sheet from bottom
  - [ ] Four template cards:
    - [ ] Work Time (25 min) - free
    - [ ] Study Session (50 min) - [PRO]
    - [ ] Deep Work (90 min) - [PRO]
    - [ ] Custom Duration - [PRO]
  - [ ] Premium badge on locked templates
  - [ ] Tapping template → starts session OR goes to config screen

### Session Configuration (Premium)
- [ ] Create `SessionConfigView.swift` (Screen 12)
  - [ ] Session length stepper (±buttons, 5-120 min)
  - [ ] Break settings toggle
  - [ ] Break frequency stepper (every 25 min)
  - [ ] Break length stepper (5-15 min)
  - [ ] Intensity level radio buttons (Easy, Moderate, Hardcore)
  - [ ] "Start Session" button
  - [ ] Premium-only feature gate

### Add Protected App
- [ ] Create `AddAppView.swift` (Screen 13)
  - [ ] Search bar with app filtering
  - [ ] Popular apps grid (Instagram, Snapchat, Reddit, Facebook, etc.)
  - [ ] "All Apps" expandable section
  - [ ] Checkboxes for selection
  - [ ] Free tier limit (3 apps max) with paywall prompt
  - [ ] "Upgrade to Premium" button for upsell

### Configure App Protection
- [ ] Create `AppSettingsView.swift` (Screen 14)
  - [ ] App icon + name at top
  - [ ] Three behavior toggle sections:
    - [ ] "⚡ Block immediately" [Toggle: OFF]
    - [ ] "⏱️ Add delay before opening" [Toggle: ON]
      - [ ] Duration stepper (5-60 seconds, premium only)
    - [ ] "💬 Ask before opening" [Toggle: OFF]
  - [ ] Free tier: only ONE toggle can be enabled
  - [ ] Premium: can mix behaviors
  - [ ] Schedule Protection section (premium only):
    - [ ] Always protected toggle
    - [ ] Or custom hours (weekdays/weekends with time pickers)
  - [ ] "Save" button

**Deliverable:** Shield tab fully functional, sessions can be started/stopped

---

## Phase 6: Intervention Screens (Week 4)
**Location:** `Views/Interventions/`

### Models
- [ ] Create `Models/InterventionType.swift`
  - [ ] Enum: delay, block, ask

### Delay Intervention (one-sec style)
- [ ] Create `DelayInterventionView.swift` (Screen 21)
  - [ ] Full-screen overlay (can't dismiss or skip)
  - [ ] Calming background image (mountains/forests)
  - [ ] Breathing circle animation (expand/contract, 4s cycle)
  - [ ] Text: "Take a deep breath..."
  - [ ] Question: "Do you really want to open Instagram right now?"
  - [ ] Countdown display (10...9...8...)
  - [ ] After countdown: two buttons
    - [ ] "Yes, Open It" → opens app, logs as "loss"
    - [ ] "No, Stay Focused" → closes intervention, logs as "win"
  - [ ] Haptic feedback synced with breathing
  - [ ] Optional: Audio cue (soft tone, default off)
  - [ ] Premium: customize duration (5-60s), backgrounds, audio

### Block Intervention (No Active Session)
- [ ] Create `BlockInterventionView.swift` (Screen 22)
  - [ ] Full-screen dark background
  - [ ] Large 🚫 icon
  - [ ] Headline: "Instagram is Blocked"
  - [ ] Stats: "You've tried to open it 6 times in the last hour"
  - [ ] Reset time: "Your protection resets at 3:00 PM (in 2 hours, 15 minutes)"
  - [ ] Option: "Emergency Bypass" button
    - [ ] Shows remaining bypasses (2/3)
  - [ ] Links: "Change Protection Settings", "Start Focus Session"

### Block Intervention (During Active Session)
- [ ] Create `BlockInterventionSessionView.swift` (Screen 23)
  - [ ] Full-screen with session background
  - [ ] Large 🚫 icon
  - [ ] Headline: "Focus Session Active"
  - [ ] Time remaining: "Instagram is blocked until your session ends (18:32)"
  - [ ] Attempt count: "You've tried 4 times during this session"
  - [ ] Motivational quote (rotates):
    - "Don't give up so easily"
    - "You're 73% done. Keep going."
    - "Future you will thank you."
    - "This is what commitment looks like."
  - [ ] "🎯 Take 15min Break" button → Screen 24
  - [ ] "End Session" small text link (red)

### Break Permission (Opal style)
- [ ] Create `BreakPermissionView.swift` (Screen 24)
  - [ ] Calming mountain background
  - [ ] Headline: "Take a break for..."
  - [ ] Scrollable time picker wheel (2-15 minutes)
  - [ ] "Select" button
  - [ ] Info: "After your break, these apps will be blocked again"
  - [ ] Visual grid of app icons
  - [ ] Message: "Your focus session will resume automatically"

### Break Active (Notification)
- [ ] Create persistent notification when break active
  - [ ] Text: "Break Time: 4:35 remaining"
  - [ ] Tapping notification opens break screen
  - [ ] When break ends: "Break's over! Apps are blocked again."

### Ask Intervention (Modal)
- [ ] Create `AskInterventionView.swift` (Screen 26)
  - [ ] Modal overlay with blurred background
  - [ ] App name at top
  - [ ] Question: "Do you really need to open this right now?"
  - [ ] Two buttons:
    - [ ] "Yes, I Need It" → opens app
    - [ ] "No, I'll Skip It" → dismisses modal
  - [ ] Logs decision in stats

### Emergency Bypass (Shake Phone)
- [ ] Create `EmergencyBypassView.swift` (Screen 27)
  - [ ] Full-screen red warning
  - [ ] 🚨 icon
  - [ ] Headline: "Emergency Bypass Requested"
  - [ ] Instructions: "Shake your phone 3 times to temporarily disable protection"
  - [ ] Visual counter: ● ○ ○ → ● ● ○ → ● ● ●
  - [ ] Detect shake using Core Motion
  - [ ] Heavy haptic feedback on each shake
  - [ ] After 3 shakes:
    - [ ] "✓ Bypass Granted"
    - [ ] "Instagram is unblocked for 15 minutes"
    - [ ] "Bypasses remaining today: 2/3"
  - [ ] Premium: customize shake count, bypass duration, alternative methods (PIN, friend approval)

- [ ] Create `CoreMotionManager.swift`
  - [ ] Detect shake gestures via accelerometer
  - [ ] Threshold for sudden acceleration
  - [ ] Count shakes within 3-second window

**Deliverable:** All intervention screens functional, real-time blocking working

---

## Phase 7: Stats Tab (Week 4-5)
**Location:** `Views/Stats/`

### Today's Stats
- [ ] Create `StatsDashboardView.swift` (Screen 15)
  - [ ] Large card: "Today: Saved 18 Times"
    - [ ] Message: "You resisted mindless scrolling 18 times today. That's 2 hours of focus regained."
  - [ ] Card: "Most Blocked Today"
    - [ ] Top 3 apps with attempt counts
  - [ ] Card: "Success Rate: 73%"
    - [ ] Message: "You chose to stay focused 13 out of 18 times"
  - [ ] Card: "Total Focus Time Today"
    - [ ] Large number (2h 35m)
    - [ ] Subtitle: "Across 3 focus sessions"
  - [ ] Locked card: "Weekly Trends [PRO]"
    - [ ] Teaser + paywall button

### Weekly Stats (Premium)
- [ ] Create `WeeklyStatsView.swift` (Screen 16)
  - [ ] Line chart showing daily saves (M-S)
    - [ ] Integrate Charts library (or custom chart)
  - [ ] Total this week: "47 times saved"
  - [ ] Card: "Best Focus Days"
    - [ ] Top days with duration
  - [ ] Card: "Most Distracting Times"
    - [ ] Time slots with attempt counts
  - [ ] Tip: "Schedule focus sessions during high-risk times"

### Milestones
- [ ] Create `MilestonesView.swift` (Screen 17)
  - [ ] Grid/list of milestones:
    - [ ] ✅ First Focus Session
    - [ ] ✅ 10 Times Saved
    - [ ] 🔒 7-Day Streak (6/7 progress bar)
    - [ ] 🔒 100 Times Saved (47/100 progress bar)
    - [ ] 🔒 30-Day Challenge
  - [ ] Show completion date for unlocked milestones
  - [ ] "View All" link to detailed list

**Deliverable:** Stats tab showing real data from Core Data

---

## Phase 8: Settings Tab (Week 5)
**Location:** `Views/Settings/`

### Settings Home
- [ ] Create `SettingsView.swift` (Screen 18)
  - [ ] Account section:
    - [ ] Avatar + user name
    - [ ] Premium status: "Premium: 5 days left in trial"
    - [ ] "Manage Subscription" button → Screen 19
  - [ ] Protection Settings section:
    - [ ] "Emergency Bypasses" card
    - [ ] "3 per day remaining"
    - [ ] "Tap to configure" (premium only)
  - [ ] App Preferences section:
    - [ ] Notifications toggle [ON]
    - [ ] Haptic Feedback toggle [ON]
    - [ ] Dark Mode (locked to Always On, no toggle)
  - [ ] Support section:
    - [ ] Rate Us
    - [ ] Send Feedback
    - [ ] Privacy Policy
    - [ ] Terms of Service
  - [ ] App Version 1.0.0

### Subscription Management
- [ ] Create `SubscriptionView.swift` (Screen 19)
  - [ ] Trial countdown: "Your trial ends in 5 days"
  - [ ] Premium Benefits list (7 items with checkmarks)
  - [ ] Two plan cards:
    - [ ] Annual (highlighted as "RECOMMENDED")
      - [ ] $34.99/year
      - [ ] "Save $225 vs weekly"
      - [ ] "Just $2.92/month"
    - [ ] Weekly
      - [ ] $4.99/week
      - [ ] "($259/year)"
      - [ ] "Cancel anytime"
  - [ ] "Continue" button (selected plan)
  - [ ] Links: "Cancel trial anytime", "Terms of Service", "Privacy Policy"

### Emergency Bypass Settings (Premium)
- [ ] Create `EmergencyBypassSettingsView.swift` (Screen 20)
  - [ ] Slider: 0 — ● — 10 bypasses per day
  - [ ] Bypass Method radio buttons:
    - [ ] ● Shake phone 3 times (default)
    - [ ] ○ Enter PIN code
    - [ ] ○ Ask a friend (Accountability mode)
  - [ ] Hardcore Mode toggle [OFF]
    - [ ] Info: No bypasses, can't end sessions, friend approval to disable
    - [ ] "Learn More" link
    - [ ] Enable confirmation dialog with scary warning
  - [ ] "Save" button

**Deliverable:** Settings tab fully functional, subscription accessible

---

## Phase 9: Monetization & Paywalls (Week 5-6)
**Location:** `Views/Paywall/`, `Managers/SubscriptionManager.swift`

### StoreKit 2 Setup
- [ ] Create `Managers/SubscriptionManager.swift`
  - [ ] Define products:
    - [ ] `weekly_premium`: $4.99/week
    - [ ] `annual_premium`: $34.99/year
  - [ ] Initialize StoreKit
  - [ ] Fetch products from App Store
  - [ ] Track subscription status (@Published var)
  - [ ] Handle trial logic
  - [ ] Validate receipts
  - [ ] Restore purchases

### Free Tier Enforcement
- [ ] Create `Managers/PremiumGatekeeper.swift`
  - [ ] Check if user can add app (max 3 on free)
  - [ ] Check if can access feature (analytics, hardcore, etc.)
  - [ ] Return paywall screen if feature locked
  - [ ] Track feature gate triggers (for analytics)

### Soft Paywall (After Trial Ends)
- [ ] Create `SoftPaywallView.swift` (Screen 28)
  - [ ] Non-blocking full-screen modal
  - [ ] Headline: "Your Trial Has Ended"
  - [ ] Stats highlight: "You've been saved from distraction 94 times this week"
  - [ ] What you'll lose (list of 3 items)
  - [ ] "Upgrade to Premium" button
  - [ ] "Maybe Later" dismissible button
  - [ ] Reappears every 3 days if not upgraded

### Hard Paywall (Feature Gate)
- [ ] Create `HardPaywallView.swift` (Screen 29)
  - [ ] Blocking modal (can't dismiss)
  - [ ] 🔒 icon
  - [ ] Feature being locked: "Unlock Unlimited Apps"
  - [ ] Current free tier usage: "You're protecting: Instagram, TikTok, Twitter"
  - [ ] Call-to-action: "To add more apps, upgrade to Premium"
  - [ ] Premium features list
  - [ ] "Upgrade Now" button
  - [ ] "Cancel" button (dismisses modal, prevents action)

### Premium Purchase Flow
- [ ] Create `PremiumPaywallView.swift` (Screen 30)
  - [ ] Two plan cards (Annual "RECOMMENDED", Weekly)
  - [ ] Visual selection (purple border, background glow)
  - [ ] Premium Benefits list (7 items)
  - [ ] "Continue" button
  - [ ] Legal links: Terms, Privacy Policy
  - [ ] Tapping Continue → native StoreKit payment sheet

### Payment Success
- [ ] Create `PremiumSuccessView.swift` (Screen 31)
  - [ ] Confetti animation
  - [ ] Large ✨ or 💎 icon
  - [ ] Headline: "Welcome to Premium!"
  - [ ] Unlocked features list
  - [ ] "Get Started" button → returns to main app
  - [ ] Success haptic feedback

**Deliverable:** In-app purchases working, trials and premium features gated properly

---

## Phase 10: First Launch & Deep Links (Week 6)
**Location:** Root-level app structure

### App Delegate & Entry Point
- [ ] Create `screengateApp.swift`
  - [ ] Check if user completed onboarding
  - [ ] Route to onboarding OR main app (tabs)
  - [ ] Initialize Core Data manager
  - [ ] Request FamilyControls permission (deferred from onboarding)
  - [ ] Set up analytics event tracking
  - [ ] Set up notification listeners

### Main App Container
- [ ] Create `MainTabView.swift`
  - [ ] TabBar with 3 tabs: Shield, Stats, Settings
  - [ ] Navigation between tabs
  - [ ] Preserve scroll position when switching tabs

### Deep Linking
- [ ] Handle URL schemes for:
  - [ ] `focusclub://start-session` → start focus session
  - [ ] `focusclub://stats` → go to stats tab
  - [ ] `focusclub://settings/subscription` → open subscription
  - [ ] `focusclub://app-settings/<bundleID>` → configure specific app

**Deliverable:** App launches cleanly, user routing works (onboarding vs main app)

---

## Phase 11: Analytics & User Tracking (Week 6)
**Location:** `Managers/AnalyticsManager.swift`

### Firebase Analytics Integration
- [ ] Set up Firebase project
- [ ] Create `AnalyticsManager.swift` singleton
- [ ] Track events:
  - [ ] `onboarding_started`, `onboarding_completed`
  - [ ] `apps_selected`, `protection_style_chosen`
  - [ ] `permission_granted`, `permission_denied`
  - [ ] `session_started`, `session_completed`, `session_ended_early`
  - [ ] `intervention_shown`, `intervention_outcome`
  - [ ] `paywall_shown`, `paywall_dismissed`
  - [ ] `purchase_started`, `purchase_completed`, `purchase_failed`
  - [ ] `app_opened` (with daysInactive)
  - [ ] `app_uninstalled` (in cleanup)

### Crashlytics
- [ ] Initialize Firebase Crashlytics
- [ ] Log non-fatal errors for debugging

**Deliverable:** Analytics pipeline collecting key user events

---

## Phase 12: Testing & Quality Assurance (Week 7)
**Location:** `Tests/` folder

### Unit Tests
- [ ] Test `CoreDataManager` (CRUD operations)
- [ ] Test `StatsManager` (calculations)
- [ ] Test `SessionManager` (session logic)
- [ ] Test `SubscriptionManager` (trial logic, premium checks)
- [ ] Test milestone unlock logic
- [ ] Test date/time edge cases

### UI Testing
- [ ] Test onboarding flow (all 8 screens)
- [ ] Test app selection & protection setup
- [ ] Test session creation & timer
- [ ] Test intervention flows (delay, block, ask)
- [ ] Test paywall & purchase flow
- [ ] Test stats display

### Device Testing (Real Device Required)
- [ ] Test Screen Time API blocking on physical iPhone
- [ ] Test intervention screens when app opened
- [ ] Test notifications during sessions
- [ ] Test break system
- [ ] Test emergency bypass (shake detection)
- [ ] Test background behavior
- [ ] Test battery drain (focus sessions & monitoring)

### Manual Testing Checklist
- [ ] Permissions granted/denied scenarios
- [ ] Trial countdown accuracy
- [ ] Stats calculations correctness
- [ ] Free tier limits enforced (3-app max)
- [ ] Premium features accessible after purchase
- [ ] App state persistence (force-quit app)
- [ ] Network issues (if future backend added)
- [ ] Accessibility (VoiceOver, Dynamic Type)
- [ ] Dark mode all screens
- [ ] Landscape orientation (iPad future-proofing)

### Performance Testing
- [ ] App launch time (<2 seconds)
- [ ] Tab switching latency
- [ ] Session timer accuracy
- [ ] Core Data query performance (100+ intervention logs)
- [ ] Memory usage (watch for leaks)
- [ ] Battery impact (background monitoring)

**Deliverable:** >95% crash-free rate, all critical flows tested

---

## Phase 13: App Store Submission (Week 7-8)
**Location:** App Store Connect

### App Store Assets
- [ ] App Icon: 1024x1024 (all required sizes auto-generated)
- [ ] Screenshots:
  - [ ] Screenshot 1: Hero (problem statement)
  - [ ] Screenshot 2: Solution (intervention shown)
  - [ ] Screenshot 3: Stats dashboard
  - [ ] Screenshot 4: Focus sessions
  - [ ] Screenshot 5: Customization per-app
  - [ ] Screenshot 6: Social proof (testimonials)
  - [ ] Screenshot 7: Premium CTA
  - [ ] Generate for all 6 screen sizes (6.7", 6.5", 5.5", 5.8", etc.)

- [ ] App Preview Video (15-30 seconds)
  - [ ] 0-2s: Problem (150+ unlocks/day)
  - [ ] 3-5s: Solution (breathing screen appears)
  - [ ] 6-8s: Benefit (user pauses, closes phone)
  - [ ] 9-11s: Results (stats showing saves)
  - [ ] 12-14s: Call-to-action (app icon, "Start free trial")
  - [ ] Export as H.264, max 500MB, muted autoplay

### App Store Connect Setup
- [ ] App Name: "Focus Club" (or "Focus Club: Block Distractions")
- [ ] Subtitle (30 chars): "Screen Time Manager & Focus Timer"
- [ ] Description (first 3 lines visible):
  ```
  Stop mindless scrolling. Start focusing.
  
  Focus Club combines breathing delays (like one-sec) with hard blocking 
  (like Opal) to help you regain control over your phone.
  ```
- [ ] Full description (170 chars):
  - [ ] How it works
  - [ ] Key features
  - [ ] Focus sessions concept
  - [ ] Stats tracking
  - [ ] Premium benefits

- [ ] Keywords (100 chars):
  ```
  screen time, focus timer, app blocker, productivity, digital wellbeing, 
  social media blocker, distraction blocker, pomodoro, deep work
  ```

- [ ] Support URL: [Your website or support page]
- [ ] Privacy Policy URL: [Linked from website]
- [ ] Age Rating: 4+ (no objectionable content)

### Privacy & Legal
- [ ] Privacy Policy document (required for Screen Time API)
  - [ ] Explain data collection (local only, no server)
  - [ ] Explain Screen Time API usage
  - [ ] Explain permissions requested
  - [ ] Publish on website

- [ ] Terms of Service (optional but recommended)
  - [ ] Subscription terms
  - [ ] Trial terms
  - [ ] Refund policy
  - [ ] Liability disclaimers

### Pre-Submission QA
- [ ] TestFlight build (Internal testing)
  - [ ] Invite 5-10 internal testers
  - [ ] Wait 24+ hours for processing
  - [ ] Test all critical flows
  - [ ] Document any bugs found

- [ ] TestFlight build (External testing)
  - [ ] Invite 50+ beta users if possible
  - [ ] Collect feedback for 1 week
  - [ ] Fix critical issues
  - [ ] Monitor crash reports

### App Store Review Preparation
- [ ] Review guideline checklist:
  - [ ] No private APIs (only official FamilyControls)
  - [ ] Clear subscription terms (7-day trial, auto-renewal)
  - [ ] No misleading marketing
  - [ ] Appropriate content rating
  - [ ] Proper permissions disclosure

- [ ] Prepare App Review notes:
  - [ ] Explain Screen Time API usage
  - [ ] Demo account credentials (if needed)
  - [ ] Key features & differentiators
  - [ ] Any non-obvious functionality

### Submission
- [ ] Build for release (not debug)
- [ ] Increment version (1.0.0)
- [ ] Upload to TestFlight
- [ ] Wait for processing (1-2 hours)
- [ ] Mark build as ready for review
- [ ] Submit to App Review
- [ ] Monitor review status daily
- [ ] Respond to reviewer questions within 48 hours
- [ ] Expected review time: 24-48 hours

**Deliverable:** App submitted to App Store, awaiting approval

---

## Phase 14: Soft Launch (Week 9)
**Countries:** Canada, Australia  
**Goal:** Test conversion metrics, gather initial feedback

### Launch Activities
- [ ] Release to App Store (both countries)
- [ ] Monitor analytics daily:
  - [ ] Onboarding completion rate
  - [ ] Trial-to-paid conversion (target 15%+)
  - [ ] D1 retention (target 40%+)
  - [ ] Crash rates
- [ ] Gather App Store reviews (target 4+ stars)
- [ ] Respond to reviews (especially 1-2 star reviews)
- [ ] Monitor support emails
- [ ] Fix critical bugs ASAP

### Metrics Tracking
- [ ] Download count
- [ ] Onboarding completion %
- [ ] Permission grant rate
- [ ] Trial start rate
- [ ] Trial-to-paid conversion %
- [ ] Session completion rate
- [ ] Intervention success rate
- [ ] Crash-free rate

### Success Criteria
- [ ] No critical bugs
- [ ] 15%+ trial-to-paid conversion
- [ ] 4+ star average rating
- [ ] <0.5% crash rate
- [ ] 40%+ D1 retention

**Deliverable:** Metrics validated, feedback collected

---

## Phase 15: Full Launch (Week 10)
**Countries:** US, UK, EU  
**Goal:** Scale to mainstream markets

### Press & Media Outreach
- [ ] Contact TechCrunch, MacStories, AppStore Stories
- [ ] Reach out to productivity YouTubers:
  - [ ] Ali Abdaal
  - [ ] Thomas Frank
  - [ ] Matt D'Avella
- [ ] Reddit posts:
  - [ ] r/productivity
  - [ ] r/getdisciplined
  - [ ] r/nosurf
  - [ ] r/iOS

- [ ] Twitter/X threads from founder account

### Product Hunt Launch
- [ ] Create compelling Product Hunt post
- [ ] Target for top 5-10 ranking
- [ ] Engage with comments throughout launch day
- [ ] Plan for ~500+ upvotes if quality content

### Paid Acquisition (Optional)
- [ ] Apple Search Ads: Start with $500-1000 budget
  - [ ] Keywords: "screen time", "app blocker", "focus timer"
  - [ ] Target iOS 15+ users
  - [ ] Monitor CPI and conversion

### Social Media Launch
- [ ] Twitter/X: Daily productivity tips, user success stories
- [ ] Instagram: Before/after stats graphics
- [ ] TikTok: 15-30s demos of app in action
- [ ] Email: Send to existing audience (if any)

**Deliverable:** App visible to mainstream market, download spike expected

---

## Phase 16: Post-Launch Iteration (Week 11+)
**Goal:** Optimize for conversion, retention, and revenue

### Analytics Review (Bi-Weekly)
- [ ] Analyze user funnels:
  - [ ] Download → Onboarding completion drop-off
  - [ ] Onboarding → Permission grant drop-off
  - [ ] Permission → First intervention (aha moment)
  - [ ] First intervention → First session
  - [ ] First session → Trial → Paid conversion
- [ ] Identify biggest drop-off points
- [ ] Prioritize fixes for top 2 bottlenecks

### A/B Testing Plan
- [ ] Week 1: A/B test onboarding copy (current vs simplified)
- [ ] Week 2: A/B test paywall timing (Day 5 vs Day 7)
- [ ] Week 3: A/B test paywall messaging (social proof vs features)
- [ ] Week 4: A/B test pricing (current vs alternative)

### User Feedback Collection
- [ ] Read all App Store reviews
- [ ] Categorize feedback (features, bugs, pricing, UX)
- [ ] Create spreadsheet of top requests
- [ ] Address top 3 bugs/requests in V1.1

### V1.1 Feature Planning
- [ ] Top 3 bug fixes based on crash logs
- [ ] Top 2 user-requested features
- [ ] Paywall/pricing adjustments based on A/B tests
- [ ] Onboarding flow optimizations

**Deliverable:** Feedback loop established, iterative improvements planned

---

## Summary of Files to Create

### Core Structure
```
screengate/
├── screengate/
│   ├── screengateApp.swift (entry point)
│   ├── MainTabView.swift
│   │
│   ├── Theme/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   ├── Animations.swift
│   │   └── ViewModifiers.swift
│   │
│   ├── Views/
│   │   ├── Components/
│   │   │   ├── PrimaryButton.swift
│   │   │   ├── CardView.swift
│   │   │   ├── StatsCard.swift
│   │   │   ├── ProgressRing.swift
│   │   │   ├── TabBar.swift
│   │   │   └── ToggleSwitch.swift
│   │   │
│   │   ├── Onboarding/
│   │   │   ├── OnboardingCoordinator.swift
│   │   │   ├── OnboardingScreen1.swift
│   │   │   ├── OnboardingScreen2.swift
│   │   │   ├── OnboardingScreen3.swift
│   │   │   ├── OnboardingScreen4.swift
│   │   │   ├── OnboardingScreen5.swift
│   │   │   ├── OnboardingScreen6.swift
│   │   │   ├── OnboardingScreen7.swift
│   │   │   └── OnboardingScreen8.swift
│   │   │
│   │   ├── Shield/
│   │   │   ├── ShieldHomeView.swift
│   │   │   ├── ActiveSessionView.swift
│   │   │   ├── SessionTemplatesView.swift
│   │   │   ├── SessionConfigView.swift
│   │   │   ├── AddAppView.swift
│   │   │   └── AppSettingsView.swift
│   │   │
│   │   ├── Interventions/
│   │   │   ├── DelayInterventionView.swift
│   │   │   ├── BlockInterventionView.swift
│   │   │   ├── BlockInterventionSessionView.swift
│   │   │   ├── BreakPermissionView.swift
│   │   │   ├── AskInterventionView.swift
│   │   │   ├── EmergencyBypassView.swift
│   │   │   └── BreakNotificationView.swift
│   │   │
│   │   ├── Stats/
│   │   │   ├── StatsDashboardView.swift
│   │   │   ├── WeeklyStatsView.swift
│   │   │   └── MilestonesView.swift
│   │   │
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── SubscriptionView.swift
│   │   │   └── EmergencyBypassSettingsView.swift
│   │   │
│   │   └── Paywall/
│   │       ├── SoftPaywallView.swift
│   │       ├── HardPaywallView.swift
│   │       ├── PremiumPaywallView.swift
│   │       └── PremiumSuccessView.swift
│   │
│   ├── Models/
│   │   ├── OnboardingState.swift
│   │   ├── ShieldState.swift
│   │   ├── InterventionType.swift
│   │   └── (Core Data models - see Phase 2)
│   │
│   └── Managers/
│       ├── CoreDataManager.swift
│       ├── UserManager.swift
│       ├── ProtectedAppManager.swift
│       ├── SessionManager.swift
│       ├── StatsManager.swift
│       ├── MilestoneManager.swift
│       ├── DeviceActivityManager.swift
│       ├── SharedContainerManager.swift
│       ├── SubscriptionManager.swift
│       ├── PremiumGatekeeper.swift
│       ├── CoreMotionManager.swift
│       └── AnalyticsManager.swift
│
├── Shared/
│   └── (Data models shared with extensions)
│
├── DeviceActivityMonitorExtension/
│   ├── DeviceActivityMonitorExtension.swift
│   └── Info.plist
│
├── ShieldConfigurationExtension/
│   ├── ShieldConfigurationExtension.swift
│   └── Info.plist
│
├── ShieldActionExtension/
│   ├── ShieldActionExtension.swift
│   └── Info.plist
│
└── Tests/
    └── (Unit & UI tests)
```

---

## Development Timeline

| Phase | Duration | Key Deliverable |
|-------|----------|-----------------|
| 0 | Week 0 | Project setup, entitlements, git |
| 8 | Week 1 | Design system complete |
| 2 | Week 1-2 | Core Data + models |
| 3 | Week 2 | Device Activity integration |
| 4 | Week 2-3 | Onboarding flow (8 screens) |
| 5 | Week 3-4 | Shield tab (6 screens) |
| 6 | Week 4 | Interventions (7 screens) |
| 7 | Week 4-5 | Stats tab (3 screens) |
| 8 | Week 5 | Settings tab (3 screens) |
| 9 | Week 5-6 | Monetization (paywalls + StoreKit) |
| 10 | Week 6 | App launch & deep linking |
| 11 | Week 6 | Analytics integration |
| 12 | Week 7 | Testing & QA |
| 13 | Week 7-8 | App Store submission |
| 14 | Week 9 | Soft launch (Canada, Australia) |
| 15 | Week 10 | Full launch (US, UK, EU) |
| 16 | Week 11+ | Post-launch optimization |

**Total: 10-12 weeks to App Store release**

---

## Critical Success Factors

✅ **Must complete before launch:**
- Phase 0-8: Core infrastructure & design system
- Phase 1-6: All screens implemented
- Phase 9: StoreKit integration (monetization)
- Phase 12: Testing on real device (Screen Time API)
- Phase 13: App Store submission & approval

⚠️ **Can defer post-launch (V1.1+):**
- Advanced analytics (weekly trends, charts)
- Hardcore mode with friend approval
- Accountability features
- Widgets
- iPad version
- Localization

---

## Risk Mitigations

| Risk | Mitigation |
|------|-----------|
| Screen Time API complexity | Start Phase 3 early, test on real device |
| Weekly pricing rejection | Have $6.99/month alternative ready |
| Low conversion rate | A/B test paywall early (soft launch) |
| High churn rate | Plan engagement features (streaks, notifications) |
| Competition from Opal/One-sec | Focus on UX & customer support |
| App approval delay | Submit early, prepare App Review notes |
| Bugs in Device Activity extension | Extensive testing on iPhone, not simulator |

---

## Notes for Development

1. **Start simple:** Implement MVP first (phases 0-9), add complexity later
2. **Test early:** Device testing for Screen Time API can't be deferred
3. **Track metrics:** Set up analytics from day 1 for informed decisions
4. **Iterate fast:** Launch soft, get feedback, iterate before full launch
5. **Document code:** Future-proof with clear comments and architecture
6. **Keep users in mind:** Every screen should feel intentional & delightful

---

**Good luck! Ship V1, learn from users, iterate. 🚀**
