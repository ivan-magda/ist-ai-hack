import Foundation

class APIKeyManager {
    static let shared = APIKeyManager()

    private init() {}

    var openAIAPIKey: String {
        AppConfiguration.openAIAPIKey
    }

    var elevenLabsAPIKey: String {
        AppConfiguration.elevenLabsAPIKey
    }

    var elevenLabsVoiceId: String {
        AppConfiguration.elevenLabsVoiceId
    }

    func isAPIKeyConfigured() -> Bool {
        !openAIAPIKey.isEmpty && openAIAPIKey != "YOUR_OPENAI_API_KEY"
    }

    func isElevenLabsConfigured() -> Bool {
        !elevenLabsAPIKey.isEmpty && elevenLabsAPIKey != "YOUR_ELEVEN_LABS_API_KEY"
    }
}
