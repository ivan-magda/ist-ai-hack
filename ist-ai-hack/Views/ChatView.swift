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
            speechInputContainer
        }
        .padding()
    }

    private var speechInputContainer: some View {
        HStack {
            Spacer()

            Button(
                action: {
                    if viewModel.speechService.isRecording {
                        viewModel.stopRecording()
                    } else {
                        viewModel.startRecording()
                    }
                },
                label: {
                    ZStack {
                        Circle()
                            .fill(microphoneButtonColor)
                            .frame(width: 60, height: 60)

                        Image(systemName: microphoneIcon)
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            )
            .scaleEffect(viewModel.speechService.isRecording ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: viewModel.speechService.isRecording)

            Spacer()
        }
        .padding(.bottom)
    }

    private var microphoneButtonColor: Color {
        switch viewModel.speechService.recognitionState {
        case .idle: .blue
        case .recording: .red
        case .processing: .orange
        case .error: .gray
        }
    }

    private var microphoneIcon: String {
        switch viewModel.speechService.recognitionState {
        case .idle: "mic.fill"
        case .recording: "stop.fill"
        case .processing: "ellipsis"
        case .error: "mic.slash.fill"
        }
    }
}

#Preview {
    ChatView()
}
