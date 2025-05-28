import Foundation

struct OnboardingStep: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

let onboardingSteps = [
    OnboardingStep(
        imageName: "mic.fill",
        title: "Speak Naturally",
        description: "Talk to the app in your target language. Your speech is transcribed instantly."
    ),
    OnboardingStep(
        imageName: "message.fill",
        title: "AI-Powered Replies",
        description: "Get conversational responses, grammar corrections, and helpful vocabulary."
    ),
    OnboardingStep(
        imageName: "speaker.wave.2.fill",
        title: "Listen & Learn",
        description: "Hear natural-sounding speech synthesis."
    )
]
