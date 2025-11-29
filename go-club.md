# ScreenGate: Screen Time Management App – Detailed Storyboard

> **Design Principle**: Beautiful UI inspired by **Go Club**, with core functionality modeled after **one-sec.app** and **opal.so**

---

## 🎨 Design System Overview

| Element             | Specification                                  |
|---------------------|-----------------------------------------------|
| **Primary Color**   | `#0A1F44` (Deep navy blue)                    |
| **Accent Gradient** | Blue → Purple (`#1A56DB` → `#6B46C1`)         |
| **Highlight**       | Yellow (`#FFD700`) for CTAs and key metrics    |
| **Text Color**      | White (`#FFFFFF`) on dark background           |
| **Typography**      | SF Pro (iOS system font)                      |
| **Layout Style**    | Card-based, rounded corners, bottom navigation|

---

## 📱 Full User Journey (25 Screens)

### 1. Splash Screen (0.0 – 0.6s)

- **Visual**: Black background with glowing ScreenGate logo (gate + screen icon)
- **Animation**: Subtle blue-to-purple gradient pulse
- **Transition**: Auto-advance after 600 ms

---

### 2. Sign-In Screen (0.6 – 4.3s)

**Layout**:

> ScreenGate Logo  
> **every tap counts** ← "tap" in yellow  
> _towards a better you!_  
>   
> \[Sign in with Apple\] ← Pill button  
> \[Sign in with Google\] ← Pill button  
>   
> _By signing up, you agree to our Terms and Privacy Policy_

**Interaction**:  
→ Tap Apple/Google → Native auth flow with Face ID

---

### 3. Apple Sign-In Flow (4.3 – 10.8s)

- System permission dialog
- Email sharing options
- Face ID authentication
- Returns to app on success

---

### 4. Primary Goal Selection (10.8 – 16.5s)

**Options** (single select):

- 🔷 **Deep Work** – For productivity focus
- 🌿 **Digital Detox** – For screen time reduction

**UI**: Toggle buttons with yellow border on selection  
**Next**: Enabled only after selection

---

### 5. Screen Time Habits (16.5 – 22.2s)

**User Profile** (single select):

- ⚫ **Heavy User** – 5+ hours/day
- ⚪ **Moderate User** – 3–5 hours/day ← *Selected*
- ⚪ **Light User** – 1–3 hours/day
- ⚪ **Minimal User** – <1 hour/day

---

### 6. Focus Frequency (22.2 – 27.9s)

**Schedule** (single select):

- `1 day/week` | `2 days/week` | `3 days/week`
- `4 days/week` | `5–6 days/week` ← *Selected* | `Daily`

**Layout**: 2×3 grid with consistent card styling

---

### 7. Daily Focus Goal (27.9 – 40.5s)

**Controls**:

- **Display**: `2.5 hours` (large centered text)
- **Adjusters**: `[-]` and `[+]` buttons
- **Info**: _"2–3 hours: Recommended for heavy users"_
- **Action**: `[Done]` button

**User Flow**:  
2.5h → tap `[+]` → 3.0h → `[Done]`

---

### 8. Screen Time Permission (40.5 – 46.2s)

**Content**:

> 🔗 **link to Screen Time**  
> With this access, we can create a more personalized experience  
>   
> _Your usage data is never stored or shared. It remains private and is used only to enhance your experience._

**Button**: `[Continue]` (yellow highlight)

---

### 9. System Permission Dialog (46.2 – 51.9s)

**iOS Native Screen**:

- **Toggle**: `Distracted Time` ← *Enabled*
- **Toggle**: `App Usage` ← *Enabled*
- **Action**: `[Allow]` → Face ID → Return to app

---

### 10. Plan Generation (51.9 – 57.6s)

**Visual**:

- Animated blue particle dots forming circular patterns
- Text: _"here's something just for you"_
- Subtext: _"Sit back, relax, and let ScreenGate AI do the thinking"_

**Duration**: 5.7 seconds (loading state)

---

### 11. Plan Ready (57.6 – 63.3s)

**Content**:

> 🎯 **your plan is ready! are you?**  
> Start your first week journey with us for free!

**Today's Plan**:

- 📅 **Today**: Work Session (3 hours)
- 📅 **Tomorrow**: Digital Detox (No social media)

**CTA**: `[Let's GO!]` (large yellow button)

---

### 12. Main Dashboard (63.3 – 71.2s)

**Layout**:

> **Good evening. Let's finish strong!**  
>   
> 🎁 _Start your journey today! First week's on us._  
>   
> 🎯 **TODAY'S GOAL**  
> Deep Work Session  
> 3 hours • 12 tasks  
>   
> ⚡ **Focus Window**  
> Turn on Screen Time to know the best time for focus  
>   
> 📊 **38.7% Completed**  
> \[View Plan\]

