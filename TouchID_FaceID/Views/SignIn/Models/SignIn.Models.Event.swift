import Foundation

extension SignIn.Models {
    enum Event {
        case
            viewEvent(ViewEvent),
            authorized(_ token: String),
            failed(Error)
    }
}
