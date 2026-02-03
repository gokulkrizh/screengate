# ScreenDiet: DeviceActivityReport Integration

> Analysis of the DeviceActivityReport API and its integration into the ScreenDiet architecture for weekly nutritional reports and adaptive prescriptions.

---

## What DeviceActivityReport Actually Provides

From the documentation, this extension context allows:

| Capability | What It Means for ScreenDiet |
|------------|------------------------------|
| `DeviceActivityResults` | Access to historical activity data across user-selected apps |
| `DeviceActivityData` | Aggregated usage metrics per application/category |
| `totalActivityDuration` | Total time spent in specific apps/categories |
| `totalPickups` | Number of times device was picked up |
| `totalNotifications` | Notification count received |
| **Custom predicates** | Filter data by time ranges, app categories, etc. |

**Key insight:** This runs in a **separate extension context** (like a widget), not real-time. It provides **retrospective analysis**, not live monitoring.

---

## Revised ScreenDiet: Report-Based Nutrition

### The New Capability: Weekly Nutritional Reports

Since we cannot do real-time behavioral analysis, we do **retrospective dietary analysis**—like a nutritionist reviewing your food diary after the week.

**The DeviceActivityReport Extension generates:**

```
┌─────────────────────────────────────────┐
│  📊 WEEK 12 NUTRITION REPORT            │
│                                         │
│  Digital Body Fat: 62% (High Carbs)     │
│  Metabolic Score: C+                    │
│                                         │
│  MACRONUTRIENT BREAKDOWN:               │
│  🥩 Protein: 15% (Goal: 30%) ⚠️         │
│  🍩 Carbs: 62% (Goal: 20%) 🔴           │
│  🥑 Fats: 13% (Goal: 25%) ⚠️            │
│  🥦 Fiber: 10% (Goal: 25%) ⚠️           │
│                                         │
│  EATING PATTERNS:                       │
│  • Late Night Snacking: 4 hrs (1-4am)   │
│  • Binge Episodes: 3 (90+ min sessions) │
│  • Grazing: 47 pickups/day              │
│                                         │
│  HEALTH IMPACT:                         │
│  • Attention Span: -12% vs last week    │
│  • Sleep Quality: Poor (3 nights)       │
│                                         │
│  [Adjust Diet]  [View Details]          │
└─────────────────────────────────────────┘
```

---

## What DeviceActivityReport Actually Reveals

### Available Metrics (From API)

| Metric | Source | ScreenDiet Translation |
|--------|--------|------------------------|
| `totalActivityDuration` | Time in apps | "Caloric intake" (total screen time) |
| `totalPickups` | Device pickups | "Grazing behavior" (compulsive checking) |
| `totalNotifications` | Notifications received | "External triggers" (appetite stimulants) |
| `applicationActivity` | Per-app duration | Macro breakdown by app category |
| `categoryActivity` | Category aggregation | Nutritional food groups |

### Derived Insights (Our Calculations)

| Insight | Calculation | Nutritional Framing |
|---------|-------------|---------------------|
| Binge sessions | Sessions > 45 mins | "Heavy meals" vs "snacking" |
| Late night usage | Activity 10pm-6am | "Midnight snacking" |
| Pickup frequency | Pickups / waking hours | "Grazing" behavior |
| Protein ratio | Creation apps / Total | "Diet quality score" |
| Carb spikes | Social/Entertainment % | "Sugar crashes" |

---

## The Revised Architecture: Two-Phase System

### Phase 1: Scheduled Enforcement (Real-Time)

**Components:** `DeviceActivityMonitor` + `ShieldConfiguration` + `ManagedSettings`

**Function:** Time-restricted eating (intermittent fasting)
- Block carbs outside eating windows
- Enforce daily macro limits
- Static shields with nutritional labels

**Limitation:** Cannot adapt based on behavior

### Phase 2: Retrospective Analysis (Weekly)

**Components:** `DeviceActivityReport` extension

**Function:** Nutritional analysis and plan adjustment
- Generate weekly "metabolic report"
- Identify binge patterns, grazing, late-night usage
- Suggest diet adjustments for next week
- Track "digital body composition" over time

**Value:** The report provides the **feedback loop** that makes scheduling feel intelligent, even though enforcement is dumb.

---

## The New User Flow

### Daily Experience

```
8am: Open Notes (Protein) → No shield, always allowed
      ↓
12pm: Open Instagram (Carbs) → Shield: "Carb window open. Serving: 20 mins"
      ↓
12:20pm: Instagram blocks → Shield: "Portion finished. Try Protein?"
      ↓
10pm: Open TikTok (Carbs) → Shield: "Kitchen closed. Fasting until 8am"
```

### Weekly Experience (Sunday Morning)

```
Notification: "Your Weekly Nutrition Report is ready"
      ↓
Open ScreenDiet → DeviceActivityReport generates:
      ↓
📊 WEEK 12 REPORT:
   Digital Body Fat: 58% (-4% from last week! 🎉)
   Metabolic Score: B-
   
   ISSUES DETECTED:
   • Late night carb binging (Tue, Thu: 2hrs after 10pm)
   • Protein deficiency (only 18% creation time)
   
   PRESCRIPTION FOR WEEK 13:
   • Tighten carb window: 12pm-5pm (was 12pm-6pm)
   • Add mandatory Protein breakfast (30 mins creation before 10am)
   • Enable "Carb curfew" at 9pm
      ↓
[Accept Prescription] → Auto-updates DeviceActivitySchedule
```

