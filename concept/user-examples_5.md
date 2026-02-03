   I'll provide concrete examples of how ScreenDiet's three-phase system works in practice, showing real user scenarios with actual data.

---

## **Example 1: Sarah, 28, Marketing Manager**

### **Day 0: Onboarding & First Prescription**

**Sarah's goal:** "I waste hours on Instagram and TikTok at night, then feel terrible. I want to read more and sleep better."

**ScreenDiet onboarding:**
```
Step 1: Select apps
- Protein (🥩): Notes, Kindle, Camera (batch-selected, 3 taps)
- Carbs (🍩): Instagram, TikTok, Twitter (batch-selected, 3 taps)
- Fats (🥑): Messages, WhatsApp (batch-selected, 2 taps)

Step 2: Pick diet template
- [Keto: High creation, low consumption] ✓ Selected
- [Balanced: Moderate mix]
- [Detox: 7-day elimination]

Step 3: Set eating window
- Carbs allowed: 12pm - 6pm (default for Keto)
- Daily carb limit: 60 minutes

Step 4: Activate
"Keto diet activated. Your prescription:
• Protein apps: Always available
• Carbs: 12pm-6pm only, 60min daily max
• Fasting: 6pm-12pm (18-hour daily fast)"
```

**Initial schedule created:**
```swift
DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 12, minute: 0),
    intervalEnd: DateComponents(hour: 18, minute: 0),
    repeats: true,
    warningTime: nil
)
```

---

### **Week 1: Enforcement & Data Collection**

**Daily experience:**

| **Time** | **Action** | **ScreenDiet Response** |
|----------|-----------|------------------------|
| 9:00am | Opens Notes to journal | ✅ No shield. Protein always allowed. |
| 11:30am | Tries Instagram | 🚫 Shield: "Kitchen closed. Carbs at 12pm." |
| 12:05pm | Opens Instagram | ⚠️ Shield: "Carb window open. Serving: 20 mins. Daily limit: 60 mins." |
| 12:25pm | Instagram auto-blocks | 🚫 Shield: "Portion finished. 40 mins remaining today." |
| 3:00pm | Opens TikTok | ⚠️ Shield: "Carb window open. 35 mins used / 60 mins." |
| 6:30pm | Tries Twitter | 🚫 Shield: "Carb curfew. Fasting until 12pm tomorrow." |
| 10:00pm | Tries Instagram | 🚫 Shield: "Night fasting active. Try Fiber (Kindle)?" |

**Week 1 data collected (via DeviceActivityReport):**
- Total screen time: 38 hours
- Protein: 4 hours (11%) ❌
- Carbs: 26 hours (68%) 🔴
- Fats: 5 hours (13%)
- Fiber: 3 hours (8%)
- Late night usage (10pm-2am): 8 hours 🔴
- Pickups: 89/day 🔴
- Carb limit exceeded: 5/7 days

---

### **Week 1 Review: Sunday Report**

**Sarah opens ScreenDiet:**

```
┌─────────────────────────────────────────┐
│  📊 WEEK 1 NUTRITION REPORT             │
│                                         │
│  METABOLIC SCORE: D+ 🔴                 │
│  Digital Body Fat: 68% (Obese)          │
│                                         │
│  🚨 CRITICAL ISSUES DETECTED:           │
│                                         │
│  1. SEVERE PROTEIN DEFICIENCY           │
│     Goal: 40% | Actual: 11%             │
│     Impact: Focus, creativity depleted  │
│                                         │
│  2. LATE-NIGHT BINGE PATTERN            │
│     8 hrs after carb curfew (10pm-2am)  │
│     Peak: Tuesday 11:30pm (2.5 hrs)     │
│     Impact: Sleep quality destroyed     │
│                                         │
│  3. GRAZING EPIDEMIC                    │
│     89 pickups/day (Healthy: <30)       │
│     Every 6 minutes during work hours   │
│                                         │
│  4. CARB ADDICTION                      │
│     Exceeded daily limit 5/7 days       │
│     Average: 94 mins (Target: 60)       │
│                                         │
│  [View Full Analysis]                   │
└─────────────────────────────────────────┘
```

**Sarah taps "View Full Analysis":**

