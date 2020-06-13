import Foundation

extension Main.Models {
    struct State: Equatable {
        var name: String
        var biometricAuthTypeLabel: String
        var biometricAuthAllowed: Bool
        var biometricAuthAvailability: BiometricAuthAvailability
        var state: State
    }
}

// MARK: - State
extension Main.Models.State {
    enum State: Equatable {
        case
            `default`,
            savingUserName,
            savingBiometricAuthAllowance,
            logout
    }
}

// MARK: - BiometricAuthAvailability
extension Main.Models.State {
    enum BiometricAuthAvailability: Equatable {
        case available, unavailable
    }
}
