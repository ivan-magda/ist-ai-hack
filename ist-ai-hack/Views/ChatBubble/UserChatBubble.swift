import SwiftUI

struct UserChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            Spacer()
            Text(message.text)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
        }
        .padding(.leading, 40)
        .padding(.vertical, 4)
    }
}

#Preview {
    UserChatBubble(
        message: ChatMessage(
            text: "Hello! How are you?",
            isUser: true
        )
    )
    .padding()
}
