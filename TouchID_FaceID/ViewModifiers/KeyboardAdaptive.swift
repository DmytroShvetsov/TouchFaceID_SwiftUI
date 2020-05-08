import SwiftUI
import Combine

struct KeyboardAdaptive: ViewModifier {
    typealias Completion = (_ geometry: GeometryProxy, _ keyboardHeight: CGFloat) -> CGFloat
    @State private var bottomPadding: CGFloat = 0
    fileprivate let receiveCompletion: (_ geometry: GeometryProxy, _ keyboardHeight: CGFloat) -> CGFloat
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.bottomPadding)
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    let padding = self.receiveCompletion(geometry, keyboardHeight)
                    self.bottomPadding = max(0, padding)
            }
            .animation(.easeOut(duration: 0.25))
        }
    }
}

extension View {
    func keyboardAdaptive(_ paddingOnChanges: @escaping KeyboardAdaptive.Completion = { _, h in h }) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive(receiveCompletion: paddingOnChanges))
    }
}
