import Foundation

// MARK: - AuthResponse
extension Network.Common.Responses {
    enum AuthResponse: Decodable {
        case
            success(token: String),
            failed(reason: Error)
        
        // MARK: Decodable
        private enum CodingKeys: CodingKey {
            case token, error
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            do {
                let token: String = try container.decode(.token)
                self = .success(token: token)
            } catch {
                let reason: String = try container.decode(.error)
                self = .failed(reason: AppError(error: reason))
            }
        }
    }
}
