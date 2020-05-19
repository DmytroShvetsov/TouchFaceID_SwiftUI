import Foundation

protocol TargetType {
    /// The target's base `URL`.
    var baseURL: URL { get }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    
    /// The HTTP method used in the request.
    var method: Network.Common.Method { get }

    /// The type of HTTP task to be performed.
    var task: Network.Common.Task { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }
}
