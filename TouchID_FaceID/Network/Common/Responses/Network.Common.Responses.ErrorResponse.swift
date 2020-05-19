import Foundation

private typealias ErrorResponse = Network.Common.Responses.ErrorResponse

// MARK: - ErrorResponse
extension Network.Common.Responses {
    struct ErrorResponse {
        let message: String?
    }
}

// MARK: - LocalizedError
extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}

// MARK: - Decodable
extension ErrorResponse: Decodable {
    private enum CodingKeys: CodingKey {
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let message: String? = try? container.decode(.error)
        
        if let message = message {
            self.message = message
        } else {
            throw Network.Common.Error.modelMapping(nil)
        }
    }
}
