import SwiftUI

struct GradientBackground: View {
    var config: GradientTheme.Config = GradientTheme.current

    var body: some View {
        LinearGradient(colors: config.colors, startPoint: config.startPoint, endPoint: config.endPoint)
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
    func globalGradientBackground() -> some View {
        modifier(GradientBackgroundModifier())
    }
}
