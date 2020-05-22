import Foundation
import Combine

protocol AuthService {
    var isAuthorized: AnyPublisher<Bool, Never> { get }
    func signIn(login: String, password: String) -> AnyPublisher<Network.Common.Responses.AuthResponse, Network.Common.Error>
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
        userService.user
            .map { $0.status.token() != nil }
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
}
