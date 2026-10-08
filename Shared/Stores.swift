import ManagedSettings

// MARK: - Named ManagedSettings stores

/// One store per rule so that blocks stack instead of overwriting each other.
///
/// - `carbs`: the carbs selection, blocked outside the window / after the portion.
/// - `night`: carbs + fats during Night Fast.
/// - `fast`: carbs + fats during Fast Now.
/// - `strict`: strict-mode system settings (premium, Phase 9).
extension ManagedSettingsStore.Name {
    static let carbs = ManagedSettingsStore.Name("diet.carbs")
    static let night = ManagedSettingsStore.Name("diet.night")
    static let fast = ManagedSettingsStore.Name("diet.fast")
    static let strict = ManagedSettingsStore.Name("diet.strict")

    /// The single pre-v1 store, kept only so it can be cleaned up after migration.
    static let legacy = ManagedSettingsStore.Name("com.gia.screendiet")
}
