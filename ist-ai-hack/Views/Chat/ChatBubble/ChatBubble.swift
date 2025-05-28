import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        if message.isUser {
            UserChatBubble(message: message)
        } else {
            AIChatBubble(message: message)
        }
    }
}

#Preview {
    VStack {
        ChatBubble(
            message: ChatMessage(
                text: "Hello! How are you?",
                isUser: true
            )
        )

        ChatBubble(
            message: ChatMessage(
                text: "Hello, how can I help you today?",
                isUser: false
            )
        )

        ChatBubble(
            message: ChatMessage(
                text: "Thinking",
                isUser: false,
                isLoading: true
            )
        )
    }
    .padding()
}
