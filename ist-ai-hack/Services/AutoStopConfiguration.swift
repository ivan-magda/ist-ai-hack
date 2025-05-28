import Foundation

struct AutoStopConfiguration: Codable {
    let enabled: Bool
    let threshold: TimeInterval
    let adaptiveTimeout: Bool
    let maxRecordingDuration: TimeInterval

    static let `default` = AutoStopConfiguration(
        enabled: true,
        threshold: 3.0,
        adaptiveTimeout: true,
        maxRecordingDuration: 60.0
    )

    static let quickMode = AutoStopConfiguration(
        enabled: true,
        threshold: 1.5,
        adaptiveTimeout: false,
        maxRecordingDuration: 30.0
    )

    static let learningMode = AutoStopConfiguration(
        enabled: true,
        threshold: 5.0,
        adaptiveTimeout: true,
        maxRecordingDuration: 120.0
    )

    func getAdaptiveThreshold(for textLength: Int, language: String) -> TimeInterval {
        guard adaptiveTimeout else { return threshold }

        // Adjust timeout based on context
        var adaptiveThreshold = threshold

        // Longer timeout for longer sentences in progress
        if textLength > 20 {
            adaptiveThreshold += 1.0
        }

        // Language-specific adjustments
        switch language.prefix(2) {
        case "zh", "ja", "ko": // Asian languages may need more processing time
            adaptiveThreshold += 0.5
        case "de", "fi", "hu": // Languages with complex word formation
            adaptiveThreshold += 0.3
        default:
            break
        }

        return min(adaptiveThreshold, maxRecordingDuration)
    }
}

@Observable
class AutoStopConfigurationManager {
    static let shared = AutoStopConfigurationManager()

    var currentConfiguration: AutoStopConfiguration {
        didSet {
            saveConfiguration()
        }
    }

    var isLearningMode: Bool {
        didSet {
            updateConfigurationForMode()
        }
    }

    private let userDefaults = UserDefaults.standard

    private init() {
        self.currentConfiguration = Self.loadConfiguration()
        self.isLearningMode = userDefaults.bool(forKey: "autoStopLearningMode")
    }

    private static func loadConfiguration() -> AutoStopConfiguration {
        guard let data = UserDefaults.standard.data(forKey: "autoStopConfiguration"),
              let config = try? JSONDecoder().decode(AutoStopConfiguration.self, from: data) else {
            return .default
        }
        return config
    }

    private func saveConfiguration() {
        if let data = try? JSONEncoder().encode(currentConfiguration) {
            userDefaults.set(data, forKey: "autoStopConfiguration")
        }
    }

    private func updateConfigurationForMode() {
        userDefaults.set(isLearningMode, forKey: "autoStopLearningMode")

        if isLearningMode {
            currentConfiguration = .learningMode
        } else {
            currentConfiguration = .default
        }
    }

    func setQuickMode() {
        currentConfiguration = .quickMode
        isLearningMode = false
    }

    func setCustomConfiguration(enabled: Bool, threshold: TimeInterval, adaptive: Bool, maxDuration: TimeInterval) {
        currentConfiguration = AutoStopConfiguration(
            enabled: enabled,
            threshold: max(0.5, min(10.0, threshold)),
            adaptiveTimeout: adaptive,
            maxRecordingDuration: max(10.0, min(300.0, maxDuration))
        )
    }

    func getEffectiveThreshold(for text: String, language: String) -> TimeInterval {
        currentConfiguration.getAdaptiveThreshold(for: text.count, language: language)
    }
}
