import Foundation

extension SignIn.Models {
    enum Event {
        case
            viewEvent(ViewEvent),
            previousUserLogin(String),
            initiateBiometricAuth,
            authorized,
            failed(Error)
    }
}
