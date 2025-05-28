import Foundation

class APIKeyManager {
    static let shared = APIKeyManager()

    private init() {}

    var openAIAPIKey: String {
        AppConfiguration.openAIAPIKey
    }

    func isAPIKeyConfigured() -> Bool {
        !openAIAPIKey.isEmpty && openAIAPIKey != "YOUR_OPENAI_API_KEY"
    }
}
