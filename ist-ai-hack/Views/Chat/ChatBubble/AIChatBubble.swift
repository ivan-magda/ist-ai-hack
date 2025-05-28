import SwiftUI

struct AIChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            HStack {
                Text(message.text)

                if message.isLoading {
                    LoadingDotsView()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.black)
            .cornerRadius(16)

            Spacer()
        }
        .padding(.trailing, 40)
        .padding(.vertical, 4)
    }
}

private struct LoadingDotsView: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.primary.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

#Preview {
    VStack {
        AIChatBubble(
            message: ChatMessage(
                text: "Hello! How can I help you today?",
                isUser: false
            )
        )

        AIChatBubble(
            message: ChatMessage(
                text: "Thinking",
                isUser: false,
                isLoading: true
            )
        )
    }
    .padding()
}
