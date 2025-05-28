import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()

    var body: some View {
        if let apiError = viewModel.apiKeyValidationError {
            Text(apiError)
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
        } else {
            chatContent
        }
    }

    private var chatContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.messages) { message in
                    ChatBubble(message: message)
                }

                if viewModel.isShowingLiveTranscription {
                    LiveTranscriptionBubble(text: viewModel.currentTranscription)
                }
            }
            .padding(.horizontal)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            VStack {
                if let errorMessage = viewModel.speechService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

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
                .padding()
            }
            .padding()
            .background(Material.bar)
        }
    }
}

#Preview {
    ChatView()
}
