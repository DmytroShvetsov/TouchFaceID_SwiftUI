import Foundation

extension Main.Models {
    enum Event {
        case
            viewEvent(ViewEvent),
            updateUserName(String),
            userNameSaved,
            logoutExecuted
    }
}
