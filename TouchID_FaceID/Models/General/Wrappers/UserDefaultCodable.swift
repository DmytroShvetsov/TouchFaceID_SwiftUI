import Foundation

@propertyWrapper
struct UserDefaultCodable<T: Codable> {
    let key: String
    let defaultValue: T
    
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(_ key: String, defaultValue: T,
         encoder: JSONEncoder = .defaultEncoder(),
         decoder: JSONDecoder = .defaultDecoder()) {
        
        self.key = key
        self.defaultValue = defaultValue
        self.encoder = encoder
        self.decoder = decoder
    }

    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return defaultValue }
            let value = try? decoder.decode(T.self, from: data)
            assert(value != nil, "\nclass: \(Self.self), \nkey: \(key)\n")
            return value ?? defaultValue
        }
        set {
            let data = try? encoder.encode(newValue)
            assert(data != nil, "\nclass: \(Self.self), \nkey: \(key), \nvalue: \(newValue)\n")
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
