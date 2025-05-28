import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ChatView()
                .navigationTitle("Language Tutor")
        }
    }
}

#Preview {
    ContentView()
}
