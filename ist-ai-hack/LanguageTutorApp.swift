import SwiftUI

@main
struct LanguageTutorApp: App {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false

    var body: some Scene {
        WindowGroup {
            if didCompleteOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
