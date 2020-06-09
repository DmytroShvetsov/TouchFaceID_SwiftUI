import Foundation

@propertyWrapper
struct KeychainCodable<T: Codable> {
    let defaultValue: T
    
    private let keychainItem: KeychainItem

    init(_ key: String,
         containerKey: String = "KeychainCodable",
         defaultValue: T,
         encoder: JSONEncoder = .defaultEncoder(),
         decoder: JSONDecoder = .defaultDecoder()) {
        
        self.defaultValue = defaultValue
        keychainItem = .init(service: containerKey, account: key, encoder: encoder, decoder: decoder)
    }

    var wrappedValue: T {
        get {
            do {
                let value: T = try keychainItem.readItem()
                return value
            } catch KeychainItem.KeychainError.noItem {
                return defaultValue
            } catch {
                assertionFailure("\nclass: \(Self.self), \nservice: \(keychainItem.service), \naccount: \(keychainItem.account)\n")
                return defaultValue
            }
        }
        
        set {
            do {
                try keychainItem.saveItem(newValue)
            } catch {
                assertionFailure("\nclass: \(Self.self), \nservice: \(keychainItem.service), \naccount: \(keychainItem.account), \nvalue: \(newValue)\n")
            }
        }
    }
}
