import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0

    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false

    var body: some View {
        VStack {
            TabView(selection: $currentStep) {
                ForEach(0..<onboardingSteps.count, id: \.self) { index in
                    OnboardingStepView(step: onboardingSteps[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentStep)

            Button(action: nextTapped) {
                Text(currentStep < onboardingSteps.count - 1 ? "Next" : "Get Started")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
        }
    }

    private func nextTapped() {
        if currentStep < onboardingSteps.count - 1 {
            currentStep += 1
        } else {
            didCompleteOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
}
