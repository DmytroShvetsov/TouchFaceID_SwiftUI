import Foundation

// MARK: - TimeoutRequest
extension Network.Core.Plugins {
    final class TimeoutRequest {
        
    }
}

// MARK: - PluginType
extension Network.Core.Plugins.TimeoutRequest: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        let timeoutInterval = (target as? RequestTimeoutPresentable)?.requestTimeoutInterval ?? 20
        var request = request
        
        request.timeoutInterval = timeoutInterval
        
        return request
    }
}
