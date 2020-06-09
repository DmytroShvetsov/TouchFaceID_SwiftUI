import Foundation

enum ServicesFactory {
    private static let lock = NSRecursiveLock()
    
    // ApplicationService
    static func applicationService() -> ApplicationService {
        ApplicationServiceImpl()
    }
    
    // AuthService
    private static var _authService: AuthService!
    static func authService() -> AuthService {
        var service: AuthService!
        
        lock.lock()
            if _authService == nil {
                let userService = UserServiceImpl()
                _authService = AuthServiceImpl(userService: userService)
            }
            service = _authService
        lock.unlock()
        
        return service
    }
    
    // UserService
    private static var _userService: UserService!
    static func userService() -> UserService {
        var service: UserService!
        
        lock.lock()
            if _userService == nil {
                _userService = UserServiceImpl()
            }
            service = _userService
        lock.unlock()
        
        return service
    }
}
