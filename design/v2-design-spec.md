# ScreenDiet v2 design spec

Handoff spec for building the v2 design in SwiftUI. The source of truth for visuals is the Claude Design canvas **"ScreenDiet Onboarding"**:

- page **v2 · Kitchen states**: splash + 19 onboarding screens
- page **v2 · App screens**: Kitchen (5 states), Pantry, Journal, Settings, Focus Fast sheet, Extra serving sheet, shields
- page **v1 · Charcoal vs Warm**: earlier exploration, kept for comparison only

All numbers, prices and report values on the canvas are samples.

---

## 1. Core idea: the theme follows the kitchen

The app has no fixed light/dark look. The background tells the user the kitchen's state at a glance.

| Kitchen state | Theme | Where it's used |
|---|---|---|
| Closed / evening / premium | **Lamp** (warm charcoal + overhead lamp glow) | Splash, Welcome, Story, Membership, Journal, Kitchen *closed*, Kitchen *Focus Fast*, Focus Fast sheet |
| Open / building your diet | **Daylight** (warm cream + sun glow) | Onboarding 03–14, 16–17, 19; Kitchen *open* and *portion served*; Pantry; Settings; Extra serving sheet |
| Night Fast | **Night** (deep indigo + moonlight) | Onboarding 15, Kitchen *Night Fast*, Night Fast shield |

The Kitchen screen should switch theme from `DietRules` state (precedence `fastNow > nightFast > portionHit > kitchenClosed > open`). Animate theme changes with a 0.6 s cross-fade.

---

## 2. Colour tokens

### Brand accent: Lamp
Lamp is the only brand colour. Use it for: the logo dot, the progress bar, primary buttons on dark themes, selected/suggested badges, focus rings. It is not a food-group colour.

### Food groups (meaning, never decoration)

| Group | Role | Lamp / Night themes | Daylight theme | Soft fill |
|---|---|---|---|---|
| Carbs · *Consume* | portion-limited | `#F4929F` frosting pink | `#B83E5E` | group colour at 10–14 % |
| Fats · *Connect* | rests during fasts | `#B6D07E` avocado | `#4F7A22` | 11–14 % |
| Protein · *Create* | always available | `#EBA75A` egg-yolk amber | `#995A12` | 11–15 % |

Carbs and Protein differ in lightness as well as hue so they stay distinguishable for colour-blind users.

### Theme tokens

| Token | Lamp | Daylight | Night |
|---|---|---|---|
| `bg` | `#15120F` | `#F5EFE4` | `#0F1226` |
| `surface` | `#221E1A` | `#FFFDF8` | `#1A1E38` |
| `surface2` | `#2D2823` | `#EDE5D6` | `#262B4A` |
| `line` | `#FFECD2` @ 8 % | `#3C2814` @ 9 % | `#DCE2FF` @ 8 % |
| `line2` | `#FFECD2` @ 15 % | `#3C2814` @ 16 % | `#DCE2FF` @ 15 % |
| `text` | `#F7F2E9` | `#1F1A14` | `#EEF0FA` |
| `muted` | `#B5AC9F` | `#5F564A` | `#ABB0CC` |
| `faint` | `#918778` | `#766B5E` | `#8A90B0` |
| `lamp` | `#F3D9A4` | `#B8862C` (darker, for contrast on cream) | `#F3D9A4` |
| `buttonBg` | `#F3D9A4` | `#1F1A14` | `#F3D9A4` |
| `buttonText` | `#1D1812` | `#F7F1E6` | `#151830` |
| `plate` / `plateInner` / `plateEdge` | `#EDE6D8` / `#F6F1E7` / `#BDB3A1` | `#FFFFFF` / `#FAF6EE` / `#E0D5C2` | — |

### Backgrounds (never flat)
Every screen background has three layers:
1. **Light source:** a radial glow at the top, like a pendant lamp.
   - Lamp: `#F3D9A4` @ 18 %, ellipse 110 % × 55 % centred above the screen.
   - Daylight: `#FFCE78` @ 38 % from the top-right ("sun through the window").
   - Night: `#96A0FF` @ 20 % from the top-left (moonlight), plus a few twinkling 2–3 pt stars.
2. **Backsplash:** a 48 pt square tile grid of 1 pt lines at 2.5–3 % opacity.
3. **Base colour** (`bg`).

---

## 3. Typography

