import SwiftUI
import Observation

@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var speechService = SpeechService()
    var currentTranscription = ""
    var isShowingLiveTranscription = false

    init() {
        observeSpeechService()
    }

    func startRecording() {
        speechService.clearError()
        Task {
            await speechService.startRecording()
        }
    }

    func stopRecording() {
        speechService.stopRecording()
    }

    private func addUserMessage(_ text: String) {
        let message = ChatMessage(text: text, isUser: true)
        messages.append(message)
    }

    func addAIMessage(_ text: String) {
        let message = ChatMessage(text: text, isUser: false)
        messages.append(message)
    }
}

private extension ChatViewModel {
    func observeSpeechService() {
        Task { @MainActor in
            var lastProcessedState: SpeechRecognitionState = .idle

            while true {
                let currentState = speechService.recognitionState

                // Only process state changes to avoid multiple processing
                if currentState != lastProcessedState {
                    switch currentState {
                    case .recording:
                        // Reset transcription when starting new recording
                        if lastProcessedState != .recording {
                            currentTranscription = ""
                            isShowingLiveTranscription = false
                        }
                    case .processing:
                        // Only process once when transitioning to processing
                        if lastProcessedState == .recording {
                            // Use the current transcription instead of calling finalizeSpeech
                            let finalText = currentTranscription.isEmpty
                                ? speechService.transcribedText
                                : currentTranscription
                            if !finalText.isEmpty {
                                addUserMessage(finalText)
                                // Clear the speech service state
                                _ = speechService.finalizeSpeech()
                            }
                            currentTranscription = ""
                            isShowingLiveTranscription = false
                        }
                    case .error, .idle:
                        currentTranscription = ""
                        isShowingLiveTranscription = false
                    }
                    lastProcessedState = currentState
                }

                // Update live transcription during recording
                if speechService.isRecording && !speechService.transcribedText.isEmpty {
                    currentTranscription = speechService.transcribedText
                    isShowingLiveTranscription = true
                }

                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }
}