**Navigation**: `Focus | Schedule | Profile`

---

### 13. Focus Session Setup (71.2 – 76.9s)

**Customization**:

- **Duration**: Slider (30 min ↔ 4 hours) → *2 hours*
- **Options**:
  - ☑️ Block distracting apps
  - ☐ Enable focus sounds
- **Action**: `[Begin Session]`

---

### 14. Active Focus Session (76.9 – 82.6s)

**Live Display**:
01:59:23
┌──────────────┐
│██████████ │ 72%
└──────────────┘

⏱️ Time focused: 23 min
🚫 Distractions avoided: 5

[End Session]


**Features**: Real-time updates, app blocking active

---

### 15. Session Complete (82.6 – 88.3s)

**Celebration Screen**:

> 🎉 **Great job!**  
> You completed 100% of your focus session

**Stats**:

- ✅ Time focused: **2 hours**
- ✅ Distractions avoided: **8**
- ✅ Tasks completed: **12**

**Visual**: Circular progress chart with confetti animation

---

### 16. Weekly Plan (88.3 – 94.0s)

**Week 1: Digital Detox Plan**  
_Achieve consistent screen time reduction_

**Daily Schedule**:

- **Day 1**: Deep Work Session (3h)
- **Day 2**: Social Media Block (4h)
- **Day 3**: Focus Mode (2h)
- **Day 4**: Complete Digital Detox (6h)
- **Day 5**: Study Session (3h)
- **Day 6**: No Screen Time (4h)
- **Day 7**: Reflection & Reset

---

### 17. Analytics (94.0 – 100.7s)

**Dashboard**:

- **Period**: `Day` | `Week` | `Month`
- **Chart**: Bar graph showing daily usage
- **Insight**: _"21% lower than last week"_ ✅
- **Breakdown**:
  - Social Media: 42% 🔴
  - Work: 28% 🔵
  - Entertainment: 30% 🟢
- **Tip**: _"Block social media during work hours"_

---

### 18. Subscription Screen (100.7 – 106.4s)

**Plans**:

| Plan       | Price         | Savings        |
|------------|---------------|----------------|
| Monthly    | $9.99/mo      | —              |
| **Yearly** | **$59.99/yr** | **Save 50%** ⭐ |
| Lifetime   | $149.99       | One-time       |

**CTA**: `[Continue]` (for selected plan)

---

### 19. App Store Flow (106.4 – 112.1s)

**System Screen**:

> ScreenGate Plus  
> $59.99 per year  
> Starting today • Cancel anytime  
>   
> \[Confirm with Side Button\]

**Process**: Face ID → Payment confirmation → Return to app

---

### 20. Premium Features (112.1 – 117.8s)

**Unlocked Features**:

- 📈 **Advanced Analytics** – Usage patterns & trends
- 🎨 **Custom Focus Modes** – Create your scenarios
- 🤖 **AI Recommendations** – Personalized tips
- 📱 **Widget Collection** – Premium home screen widgets

**CTA**: `[Let's Go!]`

---

### 21. Profile & Settings (117.8 – 123.5s)

**Menu**:

- 👤 **Focus Goals**
- 🚫 **Blocked Apps**
- 🔔 **Notifications**
- 🎨 **App Appearance** (Dark/Light/System)
- 💳 **Subscription** *(Plus badge)*
- 🔙 **Log Out**

---

### 22. Focus Mode Themes (123.5 – 129.2s)

**Theme Gallery** (2×3 grid):

- 🌌 **Dark Blue** (default)
- 🌊 **Ocean** (blue-green)
- 🌲 **Forest** (green-brown)
- 🌅 **Sunset** (orange-purple)
- ⚪ **Minimal** (black-white)
- ☀️ **Classic** (light mode)

**Preview**: Live focus session mockup for each theme

---

### 23. App Blocker (129.2 – 134.9s)

**Interface**:

> \[🔍 Search Apps\]  
>   
> 📱 **Social Media**  
> ☑️ Instagram    ☑️ TikTok  
> ☑️ Facebook     ☑️ Twitter  
>   
> 🎮 **Entertainment**  
> ☑️ YouTube      ☑️ Netflix  
> ☑️ Spotify  
>   
> \[Select All\]

**Function**: Toggle individual apps or select by category

---

### 24. Widget Configuration (134.9 – 140.6s)

**Available Widgets**:

- ⏱️ **Focus Time Counter** (Small)
- 📊 **Daily Screen Time** (Medium)
- 📈 **Weekly Progress** (Large)
- 🏠 **Distraction Free Time** (Extra Large)

