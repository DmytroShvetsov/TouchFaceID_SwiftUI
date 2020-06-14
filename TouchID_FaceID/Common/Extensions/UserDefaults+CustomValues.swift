import Foundation
import Combine

extension UserDefaults {
    @UserDefault(.biometricAuthAllowed, defaultValue: false)
    static var biometricAuthAllowed: Bool
    
    static func publisher<T>(for key: Keys) -> AnyPublisher<T, Never> {
        NotificationCenter.default
            .publisher(for: .init(key.rawValue))
            .compactMap { $0.object as? T }
            .eraseToAnyPublisher()
    }
}

// MARK: - Keys
extension UserDefaults {
    enum Keys: String {
        case
            biometricAuthAllowed
    }
}

// MARK: - convenient
private extension UserDefault {
    init(_ key: UserDefaults.Keys, defaultValue: T) {
        self.init(key.rawValue, defaultValue: defaultValue)
    }
}

private extension UserDefaultCodable {
    init(_ key: UserDefaults.Keys, defaultValue: T) {
        self.init(key.rawValue, defaultValue: defaultValue)
    }
}

