import Foundation

extension SignIn.Models {
    enum ViewEvent {
        case
            signIn,
            signInViaBiometricAuth,
            typingLogin(String),
            typingPassword(String)
    }
}