```
┌─────────────────────────────────────────┐
│  BEHAVIORAL PATTERN ANALYSIS            │
│                                         │
│  YOUR EATING HABITS:                    │
│                                         │
│  🕐 9am-12pm: Fasting (good)            │
│     But: 23 pickups checking phone      │
│                                         │
│  🍽️ 12pm-6pm: Carb window               │
│     Problem: Binge eating (94 min avg)  │
│     Pattern: Open Instagram → 45 mins   │
│              Close → 5 mins → Reopen    │
│              (Compulsive loop detected) │
│                                         │
│  🌙 6pm-2am: SUPPOSED TO FAST           │
│     Reality: 8 hrs secret snacking      │
│     Willpower exhausted by evening      │
│                                         │
│  💤 2am-9am: Sleep (interrupted)        │
│     4 late-night pickups avg            │
│                                         │
│  PRESCRIPTION FOR WEEK 2:               │
│                                         │
│  🥗 ADJUSTED DIET: "Strict Keto Plus"   │
│                                         │
│  Changes:                               │
│  • Carb window: 12pm-5pm (was 6pm)      │
│    Reason: Earlier curfew stops binging │
│                                         │
│  • Carb limit: 45 mins (was 60)         │
│    Reason: Force portion control        │
│                                         │
│  • Mandatory Protein Breakfast          │
│    9am-10am: Only Protein apps unlock   │
│    Reason: Front-load creation          │
│                                         │
│  • Night Lockdown                       │
│    9pm-8am: All apps blocked except     │
│    Phone, Messages (emergency only)     │
│    Reason: Stop late-night binging      │
│                                         │
│  • Grazing Guard                        │
│    30-min cooldown between carb apps    │
│    Reason: Break compulsive loops       │
│                                         │
│  [Accept Prescription] [Modify] [Skip]  │
└─────────────────────────────────────────┘
```

**Sarah taps [Accept Prescription]:**

```
✅ PRESCRIPTION APPLIED

Your schedule updated:
• Carb window: 12pm-5pm (1 hour earlier)
• Daily carb limit: 45 minutes
• Protein breakfast: 9am-10am mandatory
• Night lockdown: 9pm-8am strict
• Cooldown timer: 30 mins between apps

Next report: Sunday, 9am
```

**Behind the scenes:**
```swift
// Old schedule replaced
let newCarbSchedule = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 12, minute: 0),
    intervalEnd: DateComponents(hour: 17, minute: 0), // Was 18
    repeats: true
)

let proteinBreakfast = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 9, minute: 0),
    intervalEnd: DateComponents(hour: 10, minute: 0),
    repeats: true
)

let nightLockdown = DeviceActivitySchedule(
    intervalStart: DateComponents(hour: 21, minute: 0),
    intervalEnd: DateComponents(hour: 8, minute: 0), // Next day
    repeats: true
)

// Apply via DeviceActivityCenter
center.stopMonitoring([oldSchedule])
center.startMonitoring([newCarbSchedule, proteinBreakfast, nightLockdown])
```

---

### **Week 2: Adjusted Enforcement**

**New daily experience:**

| **Time** | **Action** | **ScreenDiet Response** |
|----------|-----------|------------------------|
| 9:00am | Tries Instagram | 🚫 Shield: "Protein breakfast. Create first." Opens Notes instead |
| 9:45am | Opens Kindle | ✅ Allowed. Protein window active |
| 10:05am | Tries Instagram | 🚫 Shield: "Fasting until 12pm. 2 hours left." |
| 12:05pm | Opens Instagram | ⚠️ Shield: "Carb window: 45 mins. Portion: 15 mins." |
| 12:20pm | Instagram blocks | 🚫 Shield: "Cooling down. 30 mins until next carb." |
| 12:25pm | Tries TikTok | 🚫 Shield: "Cooldown active. 25 mins remaining." |
| 3:00pm | Opens TikTok | ⚠️ Shield: "30 mins carbs remaining today." |
| 5:05pm | Tries Twitter | 🚫 Shield: "Carb curfew. Kitchen closed." |
| 9:30pm | Tries Instagram | 🚫 Shield: "Night lockdown. Sleep mode until 8am." |

