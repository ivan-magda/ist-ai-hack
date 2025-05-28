import SwiftUI

struct SpeechInputButton: View {
    let isRecording: Bool
    let recognitionState: SpeechRecognitionState
    let remainingTime: TimeInterval
    let isAutoStopCountdown: Bool
    let onTap: () -> Void

    @State private var recordingPulseScale: CGFloat = 1.0
    @State private var recordingPulseOpacity: Double = 0.8
    @State private var iconScale: CGFloat = 1.0

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        HStack {
            Spacer()

            Button(
                action: onTap
            ) {
                ZStack {
                    // Countdown progress ring
                    if isRecording && isAutoStopCountdown {
                        Circle()
                            .stroke(Color.red.opacity(0.3), lineWidth: 4)
                            .frame(width: 85, height: 85)

                        Circle()
                            .trim(from: 0, to: min(remainingTime / 1.0, 1.0))
                            .stroke(Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 85, height: 85)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: remainingTime)
                    }

                    // Outer pulsing ring when recording
                    if isRecording {
                        Circle()
                            .stroke(microphoneButtonColor.opacity(0.3), lineWidth: 2)
                            .frame(width: 80, height: 80)
                            .scaleEffect(recordingPulseScale)
                            .opacity(recordingPulseOpacity)
                            .animation(
                                .easeInOut(duration: isAutoStopCountdown ? 0.3 : 1.0)
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
        if !isEnabled {
            return .gray.opacity(0.5)
        }

        // Show warning color during countdown
        if isAutoStopCountdown && isRecording {
            return remainingTime < 0.5 ? .red : .orange
        }

        switch recognitionState {
        case .idle:
            return .blue
        case .recording:
            return .red
        case .processing:
            return .orange
        case .error:
            return .gray
        }
    }

    private var microphoneIcon: String {
        if !isEnabled {
            return "speaker.wave.2"
        }

        switch recognitionState {
        case .idle:
            return "mic.fill"
        case .recording:
            return "stop.fill"
        case .processing:
            return "ellipsis"
        case .error:
            return "mic.slash.fill"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SpeechInputButton(
            isRecording: false,
            recognitionState: .idle,
            remainingTime: 0,
            isAutoStopCountdown: false
        ) {}

        SpeechInputButton(
            isRecording: true,
            recognitionState: .recording,
            remainingTime: 3.0,
            isAutoStopCountdown: false
        ) {}

        SpeechInputButton(
            isRecording: true,
            recognitionState: .recording,
            remainingTime: 0.8,
            isAutoStopCountdown: true
        ) {}

        SpeechInputButton(
            isRecording: false,
            recognitionState: .processing,
            remainingTime: 0,
            isAutoStopCountdown: false
        ) {}

        SpeechInputButton(
            isRecording: false,
            recognitionState: .error("Test error"),
            remainingTime: 0,
            isAutoStopCountdown: false
        ) {}

        SpeechInputButton(
            isRecording: false,
            recognitionState: .idle,
            remainingTime: 0,
            isAutoStopCountdown: false
        ) {}
            .disabled(true)
    }
    .padding()
}
