import Foundation

// MARK: - clearStorage
extension UserDefaults {
    static func clearStorage() {
        guard let identifier = Bundle.main.bundleIdentifier,
              let keys = UserDefaults.standard.persistentDomain(forName: identifier)?.keys else { return }
        
        keys.forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }
}
