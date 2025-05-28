import Foundation

struct ChatMessage: Hashable, Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let isLoading: Bool

    init(text: String, isUser: Bool, isLoading: Bool = false) {
        self.text = text
        self.isUser = isUser
        self.isLoading = isLoading
    }
}
