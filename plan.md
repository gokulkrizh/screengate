# Focus Club - Complete App Specification
**Version 1.0 | Created: November 2024**

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Product Overview](#product-overview)
3. [Complete Feature List](#complete-feature-list)
4. [Visual Design System](#visual-design-system)
5. [Screen-by-Screen Storyboard](#screen-by-screen-storyboard)
6. [Technical Architecture](#technical-architecture)
7. [Monetization Strategy](#monetization-strategy)
8. [Go-to-Market Strategy](#go-to-market-strategy)
9. [Success Metrics](#success-metrics)
10. [Critical Challenges & Warnings](#critical-challenges-warnings)
11. [Implementation Checklist](#implementation-checklist)

---

## Executive Summary

**App Name:** Focus Club

**Tagline:** Stop mindless scrolling. Start focusing.

**Core Value Proposition:** Combines one-sec.app's friction-based interventions with Opal's blocking system to help users regain control over their screen time.

**Target Audience:** Mass market - students, professionals, and anyone struggling with digital distractions

**Business Model:** Freemium with 7-day trial
- Free: 3 apps, basic features
- Premium: $4.99/week or $34.99/year

**Key Differentiator:** First app to combine both friction delays (breathing exercises) AND hard blocking (focus sessions) in a single, intuitive interface.

---

## Product Overview

### Problem Statement
- Average user unlocks phone 150+ times per day
- Most opens are mindless, automatic behaviors
- Existing solutions either add friction OR block apps, not both
- Apple's Screen Time is too easy to ignore

### Solution
Focus Club provides **adaptive protection**:
1. **Outside focus sessions:** Breathing delays before app opens (one-sec style)
2. **During focus sessions:** Complete app blocking (Opal style)
3. **Per-app customization:** Mix behaviors (block Instagram, delay TikTok, ask for Twitter)

### User Journey
```
Download → Onboarding (30s) → Grant Permissions → Experience First Intervention → 
Start Focus Session → See Stats → Convert to Premium (Day 5-7)
```

---

## Complete Feature List

### Core Features (Available in Free & Premium)

#### 1. App Protection System
**Per-App Behavior Rules:**
- **Block Immediately:** Hard block until user manually approves
- **Add Delay:** 10-60 second breathing exercise before app opens
- **Ask First:** Simple awareness prompt ("Do you really need this?")

**Protection Modes:**
- Always On (24/7 protection)
- Focus Session Only (during timed sessions)
- Scheduled (e.g., "Block social media 9 AM - 5 PM weekdays") - Premium only

**Supported Apps:**
- Social Media: Instagram, TikTok, Twitter, Snapchat, Facebook
- Entertainment: YouTube, Netflix, Twitch
- Messaging: WhatsApp, Telegram, Discord
- Any iOS app via search

#### 2. Focus Sessions
**Pre-Built Templates:**
- Quick Focus (25 min)
- Deep Work (90 min) - Premium only
- Study Session (50 min) - Premium only
- Custom Duration - Premium only

**Session Features:**
- Visual countdown timer with progress ring
- Calming background images (mountains, forests, ocean)
- Apps automatically blocked during session
- Can't cancel without consequence (optional)
- Break system (take 5-15 min break, then auto re-block)

**Intensity Levels:**
- Easy: Can cancel anytime
- Moderate: 3 emergency bypasses allowed
- Hardcore: No escapes, friend approval required - Premium only

#### 3. Intervention Screens
**Delay Intervention (one-sec style):**
- Full-screen breathing animation or calming video
- Customizable countdown (10 seconds default, 5-60 seconds premium)
- Choice: "Yes, open it" or "No, stay focused"
- Logs user decision in stats

**Block Intervention (Opal style):**
- Shows attempt count ("You've tried 4 times in last hour")
- Time until protection resets
- Option to take temporary break (15 min access)
- Emergency bypass option (if available)

**Ask Intervention:**
- Simple modal overlay
- "Do you really need to open this?"
- One-tap yes/no decision

#### 4. Stats & Analytics
**Today View (Free):**
- Times saved from opening apps
- Most blocked app
- Total focus time
- Success rate (% of times resisted temptation)

**Weekly/Monthly Trends (Premium):**
- Daily breakdown charts
- Best focus times of day
- Worst distraction times
- Improvement trends over time

**Milestones:**
- First Focus Session ✓
- 10 Times Saved ✓
- 7-Day Streak 🔥
- 100 Times Saved 🏆
- 30-Day Challenge 💎

#### 5. Emergency Bypass System
**Free Tier:**
- 3 bypasses per day
- Shake phone 3 times to activate
- 15-minute temporary access granted

**Premium Tier:**
- Configurable (0-10 bypasses per day)
- Multiple bypass methods:
  - Shake phone
  - Enter PIN code
  - Ask a friend (Accountability Mode)
- Set to 0 for maximum discipline

**Hardcore Mode (Premium):**
- No bypasses allowed
- Can't end sessions early
- Can't uninstall app without friend approval
- Nuclear option for serious commitment

---

### Free Tier Limitations
- ✅ App protection (all three behaviors)
- ✅ 3 protected apps maximum
- ✅ One behavior per app (can't mix block + delay)
- ✅ 25-minute focus sessions only
- ✅ Today's stats only
- ✅ 3 emergency bypasses per day
- ❌ No custom delay duration (fixed 10 seconds)
- ❌ No scheduled protection hours
- ❌ No weekly/monthly analytics
- ❌ No hardcore mode

### Premium Tier ($4.99/week or $34.99/year)
- ✅ Unlimited protected apps
- ✅ Mix behaviors per app (block Instagram, delay TikTok, ask for Twitter)
- ✅ Custom focus session durations
- ✅ Customize delay (5-60 seconds)
- ✅ Weekly/monthly stats and trends
- ✅ Schedule protection by time/day
- ✅ Deep Work & Study templates
- ✅ Hardcore mode
- ✅ 10 emergency bypasses per day (or 0)
- ✅ Accountability mode (friend approval)
- ✅ Custom background images

---

## Visual Design System

### Design Philosophy
- **Go Club's UX structure:** Card-based layouts, clear hierarchy, minimal text
- **Focus-appropriate aesthetics:** Dark mode, calming colors, no bright gradients
- **Inspiration:** Opal's dark themes + Forest's nature imagery + Endel's ambient feel

### Color Palette

**Primary Colors:**
```
Dark Base: #0A0E27 (deep navy, almost black)
Card Background: #1A1F3A (subtle elevation)
Accent (Focus): #6C63FF (soft purple - calmer than electric blue)
Success: #4ECDC4 (muted teal)
Warning: #FFB347 (soft orange)
Destructive: #FF6B9D (soft pink-red)
Text Primary: #FFFFFF (white)
Text Secondary: #B8B8D0 (light gray)
```

**Gradients (Subtle, Not Bright):**
```
Background: linear-gradient(180deg, #0A0E27 0%, #1A1F3A 100%)
Button: linear-gradient(135deg, #6C63FF 0%, #9D8CFF 100%)
Success: linear-gradient(135deg, #4ECDC4 0%, #6DD5C3 100%)
```

**Why This Works:**
- Dark mode reduces eye strain during focus
- Purple is calmer and more focus-inducing than bright blue
- Muted accent colors don't overstimulate
- Still feels premium and modern (gradient depth)

### Typography

**Font Family:** SF Pro (Apple's system font)

**Text Styles:**
```
Display (Onboarding Headlines): SF Pro Display, Bold, 34pt
Headline (Screen Titles): SF Pro Display, Bold, 28pt
Title (Card Headers): SF Pro Text, Semibold, 20pt
Body (Main Content): SF Pro Text, Regular, 16pt
Caption (Metadata): SF Pro Text, Medium, 14pt
Button: SF Pro Text, Semibold, 18pt
```

**Hierarchy Rules:**
- One primary headline per screen
- Generous line spacing (1.4-1.6)
- Maximum 2-3 lines of body text per card
- White text on dark backgrounds (WCAG AAA contrast)

### Layout System

**Card-Based UI (Go Club Pattern):**
```
Card Properties:
- Corner radius: 16px
- Shadow: 0px 4px 20px rgba(0, 0, 0, 0.3)
- Padding inside: 16px
- Margin between cards: 20px
- Background: #1A1F3A
```

**Grid System:**
```
Screen margins: 20px left/right
Safe area insets: Automatic (iOS)
Card width: Screen width - 40px
Spacing between elements: 12px
```

**Bottom-Heavy CTAs (Go Club Style):**
```
Primary button:
- Position: Bottom of screen (16px from safe area)
- Width: Full width minus 40px margins
- Height: 56px
- Border radius: 28px (pill shape)
- Gradient background
- White text, 18pt semibold
- Drop shadow: 0px 8px 16px rgba(108, 99, 255, 0.3)
```

### Component Library

**1. Primary Button**
```
Default State:
- Background: Purple gradient (#6C63FF → #9D8CFF)
- Text: White, 18pt semibold
- Height: 56px
- Corner radius: 28px

Pressed State:
- Scale: 0.95
- Opacity: 0.8

Disabled State:
- Background: #2A2F4A (dark gray)
- Text: #6B7089 (muted gray)
```

**2. Card Component**
```
Container:
- Background: #1A1F3A
- Border radius: 16px
- Padding: 16px
- Shadow: 0px 4px 20px rgba(0, 0, 0, 0.3)

Content Layout:
- Icon/Image (optional): 40x40px, top left
- Title: 20pt semibold, white
- Description: 16pt regular, #B8B8D0
- Action (optional): Right-aligned chevron or button
```

**3. Tab Bar**
```
Background: #1A1F3A with blur effect
Height: 49px + safe area inset
Items: 3 tabs (Shield, Stats, Settings)

Tab Item:
- Icon: 24x24px SF Symbol
- Label: 12pt medium
- Active color: #6C63FF
- Inactive color: #6B7089
```

**4. Stats Card**
```
Large Number Display:
- Value: 48pt bold, white
- Label: 14pt medium, #B8B8D0
- Icon: 32x32px, tinted #6C63FF
- Background: Dark card with subtle gradient
```

**5. Toggle Switch**
```
iOS native toggle styled:
- On color: #6C63FF
- Off color: #2A2F4A
- Thumb: White
```

### Animations

**Timing Functions:**
```
Page transitions: ease-out, 300ms
Button press: ease-in-out, 100ms
Card reveal: ease-out, 400ms
Modal appearance: spring(0.6, 0.8), 500ms
Breathing animation: ease-in-out, 4000ms (loop)
```

**Key Animations:**
1. **Page Transitions:** Slide from right with fade
2. **Button Press:** Scale down to 0.95 with haptic
3. **Card Reveal:** Fade in + slide up from bottom
4. **Intervention Screen:** Full-screen fade in (dramatic)
5. **Breathing Circle:** Expand/contract smoothly (4s cycle)
6. **Progress Ring:** Animated stroke draw
7. **Success Celebration:** Confetti + scale pulse

**Haptic Feedback:**
- Button press: Light impact
- Toggle switch: Selection changed
- Emergency bypass: Heavy impact (3x)
- Session complete: Notification feedback

---

## Screen-by-Screen Storyboard

### ONBOARDING FLOW (30 seconds total)

#### Screen 1: Welcome/Problem Statement
**Duration:** 3 seconds

**Visual:**
- Full screen dark gradient background (#0A0E27 → #1A1F3A)
- Center-aligned emoji: 📱 → 🧠 (animated arrow between)
- Headline below

**Content:**
```
📱 → 🧠

You unlock your phone 
150+ times per day

Most of those times?
You don't even remember doing it.
```

**CTA:**
- Primary button at bottom: "Next"
- Auto-advances after 3 seconds or on tap

**Purpose:** Establish problem awareness

---

#### Screen 2: Solution Introduction
**Duration:** 5 seconds

**Visual:**
- Animation: Phone icon transforms into shield icon
- Soft glow effect around shield
- Subtle particle effects

**Content:**
```
Focus Club catches you
BEFORE you start scrolling

No willpower needed.
Just automatic protection.
```

**CTA:**
- Primary button: "Show me how"

**Purpose:** Position product as automatic solution (low effort)

---

#### Screen 3: Select Distracting Apps
**Duration:** 8 seconds

**Visual:**
- Grid layout (2 columns)
- App icons with labels
- Selected apps get checkmark + purple border
- "Show more apps" expandable section

**Content:**
```
Which apps distract you most?
(Select at least 2)

[Grid of app icons:]
☐ Instagram    ☐ TikTok
☐ Twitter      ☐ YouTube
☐ Snapchat     ☐ Reddit
☐ Facebook     ☐ WhatsApp

[Show more apps...]
```

**CTA:**
- Primary button: "Continue" (disabled until 2 selected)

**Interaction:**
- Tap app icon to select/deselect
- Haptic feedback on selection
- Button enables once requirement met

**Purpose:** Personalize experience immediately

---

#### Screen 4: Choose Protection Style ⚠️ CRITICAL SCREEN
**Duration:** 10 seconds

**Visual:**
- Three large cards (vertical stack)
- Each card has icon, title, description
- Selected card has purple border + background glow
- Preview animation shows behavior below cards

**Content:**
```
How should we protect you?

┌─────────────────────────┐
│ ⚡ Block Immediately     │
│ Can't open until you    │
│ manually allow it       │
└─────────────────────────┘

┌─────────────────────────┐
│ ⏱️ Make Me Wait First   │ ← Default selected
│ 10-second breathing     │
│ delay before opening    │
└─────────────────────────┘

┌─────────────────────────┐
│ 💬 Ask Me Every Time    │
│ Gentle reminder:        │
│ "Do you really need?"   │
└─────────────────────────┘

[Preview animation area]
```

**Preview Animations:**
- **Block:** App icon shakes, big red X appears, "Blocked" text
- **Delay:** Breathing circle expands/contracts, countdown timer
- **Ask:** Modal pops up with question mark

**CTA:**
- Primary button: "Continue"

**Purpose:** Let user choose their preferred intervention style

**Note:** This applies to ALL selected apps. Premium unlocks per-app customization.

---

#### Screen 5: Focus Sessions Introduction
**Duration:** 8 seconds

**Visual:**
- Split screen animation:
  - Left: Timer counting down
  - Right: Apps greyed out with lock icons
- Smooth transition between states

**Content:**
```
Need serious focus time?

Start a Focus Session to
hard-block all distracting apps
until your session ends.

[Animation showing timer + locked apps]

Perfect for:
• Work meetings
• Study sessions  
• Deep work blocks
```

**CTA:**
- Toggle switch: "Enable Focus Sessions" (default: ON)
- Primary button: "Continue"

**Purpose:** Introduce second protection mode (blocking)

---

#### Screen 6: Apple Screen Time Permission
**Duration:** 5 seconds

**Visual:**
- Shield icon with checkmark
- Three benefit bullets with icons
- Friendly, trustworthy tone

**Content:**
```
One last thing...

Focus Club needs permission to
manage your screen time.

This allows us to:
✓ Block apps you select
✓ Track your daily habits
✓ Show you real progress

[Grant Permission] ← button

Don't worry—we never see
what you do inside apps.
```

**CTA:**
- Primary button: "Grant Permission"

**Taps button → Triggers iOS Screen Time permission modal**

**Purpose:** Request critical permission with clear explanation

---

#### Screen 7: iOS Screen Time Modal
**Native iOS UI** (not customizable)

**Content:**
```
"Focus Club" Would Like to
Access Screen Time

This allows the app to monitor
and restrict your app usage.

[Don't Allow]  [Allow]
```

**If user taps "Don't Allow":**
Show error screen:
```
❌ Permission Required

Focus Club needs Screen Time
permission to protect you.

Without it, we can't block apps.

[Try Again]
```

**If user taps "Allow":**
Continue to Screen 8

---

#### Screen 8: Setup Complete / Trial Start
**Duration:** 5 seconds

**Visual:**
- Success animation (confetti + sparkles)
- Large checkmark or shield icon
- Celebration micro-animation

**Content:**
```
✨ You're protected!

Your distracting apps are now
under your control.

Try opening Instagram right now
and see what happens.

[Start Free Trial] ← 7 days free
Then $4.99/week

[Already Premium? Restore]
```

**CTA:**
- Primary button: "Start Free Trial"
- Small text link: "Already Premium? Restore"

**Purpose:** 
- Confirm setup success
- Start 7-day trial (no payment required)
- Encourage immediate testing

**After tapping button → Goes to main app (Screen 9)**

---

### MAIN APP - TAB 1: SHIELD (Home Screen)

#### Screen 9: Shield Home - No Active Session
**Default state when user opens app**

**Visual Layout:**
```
┌─────────────────────────────────────┐
│ [Status Bar]                   12:14 │
├─────────────────────────────────────┤
│                                       │
│ 🛡️ Protection Active                 │
│                                       │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │  No Active Session              │ │
│ │                                 │ │
│ │  [Start Focus Session]          │ │
│ │       ↑ Big purple button       │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Protected Apps (3)              │ │
│ │                                 │ │
│ │ ⏱️ Instagram   (10s delay)      │ │
│ │ ⏱️ TikTok      (10s delay)      │ │
│ │ ⏱️ Twitter     (10s delay)      │ │
│ │                                 │ │
│ │ [+ Add More Apps]               │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 📊 Today's Stats                │ │
│ │                                 │ │
│ │ Times Saved: 12                 │ │
│ │ Most Blocked: Instagram (7x)    │ │
│ │                                 │ │
│ │ [View Details →]                │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│                                       │
│ [Shield] [Stats] [Settings] ← Tab bar│
└─────────────────────────────────────┘
```

**Interactions:**
- Tap "Start Focus Session" → Screen 11
- Tap "Add More Apps" → Screen 13
- Tap app name → Screen 14 (configure individual app)
- Tap "View Details" → Tab 2 (Stats)
- Swipe cards left/right for more info

---

#### Screen 10: Shield Home - Session Active
**State when focus session is running**

**Visual Layout:**
```
┌─────────────────────────────────────┐
│ 🛡️ Focus Session Active             │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ [Mountain background image]     │ │
│ │                                 │ │
│ │        Work Time                │ │
│ │                                 │ │
│ │         18:32                   │ │
│ │      remaining                  │ │
│ │                                 │ │
│ │  [Circular progress ring]       │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Blocked Apps (3)                    │
│                                       │
│ 🚫 Instagram                         │
│ 🚫 TikTok                            │
│ 🚫 Twitter                           │
├─────────────────────────────────────┤
│                                       │
│           [End Session]               │
│          ↑ Small text link           │
└─────────────────────────────────────┘
```

**Timer Display:**
- Large time remaining (48pt font)
- Circular progress ring animates clockwise
- Background changes every 10 minutes (subtle transitions)

**Interactions:**
- Timer updates every second
- Tap "End Session" → Confirmation dialog:
  ```
  ⚠️ Are you sure?
  
  You'll lose your 18-minute streak.
  
  [Keep Going]  [Yes, End Session]
  ```

---

#### Screen 11: Start Focus Session (Choose Template)
**Modal sheet from bottom**

**Visual:**
```
Choose a Session

┌─────────────────────────┐
│ 🖥️ Work Time            │
│ 25 minutes              │
│ Perfect for focused     │
│ work blocks             │
└─────────────────────────┘

┌─────────────────────────┐
│ 📚 Study Session        │
│ 50 minutes              │
│ Ideal for deep learning │
│                    [PRO]│
└─────────────────────────┘

┌─────────────────────────┐
│ 🚀 Deep Work            │
│ 90 minutes              │
│ Maximum productivity    │
│                    [PRO]│
└─────────────────────────┘

┌─────────────────────────┐
│ ⚙️ Custom Duration      │
│ Set your own            │
│                    [PRO]│
└─────────────────────────┘

[Cancel]
```

**Free users:**
- Work Time (25 min) is unlocked
- Other templates show [PRO] badge
- Tapping locked templates → Paywall

**Premium users:**
- All templates unlocked
- Can customize any template

**Interaction:**
- Tap template → Starts session immediately OR
- Tap template → Screen 12 (if customization enabled)

---

#### Screen 12: Session Configuration (Premium Only)
**Edit session before starting**

**Visual:**
```
Work Time Setup

Session Length: 25 min
[−  25  +] ← Stepper

━━━━━━━━━━━━━━━━━━━━━━━━

Break Settings

Allow breaks?  [Toggle: ●]

If yes, how often?
Every 25 minutes

Break length: 5 min
[−  5  +]

━━━━━━━━━━━━━━━━━━━━━━━━

Intensity Level

[○ Easy]      Can cancel anytime
[● Moderate]  3 bypasses allowed
[○ Hardcore]  No escape

━━━━━━━━━━━━━━━━━━━━━━━━

[Start Session]
```

**Interactions:**
- +/− buttons adjust values
- Toggle enables/disables breaks
- Radio buttons select intensity
- "Start Session" → Returns to Screen 10 with active timer

---

#### Screen 13: Add Protected App
**Modal sheet or full screen**

**Visual:**
```
Add Protected App

[Search bar: "Search apps..."]

Popular Apps:

☐ Snapchat
☐ Reddit
☐ Facebook
☐ YouTube
☐ WhatsApp
☐ Discord

[All Apps →]

━━━━━━━━━━━━━━━━━━━━━━━━

FREE: 3 apps maximum
Upgrade for unlimited 🔒

[Upgrade to Premium]
```

**Free tier limitation:**
- If user already has 3 apps, checkboxes are disabled
- Show paywall message
- "Upgrade to Premium" → Screen 29

**Interactions:**
- Tap checkbox to select app
- Search bar filters app list
- "All Apps" shows full iOS app library

---

#### Screen 14: Configure App Protection (Per-App Settings)
**Available after selecting app**

**Visual:**
```
Instagram Protection

How should we protect you?

[Three toggle sections:]

⚡ Block immediately
   [Toggle: ○ OFF]

⏱️ Add delay before opening
   [Toggle: ● ON]
   Duration: 10 seconds [− +]

💬 Ask before opening
   [Toggle: ○ OFF]

━━━━━━━━━━━━━━━━━━━━━━━━

Schedule Protection [PRO 🔒]

Always protected  [Toggle: ●]

Or set specific hours:
Weekdays: 9 AM - 5 PM
Weekends: Off

━━━━━━━━━━━━━━━━━━━━━━━━

[Save]
```

**Free tier:**
- Can only enable ONE toggle (enforce exclusive choice)
- Duration locked at 10 seconds
- Scheduling section locked

**Premium tier:**
- Can mix behaviors (e.g., delay + ask)
- Adjust duration 5-60 seconds
- Set custom schedule

---

### MAIN APP - TAB 2: STATS

#### Screen 15: Stats Home
**Overview of user's impact**

**Visual:**
```
📊 Your Impact

┌─────────────────────────┐
│ Today: Saved 18 Times   │
│                         │
│ You resisted mindless   │
│ scrolling 18 times      │
│ today. That's 2 hours   │
│ of focus regained.      │
└─────────────────────────┘

┌─────────────────────────┐
│ Most Blocked Today      │
│                         │
│ 1. Instagram    7 times │
│ 2. TikTok       6 times │
│ 3. Twitter      5 times │
└─────────────────────────┘

┌─────────────────────────┐
│ Success Rate: 73%       │
│                         │
│ You chose to stay       │
│ focused 13 out of       │
│ 18 times.               │
└─────────────────────────┘

┌─────────────────────────┐
│ Total Focus Time Today  │
│                         │
│        2h 35m           │
│                         │
│ Across 3 focus sessions │
└─────────────────────────┘

┌─────────────────────────┐
│ 📈 Weekly Trends  [PRO] │
│                         │
│ See your progress over  │
│ time                    │
│                         │
│ [Unlock Premium]        │
└─────────────────────────┘
```

**Interactions:**
- Tap any card for detailed breakdown
- Locked card → Paywall

---

#### Screen 16: Weekly Stats (Premium)
**7-day trend view**

**Visual:**
```
📊 This Week

[Line graph showing daily saves:]

         ●
        ●│
       ● │
      ●  │
 ●   ●   │
●│  │   │
─┴──┴───┴───────
M  T  W  T  F  S  S

Total this week: 47 times saved

━━━━━━━━━━━━━━━━━━━━━━━━

Best Focus Days

Tuesday:  2h 35m  ← today
Monday:   1h 52m

━━━━━━━━━━━━━━━━━━━━━━━━

Most Distracting Times

3 PM - 5 PM  (12 attempts)
9 AM - 10 AM (8 attempts)

💡 Tip: Schedule focus
sessions during high-risk times.
```

**Interactions:**
- Tap data point on graph for daily detail
- Tap time slot for hourly breakdown

---

#### Screen 17: Milestones
**Achievement system**

**Visual:**
```
🏆 Milestones

Your Achievements:

✅ First Focus Session
   Completed Nov 20

✅ 10 Times Saved
   Reached Nov 21

🔒 7-Day Streak
   6/7 days complete

🔒 100 Times Saved
   47/100 (47% there)

🔒 30-Day Challenge
   Locked

[View All]
```

**Interactions:**
- Completed milestones show checkmark + date
- Locked milestones show progress bar
- "View All" → Full achievement list

---

### MAIN APP - TAB 3: SETTINGS

#### Screen 18: Settings Home
**Account & preferences**

**Visual:**
```
⚙️ Settings

━━━━━━━━━━━━━━━━━━━━━━━━

Account

[Avatar] Your Name
Premium: 5 days left in trial

[Manage Subscription]

━━━━━━━━━━━━━━━━━━━━━━━━

Protection Settings

Emergency Bypasses
3 per day remaining

[Tap to configure - PRO]

━━━━━━━━━━━━━━━━━━━━━━━━

App Preferences

Notifications         [● ON]
Haptic Feedback      [● ON]
Dark Mode            Always On

━━━━━━━━━━━━━━━━━━━━━━━━

Support

Rate Us
Send Feedback
Privacy Policy
Terms of Service

━━━━━━━━━━━━━━━━━━━━━━━━

App Version 1.0.0
```

**Interactions:**
- Tap "Manage Subscription" → Screen 19
- Tap "Emergency Bypasses" → Screen 20 (premium only)
- Toggles immediately apply changes
- Support links open respective screens

---

#### Screen 19: Manage Subscription
**Pricing & plan management**

**Visual:**
```
Premium Benefits

Your trial ends in 5 days.

Unlock full power:

✓ Unlimited protected apps
✓ Custom focus sessions
✓ Weekly analytics
✓ Scheduled protection
✓ Hardcore mode

━━━━━━━━━━━━━━━━━━━━━━━━

Choose Your Plan

┌─────────────────────────┐
│ 💎 RECOMMENDED          │
│                         │
│ Annual                  │
│ $34.99/year            │
│                         │
│ Save $225 vs weekly    │
│ Just $2.92/month       │
└─────────────────────────┘

┌─────────────────────────┐
│ Weekly                  │
│ $4.99/week             │
│ ($259/year)            │
│                         │
│ Cancel anytime         │
└─────────────────────────┘

[Start Premium]

Cancel trial anytime
```

**Interactions:**
- Tap card to select plan (purple border appears)
- "Start Premium" → iOS payment modal
- After successful payment → Screen 31

**Note:** Weekly pricing shows annual cost for transparency

---

#### Screen 20: Emergency Bypass Settings (Premium)
**Configure escape hatch**

**Visual:**
```
Emergency Bypasses

How many times can you bypass
protection per day?

[Slider: 0 ——●—— 10]
Currently: 3 times

━━━━━━━━━━━━━━━━━━━━━━━━

Bypass Method

[Radio buttons:]
● Shake phone 3 times
○ Enter PIN code
○ Ask a friend (Accountability)

━━━━━━━━━━━━━━━━━━━━━━━━

Hardcore Mode [Toggle: ○ OFF]

When enabled:
- No bypasses allowed
- Can't end sessions early
- Can't uninstall app

⚠️ Disable requires friend approval

[Learn More]

━━━━━━━━━━━━━━━━━━━━━━━━

[Save]
```

**Interactions:**
- Slider adjusts bypass limit
- Radio buttons change method
- Hardcore toggle shows confirmation:
```
  ⚠️ Enable Hardcore Mode?
  
  This will:
  • Remove all bypass options
  • Lock you into sessions
  • Require friend approval to disable
  
  Only enable if you're serious.
  
  [Cancel] [Enable]
```

---

### INTERVENTION SCREENS (User Opens Protected App)

#### Screen 21: Delay Intervention (one-sec style)
**Breathing exercise before app opens**

**Visual:**
```
[Full-screen overlay, blocks entire UI]

[Calming background: 
Mountain landscape OR 
Soft gradient animation]

[Center: Breathing circle]
○ → ● → ○ → ● 
(Expands/contracts smoothly)

Take a deep breath...

Do you really want to 
open Instagram right now?

━━━━━━━━━━━━━━━━━━━━━━━━

[10-second countdown]
10... 9... 8... 7...

━━━━━━━━━━━━━━━━━━━━━━━━

[After countdown ends:]

[Yes, Open It]  [No, Stay Focused]
```

**Behavior:**
- User CANNOT dismiss or skip countdown
- Breathing animation loops (4 seconds inhale, 4 seconds exhale)
- Haptic feedback syncs with breathing rhythm
- Audio optional (soft tone, default off)

**After countdown:**
- "Yes, Open It" → Instagram opens, logs as "loss" in stats
- "No, Stay Focused" → Returns to previous screen, logs as "win" in stats

**Premium customization:**
- Adjust countdown: 5-60 seconds
- Choose background image/video
- Enable/disable audio cue

---

#### Screen 22: Block Intervention (No Active Session)
**Hard block with attempt tracking**

**Visual:**
```
[Full-screen, dark background]

🚫

Instagram is Blocked

You've tried to open it
6 times in the last hour.

Your protection resets at 3:00 PM
(in 2 hours, 15 minutes)

━━━━━━━━━━━━━━━━━━━━━━━━

Need urgent access?

[Emergency Bypass]
(2/3 bypasses left today)

━━━━━━━━━━━━━━━━━━━━━━━━

Or:

[Change Protection Settings]
[Start a Focus Session Instead]
```

**Behavior:**
- User CANNOT open Instagram until:
  - Protection time window ends (3:00 PM)
  - Emergency bypass used
  - Settings changed

**Interactions:**
- "Emergency Bypass" → Screen 27 (shake phone)
- "Change Settings" → Screen 14 (configure app)
- "Start Focus Session" → Suggests using time productively

---

#### Screen 23: Block Intervention (During Focus Session)
**Extra friction during active session**

**Visual:**
```
[Full-screen with session background]

🚫

Focus Session Active

Instagram is blocked until
your session ends.

Time remaining: 18:32

━━━━━━━━━━━━━━━━━━━━━━━━

You've tried to open it
4 times during this session.

[Motivational quote, rotates:]
"Don't give up so easily"
"You're 73% done. Keep going."
"Future you will thank you."
"This is what commitment looks like."

━━━━━━━━━━━━━━━━━━━━━━━━

[🎯 Take 15min Break]
Apps will re-block after

━━━━━━━━━━━━━━━━━━━━━━━━

[End Session] ← small red text
```

**Behavior:**
- Shows attempt count (shame/awareness)
- Random motivational messages
- Option to take break without ending session

**Interactions:**
- "Take Break" → Screen 24 (choose break duration)
- "End Session" → Confirmation dialog:
```
  ⚠️ End Session Early?
  
  You'll lose your 18-minute
  focus streak.
  
  [Keep Going] [Yes, End It]
```

---

#### Screen 24: Break Permission (Opal style)
**Choose break duration**

**Visual:**
```
[Calming mountain background]

Take a break for...

[Scrollable picker wheel:]
2
3
4
5 min ← selected
6
7
8
10
15

[Select]

━━━━━━━━━━━━━━━━━━━━━━━━

After your break, these apps
will be blocked again:

[Visual grid of app icons]
📱 Instagram
📱 TikTok
📱 Twitter

━━━━━━━━━━━━━━━━━━━━━━━━

Your focus session will resume
automatically.
```

**Behavior:**
- Scroll wheel to select 2-15 minutes
- Can't select longer than remaining session time
- Apps temporarily unblock during break

**Interaction:**
- "Select" → Apps unblock, timer starts, returns to home screen
- Shows persistent notification: "Break: 4:35 remaining"

---

#### Screen 25: Break Active (System Notification)
**iOS home screen banner**

**Visual:**
```
┌─────────────────────────────┐
│ ⏱️ Focus Club               │
│                             │
│ Break Time: 4:35 remaining  │
│                             │
│ Apps will re-block          │
│ automatically. Tap to view. │
└─────────────────────────────┘
```

**Behavior:**
- Persistent notification at top of screen
- Updates every second
- Tapping opens app to break screen

**When break ends:**
```
┌─────────────────────────────┐
│ 🛡️ Focus Club               │
│                             │
│ Break's over!               │
│                             │
│ Apps are blocked again.     │
│ 18:32 left in your session. │
└─────────────────────────────┘
```

---

#### Screen 26: Ask Intervention (Simplest)
**Awareness prompt**

**Visual:**
```
[Modal overlay, blurred background visible]

┌─────────────────────────┐
│                         │
│      Instagram          │
│                         │
│ Do you really need      │
│ to open this right now? │
│                         │
│ [Yes, I Need It]        │
│                         │
│ [No, I'll Skip It]      │
│                         │
└─────────────────────────┘
```

**Behavior:**
- Lightest intervention (no delay, just awareness)
- User can dismiss by choosing
- Logs choice in stats

**Interactions:**
- "Yes, I Need It" → Opens app immediately
- "No, I'll Skip It" → Dismisses modal, returns to previous screen

---

#### Screen 27: Emergency Bypass (Shake Phone)
**Escape hatch activation**

**Visual:**
```
[Full-screen, haptic-heavy]

🚨

Emergency Bypass Requested

Shake your phone 3 times 
to temporarily disable protection.

[Visual indicator:]
Shake counter: 0 / 3

━━━━━━━━━━━━━━━━━━━━━━━━

[User shakes phone]

[Progress updates:]
● ○ ○  →  ● ● ○  →  ● ● ●

━━━━━━━━━━━━━━━━━━━━━━━━

[After 3 shakes:]

✓ Bypass Granted

Instagram is unblocked 
for 15 minutes.

Bypasses remaining today: 2/3

[Okay]
```

**Behavior:**
- Detects shake gestures via Core Motion
- Heavy haptic feedback on each shake
- 15-minute temporary unblock
- Auto re-blocks after time expires

**Premium options:**
- Increase/decrease shake count
- Extend/reduce bypass duration
- Alternative methods (PIN code, friend approval)

---

### PAYWALL SCREENS

#### Screen 28: Soft Paywall (After Trial Ends)
**Non-blocking reminder**

**Visual:**
```
━━━━━━━━━━━━━━━━━━━━━━━━

Your Trial Has Ended

You've been saved from 
distraction 94 times this week.

To keep your protection active,
upgrade to Premium today.

━━━━━━━━━━━━━━━━━━━━━━━━

What You'll Lose:

❌ Unlimited app protection
   (limited to 3 apps)
   
❌ Custom focus sessions
   (25-min only)
   
❌ Weekly analytics
   (today only)

━━━━━━━━━━━━━━━━━━━━━━━━

[Upgrade to Premium]
$4.99/week or $34.99/year

[Maybe Later]
```

**Behavior:**
- Appears on Day 8 when opening app
- Can dismiss with "Maybe Later"
- Re-appears every 3 days until upgraded

---

#### Screen 29: Hard Paywall (Trying to Add 4th App)
**Feature gate**

**Visual:**
```
🔒 Unlock Unlimited Apps

Free plan: 3 apps maximum

You're currently protecting:
- Instagram
- TikTok
- Twitter

To add more apps, 
upgrade to Premium.

━━━━━━━━━━━━━━━━━━━━━━━━

Premium Unlocks:

✓ Unlimited protected apps
✓ Custom focus sessions (90+ min)
✓ Weekly analytics & trends
✓ Scheduled protection hours
✓ Hardcore mode

━━━━━━━━━━━━━━━━━━━━━━━━

[Upgrade Now]
$4.99/week or $34.99/year

[Cancel]
```

**Behavior:**
- Blocks action until upgraded
- "Cancel" returns to previous screen
- Clear value proposition

---

#### Screen 30: Premium Purchase Flow
**Final conversion screen**

**Visual:**
```
Choose Your Plan

┌─────────────────────────┐
│ 🏆 BEST VALUE           │
│                         │
│ Annual Plan             │
│ $34.99/year            │
│ Just $2.92/month       │
│                         │
│ Save $225 vs weekly    │
└─────────────────────────┘ ← selected

┌─────────────────────────┐
│ Weekly Plan             │
│ $4.99/week             │
│ ($259/year)            │
│                         │
│ Cancel anytime         │
└─────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━

What You Get:

✓ Unlimited protected apps
✓ Custom focus sessions
✓ Weekly & monthly analytics
✓ Scheduled protection
✓ Hardcore mode
✓ 10 emergency bypasses/day
✓ Accountability mode

━━━━━━━━━━━━━━━━━━━━━━━━

[Continue]

- Auto-renewal, cancel anytime
- Terms of Service • Privacy Policy
```

**Interactions:**
- Tap card to select plan
- "Continue" → iOS StoreKit payment modal
- After payment → Screen 31

---

#### Screen 31: Payment Success
**Confirmation & onboarding to premium features**

**Visual:**
```
✨

Welcome to Premium!

You now have full access to:

✓ Unlimited protected apps
✓ Custom focus sessions
✓ Weekly analytics
✓ Scheduled protection
✓ Hardcore mode

━━━━━━━━━━━━━━━━━━━━━━━━

[Get Started]
```

**Behavior:**
- Confetti animation
- Success haptic feedback
- Unlocks all premium features immediately

**Interaction:**
- "Get Started" → Returns to main app (Screen 9)
- Subtle badge/indicator shows premium status

---

### ADDITIONAL SCREENS

#### Screen 32: Notifications Permission
**Optional during onboarding or first session**

**Visual:**
```
Stay on Track

Enable notifications to get:

- Focus session reminders
- Break time alerts  
- Daily progress updates
- Streak milestones

━━━━━━━━━━━━━━━━━━━━━━━━

[Enable Notifications]

[Not Now]
```

**Behavior:**
- Can appear during onboarding (Screen 8.5)
- Or after first focus session completes
- Not required for core functionality

---

#### Screen 33: Widget Setup (Optional)
**Home screen widget promotion**

**Visual:**
```
Add Home Screen Widget

See your stats and start sessions
right from your home screen.

[Widget preview image showing:
"Saved 12 times today"
"Start Focus Session" button]

━━━━━━━━━━━━━━━━━━━━━━━━

[Add to Home Screen]

[Skip]
```

**Widget sizes:**
- Small: Daily save count only
- Medium: Stats + "Start Session" button
- Large: Full dashboard with chart

---

#### Screen 34: First Session Complete
**Celebration screen**

**Visual:**
```
[Confetti animation]

🎉

Session Complete!

You focused for 25 minutes
without checking Instagram,
TikTok, or Twitter.

━━━━━━━━━━━━━━━━━━━━━━━━

Your Impact Today:

Times Saved: 18 (+12 this session)
Focus Time: 2h 35m

━━━━━━━━━━━━━━━━━━━━━━━━

[View Full Stats]

[Start Another Session]
```

**Behavior:**
- Appears immediately when session timer ends
- Haptic success feedback
- Encourages continued use

---

#### Screen 35: App Rating Prompt
**Triggered after specific milestones**

**Visual:**
```
Enjoying Focus Club?

You've been saved from
distraction 50 times!

If you're finding Focus Club
helpful, would you mind rating
us on the App Store?

[Rate Focus Club ⭐⭐⭐⭐⭐]

[Not Now]

[Already Rated]
```

**Trigger conditions:**
- After 50 successful saves, OR
- After 7-day streak, OR
- After first premium purchase

---

## Technical Architecture

### iOS Technologies Stack

#### 1. Screen Time API (FamilyControls Framework)
**Core blocking mechanism**
```swift
// Key components:
import FamilyControls
import ManagedSettings
import DeviceActivity

// Responsibilities:
- ManagedSettingsStore: Block/unblock apps
- DeviceActivityMonitor: Track attempts
- DeviceActivitySchedule: Time-based rules
- ShieldConfiguration: Custom block screens
```

**Implementation notes:**
- Requires iOS 15+ (Screen Time API availability)
- Must request `FamilyControls` authorization
- Blocking runs in extension (separate from main app)
- Can't show truly custom UI on block (Apple limitation)

**Workarounds for breathing delay:**
- Use `ShieldConfiguration` with timer message
- Schedule blocks at minute-level precision
- Monitor attempts via `DeviceActivityMonitor`

---

#### 2. SwiftUI for UI
**Modern declarative framework**
```swift
// Component structure:
- Views: CardView, StatCard, SessionTimer
- Modifiers: .cardStyle(), .primaryButton()
- ViewModels: MVVM pattern
- Combine: Reactive data flow
```

**Key patterns:**
- Environment objects for global state
- @StateObject for view-specific state
- PreferenceKey for child-to-parent communication
- matchedGeometryEffect for hero animations

---

#### 3. Core Data for Local Storage
**Persistent data management**
```swift
// Entities:
- User: Preferences, trial status
- ProtectedApp: App ID, behavior rules
- FocusSession: Start/end time, completed
- InterventionLog: Timestamp, app, decision
- DailyStat: Date, saves, focus time
```

**Why Core Data:**
- Built-in iCloud sync (optional)
- Efficient queries for stats
- Relationship management
- Migration support

---

#### 4. CloudKit (Optional, Premium Feature)
**Cross-device sync**
```swift
// Sync:
- User preferences
- Protected apps list
- Premium subscription status
- Historical stats (weekly/monthly)
```

**Implementation:**
- Private database (user data only)
- Conflict resolution (last-write-wins)
- Background sync via CKQuerySubscription

---

#### 5. UserNotifications Framework
**Reminder system**
```swift
// Notification types:
- Session reminders: "Time to focus!"
- Break alerts: "Break time: 5 min"
- Daily summary: "You saved 18 times today"
- Milestone celebrations: "7-day streak! 🔥"
```

**Behavior:**
- Rich notifications with actions
- Tapping notification opens relevant screen
- Badge count = active session time remaining

---

#### 6. StoreKit 2 for In-App Purchases
**Subscription management**
```swift
// Products:
- weekly_premium: $4.99/week
- annual_premium: $34.99/year

// Features:
- Automatic trial handling
- Receipt validation
- Subscription status monitoring
- Restore purchases
```

**Implementation:**
- SwiftUI `SubscriptionStoreView` (iOS 17+)
- Or custom view using `Product.SubscriptionInfo`
- Verify subscription on every app launch
- Handle edge cases (billing issues, cancellations)

---

#### 7. Core Motion (Shake Detection)
**Emergency bypass trigger**
```swift
import CoreMotion

// Detect shake gesture:
- Monitor accelerometer data
- Threshold: Sudden acceleration spike
- Count shakes within 3-second window
- Trigger bypass after 3 consecutive shakes
```

**Alternatives:**
- Long-press power button (not available in iOS)
- 3D Touch (deprecated)
- Face ID authentication for bypass

---

### App Architecture Diagram
```
┌─────────────────────────────────────────┐
│           Main App Target               │
│                                         │
│  ┌─────────────┐  ┌─────────────┐     │
│  │  SwiftUI    │  │ View Models │     │
│  │   Views     │←→│   (MVVM)    │     │
│  └─────────────┘  └─────────────┘     │
│         ↕                ↕              │
│  ┌─────────────┐  ┌─────────────┐     │
│  │ Core Data   │  │  StoreKit 2 │     │
│  │  Manager    │  │   Manager   │     │
│  └─────────────┘  └─────────────┘     │
│         ↕                               │
│  ┌─────────────────────────────┐       │
│  │  Screen Time Manager        │       │
│  │  (FamilyControls bridge)    │       │
│  └─────────────────────────────┘       │
└─────────────────────────────────────────┘
                  ↕
┌─────────────────────────────────────────┐
│    Device Activity Monitor Extension    │
│                                         │
│  - Runs independently                   │
│  - Monitors app launches                │
│  - Logs intervention attempts           │
│  - Communicates via shared container    │
└─────────────────────────────────────────┘
```

---

### Key Implementation Challenges

#### Challenge 1: Screen Time API Limitations

**Problem:** Can't truly intercept app launches with custom UI

**iOS Restrictions:**
- `ShieldConfiguration` only shows preset templates
- Can't run custom SwiftUI views on app launch
- Delay must be simulated with scheduled blocks

**Solution:**
```swift
// Simulate breathing delay:
1. User taps Instagram
2. DeviceActivityMonitor detects attempt
3. Schedule 10-second block immediately
4. ShieldConfiguration shows: "Take a breath (10s remaining)"
5. After 10 seconds, unblock automatically
6. Show in-app modal: "Do you still want to open?"
```

**Trade-off:** Not as smooth as one-sec.app (which may use private APIs or jailbreak workarounds)

---

#### Challenge 2: Real-Time Stats Accuracy

**Problem:** Screen Time API has 1-minute reporting delay

**Impact:**
- "You've tried 6 times" may lag behind reality
- Intervention screens can't show exact real-time counts

**Solution:**
- Cache attempts locally in DeviceActivity extension
- Sync to main app via shared App Group container
- Show "approximate" language: "~6 attempts"
- Update stats when user returns to app

---

#### Challenge 3: Background Session Monitoring

**Problem:** iOS kills background tasks after 30 seconds

**Impact:**
- Can't show notifications mid-session
- Timer only updates when app is active

**Solution:**
- Use `DeviceActivityMonitor` extension (survives in background)
- Schedule local notifications at session milestones
- Show persistent notification with remaining time
- Update timer via background refresh (when available)

---

#### Challenge 4: Emergency Bypass Implementation

**Problem:** User can force-quit app to circumvent blocks

**Mitigation strategies:**
1. **Education:** Explain during onboarding that force-quitting defeats the purpose
2. **Social accountability:** Hardcore mode requires friend approval (via iMessage)
3. **Stats tracking:** Log force-quits as "failures" in stats (shame mechanism)
4. **Technical:** Screen Time blocks persist even if app is force-quit

**Note:** Can't truly prevent force-quit (iOS design decision), but can make it psychologically harder.

---

### Data Models (Core Data)
```swift
// User Entity
class User: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var createdAt: Date
    @NSManaged var isPremium: Bool
    @NSManaged var trialEndsAt: Date?
    @NSManaged var emergencyBypassLimit: Int16
    @NSManaged var defaultProtectionBehavior: String // "block", "delay", "ask"
}

// ProtectedApp Entity
class ProtectedApp: NSManagedObject {
    @NSManaged var bundleID: String
    @NSManaged var name: String
    @NSManaged var behavior: String // "block", "delay", "ask"
    @NSManaged var delayDuration: Int16 // seconds
    @NSManaged var isScheduled: Bool
    @NSManaged var scheduleStart: Date?
    @NSManaged var scheduleEnd: Date?
}

// FocusSession Entity
class FocusSession: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var startTime: Date
    @NSManaged var endTime: Date?
    @NSManaged var duration: Int32 // seconds
    @NSManaged var isCompleted: Bool
    @NSManaged var template: String // "work", "study", "deep_work"
    @NSManaged var blockedApps: Set<ProtectedApp>
}

// InterventionLog Entity
class InterventionLog: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var timestamp: Date
    @NSManaged var appBundleID: String
    @NSManaged var interventionType: String // "block", "delay", "ask"
    @NSManaged var userDecision: String // "opened", "resisted", "bypassed"
}

// DailyStat Entity
class DailyStat: NSManagedObject {
    @NSManaged var date: Date
    @NSManaged var timesSaved: Int32
    @NSManaged var timesOpened: Int32
    @NSManaged var totalFocusTime: Int32 // seconds
    @NSManaged var bypassesUsed: Int16
}
```

---

### API Integration (Future Consideration)

**If you want to add backend later:**
```swift
// Endpoints:
POST /api/v1/users/register
POST /api/v1/users/login
GET  /api/v1/stats/sync
POST /api/v1/accountability/request-approval
GET  /api/v1/leaderboard (social feature)
```

**Benefits of backend:**
- Cross-platform sync (iOS + web dashboard)
- Accountability mode (friend approval via server)
- Social features (leaderboards, challenges)
- Analytics (aggregate usage data)

**MVP: Skip backend entirely**
- Use CloudKit for sync
- Implement accountability via ShareSheet (manual)
- Focus on core product first

---

## Monetization Strategy

### Pricing Model

**Free Tier (Forever):**
- 3 protected apps maximum
- One behavior per app (block OR delay OR ask)
- 25-minute focus sessions only
- Today's stats only
- 3 emergency bypasses per day

**Premium Tier:**
- **Weekly:** $4.99/week ($259/year)
- **Annual:** $34.99/year (save $225 vs weekly)

**Trial:**
- 7 days free
- Full premium access
- No credit card required upfront (Apple handles)
- Auto-converts to selected plan after trial

---

### Pricing Psychology

**Why weekly pricing works:**
1. **Lower barrier:** "$5 for a week" feels like coffee, not commitment
2. **Impulse purchase:** Easier to justify than $35 upfront
3. **Higher LTV:** If users stick, $259/year >> $35/year
4. **Test period:** Week-to-week feels flexible

**Why weekly pricing is risky:**
1. **Bad optics:** "$259/year?!" feels like a scam when discovered
2. **High churn:** Weekly subscribers forget and cancel
3. **App Store scrutiny:** Apple flags "predatory" pricing
4. **Competition:** Opal ($9.99/month), One-sec ($19.99/year)

**Mitigation strategies:**
1. **Show annual cost clearly:** "$4.99/week ($259/year)" on paywall
2. **Emphasize annual plan:** "Best Value" badge, 85% savings
3. **Justify value:** Unlimited apps, hardcore mode, analytics
4. **Alternative:** Consider $6.99/month instead of weekly

---

### Conversion Funnel
```
100 users download
  ↓ 80% complete onboarding (80 users)
  ↓ 70% grant Screen Time permission (56 users)
  ↓ 90% experience first intervention (50 users)
  ↓ 60% complete first focus session (30 users)
  ↓ 40% still active on Day 7 (20 users)
  ↓ 20% convert to premium (4 paying users)
```

**Target conversion rate:** 15-25% trial-to-paid
**Industry benchmark:** 5-10% for productivity apps
**Opportunity:** Better onboarding can improve this

---

### Paywall Strategy

**Soft paywalls (dismissable):**
- Day 8: "Trial ended" full-screen modal
- Re-appears every 3 days if not upgraded
- Can still use free tier after dismissing

**Hard paywalls (blocking):**
- Trying to add 4th protected app
- Attempting to start Deep Work session (90 min)
- Accessing weekly analytics
- Configuring per-app behaviors (mix block + delay)

**Best performing paywall moment:**
- **After first successful focus session:** "You just focused for 25 minutes! Upgrade to unlock longer sessions"
- **When hitting 3-app limit:** "You want to protect [YouTube] too? Upgrade for unlimited apps"
- **Day 5 of trial:** "You've been saved 47 times. Keep your streak going with Premium"

---

### Revenue Projections (Conservative Estimates)

**Assumptions:**
- 1,000 downloads/month (organic + ASO)
- 20% onboarding completion (200 users)
- 15% trial-to-paid conversion (30 paying users)
- 60% choose annual, 40% choose weekly

**Monthly revenue:**
```
Annual: 18 users × $34.99 = $629.82
Weekly: 12 users × $4.99 × 4.3 weeks = $257.28
Total: $887.10/month

Annual revenue: ~$10,645
```

**At scale (10,000 downloads/month):**
```
Annual revenue: ~$106,450
```

**Critical levers:**
1. **Increase downloads:** ASO, marketing, word-of-mouth
2. **Improve conversion:** Better onboarding, paywall timing
3. **Reduce churn:** Engagement features (streaks, milestones)

---

### Retention Strategy

**Day 1:** Onboarding + first intervention (hook moment)
**Day 2-3:** Push notification: "Start your first focus session"
**Day 5:** "You've been saved 47 times this week"
**Day 7:** "Trial ends tomorrow. Upgrade?"
**Week 2:** "7-day streak! You're on fire 🔥"
**Month 1:** "100 times saved milestone unlocked"

**Engagement tactics:**
- Daily stats push notifications
- Milestone celebrations (badges, confetti)
- Streaks (gamification)
- Social sharing ("I focused for 90 minutes today!")

---

## Go-to-Market Strategy

### App Store Optimization (ASO)

**App Name:**
```
Focus Club: Block Distractions
```

**Subtitle (30 characters):**
```
Screen Time Manager & Focus Timer
```

**Keywords (100 characters):**
```
screen time, focus timer, app blocker, productivity, digital wellbeing, social media blocker, distraction blocker, pomodoro, deep work
```

**Description (First 3 lines - visible without "more"):**
Stop mindless scrolling. Start focusing.
Focus Club combines breathing delays (like one-sec) with hard blocking (like Opal) to help you regain control over your phone.

Block Instagram, TikTok, Twitter automatically
---

### Screenshots (7 slots, optimized for conversion)

**Screenshot 1 (Hero):**
[Dark background with app icon]

Stop mindless scrolling.
Start focusing.

[Image: Breathing intervention screen]

"You unlock your phone 150+ times/day.
We help you take back control."

---

**Screenshot 2 (Problem/Solution):**
[Split screen]

Before Focus Club:
[Person scrolling TikTok mindlessly]

After Focus Club:
[Block screen: "Take a breath..."]

"Automatic protection. No willpower needed."

---

**Screenshot 3 (Stats):**
[Stats dashboard screenshot]

"You've been saved from
distraction 94 times this week"

See your real progress.

---

**Screenshot 4 (Focus Sessions):**
[Timer screen with mountain background]

"Focus for 25, 50, or 90 minutes"

Apps are hard-blocked until
your session ends.

---

**Screenshot 5 (Customization):**
[Per-app settings screen]

"Choose how each app is protected"

- Block Instagram immediately
- Add 10s delay for TikTok
- Ask before opening Twitter

---

**Screenshot 6 (Social Proof):**
[Testimonial-style]

"I finally finished my thesis!"
⭐⭐⭐⭐⭐

"Saved me from failing my exams"
⭐⭐⭐⭐⭐

Join 10,000+ focused users.

---

**Screenshot 7 (Call to Action):**
[Premium features list]

Unlock Full Power:

✓ Unlimited apps
✓ Custom focus sessions
✓ Weekly analytics
✓ Hardcore mode

Try free for 7 days.

---

### App Preview Video (15-second, muted-first)

**Script:**
0-2s:  [Person scrolling Instagram mindlessly]
       Text: "You unlock your phone 150+ times/day"

3-5s:  [Hand taps Instagram icon]
       [Breathing screen appears]
       Text: "Focus Club catches you first"

6-8s:  [Countdown: 10...9...8...]
       [User pauses, closes phone]
       Text: "No mindless scrolling"

9-11s: [Stats screen showing "94 times saved"]
       Text: "See your real progress"

12-14s: [App icon + "Focus Club"]
        Text: "Start your free trial"

15s:   [End card: "Download now"]

**Why this works:**
- Shows problem → solution → result
- No audio needed (muted autoplay)
- Clear value proposition in 15s

---

## Launch Strategy

### Phase 1: Soft Launch (Week 1-2)
**Countries:** Canada, Australia
**Goal:** Test conversion rates, fix critical bugs

**Actions:**
- Submit to App Store with all screenshots/video
- Soft launch to 2 smaller English-speaking markets
- Monitor: Onboarding completion, trial-to-paid %, crash reports
- Gather initial reviews (target 20+ reviews)

**Success criteria:**
- No critical bugs
- 15%+ trial-to-paid conversion
- 4+ star average rating

---

### Phase 2: Full Launch (Week 3-4)
**Countries:** US, UK, EU
**Goal:** Scale to broader market

**Actions:**
- Press outreach (TechCrunch, Product Hunt, MacStories)
- Influencer seeding (productivity YouTubers: Ali Abdaal, Thomas Frank)
- Reddit posts (r/productivity, r/getdisciplined, r/nosurf)
- Twitter/X threads from founder account
- Submit to Product Hunt (aim for top 5)

**Paid acquisition (if budget allows):**
- Apple Search Ads ($500-1000 to start)
- Target keywords: "screen time", "app blocker", "focus timer"
- A/B test ad creative

---

### Phase 3: Growth (Month 2-3)
**Goal:** Achieve product-market fit, refine messaging

**Actions:**
- Analyze user feedback (reviews, support emails)
- A/B test onboarding flow
- A/B test paywall timing and messaging
- Add features based on user requests
- Build referral program ("Invite 3 friends → 1 month free")

**Metrics to watch:**
- DAU/MAU ratio (target: >30%)
- D1, D7, D30 retention
LTV/CAC ratio (target: >3x)
Organic vs paid install mix


- LTV/CAC ratio (target: >3x)
- Organic vs paid install mix

---

## Content Marketing

**Blog posts (SEO + thought leadership):**
- "The Science of Digital Distraction (And How to Fight It)"
- "One-sec vs Opal vs Focus Club: Which App Blocker is Right for You?"
- "How to Actually Stick to Your Screen Time Goals"
- "The Pomodoro Technique, Explained (+ Our Twist on It)"

**Social media strategy:**
- **Twitter/X:** Daily productivity tips, user success stories
- **Instagram:** Before/after stats graphics ("I reduced screen time 40%")
- **TikTok:** Short demos of app in action (hook: "POV: You try to open Instagram")
- **Reddit:** Participate in r/productivity, r/nosurf (no spam, add value)

---

## Success Metrics

### North Star Metric
**Weekly Active Users (WAU)** who complete at least one focus session

**Why this metric:**
- Indicates real engagement (not just opening app)
- Correlates with retention and conversion
- Aligns with core product value

---

### Key Performance Indicators (KPIs)

#### 1. Acquisition Metrics
- **Downloads per day:** Track growth trajectory
- **App Store impressions:** ASO effectiveness
- **Conversion rate (impression → download):** Optimize screenshots/video
- **Cost per install (CPI):** If running paid ads

**Targets:**
- Month 1: 1,000 downloads
- Month 3: 5,000 downloads
- Month 6: 20,000 downloads

---

#### 2. Onboarding Metrics
- **% who complete onboarding:** (Target: 80%+)
- **% who grant Screen Time permission:** (Target: 70%+)
- **Time to first value (TTFV):** Seconds until first intervention
- **% who select 2+ apps:** (Target: 95%+)

**If onboarding completion <70%:**
- A/B test fewer screens
- Simplify permission request
- Add progress indicator

---

#### 3. Activation Metrics
- **% who experience first intervention:** (Target: 90%+)
- **% who complete first focus session:** (Target: 60%+)
- **% who see stats within 24h:** (Target: 80%+)

**"Aha moment" definition:**
- User blocks distraction attempt successfully
- OR completes 25-minute focus session
- Happens within first 24 hours

---

#### 4. Engagement Metrics
- **DAU / MAU ratio:** (Target: 30%+)
- **Focus sessions per user per week:** (Target: 5+)
- **"Times saved" per user per day:** (Target: 10+)
- **Session completion rate:** (Target: 75%+)

**If engagement drops:**
- Increase push notification frequency
- Add streak gamification
- Improve session templates

---

#### 5. Monetization Metrics
- **Trial start rate:** % of users who start 7-day trial (Target: 100%)
- **Trial-to-paid conversion:** (Target: 15-25%)
- **% choosing annual vs weekly:** (Track for pricing optimization)
- **Average revenue per user (ARPU):** (Target: $0.50-1.00 in first month)
- **Lifetime value (LTV):** (Target: $20+ for annual, $50+ for weekly subscriptions)

**If conversion <10%:**
- Test paywall timing (earlier vs later)
- Revise paywall copy/design
- Add social proof (testimonials)

---

#### 6. Retention Metrics
- **D1 retention:** % who return Day 1 (Target: 40%+)
- **D7 retention:** % who return Day 7 (Target: 25%+)
- **D30 retention:** % who return Day 30 (Target: 15%+)
- **Churn rate:** % of paid users who cancel (Target: <5%/month)

**Cohort analysis:**
Track retention by:
- Acquisition channel (organic vs paid)
- Onboarding completion (full vs partial)
- First action taken (session vs app protection only)

---

## Analytics Implementation

**Tools:**
- **Apple App Analytics:** Free, basic metrics
- **Firebase Analytics:** Event tracking, funnels
- **Mixpanel or Amplitude:** Advanced cohort analysis (if budget allows)
- **RevenueCat:** Subscription analytics

**Key events to track:**

```swift
// Onboarding
analytics.log("onboarding_started")
analytics.log("apps_selected", apps: selectedApps)
analytics.log("protection_style_chosen", style: "delay")
analytics.log("screen_time_permission_granted")
analytics.log("onboarding_completed")

// Activation
analytics.log("first_intervention_shown", app: "Instagram", type: "delay")
analytics.log("first_intervention_outcome", decision: "resisted")
analytics.log("first_session_started", template: "work_time")
analytics.log("first_session_completed")

// Engagement
analytics.log("session_started", template: "deep_work", duration: 90)
analytics.log("session_completed", duration: 90, blockedAttempts: 4)
analytics.log("intervention_shown", app: "TikTok", type: "block", attemptNumber: 3)
analytics.log("intervention_outcome", decision: "opened"/"resisted"/"bypassed")

// Monetization
analytics.log("paywall_shown", trigger: "add_4th_app")
analytics.log("paywall_dismissed")
analytics.log("purchase_started", plan: "annual")
analytics.log("purchase_completed", plan: "annual", price: 34.99)
```

```swift
analytics.log("subscription_cancelled", reason: "too_expensive")

// Retention
analytics.log("app_opened", daysSinceInstall: 7)
analytics.log("push_notification_received", type: "session_reminder")
analytics.log("push_notification_opened")
```

---

## Critical Challenges & Warnings

### ⚠️ Challenge 1: Weekly Pricing Will Face Scrutiny

**The Problem:**
- $4.99/week = $259/year
- Competitors: Opal ($9.99/month = $120/year), One-sec ($19.99/year)
- Apple is cracking down on "predatory" pricing

**Recent rejections:**
- Apps charging $9.99/week without clear value justification
- Apps that don't show annual cost prominently
- Apps that trick users with "free trial" then surprise billing

**How to comply:**
- Show annual cost explicitly: "$4.99/week ($259/year if billed weekly)"
- Make annual plan more prominent: Larger card, "Best Value" badge
- Justify pricing: "Unlimited apps + hardcore mode + analytics = $5/week"
- Alternative: Offer $6.99/month instead of weekly

**My recommendation:**
- Test weekly pricing in soft launch
- If rejection risk seems high, pivot to monthly before full launch
- Monitor competitor pricing changes

---

### ⚠️ Challenge 2: Screen Time API is Limited

**What you CAN'T do:**
- Show custom SwiftUI views when user opens app (iOS restriction)
- Detect app launches in true real-time (1-minute delay)
- Block apps mid-session without pre-scheduling
- Prevent force-quit workarounds

**What this means:**
- The "breathing delay" won't be as smooth as one-sec.app
- Stats like "You've tried 6 times" may lag slightly
- Users can technically circumvent blocks by force-quitting

**How to manage expectations:**
- Be transparent in onboarding: "Protection may take up to 1 minute to activate"
- Use language like "~6 attempts" (approximate)
- Emphasize psychological benefit over technical perfection
- Consider adding disclaimer: "Works best when you're committed to focus"

---

### ⚠️ Challenge 3: Mass Market = Commoditization

**The problem with "for everyone":**

You're competing with 100+ focus/screen time apps
Generic marketing ("Block distractions!") blends in
No clear differentiation

**What successful apps do:**

- **Opal**: Targets Gen Z with aesthetic design + social features
- **One-sec**: Targets mindfulness practitioners with breathing focus
- **Forest**: Targets students with gamification + tree planting

**Your risk:**

- Being a "me-too" app (one-sec + Opal features but no unique angle)
- Struggling to get initial traction
- Difficulty with word-of-mouth (no clear "who is this for?")

**Recommended approach:**

**Launch positioning: Target ONE specific group first**

- Example: "For remote workers drowning in Slack notifications"
- Example: "For students who fail exams because of TikTok"

**Initial marketing**: Speak directly to that group's pain
**Social proof**: Get testimonials from that audience
**Later**: Expand to mass market once you have traction

> Even if you build for everyone, MARKET to someone specific first.

---

### ⚠️ Challenge 4: Feature Parity with Established Apps

**Reality check:**

- Opal has 2M+ downloads, 4+ years of development, $10M funding
- One-sec has refined UX over 3+ years, large user base
- You're launching V1 with similar features

**Your disadvantages:**

- No brand recognition
- No user reviews initially
- No network effects (social features require scale)
- Larger apps can copy your features if you innovate

**Your advantages:**

- You can iterate faster (smaller team)
- You can target underserved niches
- You can offer better pricing (if you choose)
- You can provide better customer support (personal touch)

**Mitigation strategy:**

- Don't compete on features alone — compete on UX, pricing, or customer service
- Find ONE thing to be best at — e.g., "easiest onboarding" or "best free tier"
- Build in public — Share development progress, build audience before launch
- Focus on delight — Small touches (animations, messaging) create loyalty

---

### ⚠️ Challenge 5: Conversion Optimization is Hard

**Industry reality:**

- Average freemium app: 2-5% conversion
- Top productivity apps: 10-15% conversion
- Your target: 15-25% conversion (ambitious)

**Why conversion is hard:**

- Users don't value digital products until they feel pain
- Free tier may be "good enough" for most users
- Competitors offer similar features at different prices
- Subscription fatigue (people have 5-10 subscriptions already)

**What impacts conversion:**

- **Onboarding quality**: Do users reach "aha moment"?
- **Paywall timing**: Too early = annoyance, too late = no urgency
- **Value perception**: Do users understand WHY premium is worth it?
- **Pricing psychology**: Is it positioned as investment or expense?
- **Social proof**: Do others trust/use this app?

**Continuous optimization required:**

- A/B test paywall copy every 2 weeks
- Test paywall timing (Day 3 vs Day 5 vs Day 7)
- Test pricing ($4.99/week vs $6.99/month vs $39/year only)
- - Survey users who DON'T convert ("Why didn't you upgrade?")

---

## Implementation Checklist

### Before You Start Building

#### Strategic Decisions (Must answer first):

**Target audience finalized:**
- [ ] Mass market (risky but large TAM)
- [ ] Specific niche: _________________ (safer, easier to market)

**Pricing confirmed:**
- [ ] $4.99/week + $34.99/year (higher LTV, riskier)
- [ ] $6.99/month + $39.99/year (safer, more standard)
- [ ] Other: _________________

**Visual aesthetic decided:**
- [ ] Dark mode with muted purples (focus-appropriate)
- [ ] Go Club's bright blue gradients (energetic but may conflict with focus psychology)

**MVP scope defined:**
- [ ] Core features only (onboarding, Shield tab, interventions, paywall) — 4-6 weeks
- [ ] All features in this spec (30+ screens, stats, settings) — 8-12 weeks

---

### Technical Setup

#### Development environment:
- [ ] Xcode 15+ installed
- [ ] iOS 17 SDK (minimum iOS 15 deployment target)
- [ ] Apple Developer account ($99/year)
- [ ] Device for testing (Screen Time API requires real device)

#### Third-party services:
- [ ] Firebase project created (analytics)
- [ ] RevenueCat account setup (subscription management) — optional but recommended
- [ ] CloudKit container configured (if using sync)
- [ ] App Store Connect account setup

#### Repository setup:
- [ ] Git repository created
- [ ] .gitignore configured (exclude API keys, certificates)
- [ ] README with setup instructions
- [ ] Basic CI/CD (GitHub Actions for automated builds) — optional

---

### Phase 1: MVP Core Features (Weeks 1-4)

#### Week 1: Project scaffolding + onboarding
- [ ] Create Xcode project (SwiftUI, iOS 15+)
- [ ] Set up Core Data models (User, ProtectedApp, FocusSession)
- [ ] Design system implementation (colors, typography, components)
- [ ] Onboarding screens 1-8 (SwiftUI views)
- [ ] Screen Time permission request flow
- [ ] Basic analytics integration (log onboarding events)

#### Week 2: App protection system
- [ ] FamilyControls framework integration
- [ ] ManagedSettingsStore setup (block/unblock apps)
- [ ] DeviceActivityMonitor extension (track attempts)
- [ ] ShieldConfiguration for block screens
- [ ] Per-app behavior selection (block/delay/ask)
- [ ] Test blocking on real device

#### Week 3: Focus sessions
- [ ] Session timer UI (circular progress, countdown)
- [ ] Start/pause/end session logic
- [ ] Schedule blocks during active session
- [ ] Session complete celebration screen
- [ ] Break permission flow (Screens 24-25)
- [ ] Persistent notification during session

#### Week 4: Interventions + basic stats
- [ ] Delay intervention screen (breathing animation)
- [ ] Block intervention screen (attempt count)
- [ ] Ask intervention modal
- [ ] Log intervention outcomes to Core Data
- [ ] Today's stats card (times saved, most blocked app)
- [ ] Basic Shield home screen (Screen 9-10)

---

### Phase 2: Monetization + Polish (Weeks 5-6)

#### Week 5: In-app purchases
- [ ] StoreKit 2 setup (products, subscriptions)
- [ ] Paywall screens (28-31)
- [ ] Free tier enforcement (3-app limit, feature gates)
- [ ] Trial logic (7-day countdown, conversion prompt)
- [ ] Purchase flow + receipt validation
- [ ] Restore purchases functionality

#### Week 6: Polish + edge cases
- [ ] Animations (page transitions, button presses, celebrations)
- [ ] Haptic feedback (selection, success, warnings)
- [ ] Error handling (permission denied, payment failed)
- [ ] Empty states (no apps selected, no stats yet)
- [ ] Accessibility (VoiceOver, Dynamic Type)
- [ ] Dark mode polish (all screens look good)

---

### Phase 3: Extended Features (Weeks 7-8, Optional)

#### Week 7: Stats & settings
- [ ] Stats tab (Screen 15-17)
- [ ] Weekly trends (premium, charts)
- [ ] Milestones system
- [ ] Settings tab (Screen 18-20)
- [ ] Emergency bypass configuration
- [ ] Notifications setup

#### Week 8: Advanced features
- [ ] Per-app customization (Screen 14, premium)
- [ ] Scheduled protection (weekdays 9-5, premium)
- [ ] Custom focus session durations (premium)
- [ ] Hardcore mode (friend approval, premium)
- [ ] Widget implementation (optional)

---

### Phase 4: App Store Submission (Week 9)

#### Pre-submission checklist:
- [ ] App icon (1024x1024, all sizes)
- [ ] Screenshots (7 sizes: 6.7", 6.5", 5.5")
- [ ] App preview video (15-30 seconds)
- [ ] App Store description written
- [ ] Keywords researched
- [ ] Privacy policy published (required for Screen Time API)
- [ ] Terms of service published
- [ ] Support email/website set up

#### Testing:
- [ ] TestFlight build uploaded
- [ ] Beta testing with 10-20 users
- [ ] Critical bugs fixed
- [ ] Performance optimized (60fps, <100MB app size)
- [ ] Crash-free rate >99.5%

#### Submission:
- [ ] App Store Connect listing complete
- [ ] Age rating set (4+)
- [ ] Pricing & availability configured
- [ ] Submit for review
- [ ] Respond to reviewer questions promptly

---

### Phase 5: Launch & Growth (Week 10+)

#### Soft launch:
- [ ] Release to Canada, Australia
- [ ] Monitor analytics daily
- [ ] Gather initial reviews
- [ ] Fix critical issues
- [ ] Achieve 4+ star rating

#### Full launch:
- [ ] Release to US, UK, EU
- [ ] Press outreach (TechCrunch, Product Hunt)
- [ ] Social media campaign
- [ ] Reddit posts (r/productivity)
- [ ] Influencer outreach (YouTube)

#### Post-launch:
- [ ] Weekly analytics review
- [ ] A/B test paywall timing
- [ ] Respond to user feedback
- [ ] Plan V1.1 features based on requests
- [ ] Iterate on conversion optimization

---

## Appendix A: Competitive Analysis

### One-sec.app

**Strengths:**
- Unique "breathing before opening" mechanic
- Simple, focused value proposition
- Low price point ($19.99/year)
- Strong App Store reviews (4.7 stars)

**Weaknesses:**
- Only friction-based (no hard blocking)
- Limited customization
- No focus session concept
- Minimal stats/analytics

**Takeaway**: We can beat them on features (add blocking) but must match their simplicity.

---

### Opal

**Strengths:**
- Beautiful, modern design
- Comprehensive blocking system
- Social features (accountability, groups)
- Strong brand (2M+ users)

**Weaknesses:**
- No friction delays (only blocking)
- Complex onboarding
- Higher price point ($9.99/month)
- Overwhelming for new users

**Takeaway**: We can beat them on ease of use and price, but need similar polish.

---

### Forest

**Strengths:**
- Gamification (plant trees)
- Positive reinforcement (not punitive)
- Social good (real tree planting)
- Massive user base (10M+)

**Weaknesses:**
- Focuses on phone-wide lockout (not per-app)
- Dated design
- Weak blocking mechanism (easy to quit)

**Takeaway**: We can beat them on modern design and granular control.

---

### Apple Screen Time

**Strengths:**
- Built into iOS (free)
- System-level integration
- Trusted by Apple

**Weaknesses:**
- Too easy to ignore ("Ignore Limit" button)
- Poor UX (buried in Settings)
- No behavioral psychology
- No motivation/gamification

**Takeaway**: We beat them on commitment devices and user experience.

---

## Appendix B: User Personas

### Persona 1: Sarah, Remote Worker (28)

**Background:**
- Works from home as software engineer
- Struggles with Slack/email interruptions
- Wants to achieve "flow state" for coding

**Pain points:**
- Checks Slack every 5 minutes
- Can't focus for more than 20 minutes
- Feels guilty about wasted time

**Needs:**
- Hard blocking during focus sessions
- Flexibility for breaks
- Stats to show manager ("I was productive today!")

**Messaging:**
"Turn 8 distracted hours into 4 deep work hours."

### Persona 2: Jake, College Student (20)

**Background:**
- Engineering major, heavy course load
- Addicted to TikTok/Instagram
- Fails exams due to poor study habits

**Pain points:**
- Opens TikTok "just for 5 minutes" → 2 hours gone
- Can't resist notifications
- Parents threaten to cut tuition

**Needs:**
- Aggressive blocking during study sessions
- Immediate feedback when distracted
- Proof of behavior change (for parents)

**Messaging:**
"Stop failing exams because of TikTok."

---

### Persona 3: Maria, Parent (35)

**Background:**
- Mother of two, wants to model good phone habits
- Feels guilty scrolling while kids play
- Wants to be "present"

**Pain points:**
- Mindlessly scrolls Instagram during family time
- Kids notice and ask "Why are you always on your phone?"
- Feels like a hypocrite

**Needs:**
- Gentle reminders (not aggressive blocking)
- Awareness of phone use patterns
- Scheduled protection (e.g., 6-8 PM = family time)

**Messaging:**
"Be present for the moments that matter."

---

## Appendix C: FAQ for Developers

**Q: Can I truly prevent users from bypassing blocks?**
A: No. iOS doesn't allow apps to lock users out completely. Users can:
- Force-quit your app
- Uninstall your app
- Disable Screen Time in Settings

However, you can make it psychologically harder:
- Track force-quits as "failures" in stats
- Require friend approval for hardcore mode
- Show guilt-inducing messages

The goal is behavior change, not technical enforcement.

**Q: How does the breathing delay actually work?**
A: Screen Time API doesn't support showing custom UI on app launch. Workaround:
1. User taps Instagram
2. DeviceActivityMonitor detects attempt
3. Schedule 10-second block immediately via ManagedSettingsStore
4. ShieldConfiguration shows: "Take a breath (10s remaining)"
5. After 10 seconds, unblock automatically
6. Show in-app modal: "Do you still want to open Instagram?"

It's not as smooth as one-sec.app (which may use jailbreak techniques), but it works.

**Q: How accurate are the "times saved" stats?**
A: Approximately accurate. Screen Time API has ~1-minute reporting delay, so:
- "You've tried 6 times" may actually be 5 or 7
- Use language like "~6 times" or "about 6 times"
- Sync data when user returns to app for better accuracy

Don't promise real-time precision.

**Q: Can I block system apps (Safari, Messages)?**
A: No. Apple restricts blocking:
- Phone, Messages, FaceTime (always allowed)
- Settings (always allowed)
- Third-party apps can be blocked

Communicate this limitation clearly in onboarding.

**Q: How do I handle timezone changes?**
A: DeviceActivitySchedule uses device timezone. If user travels:
- Schedules auto-adjust to new timezone
- Sessions continue in local time
- No action needed from user

Test this scenario before launch.

**Q: What if user downgrades iOS version?**
A: Screen Time API requires iOS 15+. If user downgrades:
- App will crash or show error
- Minimum deployment target should be iOS 15
- Show in-app message: "iOS 15+ required for blocking features"

Likelihood is low (users rarely downgrade).

**Q: How do I test on simulator?**
A: You can't. Screen Time API requires real device. Must have:
- Physical iPhone running iOS 15+
- Enrolled in Apple Developer Program
- Screen Time enabled in Settings

Budget 1-2 devices for testing.

---

## Appendix D: Post-Launch Roadmap

### V1.1 (Month 2)
- Widget improvements (more sizes)
- Siri shortcuts ("Start work session")
- Export stats as PDF/CSV
- Bug fixes from user feedback

### V1.2 (Month 3)
- iPad version (optimize for larger screens)
- Accountability mode (friend approval)
- Custom backgrounds for sessions
- Dark/light mode toggle

### V1.3 (Month 4)
- Social features (leaderboards, challenges)
- Apple Watch complication (timer)
- Streaks & achievements expansion
- Localization (Spanish, French, German)

### V2.0 (Month 6)
- Web dashboard (view stats online)
- Family sharing (parent controls)
- AI-powered insights ("You're most distracted at 3 PM")
- Integrations (Calendar, Todoist)

---

## Document Version History

**V1.0 (November 2024):**
- Initial complete specification
- 30+ screens documented
- Technical architecture defined
- Monetization strategy outlined
- Go-to-market plan included

**Status:** Ready for development

---

## Contact & Support

**For questions about this spec:**
- Review the relevant section above
- Check Appendix C (FAQ) first
- Contact: [Your email or preferred method]

**For development questions:**
- Apple Developer Forums (Screen Time API)
- Stack Overflow (SwiftUI, StoreKit 2)
- r/iOSProgramming (community help)

---

## Final Notes

This specification is comprehensive but not exhaustive. Expect to:

- **Make decisions**: Some details will need refinement during development
- **Encounter edge cases**: Screen Time API has quirks; test thoroughly
- **Iterate**: User feedback will shape V1.1, V1.2, etc.
- **Stay flexible**: Market conditions change; be ready to pivot pricing or features

**Most important**: Ship V1 fast, get feedback, iterate. Don't wait for perfection.

Good luck building Focus Club! 🚀