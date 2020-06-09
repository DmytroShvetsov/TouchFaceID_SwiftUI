import SwiftUI

#if !targetEnvironment(macCatalyst)
import Combine
#endif

struct ResponderTextField: UIViewRepresentable {
    private let placeholder: String
    private let placeholderColor: UIColor
    private let textColor: UIColor
    
    @Binding private var text: String
    @Binding private var isFirstResponder: Bool
    @Binding private var isSecureEntry: Bool
    
    @Environment(\.layoutDirection) fileprivate var layoutDirection
    
    init(_ placeholder: String, placeholderColor: UIColor, text: Binding<String>, textColor: UIColor, isFirstResponder: Binding<Bool>, isSecureEntry: Binding<Bool> = .constant(false)) {
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self.textColor = textColor
        self._text = text
        self._isFirstResponder = isFirstResponder
        self._isSecureEntry = isSecureEntry
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
        
        if isSecureEntry {
            textField.isSecureTextEntry = true
            textField.textContentType = .password
        }
        
        if layoutDirection == .rightToLeft {
            textField.textAlignment = .right
            textField.semanticContentAttribute = .forceRightToLeft
        } else {
            textField.textAlignment = .left
            textField.semanticContentAttribute = .forceLeftToRight
        }
        
        textField.adjustsFontForContentSizeCategory = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        
        textField.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<Self>) {
        defer { context.coordinator.listenToChanges = true }
        context.coordinator.listenToChanges = false
        
        _ = isFirstResponder ? uiView.becomeFirstResponder() : uiView.resignFirstResponder()
        uiView.text = text
        uiView.isSecureTextEntry = isSecureEntry
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
            guard UIDevice.current.userInterfaceIdiom != .pad else { return }
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
        ResponderTextField("placeholder", placeholderColor: .appGray,
                           text: .constant(""), textColor: .appText,
                           isFirstResponder: .constant(false))
            .previewLayout(.fixed(width: 250, height: 50))
            .previewsPreset()
    }
}