| Use | Font | Size / weight | Tracking |
|---|---|---|---|
| Headlines (h1) | **Bricolage Grotesque** | 34–40 pt, ExtraBold (800), line height 1.02 | −1.2 |
| Second line of a headline | same, in `muted` (or `lamp` for emphasis on dark) | | |
| Big numbers (portion, hours, grade) | Bricolage Grotesque 800, tabular figures | 40–72 pt | −1.5 to −3 |
| Wordmark `screendiet.` | Bricolage Grotesque 800, 20 pt, dot in `lamp` | | −0.6 |
| Eyebrows | Manrope 700, 11 pt, uppercase | | +0.14 em |
| Body | Manrope 400–500, 14–15 pt, line height 1.5 | | |
| Buttons | Manrope 700, 16 pt | | |

Both fonts use the SIL Open Font License, so they can be bundled. Manrope is already in `screengate/Font`; add Bricolage Grotesque (variable, opsz 12–96, weights 600–800). Support Dynamic Type by scaling from these base sizes.

**Shields** can't use custom fonts; they use the system font (see §8).

---

## 4. Layout and components

- **Safe area:** content starts at 58 pt from the top; leave the status bar alone.
- **Side margins:** 20 pt for cards, 24 pt for text.
- **Radii:** screen cards 28–32, list cards 20–24, chips 16–22, primary button 28 (pill), app tiles 28 % of size.
- **Header (onboarding):** 44 pt round back button (surface + 1 pt `line` ring), centred wordmark, chapter label at the right (uppercase, `faint`).
- **Chapter progress:** 5 equal segments (Story · You · Plates · Recipe · Ready), 4 pt tall, 4 pt gaps, filled in `lamp`. The current segment fills to `step / stepsInChapter`.
- **Primary button:** 56 pt pill, `buttonBg`. On Lamp/Night it gets a soft lamp glow (`0 12 32` @ 22 %).
- **Choice card:** min 76 pt. Selected = `surface` + 2 pt `text` ring + soft shadow; the icon tile turns `lamp`; the check circle fills.
- **Plate:** white ceramic disc with inner well and bottom edge, ringed by a 10 pt soft halo in the group colour; app tiles 54 pt arranged on a circle (radius 56).
- **Tab bar:** Kitchen · Pantry · Journal · Settings. 84 pt with 16 pt blur over a 90 % `bg` tint and a 1 pt `line` top edge.
- **Touch targets:** at least 44 pt everywhere.

---

## 5. Artwork

Use the existing clay illustrations in `screengate/Assets.xcassets` (forest-green backgrounds; place them in rounded cards):

| Screen | Asset |
|---|---|
| Welcome, Kitchen *open*, extra-serving confirm shield | `DigitalGarden` |
| Ingredients, Kitchen *portion served*, portion shield | `BalancedPantry` |
| Make room for life, Kitchen *closed*, closed shield | `LifeReclaimed` |
| Perspective, Focus Fast sheet, Kitchen *Focus Fast*, focus shield | `FocusGarden` |
| Night Fast, Kitchen *Night Fast*, Night Fast shield | `NightGarden` |
| Ready to serve | `FreshStart` |

The splash, story (overflowing plate), Screen Time (phone → three bowls), plate builders, portion dial and kitchen-hours clock are drawn in code.

---

## 6. Motion (SwiftUI mapping)

Default spring: `.spring(response: 0.55, dampingFraction: 0.8)`. Under **Reduce Motion**, replace everything below with a 0.2 s opacity fade and drop looping animations.

