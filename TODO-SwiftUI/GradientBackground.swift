import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct GradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            GradientBackground()
            content
        }
    }
}

extension View {
    func gradientBackground() -> some View {
        self.modifier(GradientBackgroundModifier())
    }
}
