import Foundation

extension SignIn.Models {
    enum Event {
        case
            viewEvent(ViewEvent),
            authorizationBegun
    }
}
