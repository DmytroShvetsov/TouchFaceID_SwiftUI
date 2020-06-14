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
            unknown,
            active(token: String),
            inactive(token: String)
            
        func toggle() -> Status {
            switch self {
                case .active(let token):
                    return .inactive(token: token)
                
                case .inactive(let token):
                    return .active(token: token)
                
                case .unknown:
                    return self
            }
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
                
                case .inactive(let token):
                    try container.encode("inactive", forKey: .key)
                    try container.encode(token, forKey: .data)
                
                case .unknown:
                    try container.encode("unknown", forKey: .key)
            }
        }
           
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let key: String = try container.decode(.key)
            
            switch key {
                case "active":
                    guard let token: String = try? container.decode(.data) else { fallthrough }
                    self = .active(token: token)
                
                case "inactive":
                    guard let token: String = try? container.decode(.data) else { fallthrough }
                    self = .inactive(token: token)
                
                case "unknown":
                    self = .unknown
                    
                default:
                    throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.key], debugDescription: "error"))
            }
        }
    }
}
