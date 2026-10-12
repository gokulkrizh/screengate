# ScreenDiet — digital kitchen HTML prototype

An interactive design review before changing the SwiftUI app. All implementation lives in this directory; no iOS files were changed for this concept.

## Open

Open `index.html` directly in a browser, or serve this directory:

```sh
python3 -m http.server 8765 --directory design/kitchen-prototype
```

Then open http://localhost:8765. No installation, package manager, remote asset or API is required. The prototype uses locally bundled Manrope fonts, custom SVG kitchen illustrations and CSS ceramic plates.

## Review

- 19-page story: welcome → digital food groups → personal goals → Screen Time explanation → three app plates → possible time return → recipe → portions → kitchen hours → night fast → reminders → personal review → membership → activation.
- Kitchen: open, closed, night, focus and portion-used previews; ring, streak, extra servings and actions.
- Pantry: three food-group plates; edit and save selection.
- Journal: sample grade, weekly bars, group breakdown, nighttime activity, pickups and top apps. Loading, empty and retry states are available.
- Focus Fast: duration choices and slide-to-confirm; keyboard-friendly tap alternative.
- Cheat meal: hold-to-confirm, no-servings and active-fast states; Enter/Space uses an explicit confirmation.
- Settings: portion, hours, plan, reminders, night fast and membership.

Use the screen navigator on desktop, or swipe its horizontal list on small screens. App trays also swipe horizontally. Adding an app moves it out of its previous group, so one app cannot occupy two plates. Large selections expand into inner and outer rings. Pantry edits return to the Pantry; settings edits return to Settings. Sample recipe state lasts while this page is open and resets on reload.

## Distinct story illustrations

Welcome uses the inviting kitchen counter. The kitchen story shows an overflowing app plate and always-open clock. Make room for life shows a cleared table with a book, cup, pencil and face-down phone. Connect Screen Time shows a secure phone linking app ingredients to three food-group bowls. Each has its own composition and appropriate motion. Night Fast uses a closing shutter and moon; reminders use a service bell and notification; activation lifts a cloche over the completed app meal; Focus Fast uses an hourglass and protected ingredients; extra servings use a side plate and a fifteen-minute ticket.

## Ingredient guidance

The introduction reveals Carbs, Fats and Protein one at a time. Each has a large app plate with a concise explanation overlay. Next moves the plate, app icons and title into a compact recap list using shared-element View Transitions, while the next group becomes the hero. After Protein, all three appear in a final list. Back reverses the sequence. Browsers without View Transitions and Reduce Motion use a direct update.

## Motion

App icons spring onto plates, remaining tokens rearrange, removals shrink away, recipe cards reveal, chart bars grow, rings draw, selected choices respond and activation celebrates. The kitchen lamp sways gently and the cup gives off steam. Motion can be paused from the review controls, including mobile. OS Reduce Motion uses static transitions automatically.

## Limits

App icons are stylized SVG representations for review, not extracted Apple app tokens. Selection happens immediately in this HTML tray; iPhone will use Apple’s system picker and animate the plate after it closes. All prices, report values, streaks and usage are explicit samples. No permissions, blocking, payments or account changes occur. The sample clock is fixed at 9:41am.

## Verification

JavaScript syntax check passed. All 25 routes were opened in the browser with no console errors. App addition/removal, Pantry editing return, focus confirmation, report empty/error/retry, pause-motion navigation and 390×844 and 375×667 mobile layouts were checked, including no horizontal page overflow and fully visible footer controls. Crowded plates were checked with all 12 sample apps. Saved screenshots are in `previews/`.
