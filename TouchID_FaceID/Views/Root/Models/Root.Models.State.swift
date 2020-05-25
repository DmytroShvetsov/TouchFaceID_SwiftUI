import Foundation

extension Root.Models {
    enum State: Equatable {
        case
            `default`,
            authorized,
            notAuthorized
    }
}
