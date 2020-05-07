import Foundation

final class AuthProvider: ObservableObject {
    @Published private(set) var isAuthorized: Bool
    
    init() {
        isAuthorized = false
    }
}
