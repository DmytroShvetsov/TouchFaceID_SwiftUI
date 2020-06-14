import Foundation
import Combine

protocol UserService {
    /// It is a current and last active user.
    var user: AnyPublisher<User, Never> { get }
    
    /// Updates current-user userInfo.
    func updateUserInfo(_ userInfo: User.Info)
    
    /// Changes an user status to inactive.
    func logout()
}

protocol UserServiceChangeable {
    func updateUser(login: String, status: User.Status)
}


final class UserServiceImpl {
    
}

// MARK: - UserService
extension UserServiceImpl: UserService {
    var user: AnyPublisher<User, Never> {
        Self.userPublisher
            .eraseToAnyPublisher()
    }
    
    func updateUserInfo(_ userInfo: User.Info) {
        Self.updateUserInfo(userInfo)
    }
    
    func logout() {
        Self.logout()
    }
}

// MARK: - UserServiceChangeable
extension UserServiceImpl: UserServiceChangeable {
    func updateUser(login: String, status: User.Status) {
        Self.updateUser(login: login, status: status)
    }
}


// MARK: - private cache
private extension UserServiceImpl {
    static let queue = DispatchQueue(label: "UserService.queue", qos: .default)
   
    @KeychainCodable("UserServiceImpl.user", defaultValue: .init(info: .init(), login: "", status: .unknown))
    static var _user: User
    
    static var user: User {
        get { _user }
        set {
            _user = newValue
            userPublisher.send(user)
        }
    }
    
    static let userPublisher = CurrentValueSubject<User, Never>.init(user)
    
    static func updateUserInfo(_ userInfo: User.Info) {
        queue.async {
            user.info = userInfo
        }
    }
    
    static func updateUser(login: String, status: User.Status) {
        queue.async {
            guard user.login != login else { return user.status = status }
            user = .init(info: .init(), login: login, status: status)
        }
    }
    
    static func logout() {
        queue.async {
            user.status = user.status.toggle()
        }
    }
}
