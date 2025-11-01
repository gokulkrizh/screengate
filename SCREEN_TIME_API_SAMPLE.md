**A Developer’s Guide to Apple’s Screen Time APIs (FamilyControls, ManagedSettings, DeviceActivity)**
=====================================================================================================

[![Juliusbrussee](https://miro.medium.com/v2/resize:fill:64:64/1*dmbNkD5D-u45r44go_cf0g.png)](https://medium.com/@juliusbrussee?source=post_page---byline--e660147367d7---------------------------------------)

[Juliusbrussee](https://medium.com/@juliusbrussee?source=post_page---byline--e660147367d7---------------------------------------)

7 min read

·

Apr 23, 2025

[nameless link](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fvote%2Fp%2Fe660147367d7&operation=register&redirect=https%3A%2F%2Fmedium.com%2F%40juliusbrussee%2Fa-developers-guide-to-apple-s-screen-time-apis-familycontrols-managedsettings-deviceactivity-e660147367d7&user=Juliusbrussee&userId=51c88374491d&source=---header_actions--e660147367d7---------------------clap_footer------------------)

--

4

[nameless link](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fbookmark%2Fp%2Fe660147367d7&operation=register&redirect=https%3A%2F%2Fmedium.com%2F%40juliusbrussee%2Fa-developers-guide-to-apple-s-screen-time-apis-familycontrols-managedsettings-deviceactivity-e660147367d7&source=---header_actions--e660147367d7---------------------bookmark_footer------------------)

Listen

Share

If you’re interested in building an app to help users avoid distractions, limit social media, or create custom focus sessions, this guide is for you. We’ll explore the main frameworks: FamilyControls, ManagedSettings, and DeviceActivity. You’ll learn the basics, the setup process (including permissions), and practical implementation tips drawn from a real-world app.

**Target Audience:** iOS developers looking to integrate Screen Time functionalities into their applications.

The Screen Time API Trio: How They Work Together
------------------------------------------------

Apple’s solution for managing device usage involves three main frameworks that collaborate:

**1. FamilyControls:** This is your gateway to understanding _what_ the user wants to manage. It provides:

**Authorization:** The mechanism to request permission from the user to manage their app and web activity. This is a critical first step.

*   **Selection:** UI components (FamilyActivityPicker) that allow users to easily select specific applications, categories of applications (like “Social Media” or “Games”), and websites they want to include in a restriction policy. The result of this selection is stored in a FamilyActivitySelection object

**2. ManagedSettings:** This framework is the enforcer. Once you know _what_ the user wants to restrict (thanks to FamilyControls), ManagedSettings lets you define the actual rules. You use a ManagedSettingsStore to:

*   **Shield Apps & Websites:** Prevent selected apps from being launched or shield specific web domains in Safari.
*   **Set App Time Limits:** (Though not shown in our primary example code, ManagedSettings also enables setting time limits).

**3. DeviceActivity:** This framework determines _when_ the rules defined in ManagedSettings should be active. It allows you to:

*   **Schedule Restrictions:** Define specific time intervals (e.g., 9 AM to 5 PM on weekdays) during which the restrictions are enforced.
*   **Monitor Activity:** Trigger events based on device usage patterns (though our focus here is primarily on activating/deactivating the ManagedSettings rules on a schedule).

Think of it like this:

FamilyControls asks the user for permission and _what_ to block. ManagedSettings sets up the _actual block_. DeviceActivity controls _when_ that block is turned on and off.

Step 0: Getting Permission — The Entitlement and Authorization Flow
-------------------------------------------------------------------

Before you write a single line of code using these APIs, you need special permission from Apple. Because these APIs deal with sensitive user activity and device control, they require an entitlement.

1.  **Request the Entitlement:** You must apply for the com.apple.developer.family-controls entitlement through Apple’s developer portal. Provide a clear explanation of why your app needs this capability. Without this entitlement granted to your App ID and provisioning profile, the APIs simply won’t work. Some tips as well are apply for this entitlement for every app target that needs it not just your main one.
2.  **Request User Authorization:** Once your app has the entitlement, you _still_ need explicit permission from the user at runtime. This is done using FamilyControls.AuthorizationCenter.

```
import FamilyControls
import SwiftUI // Or UIKit
``````
class AuthorizationManager: ObservableObject {
    @Published var authorizationStatus: FamilyControls.AuthorizationStatus = .notDetermined
    init() {
        // Check initial status if needed when the app starts
        Task {
            await checkAuthorization()
        }
    }
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual) // Use .individual for non-Family Sharing apps
            self.authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        } catch {
            // Handle errors appropriately (e.g., logging, showing an alert)
            print("Failed to request authorization: \(error)")
            self.authorizationStatus = .denied // Or handle specific errors
        }
    }
    func checkAuthorization() async {
         self.authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }
}
// Example Usage in a SwiftUI View
struct ContentView: View {
    @StateObject var authManager = AuthorizationManager()
    var body: some View {
        VStack {
            Text("Authorization Status: \(String(describing: authManager.authorizationStatus))")
            if authManager.authorizationStatus == .notDetermined {
                Button("Request Authorization") {
                    Task {
                        await authManager.requestAuthorization()
                    }
                }
            } else if authManager.authorizationStatus == .approved {
                Text("Authorization Granted!")
                // Proceed with FamilyControls features...
            } else {
                Text("Authorization Denied or Restricted. Please enable in Settings.")
                // Guide user to Settings if needed
            }
        }
        .padding()
    }
}
```

**Always check the authorizationStatus before attempting to use FamilyControls or ManagedSettings.**

Step 1: Selecting Activities with FamilyControls
------------------------------------------------

Once authorized, you need to let the user choose what they want to restrict. This is where FamilyActivityPicker comes in. It’s a SwiftUI view modifier (or a UIViewController in UIKit) that presents a system interface for selection.

```
import SwiftUI
import FamilyControls
``````
struct ProfileEditorView: View {
    // State to store the user's selection
    @State private var activitySelection = FamilyActivitySelection()
    // State to control the presentation of the picker
    @State private var isPickerPresented = false
    var body: some View {
        VStack {
            Text("Selected \(activitySelection.applicationTokens.count) apps, \(activitySelection.categoryTokens.count) categories, \(activitySelection.webDomainTokens.count) websites")
            Button("Select Apps & Websites") {
                isPickerPresented = true
            }
        }
        // The magic modifier!
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $activitySelection
        )
        .onChange(of: activitySelection) { newSelection in
            // Handle the updated selection - maybe save it?
            print("Selection Updated!")
            // In a real app, you'd likely save 'newSelection'
            // to your data model (like the 'BlockedProfiles' model).
            saveSelection(newSelection)
        }
    }
    func saveSelection(_ selection: FamilyActivitySelection) {
        // Placeholder: Implement saving logic here
        // e.g., update your SwiftData model:
        // try? BlockedProfiles.updateProfile(profile, in: context, selection: selection)
        print("Saving selection...")
    }
}
```

The FamilyActivitySelection object you get back is crucial. It contains opaque Token objects representing the user’s choices. You don’t interact with the tokens directly, but you store the FamilyActivitySelection itself (it’s Codable, making it easy to save using SwiftData, UserDefaults, Core Data, etc.).

In our example codebase, the BlockedProfiles model stores this directly:

```
// From BlockedProfiles.swift
@Model
class BlockedProfiles {
    // ... other properties
    var selectedActivity: FamilyActivitySelection // Stores the result from the picker
    // ...
}IGNORE_WHEN_COPYING_END
```

Step 2: Enforcing Rules with ManagedSettings
--------------------------------------------

Now that you have the FamilyActivitySelection, you can tell ManagedSettings to enforce the block.

```
import ManagedSettings
import FamilyControls
``````
class AppBlockerUtil { // Simplified from the provided code
    let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("yourAppRestrictionsName")) // Use a unique name
    func applyRestrictions(selection: FamilyActivitySelection) {
        print("Applying restrictions...")
        // Extract tokens from the selection
        let applicationTokens = selection.applicationTokens
        let categoryTokens = selection.categoryTokens
        let webTokens = selection.webDomainTokens
        // Apply tokens to the shield configuration
        store.shield.applications = applicationTokens.isEmpty ? nil : applicationTokens
        store.shield.applicationCategories = categoryTokens.isEmpty ? nil : .specific(categoryTokens)
        store.shield.webDomains = webTokens.isEmpty ? nil : webTokens
        print("Restrictions applied to ManagedSettingsStore.")
        // NOTE: This only defines the rules. DeviceActivity makes them active.
    }
    func removeRestrictions() {
        print("Removing restrictions...")
        // Clear the shield configuration
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        print("Restrictions removed from ManagedSettingsStore.")
        // NOTE: Also need to stop DeviceActivity monitoring.
    }
}
```

Key points:

*   Create a ManagedSettingsStore with a unique name.
*   Access the .shield property of the store.
*   Assign the applicationTokens, categoryTokens, and webDomainTokens from your saved FamilyActivitySelection to the corresponding properties on the shield.
*   To _remove_ restrictions, set these properties back to nil.

Step 3: Scheduling with DeviceActivity
--------------------------------------

Defining rules in ManagedSettings doesn’t automatically activate them. You need DeviceActivity to tell the system _when_ to pay attention to the ManagedSettingsStore.

```
import DeviceActivity
import ManagedSettings // Needed for store access if integrating tightly
``````
class AppBlockerUtil { // Continuing the simplified class
    let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("yourAppRestrictionsName"))
    let center = DeviceActivityCenter()
    // Define a unique name for your activity
    static let activityName = DeviceActivityName("com.yourdomain.yourapp.blockerActivity")
    // ... (applyRestrictions, removeRestrictions from above) ...
    func startMonitoringSchedule() {
        // Define a schedule. This example is 24/7, repeating daily.
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true,
            warningTime: nil // No warning needed for simple blocking
        )
        print("Starting DeviceActivity monitoring for schedule...")
        do {
            // Start monitoring. This tells the system to check the 'store'
            // associated with this activity during the 'schedule'.
            try center.startMonitoring(Self.activityName, during: schedule)
            print("Monitoring started successfully.")
        } catch {
            print("Error starting DeviceActivity monitoring: \(error)")
        }
    }
    func stopMonitoring() {
        print("Stopping DeviceActivity monitoring...")
        // Stop monitoring for all activities or specify names
        center.stopMonitoring([Self.activityName])
        print("Monitoring stopped.")
    }
    // Combined Activation Logic (Similar to provided code)
    func activateRestrictions(selection: FamilyActivitySelection) {
        applyRestrictions(selection: selection) // Step 2: Define rules
        startMonitoringSchedule()             // Step 3: Activate schedule
    }
    // Combined Deactivation Logic
    func deactivateRestrictions() {
        removeRestrictions() // Step 2: Clear rules
        stopMonitoring()     // Step 3: Deactivate schedule
    }
}
```

When you call startMonitoring with a specific DeviceActivityName, the system looks for a ManagedSettingsStore associated with that _same name_ (implicitly or explicitly defined via extensions) and enforces its rules during the specified DeviceActivitySchedule.

Putting it Together: Profiles, Sessions, and Strategies
-------------------------------------------------------

The Screen Time APIs provide the _mechanism_ for blocking, but a real app needs structure. The provided example code demonstrates excellent practices:

1.  **BlockedProfiles Model:** Uses SwiftData to store user-defined blocking configurations, including the FamilyActivitySelection and potentially other settings (like a name, or _how_ it should be activated).
2.  **BlockedProfileSession Model:** Tracks individual blocking periods (start time, end time) linked to a specific profile. This is great for history and analytics.
3.  **BlockingStrategy Protocol:** A clever use of the Strategy pattern. It defines a contract for _how_ blocking can be started and stopped (e.g., ManualBlockingStrategy, ScheduledBlockingStrategy think of many more in the future). This decouples the UI/trigger logic from the core blocking mechanism (AppBlockerUtil).

This structure allows for:

*   Saving multiple blocking configurations.
*   Adding different ways to trigger blocking without rewriting the core API interactions.
*   Tracking usage history effectively.

Conclusion
----------

Apple’s Screen Time APIs are powerful. You can block apps, schedule restrictions, and give users real control over their digital habits. The pieces fit together well once you understand them.

But getting there? That’s a different story.

Apple’s documentation barely exists. Using these APIs feels like solving a puzzle with half the pieces missing and no picture on the box. You’ll spend more time digging through random threads and experimenting than actually building.

That’s why clean architecture matters. Use clear models, keep your logic flexible, and give users a great experience even if the APIs don’t.

You can absolutely build something great here. Just don’t expect Apple to tell you how.