import SwiftUI

struct AutoStopSettingsView: View {
    @State private var configManager = AutoStopConfigurationManager.shared
    @State private var speechService: SpeechService

    init(speechService: SpeechService) {
        self.speechService = speechService
    }

    var body: some View {
        List {
            Section("Auto-Stop Recording") {
                Toggle("Enable Auto-Stop", isOn: $speechService.autoStopEnabled)
                    .onChange(of: speechService.autoStopEnabled) { _, enabled in
                        speechService.setAutoStopEnabled(enabled)
                    }

                if speechService.autoStopEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Silence Timeout")
                            Spacer()
                            Text("\(speechService.autoStopThreshold, specifier: "%.1f")s")
                                .foregroundColor(.secondary)
                        }

                        Slider(
                            value: $speechService.autoStopThreshold,
                            in: 0.5...10.0,
                            step: 0.5
                        ) {
                            Text("Timeout")
                        }
                        .onChange(of: speechService.autoStopThreshold) { _, threshold in
                            speechService.setAutoStopThreshold(threshold)
                        }

                        Text("Recording will stop automatically after this duration of silence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("Quick Presets") {
                Button("Quick Mode (1.5s)") {
                    configManager.setQuickMode()
                    applyConfiguration()
                }

                Button("Normal Mode (3.0s)") {
                    configManager.currentConfiguration = .default
                    applyConfiguration()
                }

                Button("Learning Mode (5.0s)") {
                    configManager.isLearningMode = true
                    applyConfiguration()
                }
            }

            Section("Advanced") {
                Toggle("Learning Mode", isOn: $configManager.isLearningMode)
                    .onChange(of: configManager.isLearningMode) { _, _ in
                        applyConfiguration()
                    }

                HStack {
                    Text("Max Recording Duration")
                    Spacer()
                    Text("\(Int(configManager.currentConfiguration.maxRecordingDuration))s")
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Adaptive Timeout")
                    Text("Automatically adjusts timeout based on sentence length and language")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if configManager.currentConfiguration.adaptiveTimeout {
                    Text("✓ Enabled")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Text("Disabled")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            Section("How It Works") {
                VStack(alignment: .leading, spacing: 12) {
                    FeatureExplanation(
                        icon: "timer",
                        title: "Silence Detection",
                        description: "Recording stops when no new speech is detected for the set duration"
                    )

                    FeatureExplanation(
                        icon: "waveform.path",
                        title: "Smart Activity Monitoring",
                        description: "Timer resets whenever meaningful changes are detected in transcription"
                    )

                    FeatureExplanation(
                        icon: "clock.badge.exclamationmark",
                        title: "Visual Countdown",
                        description: "Red progress ring appears during the final second before auto-stop"
                    )

                    FeatureExplanation(
                        icon: "gear",
                        title: "Manual Override",
                        description: "Tap the microphone button anytime to stop recording manually"
                    )
                }
            }
        }
        .navigationTitle("Auto-Stop Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func applyConfiguration() {
        let config = configManager.currentConfiguration
        speechService.setAutoStopEnabled(config.enabled)
        speechService.setAutoStopThreshold(config.threshold)
    }
}

struct FeatureExplanation: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationView {
        AutoStopSettingsView(speechService: SpeechService())
    }
}
