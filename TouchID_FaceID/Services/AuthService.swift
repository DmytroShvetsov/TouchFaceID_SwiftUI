import Foundation
import Combine

protocol AuthService {
    var isAuthorized: AnyPublisher<Bool, Never> { get }
    func signIn(login: String, password: String) -> AnyPublisher<Network.Common.Responses.AuthResponse, Network.Common.Error>
    func signInViaBiometricAuth() -> AnyPublisher<Void, AppError>
}


final class AuthServiceImpl {
    private let userService: UserService & UserServiceChangeable
    
    init(userService: UserService & UserServiceChangeable) {
        self.userService = userService
    }
}

// MARK: - AuthService
extension AuthServiceImpl: AuthService {
    var isAuthorized: AnyPublisher<Bool, Never> {
        userService.user.map {
            guard case .active = $0.status else { return false }
            return true
        }
        .eraseToAnyPublisher()
    }
    
    func signIn(login: String, password: String) -> AnyPublisher<Network.Common.Responses.AuthResponse, Network.Common.Error> {
        Network.SampleProvider.signIn(login: login,
                                      password: password,
                                      scheduler: .main)
            .delay(for: .seconds(1), scheduler: DispatchQueue.main) // MARK: - for showcase purposes;
            .tryCatch { _ in Just(Network.Common.Responses.AuthResponse.success(token: "token"))} // MARK: - for showcase purposes;
            .mapError { $0 as! Network.Common.Error } // MARK: - for showcase purposes;
            .handleEvents(receiveOutput: {
                switch $0 {
                    case .success(let token):
                        self.userService.updateUser(login: login, status: .active(token: token))
                        
                    default:
                        break
                }
            })
            .eraseToAnyPublisher()
    }
    
    func signInViaBiometricAuth() -> AnyPublisher<Void, AppError> {
        BiometricAuth().authenticate()
            .flatMap {
                self.userService.user
                    .mapError { _ in .init(error: "") }
        }
        .tryMap { user -> (String, User.Status) in
            switch user.status {
                case .inactive:
                    return (user.login, user.status.toggle())
                case .active:
                    return (user.login, user.status)
                case .unknown:
                    assertionFailure("Shouldn't ever get here.e")
                    throw AppError(error: "Please try again.")
            }
        }
        .mapError { $0 as! AppError }
        .handleEvents(receiveOutput: {
            self.userService.updateUser(login: $0, status: $1)
        })
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }
}
