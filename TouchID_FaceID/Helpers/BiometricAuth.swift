import Foundation
import LocalAuthentication
import Combine

final class BiometricAuth {
    private let context = LAContext()
    private let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
    private lazy var authReason = "Logging in with Touch ID"
    
    func biometricType() -> BiometricType {
        _ = canEvaluatePolicy()
        
        switch context.biometryType {
            case .touchID:
                return .touchID
            
            case .faceID:
                return .faceID
            
            default:
                return .none
        }
    }
    
    func canEvaluatePolicy() -> Bool {
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticate() -> AnyPublisher<Void, Error> {
        guard canEvaluatePolicy() else {
             return Fail(error: AppError(error: "Biometric auth is not available."))
                .eraseToAnyPublisher()
        }
        
        let publisher = PassthroughSubject<Void, Error>()
        
        context.evaluatePolicy(policy, localizedReason: authReason) { success, error in
            guard !success else { return publisher.send(Void()) }
            
            let errorMessage: String
            
            switch error {
                case LAError.authenticationFailed?:
                    errorMessage = "There was a problem verifying your identity."
                case LAError.userCancel?:
                    errorMessage = "You pressed cancel."
                case LAError.userFallback?:
                    errorMessage = "You pressed password."
                case LAError.biometryNotAvailable?:
                    errorMessage = "Face ID/Touch ID is not available."
                case LAError.biometryNotEnrolled?:
                    errorMessage = "Face ID/Touch ID is not set up."
                case LAError.biometryLockout?:
                    errorMessage = "Face ID/Touch ID is locked."
                default:
                    errorMessage = "Face ID/Touch ID may not be configured"
            }
            
            publisher.send(completion: .failure(AppError(error: errorMessage)))
        }
        
        return publisher
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - BiometricType
extension BiometricAuth {
    enum BiometricType {
        case none, touchID, faceID
        
        var label: String? {
            switch self {
                case .faceID:
                    return "Face ID"
                
                case .touchID:
                    return "Touch ID"
                
                default:
                    return nil
            }
        }
    }
}
