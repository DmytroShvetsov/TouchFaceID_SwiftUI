import Foundation

// MARK: - Response
extension Network.Common.Responses {
    final class Response: CustomDebugStringConvertible, Equatable {
        let statusCode: Int
        
        /// The response data.
        let data: Data
        
        /// The original URLRequest for the response.
        let request: URLRequest?
        
        /// The HTTPURLResponse object.
        let response: HTTPURLResponse?
        
        init(statusCode: Int, data: Data, request: URLRequest? = nil, response: HTTPURLResponse? = nil) {
            self.statusCode = statusCode
            self.data = data
            self.request = request
            self.response = response
        }
        
        /// A text description of the `Response`.
        var description: String {
            return "Status Code: \(statusCode), Data Length: \(data.count)"
        }
        
        /// A text description of the `Response`. Suitable for debugging.
        var debugDescription: String {
            return description
        }
        
        static func == (lhs: Response, rhs: Response) -> Bool {
            return lhs.statusCode == rhs.statusCode
                && lhs.data == rhs.data
                && lhs.response == rhs.response
        }
    }
}

// MARK: - mapJSON
extension Network.Common.Responses.Response {
    func mapJSON(failsOnEmptyData: Bool = true) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            if data.count < 1 && !failsOnEmptyData {
                return NSNull()
            }
            throw Network.Common.Error.jsonMapping(self)
        }
    }
}