**Week 2 data:**
- Total screen time: 28 hours (-26%) 🎉
- Protein: 8 hours (29%) ↑
- Carbs: 12 hours (43%) ↓
- Late night: 1 hour (-87%) 🎉
- Pickups: 45/day (-49%) 🎉
- Carb limit: 2/7 days exceeded

---

### **Week 2 Review: Progress Report**

```
┌─────────────────────────────────────────┐
│  📊 WEEK 2 NUTRITION REPORT             │
│                                         │
│  METABOLIC SCORE: B- 🟡                 │
│  (↑ from D+)                            │
│                                         │
│  Digital Body Fat: 43% (Improving)      │
│  (↓ from 68%)                           │
│                                         │
│  ✅ MAJOR IMPROVEMENTS:                 │
│                                         │
│  1. PROTEIN INTAKE DOUBLED              │
│     11% → 29% (Goal: 40%)               │
│     Morning creation habit forming      │
│                                         │
│  2. LATE-NIGHT BINGES ELIMINATED        │
│     8 hrs → 1 hr (-87%)                 │
│     Sleep quality: Improved             │
│                                         │
│  3. GRAZING REDUCED                     │
│     89 → 45 pickups/day                 │
│     Cooldown timer working              │
│                                         │
│  ⚠️ REMAINING ISSUES:                   │
│                                         │
│  1. CARB LIMIT STILL EXCEEDED           │
│     2/7 days (Tue, Fri)                 │
│     Pattern: Stress eating after work   │
│                                         │
│  2. WEEKEND SLIPPAGE                    │
│     Sat: 3 hrs carbs (no schedule)      │
│     Sun: 2.5 hrs late-night             │
│                                         │
│  PRESCRIPTION FOR WEEK 3:               │
│                                         │
│  🥗 ADJUSTED DIET: "Sustainable Keto"   │
│                                         │
│  Changes:                               │
│  • Weekend schedule added               │
│    Sat-Sun: 10am-4pm carb window        │
│    (Was: no restrictions)               │
│                                         │
│  • Stress protocol                      │
│    Tue/Fri: Extended protein lunch      │
│    12pm-1pm: Mandatory creation         │
│    (Your high-risk days)                │
│                                         │
│  • Carb limit: 50 mins (was 45)         │
│    Slightly relaxed for sustainability  │
│                                         │
│  • Remove cooldown timer                │
│    You've broken the loop habit         │
│                                         │
│  [Accept] [Modify] [Keep Current]       │
└─────────────────────────────────────────┘
```

---

## **Example 2: Mike, 35, Software Engineer**

### **Month 1-3: Escalating Prescriptions**

**Mike's journey showing progressive adaptation:**

| **Week** | **Report Finding** | **Prescription Adjustment** | **Result** |
|----------|-------------------|----------------------------|-----------|
| 1 | 85% carbs, 3am bedtime | Strict Keto: 12-6pm carbs, 9pm lockdown | 65% carbs, 1am bedtime |
| 2 | Grazing 120x/day | Add 30-min cooldowns, protein breakfast | 70x/day pickups |
| 3 | Weekend binges (no schedule) | Add weekend fasting 10am-4pm | Consistent macros |
| 4 | Protein still low (20%) | Mandatory creation 9-10am, 2-3pm | 35% protein |
| 6 | "Feeling restricted, want to quit" | Switch to "Mediterranean": 30% carbs allowed, flexible windows | Adherence improves |
| 8 | Plateau: 40% carbs, not improving | "Cyclical Keto": 5 days strict, 2 days moderate | Breaks plateau |
| 12 | Maintaining 70% protein, 20% carbs | "Maintenance Mode": Self-managed with weekly check-ins | Sustainable long-term |

---

## **Example 3: Emma, 19, College Student**

### **The Detox Protocol**

**Emma's severe addiction pattern:**

**Week 0 Assessment:**
```
DIGITAL METABOLISM: CRITICAL 🔴
• Daily screen time: 11 hours
• TikTok alone: 6 hours
• Pickups: 200+/day
• Sleep: 4 hours avg (3am-7am)
• Classes missed: 3 (scrolling in bed)
```

**Prescription: "Digital Detox - Inpatient"**

