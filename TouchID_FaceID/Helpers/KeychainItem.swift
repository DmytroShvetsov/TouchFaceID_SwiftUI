import Foundation

struct KeychainItem {
    let service: String
    private(set) var account: String
    let accessGroup: String?
    
    private var encoder: () -> JSONEncoder
    private var decoder: () -> JSONDecoder

    init(service: String, account: String, accessGroup: String? = nil,
         encoder: @autoclosure @escaping () -> JSONEncoder = .defaultEncoder(),
         decoder: @autoclosure @escaping () -> JSONDecoder = .defaultDecoder()) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
        self.encoder = encoder
        self.decoder = decoder
    }
    
    // MARK: Keychain access
    func readItem<T: Decodable>() throws -> T {
        var query = Self.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else { throw KeychainError.noItem }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = queryResult as? [String : AnyObject],
              let passwordData = existingItem[kSecValueData as String] as? Data
        else {
            throw KeychainError.unexpectedItemData
        }
        
        return try decoder().decode(T.self, from: passwordData)
    }
    
    func saveItem<T: Codable>(_ item: T) throws {
        let encodedItem = try encoder().encode(item)
        
        do {
            let _: T = try readItem()

            var attributesToUpdate: [String: AnyObject] = [:]
            attributesToUpdate[kSecValueData as String] = encodedItem as AnyObject?

            let query = Self.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        } catch KeychainError.noItem {
            var newItem = Self.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedItem as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    func deleteItem() throws {
        let query = Self.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
}

// MARK: - open api
extension KeychainItem {
    static func deleteAll() {
        let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }
}

// MARK: - Convenience
private extension KeychainItem {
    static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        var query: [String: AnyObject] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}

// MARK: KeychainError
extension KeychainItem {
    enum KeychainError: Error {
        case
            noItem,
            unexpectedItemData,
            unhandledError(status: OSStatus)
    }
}
