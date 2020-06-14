import Foundation

extension SignIn.Models {
    struct State: Equatable {
        var login: String
        var password: String
        var biometricAuthType: BiometricAuth.BiometricType
        var biometricAuthAvailable: Bool
        var state: State
    }
}

// MARK: - State
extension SignIn.Models.State {
    enum State: Equatable {
        case
            idle,
            `default`,
            authorization(biometric: Bool),
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
        
        static func == (lhs: SignIn.Models.State.State, rhs: SignIn.Models.State.State) -> Bool {
            switch (lhs, rhs) {
                case (.error(let lhsError), .error(let rhsError)) where lhsError.localizedDescription == rhsError.localizedDescription:
                    fallthrough
                    
                case (.default, .default),
                     (.authorization, .authorization),
                     (.authorized, .authorized):
                    return true
                    
                default:
                    return false
            }
        }
    }
}
