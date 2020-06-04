import SwiftUI

#if !targetEnvironment(macCatalyst)
import Combine
#endif

struct ResponderTextField: UIViewRepresentable {
    let placeholder: String
    let placeholderColor: UIColor
    let textColor: UIColor
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    
    init(_ placeholder: String, placeholderColor: UIColor, text: Binding<String>, textColor: UIColor, isFirstResponder: Binding<Bool>) {
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self.textColor = textColor
        self._text = text
        self._isFirstResponder = isFirstResponder
    }
    
    func makeCoordinator() -> Coordinator {
        .init(isFirstResponder: $isFirstResponder, text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextField {
        let textField = UITextField()
        textField.text = text
        textField.placeholder = placeholder
        textField.textColor = textColor
        textField.attributedPlaceholder = .init(string: placeholder, attributes: [.foregroundColor : placeholderColor])
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textChanged), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<Self>) {
        defer { context.coordinator.listenToChanges = true }
        context.coordinator.listenToChanges = false
        
        _ = isFirstResponder ? uiView.becomeFirstResponder() : uiView.resignFirstResponder()
        uiView.text = text
    }
}

// MARK: - Coordinator
extension ResponderTextField {
    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding private var isFirstResponder: Bool
        @Binding private var text: String

        #if !targetEnvironment(macCatalyst)
        private var anyCancellable: AnyCancellable?
        #endif
        
        fileprivate var listenToChanges: Bool = false
        
        init(isFirstResponder: Binding<Bool>, text: Binding<String>) {
            _isFirstResponder = isFirstResponder
            _text = text
            super.init()
            
            #if !targetEnvironment(macCatalyst)
            anyCancellable = Publishers.keyboardChange.sink(receiveValue: { [weak self] keyboardHeight, _ in
                guard keyboardHeight < 100 && self?.isFirstResponder == true else { return }
                
                DispatchQueue.main.async {
                    self?.isFirstResponder = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self?.isFirstResponder = true
                    }
                }
            })
            #endif
        }
        
        @objc fileprivate func textChanged(_ textField: UITextField) {
            guard listenToChanges else { return }
            text = textField.text ?? ""
        }
        
        // UITextFieldDelegate
        func textFieldDidBeginEditing(_ textField: UITextField) {
            guard listenToChanges else { return }
            isFirstResponder = textField.isFirstResponder
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            guard listenToChanges else { return }
            DispatchQueue.main.async { self.isFirstResponder = textField.isFirstResponder }
        }
    }
}


struct ResponderTextField_Previews: PreviewProvider {
    static var previews: some View {
        ResponderTextField("placeholder", placeholderColor: .gray,
                           text: .constant(""), textColor: .black,
                           isFirstResponder: .constant(false))
            .previewLayout(.fixed(width: 300, height: 100))
    }
}
