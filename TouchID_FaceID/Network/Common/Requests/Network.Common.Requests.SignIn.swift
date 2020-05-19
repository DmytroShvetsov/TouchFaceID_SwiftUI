import Foundation

// MARK: - Network.Common.Requests.SignIn
extension Network.Common.Requests {
    struct SignIn: Encodable {
        let login: String
        let password: String
    }
}
