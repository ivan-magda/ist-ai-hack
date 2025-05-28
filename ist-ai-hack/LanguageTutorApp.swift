import SwiftUI

@main
struct LanguageTutorApp: App {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false

    var body: some Scene {
        WindowGroup {
            if shouldShowOnboarding {
                OnboardingView()
            } else {
                ContentView()
            }
        }
    }

    private var shouldShowOnboarding: Bool {
        #if DEBUG
        return true
        #else
        return !didCompleteOnboarding
        #endif
    }
}
