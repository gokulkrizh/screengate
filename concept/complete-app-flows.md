# ScreenDiet: Complete App Flows

> Comprehensive user flows from onboarding to daily use, weekly reviews, and lifecycle management.

---

## Table of Contents

1. [Onboarding Flow](#1-onboarding-flow)
2. [Daily Usage Flows](#2-daily-usage-flows)
3. [Interruption Handling Flows](#3-interruption-handling-flows)
4. [Weekly Report & Prescription Flow](#4-weekly-report--prescription-flow)
5. [Settings & Management Flows](#5-settings--management-flows)
6. [Notification Flows](#6-notification-flows)

---

## 1. Onboarding Flow

### Step 1: Splash Screen

```
┌─────────────────────────────────────────┐
│                                         │
│            🍽️ SCREEN DIET               │
│                                         │
│     "You are what you consume—         │
│           digitally"                    │
│                                         │
│     [Get Started]                       │
│                                         │
└─────────────────────────────────────────┘
```

### Step 2: Grant Permissions

```
┌─────────────────────────────────────────┐
│  STEP 1: GRANT PERMISSIONS              │
│                                         │
│  ScreenDiet needs Screen Time access    │
│  to help you build healthier digital    │
│  habits.                                │
│                                         │
│  [Authorize Screen Time]                │
│                                         │
│  Required: FamilyControls entitlement   │
└─────────────────────────────────────────┘
```

### Step 3: Select Food Groups

```
┌─────────────────────────────────────────┐
│  STEP 2: SELECT YOUR FOOD GROUPS        │
│                                         │
│  Pick apps, then tap a macronutrient:   │
│                                         │
│  [🥩 PROTEIN: Create]                   │
│    Notes, Camera, GarageBand, Code      │
│    → Select apps → Done                 │
│                                         │
│  [🍩 CARBS: Consume]                    │
│    Instagram, TikTok, Twitter, Games    │
│    → Select apps → Done                 │
│                                         │
│  [🥑 FATS: Connect]                     │
│    Messages, WhatsApp, FaceTime         │
│    → Select apps → Done                 │
│                                         │
│  [🥦 FIBER: Learn]                      │
│    Kindle, Podcasts, News               │
│    → Select apps → Done                 │
│                                         │
│  [Skip remaining]                       │
└─────────────────────────────────────────┘
```

### Step 4: Choose Your Diet

```
┌─────────────────────────────────────────┐
│  STEP 3: CHOOSE YOUR DIET               │
│                                         │
│  [KETO]        [BALANCED]    [DETOX]    │
│  High creation Mixed macros  Elimination│
│  70% Protein   40/30/30      7-day      │
│  10% Carbs                    cleanse   │
│                                         │
│  [CUSTOM]                               │
│  Build your own                         │
└─────────────────────────────────────────┘
```

### Step 5: Set Eating Windows

```
┌─────────────────────────────────────────┐
│  STEP 4: SET EATING WINDOWS             │
│                                         │
│  Based on Keto diet:                    │
│                                         │
│  🥩 Protein apps: ALWAYS OPEN           │
│                                         │
│  🍩 Carb window:                        │
│     Start: [12:00 PM] ▼                 │
│     End:   [ 6:00 PM] ▼                 │
│                                         │
│  Daily carb limit: [60] minutes         │
│                                         │
│  🌙 Night fast: 6:00 PM - 12:00 PM      │
│                                         │
│  [Activate Diet]                        │
└─────────────────────────────────────────┘
```

### Step 6: Diet Activated

```
┌─────────────────────────────────────────┐
│  ✅ DIET ACTIVATED                      │
│                                         │
│  Your prescription:                     │
│  • Protein: Always available            │
│  • Carbs: 12pm-6pm, 60 min limit        │
│  • Fasting: 18 hours daily              │
│                                         │
│  First nutrition label appears when     │
│  you open any tracked app.              │
│                                         │
│  [Start Using]  [See Tutorial]          │
└─────────────────────────────────────────┘
```

**Total Onboarding Time:** 60-90 seconds

---

## 2. Daily Usage Flows

### Flow A: Opening Allowed App (Protein, Always Available)

```
User taps Notes
    ↓
┌─────────────────────────────────────────┐
│  ✅ PROTEIN: ALWAYS AVAILABLE           │
│                                         │
│  Notes is high-quality nutrition.       │
│  Create something meaningful.           │
│                                         │
│  Today's protein: 45 mins               │
│  (Goal: 60 mins)                        │
│                                         │
│  [Open App]                             │
└─────────────────────────────────────────┘
    ↓
App opens normally
```

### Flow B: Opening Restricted App Outside Window

```
User taps Instagram at 8:00 PM
    ↓
┌─────────────────────────────────────────┐
│  🍽️ SCREEN DIET                         │
│                                         │
│  [App Icon] Instagram                   │
│  Category: CARBS (Processed)            │
│                                         │
│  ⚠️ KITCHEN CLOSED                      │
│                                         │
│  Carb window: 12:00 PM - 6:00 PM        │
│  Current time: 8:00 PM                  │
│  Fasting period: 14 hours remaining     │
│                                         │
│  🥗 Available now:                      │
│  • Protein: Notes, Camera, Kindle       │
│  • Fats: Messages (connection)          │
│                                         │
│  [Close]  [Emergency Access]            │
└─────────────────────────────────────────┘
    ↓
User taps [Close]
    ↓
Returns to home screen
```

### Flow C: Opening Allowed App Within Window

```
User taps Instagram at 2:00 PM
    ↓
┌─────────────────────────────────────────┐
│  🍽️ SCREEN DIET                         │
│                                         │
│  [App Icon] Instagram                   │
│  Category: CARBS (High Glycemic)        │
│                                         │
│  ✅ CARB WINDOW OPEN                    │
│  12:00 PM - 6:00 PM (4 hours left)      │
│                                         │
│  Daily allowance: 60 minutes            │
│  Used today: 20 minutes                 │
│  Remaining: 40 minutes                  │
│                                         │
│  ⚠️ Recommended portion: 20 minutes     │
│                                         │
│  [Consume 20 Min]  [Custom Time]        │
└─────────────────────────────────────────┘
    ↓
User taps [Consume 20 Min]
    ↓
20-minute timer starts
    ↓
At 20 minutes OR if user leaves app:
┌─────────────────────────────────────────┐
│  🍽️ PORTION FINISHED                    │
│                                         │
│  You've consumed 20 minutes of carbs.   │
│                                         │
│  Daily remaining: 20 minutes            │
│  Window closes: 4:00 PM                 │
│                                         │
│  🥗 Suggested next:                     │
│  • Protein: Create something            │
│  • Fats: Call a friend                  │
│  • Fiber: Read 10 pages                 │
│                                         │
│  [Close]  [Open Protein App]            │
└─────────────────────────────────────────┘
```

### Flow D: Hitting Daily Limit

```
User has used 55 mins, opens Instagram for remaining 5 mins
    ↓
Uses for 5 mins, hits 60-min limit while scrolling
    ↓
┌─────────────────────────────────────────┐
│  🚫 DAILY CARB LIMIT REACHED            │
│                                         │
│  You've consumed your full 60-minute    │
│  daily portion.                         │
│                                         │
│  Nutrition today:                       │
│  🍩 Carbs: 60/60 mins (100%) 🔴         │
│  🥩 Protein: 25/60 mins (42%) ⚠️        │
│  🥑 Fats: 10/30 mins (33%)              │
│                                         │
│  Window closes: 6:00 PM                 │
│  Next window: Tomorrow 12:00 PM         │
│                                         │
│  🥗 Available now:                      │
│  • Protein apps (unlimited)             │
│  • Fats apps (within limits)            │
│                                         │
│  [🍕 Cheat Meal]  [Close]  [See Report] │
└─────────────────────────────────────────┘
```

### Flow E: Window Ends While Using

```
User opens Instagram at 5:45 PM
    ↓
Window ends at 6:00 PM while actively using
    ↓
┌─────────────────────────────────────────┐
│  🚫 CARB CURFEW IN EFFECT               │
│                                         │
│  Kitchen closed at 6:00 PM.             │
│                                         │
│  You were in the middle of consuming.   │
│  Save this for tomorrow's window?       │
│                                         │
│  Options:                               │
│  [Close App] - End now                  │
│  [Save to List] - Bookmark for later    │
│  [🍕 Cheat Meal] - Use flexibility      │
│                                         │
│  Tomorrow's window: 12:00 PM            │
└─────────────────────────────────────────┘
```

---

## 3. Interruption Handling Flows

### Flow A: Emergency Access (Cheat Meal)

```
User taps [Emergency Access] on any shield
    ↓
┌─────────────────────────────────────────┐
│  🍽️ CHEAT MEAL REQUEST                  │
│                                         │
│  Emergency access to restricted app.    │
│                                         │
│  Options:                               │
│                                         │
│  [🍕 Planned Cheat]                     │
│     Uses weekly allowance               │
│     Remaining: 2/3 this week            │
│     Duration: 30 minutes                │
│                                         │
│  [🆘 True Emergency]                    │
│     Bypass with consequences            │
│     Affects weekly metabolic score      │
│     Requires reason: [Text input]       │
│                                         │
│  [❌ Cancel] - Stick to diet            │
└─────────────────────────────────────────┘
    ↓
User selects [Planned Cheat]
    ↓
┌─────────────────────────────────────────┐
│  ✅ CHEAT MEAL APPROVED                 │
│                                         │
│  Duration: 30 minutes                   │
│  Starting: Now                          │
│                                         │
│  Your schedule adjusts:                 │
│  • Tomorrow's carb window: 11:30am-6pm  │
│    (30 mins shorter to balance)         │
│                                         │
│  Remaining cheats this week: 1/3        │
│                                         │
│  [Start 30-Min Timer]                   │
└─────────────────────────────────────────┘
```

### Flow B: Diet Break (Vacation Mode)

```
User goes to Settings → Diet Controls → Take Break
    ↓
┌─────────────────────────────────────────┐
│  🛑 DIET BREAK WARNING                  │
│                                         │
│  You're about to pause ScreenDiet.      │
│                                         │
│  Duration:                              │
│  [1 Day]  [Weekend]  [1 Week]  [Custom] │
│                                         │
│  ⚠️ Consequences:                       │
│  • No protection during break           │
│  • No weekly report generated           │
│  • Metabolic score paused               │
│  • May trigger old habits               │
│                                         │
│  💡 RECOMMENDED: Weekend Mode           │
│  Relaxed schedule vs. fully off:        │
│  • Carb window: 10am-8pm (extended)     │
│  • Daily limit: 90 mins (relaxed)       │
│  • Night lockdown: 11pm (later)         │
│                                         │
│  [Weekend Mode]  [Full Break]  [Cancel] │
└─────────────────────────────────────────┘
    ↓
User selects [Weekend Mode]
    ↓
┌─────────────────────────────────────────┐
│  ✅ WEEKEND MODE ACTIVATED              │
│                                         │
│  Relaxed schedule active:               │
│  • Fri 6pm - Mon 8am                    │
│                                         │
│  Adjusted windows:                      │
│  • Carbs: 10am-8pm                      │
│  • Limit: 90 mins/day                   │
│  • Night lock: 11pm                     │
│                                         │
│  Auto-resumes: Monday 8:00 AM           │
│                                         │
│  [Got It]                               │
└─────────────────────────────────────────┘
```

### Flow C: Relapse Detection (Permissions Removed)

```
System detects Screen Time authorization revoked
    ↓
User reopens ScreenDiet
    ↓
┌─────────────────────────────────────────┐
│  🚨 RELAPSE DETECTED                    │
│                                         │
│  ScreenDiet was paused on [Date, Time]  │
│                                         │
│  This is normal in recovery.            │
│  67% of users pause at least once.      │
│                                         │
│  Options:                               │
│                                         │
│  [🔄 Quick Resume]                      │
│     Restore all settings (30 seconds)   │
│                                         │
│  [📞 Call Sponsor]                      │
│     Talk to accountability partner      │
│                                         │
│  [📊 See Impact]                        │
│     What happened during the gap?       │
│                                         │
│  [🆘 Emergency Support]                 │
│     Crisis resources                    │
└─────────────────────────────────────────┘
    ↓
User taps [📊 See Impact]
    ↓
┌─────────────────────────────────────────┐
│  📊 RELAPSE IMPACT ANALYSIS             │
│                                         │
│  Break duration: 48 hours               │
│                                         │
│  During the break:                      │
│  • Screen time: 14 hrs/day (was 4) 🔴   │
│  • Peak usage: 2am-4am (sleep loss) 🔴  │
│  • Most used: TikTok (8 hrs) 🔴         │
│  • Pickups: 180/day (was 45) 🔴         │
│                                         │
│  VS. your ScreenDiet average:           │
│  • 250% increase in screen time         │
│  • Sleep schedule disrupted             │
│                                         │
│  RESUMING RECOMMENDATION:               │
│                                         │
│  [Gentle Restart]                       │
│  • Shorter windows for 3 days           │
│  • Extra sponsor check-ins              │
│  • Gradual return to full schedule      │
│                                         │
│  [Full Restart]                         │
│  • Resume previous schedule immediately │
│                                         │
│  [Start Fresh]                          │
│  • New diet prescription                │
└─────────────────────────────────────────┘
```

---

## 4. Weekly Report & Prescription Flow

### Sunday Notification

```
Sunday 9:00 AM notification
    ↓
┌─────────────────────────────────────────┐
│  📊 Your Weekly Nutrition Report        │
│                                         │
│  Week 12 is ready. See how your         │
│  digital diet affected your health.     │
│                                         │
│  [View Report]                          │
└─────────────────────────────────────────┘
```

### Weekly Report Summary

```
┌─────────────────────────────────────────┐
│  📊 WEEK 12 NUTRITION REPORT            │
│                                         │
│  METABOLIC SCORE: C+ 🟡                 │
│  (↑ from D+ last week)                  │
│                                         │
│  DIGITAL BODY COMPOSITION:              │
│  🍩 Carbs: 58% (Goal: 20%) 🔴           │
│  🥩 Protein: 22% (Goal: 40%) ⚠️         │
│  🥑 Fats: 12% (Goal: 25%)               │
│  🥦 Fiber: 8%  (Goal: 15%)              │
│                                         │
│  TOTAL SCREEN TIME: 42 hours            │
│  (↓ 8 hours from last week) 🎉          │
│                                         │
│  [See Detailed Analysis]                │
└─────────────────────────────────────────┘
```

### Detailed Analysis

```
┌─────────────────────────────────────────┐
│  🔍 DETAILED ANALYSIS                   │
│                                         │
│  🚨 ISSUES DETECTED:                    │
│                                         │
│  1. LATE-NIGHT BINGING                  │
│     6.5 hours after 6pm curfew          │
│     Peak: Tuesday 11:30pm (2 hrs)       │
│     Impact: Sleep quality degraded      │
│                                         │
│  2. PROTEIN DEFICIENCY                  │
│     Only 22% creation time              │
│     Missed morning sessions 4/7 days    │
│                                         │
│  3. WEEKEND SLIPPAGE                    │
│     Sat-Sun: 70% carbs vs 45% weekday   │
│     No schedule enforcement             │
│                                         │
│  [View Prescription]                    │
└─────────────────────────────────────────┘
```

### Prescription for Next Week

```
┌─────────────────────────────────────────┐
│  💊 PRESCRIPTION FOR WEEK 13            │
│                                         │
│  Based on your patterns, adjust:        │
│                                         │
│  🥗 STRICTER KETO PLUS                  │
│                                         │
│  Changes:                               │
│  • Carb window: 12pm-5pm (was 6pm)      │
│    Stop late-night access               │
│                                         │
│  • Carb limit: 45 mins (was 60)         │
│    Force portion control                │
│                                         │
│  • Mandatory Protein Breakfast          │
│    9am-10am: Only creation apps         │
│    Block all carbs until completed      │
│                                         │
│  • Weekend Schedule                     │
│    Sat-Sun: 10am-4pm carb window        │
│    Stop weekend slippage                │
│                                         │
│  Expected result:                       │
│  • Carbs: 58% → 35%                     │
│  • Protein: 22% → 35%                   │
│  • Sleep: Improved                      │
│                                         │
│  [Accept Prescription]  [Modify]  [Skip]│
└─────────────────────────────────────────┘
    ↓
User taps [Accept Prescription]
    ↓
┌─────────────────────────────────────────┐
│  ✅ PRESCRIPTION APPLIED                │
│                                         │
│  New schedule active immediately:       │
│                                         │
│  TODAY'S WINDOWS:                       │
│  • Protein Breakfast: 9am-10am          │
│  • Carb Window: 12pm-5pm (1 hr shorter) │
│  • Daily Limit: 45 mins                 │
│  • Night Lockdown: 5pm-9am              │
│                                         │
│  Next report: Sunday, 9am               │
│                                         │
│  [Start Week 13]                        │
└─────────────────────────────────────────┘
```

---

## 5. Settings & Management Flows

### Flow A: Modify Current Diet

```
Settings → Adjust My Diet
    ↓
┌─────────────────────────────────────────┐
│  ⚙️ ADJUST DIET                         │
│                                         │
│  Current: Keto (Strict)                 │
│                                         │
│  Quick adjustments:                     │
│                                         │
│  Carb Window:                           │
│  [11am-5pm]  [12pm-6pm]  [1pm-7pm]      │
│  [Custom]                               │
│                                         │
│  Daily Limit: [45] [60] [90] mins       │
│                                         │
│  Night Lock: [9pm] [10pm] [11pm]        │
│                                         │
│  Or switch diet:                        │
│  [Switch to Balanced]                   │
│  [Switch to Detox]                      │
│                                         │
│  [Save Changes]                         │
└─────────────────────────────────────────┘
```

### Flow B: Emergency Controls

```
Settings → Emergency
    ↓
┌─────────────────────────────────────────┐
│  🚨 EMERGENCY CONTROLS                  │
│                                         │
│  [🛑 Pause All Restrictions]            │
│     1 hour emergency access             │
│     Requires reason                     │
│                                         │
│  [🍕 Use Cheat Meal]                    │
│     2 remaining this week               │
│                                         │
│  [📞 Contact Sponsor]                   │
│     Call accountability partner         │
│                                         │
│  [🏥 Crisis Resources]                  │
│     Digital addiction support           │
│                                         │
│  [🔄 Reset All Settings]                │
│     Start fresh with new prescription   │
└─────────────────────────────────────────┘
```

### Flow C: View Digital Pantry

```
Kitchen → My Pantry
    ↓
┌─────────────────────────────────────────┐
│  🥘 MY DIGITAL PANTRY                   │
│                                         │
│  PROTEIN (Creation) 🥩                  │
│  [Notes]      [Camera]      [GarageBand]│
│  [Code]       [Design]      [Writing]   │
│  Always fresh. Unlimited portions.      │
│                                         │
│  CARBS (Consumption) 🍩                 │
│  [Instagram]  [TikTok]      [Twitter]   │
│  [YouTube]    [Games]       [Netflix]   │
│  Processed. Ration carefully.           │
│                                         │
│  FATS (Connection) 🥑                   │
│  [Messages]   [WhatsApp]    [FaceTime]  │
│  [Slack]      [Teams]                   │
│  Essential nutrients. Moderate portions.│
│                                         │
│  FIBER (Learning) 🥦                    │
│  [Kindle]     [Audible]     [Podcasts]  │
│  [News]       [Courses]                 │
│  Slow digestion. Daily recommended.     │
│                                         │
│  [+ Add Ingredient]  [Restock Pantry]   │
└─────────────────────────────────────────┘
```

---

## 6. Notification Flows

| Trigger | Notification | Action |
|---------|--------------|--------|
| 15 min before carb window | "🍽️ Carb window opens in 15 minutes" | Tap to see plan |
| Carb window opened | "✅ Kitchen open: 12pm-6pm" | Tap to open allowed apps |
| 15 min before window closes | "⚠️ Carb window closes in 15 mins" | Tap to check usage |
| Daily limit reached | "🚫 Daily carb limit reached" | Tap to see alternatives |
| Weekly report ready | "📊 Week 12 report: C+" | Tap to view full report |
| Relapse detected | "🚨 ScreenDiet was turned off" | Tap to resume |
| 3 days no protein | "⚠️ Protein deficiency detected" | Tap to create something |

---

## Summary: All Flows at a Glance

| Flow | User Goal | API Components | Key Screen |
|------|-----------|----------------|------------|
| Onboarding | Setup diet | `FamilyActivityPicker`, `DeviceActivitySchedule` | Macro selection, window setup |
| Open allowed app | Use protein app | `ShieldConfiguration` (allowed) | Nutrition label, encouragement |
| Open blocked app | Access outside window | `ShieldConfiguration` (blocked), `ManagedSettings` | Kitchen closed, alternatives |
| Within window | Use carbs | `DeviceActivityEvent` (timer), `ShieldConfiguration` | Portion timer, daily limit |
| Hit limit | Continue using | `ShieldConfiguration` (limit reached) | Daily max, cheat meal option |
| Window ends | Finish session | `DeviceActivitySchedule` cutoff | Curfew warning, save for later |
| Cheat meal | Emergency access | Temporary `DeviceActivitySchedule` | Approval, consequence display |
| Diet break | Vacation | Stop/restart `DeviceActivityCenter` | Warning, mode selection |
| Relapse | Resume after pause | Re-authorization, `AuthorizationCenter` | Impact analysis, resume options |
| Weekly report | Review progress | `DeviceActivityReport` extension | Metabolic score, prescription |
| Accept prescription | Update schedule | Update `DeviceActivitySchedule` | Confirmation, new windows |

---

## Related Documentation

- [Device Activity Report](./device-activity-report.md) - Weekly report technical implementation
- [Detailed Flows](./detailed-flows_8.md) - Fasting, kitchen, prescription deep dives
- [User Examples](./user-examples_5.md) - Sarah, Mike, Emma scenarios
- [Zero Friction Onboarding](./zero-friction-onboarding_2.md) - 60-second onboarding design
