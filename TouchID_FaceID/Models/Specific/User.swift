import Foundation

struct User {
    var info: Info
    var login: String
    var status: Status
}

// MARK: - :Codable
extension User: Codable {}

// MARK: - User.Info
extension User {
    struct Info: Codable {
        var name: String?
    }
}

// MARK: - User.Status
extension User {
    enum Status: Codable {
        case
            active(token: String),
            inactive

        func token() -> String? {
            guard case let .active(token) = self else { return nil }
            return token
        }
        
        // Codable
        private enum CodingKeys: CodingKey {
            case key, data
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
                case .active(let token):
                    try container.encode("active", forKey: .key)
                    try container.encode(token, forKey: .data)
                
                case .inactive:
                    try container.encode("inactive", forKey: .key)
            }
        }
           
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let key: String = try container.decode(.key)
            
            switch key {
                case "inactive":
                    self = .inactive
                
                case "active":
                    guard let token: String = try? container.decode(.data) else { fallthrough }
                    self = .active(token: token)
                    
                default:
                    throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.key], debugDescription: "error"))
            }
        }
    }
}
