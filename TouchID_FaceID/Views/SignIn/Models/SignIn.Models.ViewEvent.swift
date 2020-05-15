import Foundation

extension SignIn.Models {
    enum ViewEvent {
        case
            signIn,
            typingLogin(String),
            typingPassword(String)
    }
}
