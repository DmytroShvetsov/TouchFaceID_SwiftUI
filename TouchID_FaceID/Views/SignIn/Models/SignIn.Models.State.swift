import Foundation

extension SignIn.Models {
    struct State {
        var login: String
        var password: String
        var state: State
    }
}

// MARK: - State
extension SignIn.Models.State {
    enum State {
        case
            `default`,
            authorization,
            authorized,
            error(Error)
        
        var error: Error? {
            switch self {
                case .error(let error):
                    return error
                
                default:
                    return nil
            }
        }
    }
}
