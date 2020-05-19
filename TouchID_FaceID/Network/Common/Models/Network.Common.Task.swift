import Foundation

// MARK: - Task
extension Network.Common {
    /// Represents an HTTP task.
    enum Task {
        /// A request with no additional data.
        case requestPlain
        
        /// A request body set with `Encodable` type
        case requestJSONEncodable(Encodable)
        
        /// A requests body set with encoded parameters.
        case requestParameters(parameters: [String: Any])
    }
}
