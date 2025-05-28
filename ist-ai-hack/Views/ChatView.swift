import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                    }

                    if viewModel.isShowingLiveTranscription {
                        LiveTranscriptionBubble(text: viewModel.currentTranscription)
                    }
                }
            }

            if let errorMessage = viewModel.speechService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Spacer()
            SpeechInputButton(
                isRecording: viewModel.speechService.isRecording,
                recognitionState: viewModel.speechService.recognitionState
            ) {
                if viewModel.speechService.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ChatView()
}
