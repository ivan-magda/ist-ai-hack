import SwiftUI

struct OnboardingStepView: View {
    let step: OnboardingStep

    @State private var animate = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: step.imageName)
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .scaleEffect(animate ? 1.1 : 0.9)
                .opacity(animate ? 1.0 : 0.7)
                .animation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                    value: animate
                )
                .padding()

            Text(step.title)
                .font(.title)
                .bold()

            Text(step.description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)

            Spacer()
        }
        .padding()
        .onAppear {
            animate = true
        }
        .onDisappear {
            animate = false
        }
    }
}

#Preview {
    OnboardingStepView(
        step: onboardingSteps[0]
    )
}
