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
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isShowingLiveTranscription {
                        LiveTranscriptionBubble(text: viewModel.currentTranscription)
                            .id("live-transcription")
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: viewModel.messages.last) { oldMessage, newMessage in
                guard let newMessage else {
                    return
                }

                if oldMessage?.isLoading != newMessage.isLoading {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(newMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isShowingLiveTranscription) { _, isShowing in
                if isShowing {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("live-transcription", anchor: .bottom)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
            VStack {
                if let errorMessage = viewModel.speechService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                if let ttsError = viewModel.elevenLabsService.errorMessage {
                    Text(ttsError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                if viewModel.elevenLabsService.isPlaying {
                    HStack {
                        Image(systemName: "speaker.wave.2")
                        Text("Playing audio...")
                    }
                    .foregroundColor(.blue)
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
                .disabled(
                    viewModel.elevenLabsService.isPlaying ||
                    viewModel.messages.last?.isLoading == true
                )
            }
            .padding()
            .background(Material.bar)
        }
    }
}

#Preview {
    ChatView()
}
