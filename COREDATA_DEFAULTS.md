# Core Data Default Values Reference

## DailyStat Entity
- **appBlockedCount** (Integer 32): `0`
- **appInterventionCount** (Integer 32): `0`
- **breakCount** (Integer 32): `0`
- **date** (Date): `2025-01-01T00:00:00Z`
- **dayOfWeek** (String): `monday`
- **delayInterventionCount** (Integer 32): `0`
- **emergencyBypassCount** (Integer 32): `0`
- **energyLevel** (Integer 32, Optional): none needed
- **eveningMood** (String, Optional): none needed
- **focusGoalAchieved** (Boolean): `NO`
- **focusGoalMetMinutes** (Integer 32): `0`
- **focusGoalMetSeconds** (Integer 64): `0`
- **hardBlockCount** (Integer 32): `0`
- **id** (UUID): `00000000-0000-0000-0000-000000000000`
- **interventionSuccessRate** (Double): `0.0`
- **morningMood** (String, Optional): none needed
- **notes** (String, Optional): none needed
- **sessionCompletionRate** (Double): `0.0`
- **topDistractionAppBundle** (String, Optional): none needed
- **topDistractionAppName** (String, Optional): none needed
- **topDistractionCount** (Integer 32): `0`
- **totalFocusTimeSeconds** (Integer 64): `0`
- **totalSessionsCompleted** (Integer 32): `0`
- **totalSessionsScheduled** (Integer 32): `0`

## FocusSession Entity
- **abandonedAt** (Date, Optional): none needed
- **actualDurationSeconds** (Integer 64): `0`
- **allowManualBreaks** (Boolean): `YES`
- **breakCount** (Integer 32): `0`
- **completionPercentage** (Double): `0.0`
- **desc** (String, Optional): none needed
- **endTime** (Date, Optional): none needed
- **id** (UUID): `00000000-0000-0000-0000-000000000000`
- **isRecurring** (Boolean): `NO`
- **name** (String): `` (empty string)
- **recurringDays** (String, Optional): none needed
- **scheduledDurationMinutes** (Integer 32): `60`
- **startTime** (Date): `2025-01-01T00:00:00Z`
- **status** (String): `scheduled`
- **totalBreakTimeSeconds** (Integer 64): `0`
- **wasSuccessful** (Boolean): `NO`

## InterventionLog Entity
- **appBundleID** (String): `` (empty string)
- **appName** (String): `` (empty string)
- **askWasApproved** (Boolean): `NO`
- **blockReason** (String, Optional): none needed
- **blockWasOverridden** (Boolean): `NO`
- **breathingExerciseCompleted** (Boolean): `NO`
- **breathingPeakTimeSeconds** (Integer 32, Optional): none needed
- **breakDurationMinutes** (Integer 32): `0`
- **breakWasGranted** (Boolean): `NO`
- **dailyStatID** (UUID, Optional): none needed
- **delayDurationSeconds** (Integer 32): `10`
- **id** (UUID): `00000000-0000-0000-0000-000000000000`
- **overrideMethod** (String, Optional): none needed
- **sessionID** (UUID, Optional): none needed
- **sessionName** (String, Optional): none needed
- **timestamp** (Date): `2025-01-01T00:00:00Z`
- **type** (String): `` (empty string)
- **userContinuedAfterDelay** (Boolean): `NO`

## Milestone Entity
- **celebratedByUser** (Boolean): `NO`
- **currentValue** (Integer 32): `0`
- **desc** (String): `` (empty string) [Note: named 'description' in Swift, 'desc' in Core Data]
- **icon** (String): `` (empty string)
- **id** (UUID): `00000000-0000-0000-0000-000000000000`
- **lastActivityDate** (Date, Optional): none needed
- **maxStreakCount** (Integer 32): `0`
- **notificationSent** (Boolean): `NO`
- **progress** (Integer 32): `0`
- **streakCount** (Integer 32): `0`
- **targetValue** (Integer 32): `1`
- **title** (String): `` (empty string)
- **type** (String): `` (empty string)
- **unlockedAt** (Date, Optional): none needed

