import SwiftUI
import Combine

struct ResponderView<View: UIView>: UIViewRepresentable {
    @Binding var isFirstResponder: Bool
    var configuration = { (view: View) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> View { View() }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($isFirstResponder)
    }
    
    func updateUIView(_ uiView: View, context: UIViewRepresentableContext<Self>) {
        context.coordinator.view = uiView
        _ = isFirstResponder ? uiView.becomeFirstResponder() : uiView.resignFirstResponder()
        configuration(uiView)
    }
}

// MARK: - Coordinator
extension ResponderView {
    final class Coordinator {
        @Binding private var isFirstResponder: Bool
        private var anyCancellable: AnyCancellable?
        fileprivate weak var view: UIView?
        
        init(_ isFirstResponder: Binding<Bool>) {
            _isFirstResponder = isFirstResponder
            self.anyCancellable = Publishers.keyboardChange.sink(receiveValue: { [weak self] keyboardHeight, _ in
                guard let view = self?.view else { return }
                DispatchQueue.main.async {
                    if keyboardHeight.isZero && view.isFirstResponder {
                        self?.isFirstResponder = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            self?.isFirstResponder = true
                        }
                    } else {
                        self?.isFirstResponder = view.isFirstResponder
                    }
                }
            })
        }
    }
}

struct ResponderView_Previews: PreviewProvider {
    static var previews: some View {
        ResponderView<UITextField>.init(isFirstResponder: .constant(false)) {
            $0.placeholder = "Placeholder"
        }.previewLayout(.fixed(width: 300, height: 40))
    }
}
