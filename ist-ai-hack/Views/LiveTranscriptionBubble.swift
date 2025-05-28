import SwiftUI

struct LiveTranscriptionBubble: View {
    let text: String

    @State private var waveformScale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundStyle(.blue)
                    .font(.caption)
                    .scaleEffect(waveformScale)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                        value: waveformScale
                    )

                Text("Speaking...")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            if !text.isEmpty {
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: text)
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        waveformScale = 1.3
    }
}

#Preview {
    VStack {
        LiveTranscriptionBubble(text: "")
        LiveTranscriptionBubble(
            text: "Hello, I am speaking right now..."
        )
        LiveTranscriptionBubble(
            text: """
This is a longer transcription that shows how the bubble adapts to different lengths of text as the user continues speaking.
"""
        )
    }
    .padding()
}
