import SwiftUI
import Combine

// MARK: - ContentSize
extension Common.UI.ViewModifiers {
    struct ContentSize: ViewModifier {
        var width: CGFloat
        var height: CGFloat

        @Environment(\.sizeCategory) private var sizeCategory
        
        func body(content: Content) -> some View {
            let k = Self.verticalSizes[sizeCategory] ?? 1
            return content
                .frame(width: width * k, height: height * k)
        }
    }
}

private extension Common.UI.ViewModifiers.ContentSize {
    static let verticalSizes: [ContentSizeCategory: CGFloat] = [
        .extraSmall: 0.8,
        .small: 0.9,
        .medium: 1,
        .large: 1.1,
        .extraLarge: 1.2,
        .extraExtraLarge: 1.3,
        .extraExtraExtraLarge: 1.4,
        .accessibilityMedium: 1.5,
        .accessibilityLarge: 1.6,
        .accessibilityExtraLarge: 1.7,
        .accessibilityExtraExtraLarge: 1.8,
        .accessibilityExtraExtraExtraLarge: 1.9
    ]
}

extension View {
    func contentSize(width: CGFloat, height: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: Common.UI.ViewModifiers.ContentSize(width: width, height: height))
    }
}