---

## Key Innovation: The Prescription Engine

**How it works:**

1. **Collect:** `DeviceActivityReport` aggregates last 7 days of data
2. **Analyze:** Compare against nutritional goals (macro ratios, fasting adherence)
3. **Diagnose:** Identify patterns (bingeing, grazing, late-night)
4. **Prescribe:** Generate adjusted `DeviceActivitySchedule` for next week
5. **Apply:** User one-tap accepts, updates all schedules

**Example Prescriptions:**

| Detected Pattern | Prescription | Schedule Change |
|------------------|--------------|-----------------|
| Late-night carb binging | "Carb curfew 1 hour earlier" | `intervalEnd` moves from 6pm → 5pm |
| Protein deficiency | "Morning protein requirement" | New 9am-10am Protein-only window |
| Grazing (47 pickups/day) | "Intermittent fasting 16:8" | 8-hour eating window, 16-hour fast |
| Weekend binges | "Weekend carb limits" | Separate Sat/Sun schedules with lower carb thresholds |

---

## Technical Implementation (Revised)

### The Report Extension

```swift
import DeviceActivity

struct ScreenDietReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .init()
    
    func body(content: DeviceActivityReport.Context) -> some View {
        return ScreenDietReportView(context: context)
    }
}

struct ScreenDietReportView: View {
    let context: DeviceActivityReport.Context
    
    var body: some View {
        // Access aggregated data
        let totalTime = context.totalActivityDuration
        let pickups = context.totalPickups
        let appBreakdown = context.applicationActivity
        
        // Calculate macros
        let proteinTime = appBreakdown
            .filter { isProtein($0.application) }
            .reduce(0) { $0 + $1.totalActivityDuration }
        
        let carbTime = appBreakdown
            .filter { isCarb($0.application) }
            .reduce(0) { $0 + $1.totalActivityDuration }
        
        let proteinRatio = proteinTime / totalTime
        let carbRatio = carbTime / totalTime
        
        // Generate report UI
        VStack {
            Text("Digital Body Fat: \(Int(carbRatio * 100))%")
            Text("Protein Intake: \(Int(proteinRatio * 100))%")
            // ... more metrics
        }
    }
}
```

### The Prescription Generator

```swift
struct DietPrescription {
    let issue: String
    let recommendation: String
    let scheduleUpdate: DeviceActivitySchedule
}

func generatePrescription(report: DeviceActivityReport) -> [DietPrescription] {
    var prescriptions: [DietPrescription] = []
    
    // Detect late night usage
    let lateNightActivity = report.activity(during: 22...24)
    if lateNightActivity > .hours(1) {
        prescriptions.append(DietPrescription(
            issue: "Late night carb binging detected",
            recommendation: "Move carb curfew to 9pm",
            scheduleUpdate: DeviceActivitySchedule(
                intervalStart: DateComponents(hour: 12),
                intervalEnd: DateComponents(hour: 21), // Was 22
                repeats: true
            )
        ))
    }
    
    // Detect protein deficiency
    let proteinRatio = calculateProteinRatio(report)
    if proteinRatio < 0.25 {
        prescriptions.append(DietPrescription(
            issue: "Protein deficiency affecting focus",
            recommendation: "Mandatory morning creation time",
            scheduleUpdate: DeviceActivitySchedule(
                intervalStart: DateComponents(hour: 9),
                intervalEnd: DateComponents(hour: 10),
                repeats: true
                // Only protein apps allowed
            )
        ))
    }
    
    return prescriptions
}
```

---

## What This Enables (That Was Impossible Before)

| Before (Without Report) | After (With Report) |
|-------------------------|---------------------|
| Static schedules forever | Adaptive schedules based on actual behavior |
| No feedback on diet adherence | Weekly "metabolic score" with trends |
| Generic shields | Personalized shields referencing last week's patterns |
| One-size-fits-all | Personalized prescriptions |
| No insight into grazing/binging | Pickup and session analysis |
| User doesn't know if diet is working | Clear "body composition" tracking |

---

## The Honest Limitation

**Still impossible:**
- Real-time intervention ("you've scrolled too long")
- Content analysis ("this video is high glycemic")
- Dynamic shields based on current session
- Automatic app classification

**Now possible:**
- Weekly behavioral analysis
- Trend tracking over time
- Adaptive schedule recommendations
- "Nutritional coaching" based on actual data

---

## Revised Value Proposition

**ScreenDiet is a digital nutritionist that:**

1. **Prescribes** scheduled eating plans (enforcement)
2. **Reviews** your weekly food diary (report)
3. **Adjusts** the prescription based on results (adaptation)

**The metaphor holds:** Real nutritionists don't follow you around stopping you from eating—they give you a meal plan, review your food log weekly, and adjust. ScreenDiet does exactly this for digital consumption.

---

## Related Documentation

- [App Flows](./app-flows_7.md) - Complete user flow diagrams
- [Detailed Flows](./detailed-flows_8.md) - Fasting, kitchen, and prescription flows
- [User Examples](./user-examples_5.md) - Sarah, Mike, and Emma scenarios
- [Zero Friction Onboarding](./zero-friction-onboarding_2.md) - 60-second onboarding design
