import SwiftUI

struct ResponderTextField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    private var textFieldDelegate: TextFieldDelegate
    
    init(_ placeholder: String, text: Binding<String>, isFirstResponder: Binding<Bool>) {
        self.placeholder = placeholder
        self._text = text
        self._isFirstResponder = isFirstResponder
        self.textFieldDelegate = .init(text: text)
    }
    
    var body: some View {
        ResponderView<UITextField>(isFirstResponder: $isFirstResponder) {
            $0.text = self.text
            $0.placeholder = self.placeholder
            $0.delegate = self.textFieldDelegate
        }
    }
}

// MARK: - TextFieldDelegate
private extension ResponderTextField {
    final class TextFieldDelegate: NSObject, UITextFieldDelegate {
        @Binding private(set) var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}

struct ResponderTextField_Previews: PreviewProvider {
    static var previews: some View {
        ResponderTextField("Placeholder",
                           text: .constant(""),
                           isFirstResponder: .constant(false))
            .previewLayout(.fixed(width: 300, height: 40))
    }
}
