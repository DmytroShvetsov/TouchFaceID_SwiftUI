import Foundation

extension SignIn.Models {
    enum Event {
        case
            viewEvent(ViewEvent),
            previousUserLogin(String),
            authorized(_ token: String),
            failed(Error)
    }
}
