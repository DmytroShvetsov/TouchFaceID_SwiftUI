import Foundation

extension Main.Models {
    enum ViewEvent {
        case
            logout,
            typingName(String),
            toggleBiometricAuthAllowance
    }
}
