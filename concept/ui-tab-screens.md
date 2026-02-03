# ScreenGate: UI Tab Screen Designs

> Detailed ASCII mockups for all post-onboarding tab screens and shield configurations.
> 
> **Note:** Pure diet metaphor - no "focus sessions" or "active blocks". The diet schedule itself creates the restrictions.

---

## Table of Contents

1. [Kitchen Tab (Home/Dashboard)](#1-kitchen-tab-homedashboard)
2. [Report Tab (Weekly Nutrition)](#2-report-tab-weekly-nutrition)
3. [Pantry Tab (My Digital Pantry)](#3-pantry-tab-my-digital-pantry)
4. [Settings Tab](#4-settings-tab)
5. [Shield Screens](#5-shield-screens)

---

## 1. Kitchen Tab (Home/Dashboard)

Main entry point showing diet status, fasting/window state, and quick actions.

### State A: Fasting Period (Window Closed)

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│                                         │
│  🍽️ SCREEN DIET                ⚙️  🔔   │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🥗 KETO DIET ACTIVE            │    │
│  │  [Change Diet →]                │    │
│  │                                 │    │
│  │  🌙 NIGHT FAST IN PROGRESS      │    │
│  │                                 │    │
│  │  Fasted: 14 hours 32 min        │    │
│  │  [██████████████░░] 81%         │    │
│  │                                 │    │
│  │  🍽️ Window opens in 2h 15m      │    │
│  │     12:00 PM - 6:00 PM          │    │
│  │                                 │    │
│  │  🔥 Fast streak: 5 days         │    │
│  │                                 │    │
│  │  [Extend Fast 2 Hours]          │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  📊 TODAY'S NUTRITION           │    │
│  │                                 │    │
│  │  🍩 Carbs:  0/60 min  ░░░░░░░░░ │    │
│  │  🥩 Protein: 25 min   ██░░░░░░░ │    │
│  │  🥑 Fats:    10 min   █░░░░░░░░ │    │
│  │  🥦 Fiber:   5 min    ░░░░░░░░░ │    │
│  │                                 │    │
│  │  [See Details →]                │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🥗 ALWAYS AVAILABLE            │    │
│  │                                 │    │
│  │  🟢 Notes    🟢 Camera   🟢 Code│    │
│  │  🟢 Kindle   🟢 Music            │    │
│  │                                 │    │
│  │  [Browse Pantry →]              │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [🏠]    [📊]    [🥘]    [⚙️]           │
│ Kitchen  Report  Pantry  Settings       │
└─────────────────────────────────────────┘
```

### State B: Eating Window Open

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│                                         │
│  🍽️ SCREEN DIET                ⚙️  🔔   │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🥗 KETO DIET ACTIVE            │    │
│  │  [Change Diet →]                │    │
│  │                                 │    │
│  │  ✅ CARB WINDOW OPEN            │    │
│  │                                 │    │
│  │  12:00 PM - 6:00 PM             │    │
│  │  [████████████░░░░] 67%         │    │
│  │  Closes in 4 hours              │    │
│  │                                 │    │
│  │  ⏰ Night lock: 9:00 PM         │    │
│  │                                 │    │
│  │  [Close Window Early]           │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  📊 TODAY'S NUTRITION           │    │
│  │                                 │    │
│  │  🍩 Carbs:  20/60 min  ██░░░░░░░ │    │
│  │  🥩 Protein: 30 min    ███░░░░░░ │    │
│  │  🥑 Fats:    15 min    ██░░░░░░░ │    │
│  │  🥦 Fiber:   10 min    █░░░░░░░░ │    │
│  │                                 │    │
│  │  [See Details →]                │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🍽️ CARB KITCHEN IS OPEN        │    │
│  │                                 │    │
│  │  🟡 Instagram  20 min used      │    │
│  │  🟡 TikTok     15 min used      │    │
│  │  🟢 YouTube    --               │    │
│  │  🟢 Games      --               │    │
│  │                                 │    │
│  │  40 min remaining today         │    │
│  │                                 │    │
│  │  [Open Carb Pantry →]           │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [🏠]    [📊]    [🥘]    [⚙️]           │
│ Kitchen  Report  Pantry  Settings       │
└─────────────────────────────────────────┘
```

### State C: Daily Limit Reached (Within Window)

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│                                         │
│  🍽️ SCREEN DIET                ⚙️  🔔   │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🥗 KETO DIET ACTIVE            │    │
│  │  [Change Diet →]                │    │
│  │                                 │    │
│  │  ✅ CARB WINDOW OPEN            │    │
│  │     (4 hours left)              │    │
│  │                                 │    │
│  │  🚫 DAILY CARB LIMIT REACHED    │    │
│  │                                 │    │
│  │  60/60 minutes consumed         │    │
│  │  [██████████████████] 100%      │    │
│  │                                 │    │
│  │  Next carb window: Tomorrow     │    │
│  │                                 │    │
│  │  [🍕 Use Cheat Meal - 2 left]   │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🥗 AVAILABLE NOW               │    │
│  │                                 │    │
│  │  🟢 Protein: Notes, Camera      │    │
│  │  🟢 Fats: Messages (15m left)   │    │
│  │  🔴 Carbs: Limit reached        │    │
│  │                                 │    │
│  │  [Browse Pantry →]              │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [🏠]    [📊]    [🥘]    [⚙️]           │
│ Kitchen  Report  Pantry  Settings       │
└─────────────────────────────────────────┘
```

### State D: Night Lock Active (After Window, Before Sleep)

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│                                         │
│  🍽️ SCREEN DIET                ⚙️  🔔   │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🥗 KETO DIET ACTIVE            │    │
│  │                                 │    │
│  │  🌙 NIGHT LOCKDOWN              │    │
│  │                                 │    │
│  │  All apps limited after 9pm     │    │
│  │                                 │    │
│  │  ⏰ Lock started: 9:00 PM       │    │
│  │  🌅 Kitchen opens: 12:00 PM     │    │
│  │     (15 hours remaining)        │    │
│  │                                 │    │
│  │  Only protein & essential fats  │    │
│  │                                 │    │
│  │  [Why night lock? →]            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🥗 SLEEP-FRIENDLY APPS         │    │
│  │                                 │    │
│  │  🟢 Kindle    🟢 Podcasts       │    │
│  │  🟢 Music     🟢 Meditation     │    │
│  │                                 │    │
│  │  🔴 Instagram (night locked)    │
│  │  🔴 TikTok (night locked)       │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [🏠]    [📊]    [🥘]    [⚙️]           │
│ Kitchen  Report  Pantry  Settings       │
└─────────────────────────────────────────┘
```

### Today's Nutrition Detail (Tap "See Details →")

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│  ← Back                                 │
│                                         │
│  📊 TODAY'S NUTRITION                   │
│  Keto Diet - 70% Protein, 10% Carbs     │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  🍩 CARBS (Target: 10% of time)         │
│  45/60 min        [███████████░] 75%    │
│                                         │
│  Usage breakdown:                       │
│  ├─ Instagram: 20 min  [████░░]         │
│  ├─ TikTok: 15 min     [███░░░]         │
│  └─ YouTube: 10 min    [██░░░░]         │
│                                         │
│  Window: 12pm-6pm (closes in 2h)        │
│  Status: 🟢 Within window & limit       │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│                                         │
│  🥩 PROTEIN (Target: 70% of time)       │
│  45 min           [████░░░░░░░░] 33%    │
│  Goal: 2+ hours recommended             │
│                                         │
│  ├─ Notes: 25 min  [███░░░░]            │
│  ├─ Camera: 15 min [██░░░░░]            │
│  └─ Code: 5 min    [░░░░░░░]            │
│                                         │
│  💡 Try to reach 60 min more today      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│                                         │
│  🥑 FATS (Target: 15% of time)          │
│  10/30 min        [███░░░░░░░░░] 33%    │
│  Limit: 30 min/day                      │
│                                         │
│  ├─ Messages: 10 min                    │
│  └─ WhatsApp: 0 min                     │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  🥦 FIBER (Target: 5% of time)          │
│  10 min           [░░░░░░░░░░░░] 8%     │
│  Goal: Read/learn daily                 │
│                                         │
│  ├─ Kindle: 10 min                      │
│                                         │
│  [View Weekly Report →]                 │
│                                         │
└─────────────────────────────────────────┘
```

---

## 2. Report Tab (Weekly Nutrition)

Weekly analysis dashboard with metabolic score, body composition, and prescriptions.

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│                                         │
│  📊 YOUR NUTRITION        ←  Week 12  → │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     METABOLIC SCORE             │    │
│  │                                 │    │
│  │        🅱️+                      │    │
│  │      ↑ from D+                  │    │
│  │                                 │    │
│  │   [████████░░░░░░░░░░] 67%      │    │
│  └─────────────────────────────────┘    │
│                                         │
│  DIGITAL BODY COMPOSITION               │
│  ┌─────────────────────────────────┐    │
│  │ 🍩 Carbs   58% │██████░░│ 20%🔴│    │
│  │ 🥩 Protein 22% │███░░░░░│ 40%🟡│    │
│  │ 🥑 Fats    12% │█░░░░░░░│ 25%  │    │
│  │ 🥦 Fiber    8% │░░░░░░░░│ 15%  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  ⏱️ TOTAL SCREEN TIME           │    │
│  │                                 │    │
│  │     42 hours                    │    │
│  │     ↓ 8 hrs from last week 🎉   │    │
│  │                                 │    │
│  │  [Mon][Tue][Wed][Thu][Fri][Sa][Su]  │
│  │   ▓▓   ▓░   ▓▓   ▓▓   ▓░   ▓▓  ▓▓   │
│  └─────────────────────────────────┘    │
│                                         │
│  🚨 ISSUES DETECTED                     │
│  ┌─────────────────────────────────┐    │
│  │  🌙 Late-Night Binging          │    │
│  │     6.5 hrs after curfew        │    │
│  │     [View Details →]            │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │  🥗 Protein Deficiency          │    │
│  │     Only 22% creation time      │    │
│  │     [View Details →]            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  💊 VIEW PRESCRIPTION           │    │
│  │     Week 13 adjustments ready   │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [🏠]    [📊]    [🥘]    [⚙️]           │
│ Kitchen  Report  Pantry  Settings       │
└─────────────────────────────────────────┘
```

### Report Tab: Issue Detail View

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│  ← Back                                 │
│                                         │
│  🌙 LATE-NIGHT BINGING                  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  6.5 hours after 6pm curfew     │    │
│  │                                 │    │
│  │  Peak: Tuesday 11:30pm (2 hrs)  │    │
│  │  Peak: Friday 1:15am (1.5 hrs)  │    │
│  │                                 │    │
│  │  Impact: Sleep quality degraded │    │
│  │  Avg sleep: 5.5 hrs (goal: 8)   │    │
│  └─────────────────────────────────┘    │
│                                         │
│  📊 YOUR PATTERN                        │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │  6pm ████████████████████       │    │
│  │  8pm ████████████████░░░░       │    │
│  │ 10pm ████████████░░░░░░░░       │    │
│  │ 12am ████████░░░░░░░░░░░░       │    │
│  │  2am ██░░░░░░░░░░░░░░░░░░       │    │
│  │                                 │    │
│  │  Usage intensity by hour        │    │
│  └─────────────────────────────────┘    │
│                                         │
│  💊 SUGGESTED FIX                       │
│  ┌─────────────────────────────────┐    │
│  │  Move carb window earlier       │    │
│  │  10am - 4pm instead of 12-6     │    │
│  │                                 │    │
│  │  Add night lock at 9pm          │    │
│  │                                 │    │
│  │  [Apply to Prescription]        │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

### Report Tab: Prescription View

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│  ← Back                                 │
│                                         │
│  💊 PRESCRIPTION FOR WEEK 13            │
│                                         │
│  Based on your patterns, we recommend:  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     🥗 STRICTER KETO PLUS       │    │
│  │                                 │    │
│  │  Changes:                       │    │
│  │                                 │    │
│  │  • Carb window: 12pm-5pm        │    │
│  │    (was 6pm)                    │    │
│  │    Stop late-night access       │    │
│  │                                 │    │
│  │  • Carb limit: 45 mins          │    │
│  │    (was 60)                     │    │
│  │    Force portion control        │    │
│  │                                 │    │
│  │  • Mandatory Protein Breakfast  │    │
│  │    9am-10am: Only creation apps │    │
│  │    Block all carbs until done   │    │
│  │                                 │    │
│  │  • Weekend Schedule             │    │
│  │    Sat-Sun: 10am-4pm window     │    │
│  │    Stop weekend slippage        │    │
│  │                                 │    │
│  │  • Night Lock: 9:00 PM          │    │
│  │    Protect sleep schedule       │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Expected Results:                      │
│  • Carbs: 58% → 35%                     │
│  • Protein: 22% → 35%                   │
│  • Sleep: Improved                      │
│                                         │
│  [Accept Prescription]  [Modify]  [Skip]│
│                                         │
└─────────────────────────────────────────┘
```

---

## 3. Pantry Tab (My Digital Pantry)

App management organized by macronutrient categories with usage stats.

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│                                         │
│  🥘 MY DIGITAL PANTRY           [+ Add] │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  🥩 PROTEIN (Creation)                  │
│  "Always fresh. Unlimited portions."    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐      │
│  │  📝    │ │  📷    │ │  🎸    │      │
│  │ Notes  │ │ Camera │ │GarageBn│      │
│  │  ∞     │ │   ∞    │ │   ∞    │      │
│  └────────┘ └────────┘ └────────┘      │
│  ┌────────┐ ┌────────┐ ┌────────┐      │
│  │  💻    │ │  🎨    │ │  ✍️    │      │
│  │  Code  │ │ Design │ │ Writing│      │
│  │  ∞     │ │   ∞    │ │   ∞    │      │
│  └────────┘ └────────┘ └────────┘      │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  🍩 CARBS (Consumption)          15/60  │
│  "Processed. Ration carefully."         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐      │
│  │  📸    │ │  🎵    │ │  🐦    │      │
│  │Instagram│ │ TikTok │ │Twitter │      │
│  │ 20m    │ │  45m   │ │  --    │      │
│  │ 🔴BLOCK│ │ 🔴BLOCK│ │ 🟢OPEN │      │
│  └────────┘ └────────┘ └────────┘      │
│  ┌────────┐ ┌────────┐ ┌────────┐      │
│  │  ▶️    │ │  🎮    │ │  🎬    │      │
│  │YouTube │ │ Games  │ │Netflix │      │
│  │  --    │ │  --    │ │  --    │      │
│  │ 🟢OPEN │ │ 🟢OPEN │ │ 🟢OPEN │      │
│  └────────┘ └────────┘ └────────┘      │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  🥑 FATS (Connection)            10/30  │
│  "Essential nutrients. Moderate."       │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐      │
│  │  💬    │ │  💚    │ │  📹    │      │
│  │Messages│ │WhatsApp│ │FaceTime│      │
│  └────────┘ └────────┘ └────────┘      │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  🥦 FIBER (Learning)                    │
│  "Slow digestion. Daily recommended."   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐      │
│  │  📚    │ │  🎧    │ │  📰    │      │
│  │ Kindle │ │Audible │ │ News  │      │
│  └────────┘ └────────┘ └────────┘      │
│                                         │
│  [🏠]    [📊]    [🥘]    [⚙️]           │
│ Kitchen  Report  Pantry  Settings       │
└─────────────────────────────────────────┘
```

### Pantry Tab: App Detail Sheet

```
┌─────────────────────────────────────────┐
│                                         │
│         ━━━━━━━━━━━━━━━━━━━             │
│              Drag handle                │
│                                         │
│  ┌────────┐                             │
│  │  📸    │  Instagram                 │
│  │Instagram│  Category: CARBS          │
│  └────────┘  Status: 🔴 Window closed   │
│                                         │
│  📊 THIS WEEK                           │
│  ┌─────────────────────────────────┐    │
│  │  Total time: 5h 23m             │    │
│  │  Daily average: 46 minutes      │    │
│  │  Opened: 34 times               │    │
│  │  Avg session: 9.5 minutes       │    │
│  │                                 │    │
│  │  Daily limit: 60 min (diet)     │    │
│  │  Today's usage: 20 min          │    │
│  └─────────────────────────────────┘    │
│                                         │
│  📈 TREND                               │
│  ┌─────────────────────────────────┐    │
│  │  ▁▂▄▆█▆▄▂▁  Last 7 days        │    │
│  │  Usage decreasing 🎉            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ACTIONS                                │
│  ┌─────────────────────────────────┐    │
│  │  [  Move to Protein  ]          │    │
│  │  [  Set App Limit    ]          │    │
│  │  [  Remove from Diet ]          │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

---

## 4. Settings Tab

Diet controls, schedule adjustments, and emergency options.

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│                                         │
│  ⚙️ SETTINGS                            │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  👤 MY PRESCRIPTION             │    │
│  │  Current: Keto (Strict)         │    │
│  │  [Adjust My Diet →]             │    │
│  └─────────────────────────────────┘    │
│                                         │
│  SCHEDULE                               │
│  ┌─────────────────────────────────┐    │
│  │  🕐 Carb Window                 │    │
│  │     12:00 PM - 6:00 PM          │    │
│  │  ⏱️ Daily Limit: 60 minutes     │    │
│  │  🌙 Night Lock: 9:00 PM         │    │
│  └─────────────────────────────────┘    │
│                                         │
│  DIET CONTROLS                          │
│  ┌─────────────────────────────────┐    │
│  │  🍕 Use Cheat Meal              │    │
│  │     2 remaining this week       │    │
│  │                                 │    │
│  │  ⏸️ Take a Diet Break           │    │
│  │     Weekend Mode available      │    │
│  │                                 │    │
│  │  🔄 Quick Resume                │    │
│  │     (If diet was paused)        │    │
│  └─────────────────────────────────┘    │
│                                         │
│  EMERGENCY                              │
│  ┌─────────────────────────────────┐    │
│  │  🛑 Pause All Restrictions      │    │
│  │  📞 Contact Sponsor             │    │
│  │  🆘 Crisis Resources            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  APP                                    │
│  ┌─────────────────────────────────┐    │
│  │  🔔 Notifications               │    │
│  │  📱 Widgets                     │    │
│  │  🔄 Reset All Settings          │    │
│  │  ℹ️ About ScreenDiet            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     🚪 Log Out                  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [🏠]    [📊]    [🥘]    [⚙️]           │
│ Kitchen  Report  Pantry  Settings       │
└─────────────────────────────────────────┘
```

### Settings Tab: Adjust Diet

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│  ← Back                                 │
│                                         │
│  ⚙️ ADJUST MY DIET                      │
│                                         │
│  CURRENT PRESCRIPTION                   │
│  ┌─────────────────────────────────┐    │
│  │  🥗 KETO (Strict)               │    │
│  │                                 │    │
│  │  70% Protein | 10% Carbs        │    │
│  │  15% Fats | 5% Fiber            │    │
│  │                                 │    │
│  │  [Switch to Balanced]           │    │
│  │  [Switch to Detox]              │    │
│  │  [Create Custom]                │    │
│  └─────────────────────────────────┘    │
│                                         │
│  QUICK ADJUSTMENTS                      │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │  🕐 Carb Window                 │    │
│  │  [11-5] [12-6★] [1-7] [Custom]  │    │
│  │                                 │    │
│  │  ⏱️ Daily Limit                 │    │
│  │  [45] [60★] [90] [Custom]  min  │    │
│  │                                 │    │
│  │  🌙 Night Lock                  │    │
│  │  [9pm] [10pm] [11pm] [Custom]   │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     💾 SAVE CHANGES             │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

### Settings Tab: Cheat Meal Request

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│  ← Cancel                               │
│                                         │
│  🍽️ CHEAT MEAL REQUEST                  │
│                                         │
│  Emergency access to restricted app.    │
│                                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│                                         │
│  🍕 PLANNED CHEAT                       │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │  Uses weekly allowance          │    │
│  │  Remaining: 2/3 this week       │    │
│  │                                 │    │
│  │  Duration: 30 minutes           │    │
│  │                                 │    │
│  │  [Request Cheat Meal]           │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  🆘 TRUE EMERGENCY                      │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │  Bypass with consequences       │    │
│  │  Affects weekly metabolic score │    │
│  │                                 │    │
│  │  Reason required:               │    │
│  │  ┌─────────────────────────┐    │    │
│  │  │ Work deadline, family   │    │    │
│  │  │ emergency, etc.         │    │    │
│  │  └─────────────────────────┘    │    │
│  │                                 │    │
│  │  [Emergency Access]             │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

### Settings Tab: Diet Break

```
┌─────────────────────────────────────────┐
│ 9:41                              🔋100%│
│  ← Cancel                               │
│                                         │
│  🛑 DIET BREAK WARNING                  │
│                                         │
│  You're about to pause ScreenDiet.      │
│                                         │
│  ⚠️ CONSEQUENCES:                       │
│  ┌─────────────────────────────────┐    │
│  │  • No protection during break   │    │
│  │  • No weekly report generated   │    │
│  │  • Metabolic score paused       │    │
│  │  • May trigger old habits       │    │
│  └─────────────────────────────────┘    │
│                                         │
│  DURATION                               │
│  [1 Day] [Weekend] [1 Week] [Custom]    │
│                                         │
│  💡 RECOMMENDED:                        │
│  ┌─────────────────────────────────┐    │
│  │     WEEKEND MODE                │    │
│  │                                 │    │
│  │  Relaxed vs. fully off:         │    │
│  │  • Carb window: 10am-8pm        │    │
│  │  • Daily limit: 90 mins         │    │
│  │  • Night lock: 11pm             │    │
│  │                                 │    │
│  │  Auto-resumes: Monday 8am       │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [Activate Weekend Mode]                │
│  [Full Break - No Protection]           │
│                                         │
└─────────────────────────────────────────┘
```

---

## 5. Shield Screens

System overlay screens shown when opening apps based on diet status.

### Shield A: Kitchen Closed (Fasting Period)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            🍽️ SCREEN DIET               │
│                                         │
│              ┌────────┐                 │
│              │  📸    │                 │
│              │Instagram│                 │
│              │        │                 │
│              └────────┘                 │
│                                         │
│            🍩 CARBS                     │
│         (High Glycemic)                 │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│         🌙 KITCHEN CLOSED               │
│                                         │
│      You're currently fasting           │
│                                         │
│      Fasted: 14 hours 32 minutes        │
│      Goal: 16-hour fast                 │
│                                         │
│      🍽️ Window opens: 12:00 PM          │
│         (in 2 hours 15 minutes)         │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│         🥗 AVAILABLE NOW:               │
│                                         │
│         🥩 Protein Apps:                │
│         • Notes  • Camera  • Kindle     │
│                                         │
│         🥑 Fats Apps:                   │
│         • Messages • WhatsApp           │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│      [  Close  ]  [🍕 Cheat Meal]       │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

### Shield B: Portion Timer (Within Window, First Open)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            🍽️ SCREEN DIET               │
│                                         │
│              ┌────────┐                 │
│              │  📸    │                 │
│              │Instagram│                 │
│              │        │                 │
│              └────────┘                 │
│                                         │
│            🍩 CARBS                     │
│         (High Glycemic)                 │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│          ✅ KITCHEN OPEN                │
│         12:00 PM - 6:00 PM              │
│            (4 hours left)               │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│         📊 DAILY ALLOWANCE              │
│                                         │
│         Used today: 20 minutes          │
│         Remaining: 40 minutes           │
│         Limit: 60 minutes/day           │
│                                         │
│         [████████░░░░░░░░░░]            │
│              33% consumed               │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│      ⚠️ Recommended portion:            │
│            20 minutes                   │
│      Based on remaining window time     │
│                                         │
│   [ Open for 20 Min ]  [Custom Time]    │
│                                         │
│   [🔖 Save for Later]                   │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

### Shield C: Daily Limit Reached

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            🍽️ SCREEN DIET               │
│                                         │
│              ┌────────┐                 │
│              │  📸    │                 │
│              │Instagram│                 │
│              │        │                 │
│              └────────┘                 │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│         🚫 DAILY LIMIT REACHED          │
│                                         │
│      You've consumed your full          │
│      60-minute daily carb portion.      │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│         NUTRITION TODAY:                │
│                                         │
│         🍩 Carbs:  60/60 min 🔴 100%    │
│         🥩 Protein: 25/60 min 🟡  42%   │
│         🥑 Fats:    10/30 min     33%   │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│      Window closes: 6:00 PM             │
│      Next window: Tomorrow 12:00 PM     │
│                                         │
│         🥗 Available now:               │
│         • Protein apps (unlimited)      │
│         • Fats apps (within limits)     │
│                                         │
│   [🍕 Cheat]  [Close]  [See Report]     │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

### Shield D: Protein App (Always Available)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            🍽️ SCREEN DIET               │
│                                         │
│              ┌────────┐                 │
│              │  📝    │                 │
│              │ Notes  │                 │
│              │        │                 │
│              └────────┘                 │
│                                         │
│            🥩 PROTEIN                   │
│         (High Quality)                  │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│       ✅ ALWAYS AVAILABLE               │
│                                         │
│      Notes is high-quality nutrition.   │
│      Create something meaningful.       │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│         📊 TODAY'S PROTEIN              │
│                                         │
│         45 minutes                      │
│         Goal: 60 minutes                │
│                                         │
│         [███████░░░░░░░░░░░]            │
│              75% of goal                │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│      💡 Creative prompts:               │
│      • Journal about your day           │
│      • Plan your week                   │
│      • Write 3 things you're grateful   │
│                                         │
│         [   Open Notes   ]              │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

### Shield E: Carb Curfew (Window Ended While Using)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            🍽️ SCREEN DIET               │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│         🚫 CARB CURFEW IN EFFECT        │
│                                         │
│         Kitchen closed at 6:00 PM       │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│      You were in the middle of          │
│      consuming. Save this for           │
│      tomorrow's window?                 │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│           OPTIONS:                      │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  📴 CLOSE APP                   │    │
│  │     End session now             │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🔖 SAVE TO LIST                │    │
│  │     Bookmark for tomorrow       │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  🍕 CHEAT MEAL                  │    │
│  │     Use flexibility (2 left)    │    │
│  └─────────────────────────────────┘    │
│                                         │
│      Tomorrow's window: 12:00 PM        │
│      Fasted so far: 2 hours             │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

### Shield F: Night Lock Active

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            🍽️ SCREEN DIET               │
│                                         │
│              ┌────────┐                 │
│              │  📸    │                 │
│              │Instagram│                 │
│              │        │                 │
│              └────────┘                 │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│         🌙 NIGHT LOCK ACTIVE            │
│                                         │
│      It's 10:30 PM - time to wind down  │
│                                         │
│      Night lock started: 9:00 PM        │
│      Kitchen opens: 12:00 PM tomorrow   │
│                                         │
│      Protecting your sleep schedule     │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│      🥗 Sleep-friendly alternatives:    │
│                                         │
│      • Kindle - Read a book             │
│      • Podcasts - Audio only            │
│      • Meditation - Wind down           │
│      • Music - Relaxing sounds          │
│                                         │
│        ━━━━━━━━━━━━━━━━━━━━             │
│                                         │
│      [Browse Sleep Apps] [Close]        │
│                                         │
│      [I need emergency access]          │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

---

## Summary: Screen Navigation Map

```
┌─────────────────────────────────────────────────────────────┐
│                        TAB STRUCTURE                        │
├─────────────┬─────────────┬─────────────┬─────────────────┤
│   KITCHEN   │   REPORT    │   PANTRY    │    SETTINGS     │
│    (🏠)     │    (📊)     │    (🥘)     │     (⚙️)        │
├─────────────┼─────────────┼─────────────┼─────────────────┤
│             │             │             │                 │
│ • Diet      │ • Metabolic │ • Protein   │ • Adjust Diet   │
│   status    │   Score     │   apps      │ • Schedule      │
│             │             │             │                 │
│ • Fasting   │ • Body      │ • Carbs     │ • Cheat Meal    │
│   status    │   comp      │   apps      │ • Diet Break    │
│             │             │             │                 │
│ • Window    │ • Screen    │ • Fats      │ • Emergency     │
│   timer     │   time      │   apps      │ • App Settings  │
│             │             │             │                 │
│ • Nutrition │ • Issues    │ • Fiber     │ • Log Out       │
│   today     │             │   apps      │                 │
│             │ • Prescrip- │             │                 │
│ • Available │   tion      │             │                 │
│   apps      │             │             │                 │
│             │             │             │                 │
└─────────────┴─────────────┴─────────────┴─────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │     SHIELD SCREENS      │
              │    (System Overlays)    │
              ├─────────────────────────┤
              │ • Kitchen Closed        │
              │   (Fasting period)      │
              │ • Portion Timer         │
              │   (Within window)       │
              │ • Daily Limit Reached   │
              │ • Protein Available     │
              │ • Carb Curfew           │
              │   (Window ended)        │
              │ • Night Lock            │
              └─────────────────────────┘
```

---

## Related Documentation

- [Complete App Flows](./complete-app-flows.md) - Full user flows and interactions
- [Detailed Flows](./detailed-flows_8.md) - Deep dive into specific features
- [Zero Friction Onboarding](./zero-friction-onboarding_2.md) - Onboarding design
