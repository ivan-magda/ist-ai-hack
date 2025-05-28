import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            Text(message.text)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(16)
            if !message.isUser {
                Spacer()
            }
        }
        .padding(message.isUser ? .leading : .trailing, 40)
        .padding(.vertical, 4)
    }
}

#Preview {
    ChatBubble(
        message: ChatMessage(
            text: "Hello, how can I help you today?",
            isUser: false
        )
    )
    .padding()
}
