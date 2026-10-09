# ScreenDiet complete visual redesign

Forest green, warm cream, sage and apricot; editorial story headings, Manrope interface text, illustrated cards and consistent controls across the app.

## Completed scope

- 19-page onboarding: three illustrated story chapters, goals and intention, habits, personalized preview, Screen Time authorization, app selection, insight, plan choice, eating-window dial, notification preprompt, plan review, contextual membership, activation and first-day guide.
- Kitchen: state-specific artwork, portion ring, schedule, approximate live servings, measured report host, streak, cheats and focus actions. Dedicated Focus Fast and Cheat Meal sheets include active, unavailable and error states.
- Pantry, Settings, diet adjustments, strict mode, notification preferences and report guide have matching layouts and illustrations.
- Membership: personalized headline, annual/monthly/lifetime options from StoreKit, eligible trial details, real localized prices, restore, pending purchase, retry and free continuation.
- Reports: measured activity donut, food-group breakdown, seven-day bars, nighttime usage, pickups, top apps and animated grade reveal. Whole-device activity is classified inside the report extension; exact data remains there.
- Widgets, Live Activity and blocking shields use the matching palette and artwork. Shields remain static system surfaces.
- Motion: page entrances, chapter transitions, selection feedback, tactile controls, gentle artwork movement, rings and celebrations. Decorative animations respect Reduce Motion. Accessibility text sizes use regular confirmation buttons in place of cramped gesture controls.

## Generated artwork

All six illustrations were generated with the built-in image generator and inspected for a consistent matte clay style. Main assets live in `screengate/Assets.xcassets`; smaller derivatives are bundled into widgets and shields.

| Asset | Scene |
|---|---|
| DigitalGarden | Phone on a plate, avocado, donut and leaves |
| LifeReclaimed | Reading nook, book, coffee and face-down phone |
| BalancedPantry | Three bowls representing digital food groups |
| NightGarden | Sleeping phone, crescent, clouds and stars |
| FocusGarden | Phone, hourglass, plant and pencil |
| FreshStart | Growing sprout and warm rays |

The five additional generation prompts are recorded in [artwork-prompts.json](artwork-prompts.json).

Original DigitalGarden prompt: “Use case: illustration-story. Asset type: iOS ScreenDiet digital wellness app hero illustration. Create a premium tactile clay illustration of a small sage-green smartphone resting in a cream ceramic dinner plate, surrounded by a tiny avocado half, a pink donut, leafy sprigs and warm apricot stars. Metaphor: a balanced digital diet. Sculptural soft rounded forms, handcrafted matte ceramic texture, elegant editorial composition, soft studio shadows, dark forest-green background, centered scene with generous breathing room, no text, no logos. Square image.”

## Review previews

- [Onboarding overview](onboarding-overview.jpg)
- [Feature overview](features-overview.jpg)
- [Kitchen states](kitchen-overview.jpg) — labeled synthetic preview states, never saved as user data.

Debug-only launch routes in `DesignReviewView.swift` permit repeatable simulator inspection without activating restrictions or persisting sample profiles. Reviewed on iPhone 17 Pro and smaller iPhone 16e, including large text. Some onboarding content intentionally scrolls.

## Validation and practical limits

Debug and Release simulator builds passed for the full redesign. The final accessibility-button adjustment was rebuilt in Debug and visually checked on the smaller simulator; a repeated Release build was stopped while rebuilding the unchanged Superwall dependency. All 33 unit tests pass, including backward-compatible onboarding answer decoding and next-window duration calculations. `git diff --check` passes.

Simulator verification covers layout and compilation. Real authorization, blocking, shields, schedules, widgets and exact Screen Time report data require physical-device checks. Live purchase verification requires configured App Store products and a StoreKit/sandbox account. No purchase or physical enforcement success is claimed. An app-specific published privacy policy remains a release prerequisite.
