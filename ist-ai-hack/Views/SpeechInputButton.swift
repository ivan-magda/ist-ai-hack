import SwiftUI

struct SpeechInputButton: View {
    let isRecording: Bool
    let recognitionState: SpeechRecognitionState
    let onTap: () -> Void

    @State private var recordingPulseScale: CGFloat = 1.0
    @State private var recordingPulseOpacity: Double = 0.8
    @State private var iconScale: CGFloat = 1.0

    var body: some View {
        HStack {
            Spacer()

            Button(
                action: onTap
            ) {
                ZStack {
                    // Outer pulsing ring when recording
                    if isRecording {
                        Circle()
                            .stroke(microphoneButtonColor.opacity(0.3), lineWidth: 2)
                            .frame(width: 80, height: 80)
                            .scaleEffect(recordingPulseScale)
                            .opacity(recordingPulseOpacity)
                            .animation(
                                .easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true),
                                value: recordingPulseScale
                            )
                    }

                    // Main button circle
                    Circle()
                        .fill(microphoneButtonColor)
                        .frame(width: 60, height: 60)
                        .shadow(
                            color: microphoneButtonColor.opacity(0.3),
                            radius: isRecording ? 8 : 4,
                            x: 0,
                            y: isRecording ? 4 : 2
                        )

                    // Icon with breathing animation when recording
                    Image(systemName: microphoneIcon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .scaleEffect(iconScale)
                        .animation(
                            isRecording ?
                                .easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                                    .easeInOut(duration: 0.2),
                            value: iconScale
                        )
                }
            }
            .scaleEffect(isRecording ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isRecording)

            Spacer()
        }
        .padding(.bottom)
        .onAppear {
            startButtonAnimations()
        }
        .onChange(of: isRecording) { _, _ in
            startButtonAnimations()
        }
    }

    private func startButtonAnimations() {
        if isRecording {
            recordingPulseScale = 1.3
            recordingPulseOpacity = 0.2
            iconScale = 1.1
        } else {
            recordingPulseScale = 1.0
            recordingPulseOpacity = 0.8
            iconScale = 1.0
        }
    }

    private var microphoneButtonColor: Color {
        switch recognitionState {
        case .idle: .blue
        case .recording: .red
        case .processing: .orange
        case .error: .gray
        }
    }

    private var microphoneIcon: String {
        switch recognitionState {
        case .idle: "mic.fill"
        case .recording: "stop.fill"
        case .processing: "ellipsis"
        case .error: "mic.slash.fill"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SpeechInputButton(
            isRecording: false,
            recognitionState: .idle
        ) {}

        SpeechInputButton(
            isRecording: true,
            recognitionState: .recording
        ) {}

        SpeechInputButton(
            isRecording: false,
            recognitionState: .processing
        ) {}

        SpeechInputButton(
            isRecording: false,
            recognitionState: .error("Test error")
        ) {}
    }
    .padding()
}