| Moment | Spec | SwiftUI |
|---|---|---|
| Screen entrance | header → hero → headline → content → CTA rise 18 pt and fade in, staggered 0.1 s | `.transition(.move+.opacity)` with per-section `delay` |
| Progress bar | current segment grows from previous value | `.animation(.easeOut(duration: 1), value:)` |
| Hero artwork | settles from 1.12× scale, 30 % opacity | `.scaleEffect` + `.opacity` |
| Choice select | press to 0.97×, ring + fill cross-fade 0.25 s, check pops 0.3 → 1.15 → 1 | `.sensoryFeedback(.selection)` |
| Plate tiles | drop in from −80 pt with overshoot, 0.12 s stagger; on remove the rest slide to new positions | `matchedGeometryEffect` per app token |
| Portion dial | arc draws on appear; drag the ring, snaps to 5 min | `DragGesture` + `.sensoryFeedback(.increase)` per step |
| Kitchen-hours clock | dial spins in; drag either handle, snaps to 15 min | `DragGesture` |
| Perspective | "3½ hours" counts up in 0.5 h steps; bars grow from the bottom | `contentTransition(.numericText())` |
| Night Fast toggle | off = artwork desaturates and dims; on = "Closed · see you at 7" sign swings in | `PhaseAnimator` |
| Reminders | three notifications slide down one by one; bell rings | staggered `.transition` |
| Recipe card | prints top-down, lines appear at 0.12 s intervals, stamp thumps in at the end | `KeyframeAnimator` |
| Ready | sunrise on the artwork, check badge pops, confetti in group colours | `KeyframeAnimator`, Canvas particles |
| Splash | lamp flickers on, light cone appears, plate slides in, 3 tiles drop (Carbs, Fats, Protein), wordmark rises; ~2 s then "Tap to begin" | `PhaseAnimator` |
| Focus Fast | slide-to-confirm knob; snaps back unless dragged past 85 %; plain "Start without sliding" button for accessibility | `DragGesture` |
| Extra serving | press-and-hold fills the button in ~1 s; release resets; Enter/Space confirms instantly for VoiceOver | `onLongPressGesture(minimumDuration:)` |
| Kitchen status pill | dot pulses gently | `.symbolEffect(.pulse)` or a repeating scale |

---

## 7. Screen inventory

**Onboarding (19 steps + splash), chapter in brackets:**
00 Splash · 01 Welcome [Story] · 02 The kitchen story · 03 Meet your ingredients · 04 Your goal [You] · 05 Make room for life · 06 Your current rhythm · 07 Connect Screen Time · 08–10 Carbs / Fats / Protein plates [Plates] · 11 A little perspective [Recipe] · 12 Choose your plan · 13 Choose your portion · 14 Kitchen hours · 15 Night Fast · 16 Gentle reminders · 17 Your recipe [Ready] · 18 Membership · 19 Ready to serve.

Skippable steps (Perspective, Night Fast, Reminders) need a clear secondary action ("Not now" / "Skip for now").

**App:** Kitchen (open, closed, portion served, Night Fast, Focus Fast) · Pantry · Journal (Today / This week) · Settings · Focus Fast sheet · Extra serving sheet · 5 shields.

---

## 8. Shields (system UI limits)

`ShieldConfiguration` supports only: background colour/blur, one icon image, title, subtitle, primary button (label + background colour), optional secondary button. No custom layout, fonts or animation.

| Shield | Theme | Title | Primary | Secondary |
|---|---|---|---|---|
| Kitchen closed | Lamp | Kitchen's closed | Close app (Lamp) | Use an extra serving |
| Portion served | Daylight | Today's portion is served | Close app (ink) | Use an extra serving |
| Night Fast | Night | The kitchen is resting | Goodnight (Lamp) | — |
| Focus Fast | Lamp | Something good is cooking | Back to focus (Protein amber) | — |
| Extra serving, tap 2 of 2 | Daylight | Tap again to confirm | Yes, 15 minutes (Carbs) | Never mind |

Icons are the matching clay artwork cropped to a circle. Extra servings lift only the `carbs` store; Night Fast and Focus Fast shields therefore offer no extra serving.

---

## 9. Copy and naming changes

Display names only; code enums can stay as they are.

| Code | v2 label |
|---|---|
| `DietPlan.lean` | **Balanced** (free) |
| `DietPlan.keto` | **Maker** · Plus |
| `DietPlan.detox` | **Reset** · Plus |
| `DietPlan.custom` | **Custom** · Plus |
| cheat meal | **extra serving** |

Food groups use the verbs from `FoodGroup.subtitle`: Carbs = Consume, Fats = Connect, Protein = Create. Onboarding copy matches the code: Fats are unlimited and rest only during Night Fast / Focus Fast; Protein is never blocked.

Live numbers in the app are approximate and marked "≈"; exact numbers come from the report extension.

---

## 10. Open items

- Real prices and trial wording on Membership come from StoreKit (canvas shows `[YOUR PRICE]`).
- Renewal date in Settings (`[DATE]`).
- "Weekly summary" toggle in Settings is a proposal, not an existing feature.
- App icons on the canvas are stand-in glyphs; on device use Apple's `Label(token)` from Family Controls.
- Shared-element transitions between screens (e.g. the plate carrying from step 10 to 11) can't be shown on the canvas; build with `matchedGeometryEffect`.