## ProtectedApp Entity
- **addedAt** (Date): `2025-01-01T00:00:00Z`
- **allowBreakDuring** (Boolean): `YES`
- **appIconData** (Binary, Optional): none needed
- **blockedCount** (Integer 64): `0`
- **blockingMode** (String): `delay`
- **bundleIdentifier** (String): `` (empty string)
- **category** (String): `` (empty string)
- **customNotes** (String, Optional): none needed
- **delayDurationSeconds** (Integer 32): `10`
- **displayName** (String): `` (empty string)
- **id** (UUID): `00000000-0000-0000-0000-000000000000`
- **isEnabled** (Boolean): `YES`
- **lastBlockedAt** (Date, Optional): none needed
- **totalTimeBlockedSeconds** (Integer 64): `0`

## User Entity
- **allowBreaksDuringSession** (Boolean): `YES`
- **allowEmergencyBypass** (Boolean): `NO`
- **analyticsEnabled** (Boolean): `YES`
- **createdAt** (Date): `2025-01-01T00:00:00Z`
- **dailyGoalMinutes** (Integer 32): `120`
- **displayName** (String, Optional): none needed
- **email** (String, Optional): none needed
- **emergencyBypassCode** (String, Optional): none needed
- **id** (UUID): `00000000-0000-0000-0000-000000000000`
- **lastActiveAt** (Date): `2025-01-01T00:00:00Z`
- **notificationsEnabled** (Boolean): `YES`
- **preferredBreakDurationMinutes** (Integer 32): `15`
- **subscriptionEndDate** (Date, Optional): none needed
- **subscriptionStartDate** (Date, Optional): none needed
- **subscriptionStatus** (String): `free`
- **trialEndDate** (Date, Optional): none needed
- **trialStartDate** (Date, Optional): none needed

## Notes
- All attributes marked "(Optional)" have `optional="YES"` and do NOT need default values
- All other attributes must have a `defaultValue` attribute in Core Data
- For Date attributes, use ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`
- For Boolean attributes, use `YES` or `NO`
- For String attributes, use empty string `""` or appropriate default text
- For numeric attributes, use appropriate numeric defaults (e.g., `0`, `1`, `-1`)
- For UUID attributes, use `00000000-0000-0000-0000-000000000000`

## Scalar vs Non-Scalar Types

**Scalar Value Types** (use `usesScalarValueType="YES"`):
- Integer 16, Integer 32, Integer 64
- Double, Float
- Boolean
- Decimal

**Non-Scalar Value Types** (use `usesScalarValueType="NO"` or omit):
- String
- Date
- UUID
- Binary
- Transformable

### Scalar Attributes in Your Model
appBlockedCount, appInterventionCount, breakCount, focusGoalAchieved, focusGoalMetMinutes, focusGoalMetSeconds, hardBlockCount, interventionSuccessRate, sessionCompletionRate, topDistractionCount, totalFocusTimeSeconds, totalSessionsCompleted, totalSessionsScheduled, actualDurationSeconds, allowManualBreaks, completionPercentage, isRecurring, scheduledDurationMinutes, totalBreakTimeSeconds, wasSuccessful, askWasApproved, blockWasOverridden, breathingExerciseCompleted, breakDurationMinutes, breakWasGranted, delayDurationSeconds, userContinuedAfterDelay, celebratedByUser, currentValue, maxStreakCount, notificationSent, progress, streakCount, targetValue, blockedCount, isEnabled, totalTimeBlockedSeconds, allowBreaksDuringSession, allowEmergencyBypass, analyticsEnabled, dailyGoalMinutes, notificationsEnabled, preferredBreakDurationMinutes

### Non-Scalar Attributes in Your Model
date, dayOfWeek, energyLevel, eveningMood, morningMood, notes, topDistractionAppBundle, topDistractionAppName, id, desc, endTime, name, recurringDays, startTime, appBundleID, appName, blockReason, overrideMethod, sessionID, sessionName, timestamp, type, icon, description, unlockedAt, addedAt, appIconData, bundleIdentifier, category, customNotes, displayName, lastBlockedAt, email, emergencyBypassCode, createdAt, lastActiveAt, subscriptionEndDate, subscriptionStartDate, subscriptionStatus, trialEndDate, trialStartDate, blockingMode
