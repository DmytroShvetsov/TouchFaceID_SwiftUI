import Foundation

private typealias SessionDelegate = Network.Core.SessionDelegate

// MARK: - SessionDelegate
extension Network.Core {
    final class SessionDelegate: NSObject {
        override init() {
            super.init()
        }
    }
}

// MARK: - URLSessionDelegate
extension SessionDelegate: URLSessionDelegate {
    
}

// MARK: - URLSessionDataDelegate
extension SessionDelegate: URLSessionDataDelegate {
    
}
