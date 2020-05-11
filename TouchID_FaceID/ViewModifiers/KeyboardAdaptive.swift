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
                .onReceive(Publishers.keyboardChange) { keyboardHeight, animationDuration in
                    let padding = self.receiveCompletion(geometry, keyboardHeight)
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            self.bottomPadding = max(0, padding)
                        }
                    }
            }
        }
    }
}

extension View {
    func keyboardAdaptive(_ paddingOnChanges: @escaping KeyboardAdaptive.Completion = { _, h in h }) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive(receiveCompletion: paddingOnChanges))
    }
}