**Instructions**:  
_"Long press home screen > Edit Home Screen > Add Widget"_

---

### 25. Dashboard (Premium) (140.6 – 146.3s)

**Enhanced Features**:

- 👑 **Premium badge** in header
- 📈 **AI-powered recommendations** in progress card
- ⚡ **Optimized Focus Window** times
- 📊 **Additional analytics metrics**

**Status**: Full functionality unlocked with custom theme applied

---

## ⚙️ Technical Implementation

### Color System

```swift
struct ColorPalette {
    static let primary = UIColor(hex: "#0A1F44")
    static let gradientStart = UIColor(hex: "#1A56DB")
    static let gradientEnd = UIColor(hex: "#6B46C1")
    static let accent = UIColor(hex: "#FFD700") // Yellow
    static let text = UIColor.white
}
```

### Core Technologies

- **Authentication**: Sign in with Apple / Google
- **Permissions**: Screen Time API integration
- **Data Storage**: CoreData for user preferences and plans
- **UI Framework**: UIKit with custom animations
- **Home Screen**: WidgetKit for interactive widgets
- **Monetization**: StoreKit for subscription management

### Accessibility Compliance

- ✅ **Dynamic Type support** for all text
- ✅ **Full VoiceOver compatibility**
- ✅ **Minimum 4.5:1 contrast ratio**
- ✅ **Respects Reduce Motion system setting**

---

## 🚀 Development Roadmap

### Phase 1: Foundation (Weeks 1–2)
- Project setup & clean architecture
- Implement design system and theming
- Authentication flow (Apple/Google)
- Onboarding and goal selection screens

### Phase 2: Core Features (Weeks 3–4)
- Screen Time API integration
- Focus session timer and app blocking
- Dashboard with real-time progress
- Basic analytics and weekly plan generation

### Phase 3: Premium Tier (Weeks 5–6)
- Subscription system with StoreKit
- Advanced analytics dashboard
- Custom focus modes and themes
- Home screen widgets (all sizes)

### Phase 4: Launch Preparation (Weeks 7–8)
- Comprehensive QA and bug fixing
- App Store metadata and screenshots
- Privacy policy and compliance review
- Launch monitoring and feedback system

---

## 📊 Success Metrics & KPIs

### User Engagement Targets
- **Daily Active Users**: 10,000+ within 3 months
- **Session Completion Rate**: 85%+ average
- **Retention Rate**: 70% Day 7, 40% Day 30
- **Subscription Conversion**: 15%+ from free trial

### Technical Performance
- **App Launch Time**: <2 seconds
- **Memory Usage**: <50MB during active sessions
- **Battery Impact**: <5% during focus sessions
- **Crash Rate**: <0.1% across all versions

---

## 🔒 Privacy & Security

### Data Protection
- **Zero Knowledge Architecture**: Usage data never leaves device
- **On-Device Processing**: All AI calculations performed locally
- **No Third-Party Analytics**: User behavior tracking disabled by default
- **GDPR Compliant**: Full data portability and deletion rights

### Security Measures
- **End-to-End Encryption**: All subscription and user data
- **Biometric Authentication**: Face ID / Touch ID required for sensitive actions
- **Regular Security Audits**: Quarterly penetration testing
- **Privacy by Design**: Minimal data collection principles

---

## 🎯 Competitive Analysis

### Key Differentiators
1. **AI-Powered Personalization**: Adaptive focus schedules based on usage patterns
2. **Beautiful Design System**: Premium UI inspired by top wellness apps
3. **Comprehensive Free Tier**: Full functionality without upfront payment
4. **Cross-Platform Ecosystem**: Widgets, Apple Watch app, and Safari extension

### Market Position
- **Primary Competitors**: one-sec.app, opal.so, Forest
- **Price Point**: Premium tier at $59.99/year (50% below market average)
- **Target Demographic**: Professionals 25-45, students, digital wellness enthusiasts
- **Geographic Focus**: North America, Europe, Australia - English speaking markets

---

## 📈 Monetization Strategy

### Freemium Model
- **Free Features**: Basic focus sessions, app blocking (3 apps), weekly plans
- **Premium Features**: Unlimited apps, custom themes, advanced analytics, AI recommendations
- **Trial Period**: 14-day full feature access
- **Conversion Triggers**: Usage limits, advanced analytics preview, theme customization

### Revenue Projections
- **Year 1**: $250K ARR (Annual Recurring Revenue)
- **Year 2**: $1.2M ARR with 20K paid subscribers
- **Year 3**: $3.5M ARR with 50K paid subscribers
- **LTV**: $180 per user (3-year average subscription value)

---

*This comprehensive product specification serves as the foundation for developing ScreenGate into a market-leading digital wellness application.*