import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()

    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messages) { message in
                    ChatBubble(message: message)
                }
            }
            Spacer()
            Button(action: {
                viewModel.startRecording()
            }) {
                Image(systemName: "mic.fill")
                    .font(.title)
                    .padding()
                    .background(Circle().fill(Color.blue))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 10)
        }
        .padding()
    }
}

#Preview {
    ChatView()
}
