import Foundation

// MARK: - Parsers
extension Network.Common {
    enum Parsers {
        static func parseResponse<T: Decodable>(_ response: Responses.Response) throws -> T {
            do {
                let model = try JSONDecoder.defaultDecoder().decode(T.self, from: response.data)
                return model
            } catch {
                throw customError(for: response)
            }
        }
    }
}

// MARK: - internal logic
private extension Network.Common.Parsers {
    static func customError(for response: Network.Common.Responses.Response) -> Network.Common.Error {
        let error: Error? = try? JSONDecoder.defaultDecoder().decode(Network.Common.Responses.ErrorResponse.self, from: response.data)
        
        switch response.statusCode {
            case 200:
                if let error = error { return .custom(error: error) }
                return .modelMapping(response)
            
            case 401, 404:
                return .statusCode(response.statusCode, error)
            
            default:
                return .statusCode(response.statusCode, error)
        }
    }
}
