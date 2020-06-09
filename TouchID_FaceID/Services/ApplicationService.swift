import Foundation
import Combine

protocol ApplicationService {
    func didFinishLaunching()
    func applicationWillTerminate()
}


final class ApplicationServiceImpl {
    @UserDefault("ApplicationServiceImpl.appLaunchCount", defaultValue: 0)
    private var appLaunchCount: Int
    
    init() {}
}

private extension ApplicationServiceImpl {
    func clearStoragesIfNeeded() {
        if appLaunchCount == 0 {
            clearStorages()
        }
        
        appLaunchCount += 1
    }
    
    func clearStorages() {
        KeychainItem.deleteAll()
    }
}

// MARK: - ApplicationService
extension ApplicationServiceImpl: ApplicationService {
    func didFinishLaunching() {
        Self.startProgram()
        clearStoragesIfNeeded()
    }
    
    func applicationWillTerminate() {}
}

// MARK: - startProgram
private extension ApplicationServiceImpl {
    static let __once: () = {}()
    
    static func startProgram() {
        _ = __once
    }
}
