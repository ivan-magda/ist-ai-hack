import Foundation
import Speech
import AVFoundation
import Observation

enum SpeechRecognitionState: Equatable {
    case idle
    case recording
    case processing
    case error(String)
}

@Observable
class SpeechService: NSObject {
    var isRecording = false
    var transcribedText = ""
    var recognitionState: SpeechRecognitionState = .idle
    var errorMessage: String?

    // Auto-stop properties
    var autoStopEnabled = true
    var autoStopThreshold: TimeInterval = 3.0
    var remainingTime: TimeInterval = 0
    var isAutoStopCountdown = false

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()

    // Auto-stop implementation
    private var silenceTimer: Timer?
    private var lastTranscriptionUpdate = Date()
    private var previousTranscriptionText = ""
    private var maxRecordingDuration: TimeInterval = 60.0

    override init() {
        super.init()
        setupSpeechRecognizer()
    }

    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }

    func requestPermissions() async -> Bool {
        let speechAuthStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        let microphoneAuthStatus = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        return speechAuthStatus == .authorized && microphoneAuthStatus
    }

    func startRecording() async {
        guard !isRecording else { return }

        let hasPermissions = await requestPermissions()
        guard hasPermissions else {
            await MainActor.run {
                self.recognitionState = .error("Permissions not granted")
                self.errorMessage = "Please enable microphone and speech recognition permissions in Settings"
            }
            return
        }

        do {
            try await startSpeechRecognition()
        } catch {
            await MainActor.run {
                self.recognitionState = .error("Failed to start recording")
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func startSpeechRecognition() async throws {
        cleanupRecognition()

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }

        try configureAudioSession()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.requestCreationFailed
        }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }

                if let result = result {
                    let newText = result.bestTranscription.formattedString

                    // Check if transcription has meaningfully changed
                    if self.hasTranscriptionChanged(newText) {
                        self.resetAutoStopTimer()
                        self.previousTranscriptionText = newText
                    }

                    self.transcribedText = newText

                    if result.isFinal {
                        self.stopRecording()
                    }
                } else if let error = error {
                    let nsError = error as NSError

                    // Log error details for debugging
                    print("Speech recognition error - Domain: \(nsError.domain), Code: \(nsError.code), Description: \(nsError.localizedDescription)")

                    // Handle different types of errors appropriately
                    if nsError.domain == "kAFAssistantErrorDomain" || nsError.domain == "SpeechRecognitionErrorDomain" {
                        switch nsError.code {
                        case 216, 203: // Cancellation errors
                            print("Ignoring cancellation error")
                            return
                        case 1107, 300, 301, 302: // No speech detected / timeout errors
                            print("No speech detected - going to idle")
                            self.recognitionState = .idle
                            self.isRecording = false
                            return
                        default:
                            break
                        }
                    }

                    // Check for common non-critical errors by description
                    let errorDescription = error.localizedDescription.lowercased()
                    if errorDescription.contains("no speech") ||
                        errorDescription.contains("cancelled") ||
                        errorDescription.contains("timeout") {
                        print("Ignoring non-critical error: \(errorDescription)")
                        self.recognitionState = .idle
                        self.isRecording = false
                        return
                    }

                    // Only show actual critical errors
                    print("Showing error to user: \(error.localizedDescription)")
                    self.recognitionState = .error("Recognition failed")
                    self.errorMessage = error.localizedDescription
                    self.isRecording = false
                }
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        await MainActor.run {
            self.isRecording = true
            self.recognitionState = .recording
            self.transcribedText = ""
            self.errorMessage = nil
            self.previousTranscriptionText = ""
            self.lastTranscriptionUpdate = Date()
            self.startAutoStopTimer()
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        // Stop auto-stop timer
        stopAutoStopTimer()

        // Clean up audio resources
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        // Don't cancel the task here - let it complete naturally
        // recognitionTask?.cancel()
        recognitionTask = nil

        isRecording = false

        // Only set to processing if we have transcribed text
        if !transcribedText.isEmpty {
            recognitionState = .processing
        } else {
            recognitionState = .idle
        }
    }

    private func cancelRecognition() {
        stopAutoStopTimer()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        isRecording = false
    }

    private func cleanupRecognition() {
        // Clean up without canceling (which triggers error callback)
        stopAutoStopTimer()
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    func finalizeSpeech() -> String {
        let finalText = transcribedText
        transcribedText = ""
        recognitionState = .idle
        errorMessage = nil
        return finalText
    }

    func clearError() {
        if case .error = recognitionState {
            recognitionState = .idle
            errorMessage = nil
        }
    }

    // MARK: - Auto-Stop Implementation

    private func startAutoStopTimer() {
        guard autoStopEnabled else { return }

        stopAutoStopTimer() // Clean up any existing timer
        remainingTime = autoStopThreshold
        isAutoStopCountdown = false

        silenceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.isRecording else { return }

                let timeSinceLastUpdate = Date().timeIntervalSince(self.lastTranscriptionUpdate)
                self.remainingTime = max(0, self.autoStopThreshold - timeSinceLastUpdate)

                // Start countdown when less than 1 second remaining
                if self.remainingTime <= 1.0 && !self.isAutoStopCountdown {
                    self.isAutoStopCountdown = true
                }

                // Auto-stop when time runs out
                if timeSinceLastUpdate >= self.autoStopThreshold {
                    self.stopRecording()
                }

                // Maximum recording duration safety check
                if Date().timeIntervalSince(self.lastTranscriptionUpdate) > self.maxRecordingDuration {
                    self.stopRecording()
                }
            }
        }
    }

    private func stopAutoStopTimer() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        remainingTime = 0
        isAutoStopCountdown = false
    }

    private func resetAutoStopTimer() {
        guard autoStopEnabled, isRecording else { return }
        lastTranscriptionUpdate = Date()
        remainingTime = autoStopThreshold
        isAutoStopCountdown = false
    }

    private func hasTranscriptionChanged(_ newText: String) -> Bool {
        let normalizedNew = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedPrevious = previousTranscriptionText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check for meaningful changes
        if normalizedNew.count > normalizedPrevious.count {
            return true
        }

        // Check for different content (not just formatting)
        if normalizedNew != normalizedPrevious && !normalizedNew.isEmpty {
            return true
        }

        return false
    }

    func setAutoStopEnabled(_ enabled: Bool) {
        autoStopEnabled = enabled
        if !enabled {
            stopAutoStopTimer()
        } else if isRecording {
            startAutoStopTimer()
        }
    }

    func setAutoStopThreshold(_ threshold: TimeInterval) {
        autoStopThreshold = max(0.5, min(10.0, threshold)) // Clamp between 0.5 and 10 seconds
        if isRecording {
            resetAutoStopTimer()
        }
    }
}

extension SpeechService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            Task { @MainActor in
                self.recognitionState = .error("Speech recognizer unavailable")
                self.errorMessage = "Speech recognition is temporarily unavailable"
                self.stopRecording()
            }
        }
    }
}

enum SpeechError: Error, LocalizedError {
    case recognizerUnavailable
    case requestCreationFailed
    case audioSessionFailed

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            "Speech recognizer is not available"
        case .requestCreationFailed:
            "Failed to create speech recognition request"
        case .audioSessionFailed:
            "Failed to configure audio session"
        }
    }
}
