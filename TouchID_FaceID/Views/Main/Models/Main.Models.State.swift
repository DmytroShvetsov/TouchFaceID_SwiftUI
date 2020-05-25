import Foundation

extension Main.Models {
    struct State: Equatable {
        var name: String
        var state: State
    }
}

// MARK: - State
extension Main.Models.State {
    enum State: Equatable {
        case
            `default`,
            savingUserName,
            logout
    }
}
