import Foundation

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    var temperature: Double = 0.7
}

struct OpenAIChatChoice: Codable {
    let message: OpenAIMessage
}

struct OpenAIChatResponse: Codable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIModelsResponse: Codable {
    let data: [OpenAIModel]
}

struct OpenAIModel: Codable {
    let id: String
}

class OpenAIService {
    private let baseURL = "https://api.openai.com/v1"
    private let session = URLSession.shared

    func validateAPIKey() async -> Bool {
        guard APIKeyManager.shared.isAPIKeyConfigured() else {
            return false
        }

        guard let url = URL(string: "\(baseURL)/models") else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(APIKeyManager.shared.openAIAPIKey)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            print("API Key validation error:", error.localizedDescription)
            return false
        }
    }

    func generateResponse(from userInput: String) async -> String {
        guard APIKeyManager.shared.isAPIKeyConfigured() else {
            return "⚠️ OpenAI API key not configured. Please set up your API key."
        }

        let systemPrompt = """
        You are a friendly, patient language tutor. In conversations, subtly correct grammar, suggest improved phrasing, and occasionally introduce helpful vocabulary naturally. Keep responses conversational and encouraging. Provide brief explanations when correcting errors, but don't overwhelm the learner.
        """

        let chatRequest = OpenAIChatRequest(
            model: "gpt-4",
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: userInput)
            ]
        )

        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            return "Sorry, I couldn't generate a response right now. Please try again."
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIKeyManager.shared.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let requestData = try JSONEncoder().encode(chatRequest)
            request.httpBody = requestData

            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("OpenAI API Error: Status code \(httpResponse.statusCode)")
                return "Sorry, I couldn't generate a response right now. Please try again."
            }

            let chatResponse = try JSONDecoder().decode(OpenAIChatResponse.self, from: data)
            return chatResponse.choices.first?.message.content ?? "Sorry, I couldn't generate a response right now. Please try again."
        } catch {
            print("OpenAI Error:", error.localizedDescription)
            return "Sorry, I couldn't generate a response right now. Please try again."
        }
    }
}
