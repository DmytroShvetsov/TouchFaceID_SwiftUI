import SwiftUI

struct LocalePreview<Preview: View>: View {
    private let preview: Preview

    var body: some View {
        ForEach(Locale.all, id: \.self) { locale in
            self.preview
                .previewLayout(PreviewLayout.sizeThatFits)
                .environment(\.locale, locale)
                .previewDisplayName("Locale: \(locale.identifier)")
        }
    }

    init(@ViewBuilder builder: @escaping () -> Preview) {
        preview = builder()
    }
}

private extension Locale {
    static let all = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
}
