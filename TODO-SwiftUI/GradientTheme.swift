import SwiftUI

enum GradientTheme {
    struct Config: Equatable {
        var colors: [Color]
        var startPoint: UnitPoint
        var endPoint: UnitPoint
    }

    static var current: Config = .init(
        colors: [
            Color(red: 0.11, green: 0.12, blue: 0.20),
            Color(red: 0.07, green: 0.27, blue: 0.49),
            Color(red: 0.26, green: 0.58, blue: 0.66)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
