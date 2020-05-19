import Foundation

// MARK: - decode<T>
extension SingleValueDecodingContainer {
    func decode<T: Decodable>() throws -> T {
        return try decode(T.self)
    }
}

// MARK: - decode<T>:key & decodeIfPresent<T>:key
extension KeyedDecodingContainer {
    func decode<T: Decodable>(_ key: Key) throws -> T {
        return try self.decode(T.self, forKey: key)
    }
    
    func decodeIfPresent<T: Decodable>(_ key: Key) throws -> T? {
        return try self.decodeIfPresent(T.self, forKey: key)
    }
}