```
WEEK 1-2: ACUTE DETOX
• All carbs eliminated (100% block)
• Protein only: Notes, Camera, Kindle
• Fats: Messages (family only, 30 mins/day)
• 24/7 medical monitoring (sponsor check-ins)
• Symptom tracking: Anxiety, cravings, irritability

WEEK 3-4: TAPERED REINTRODUCTION  
• Carbs: 15 mins/day, 12-12:15pm only
• Must complete 30-min protein first
• Gradual increase: 15→20→30→45 mins

WEEK 5-8: MAINTENANCE PROTOCOL
• Target: 60 mins carbs/day
• Strict 12-6pm window
• Weekend flexibility (social needs)
• Sponsor accountability
```

**Week 4 Report:**
```
DETOX PROGRESS: 28 DAYS CLEAN 🎉

Withdrawal symptoms: Resolved
• Week 1: Severe anxiety, phantom vibrations
• Week 2: Irritability, FOMO
• Week 3: Cravings reduced
• Week 4: Stable mood, improved focus

Metabolic healing:
• Screen time: 11 hrs → 4.5 hrs (-59%)
• Protein: 5% → 45% (creation restored)
• Sleep: 4 hrs → 7.5 hrs
• GPA trend: ↑ (attendance improved)

PRESCRIPTION: Transition to Maintenance
• Gradual carb increase to 60 mins
• Social apps reintroduced carefully
• Continue sponsor support
• Monthly check-ins (vs weekly)
```

---

## **The Prescription Algorithm (Simplified)**

```swift
func generatePrescription(week: DeviceActivityReport) -> Prescription {
    var changes: [ScheduleChange] = []
    
    // Issue 1: Late night usage
    let lateNight = week.activity(during: 22...24)
    if lateNight > .hours(2) {
        changes.append(.moveCarbCurfewEarlier(by: 1)) // 6pm→5pm
        changes.append(.enableNightLockdown(from: 21))
    }
    
    // Issue 2: Protein deficiency
    let proteinRatio = week.proteinTime / week.totalTime
    if proteinRatio < 0.25 {
        changes.append(.addMandatoryProteinWindow(9...10))
        changes.append(.blockCarbsUntilProteinCompleted)
    }
    
    // Issue 3: Grazing
    if week.pickups > 60 {
        changes.append(.addCooldownBetweenApps(30))
    }
    
    // Issue 4: Weekend slippage
    if week.weekendCarbs > week.weekdayCarbs * 2 {
        changes.append(.addWeekendSchedule)
    }
    
    // Issue 5: Stress pattern (same weekdays high)
    let highCarbDays = week.daysWhere { $0.carbTime > limit }
    if highCarbDays.hasPattern(.tuesday, .friday) {
        changes.append(.addStressProtocol(highCarbDays))
    }
    
    // Issue 6: User burnout (adherence dropping)
    if week.shieldBypassRate > 0.3 {
        changes.append(.relaxRestrictionsSlightly) // Sustainability
        changes.append(.switchToMoreFlexibleDiet)
    }
    
    return Prescription(changes: changes, explanation: generateExplanation(changes))
}
```

---

## **Summary: The Three-Phase Loop**

| **Phase** | **Frequency** | **Action** | **User Experience** |
|-----------|--------------|-----------|---------------------|
| **Prescribe** | Day 0, Weekly | Set macro schedules, eating windows | "Your personalized diet plan" |
| **Enforce** | Real-time | `ShieldConfiguration` blocks, `DeviceActivitySchedule` windows | Immediate feedback at point of use |
| **Review** | Weekly Sunday | `DeviceActivityReport` analysis | "Here's what happened, why, and what's next" |
| **Adjust** | Weekly Sunday | Update schedules based on data | One-tap prescription acceptance |

**The magic:** Even though enforcement is dumb (time-based only), the **weekly feedback loop makes it feel intelligent and personalized**. Sarah doesn't just see "Instagram blocked"—she sees "We blocked Instagram because last week you binged 8 hours after bedtime, and here's how that's improving."

Is this level of concrete example helpful? Should I detail the **specific shield copy** (what the blocking messages actually say) or the **sponsor/ accountability integration** (how the social component works)?