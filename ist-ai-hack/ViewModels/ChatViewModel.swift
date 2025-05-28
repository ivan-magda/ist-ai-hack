import SwiftUI
import Observation

@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var currentTranscription = ""
    var isShowingLiveTranscription = false
    var apiKeyValidationError: String?

    var speechService = SpeechService()
    var openAIService = OpenAIService()
    var elevenLabsService = ElevenLabsService()

    init() {
        observeSpeechService()
        validateAPIKey()
    }

    private func validateAPIKey() {
        Task {
            let isValid = await openAIService.validateAPIKey()
            await MainActor.run {
                if !isValid {
                    apiKeyValidationError = "OpenAI API key is invalid or not configured. Please check your API key."
                } else {
                    apiKeyValidationError = nil
                }
            }
        }
    }

    func startRecording() {
        guard !elevenLabsService.isPlaying else {
            return
        }

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

        generateAIResponse(for: text)
    }

    func addAIMessage(_ text: String) {
        let message = ChatMessage(text: text, isUser: false)
        messages.append(message)
    }

    private func generateAIResponse(for userInput: String) {
        let loadingMessage = ChatMessage(text: "Thinking", isUser: false, isLoading: true)
        messages.append(loadingMessage)

        Task {
            let response = await openAIService.generateResponse(from: userInput)
            _ = await elevenLabsService.synthesizeAndPlay(text: response)
            await MainActor.run {
                if let loadingIndex = messages.firstIndex(where: { $0.id == loadingMessage.id }) {
                    messages.remove(at: loadingIndex)
                }
                addAIMessage(response)
            }
        }
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
