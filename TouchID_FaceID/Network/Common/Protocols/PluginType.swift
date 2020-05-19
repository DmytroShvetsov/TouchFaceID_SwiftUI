import Foundation

protocol PluginType {
    /// Called to modify a request before sending.
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest
    
    /// Called immediately before a request is sent over the network (or stubbed).
    func willSend(_ request: URLRequest, target: TargetType)
    
    /// Called after a response has been received, but before the Provider has invoked its completion handler.
    func didReceive(_ result: Result<Network.Common.Responses.Response, Network.Common.Error>, target: TargetType)
    
    /// Called to modify a result before completion.
    func process(_ result: Result<Network.Common.Responses.Response, Network.Common.Error>, target: TargetType) -> Result<Network.Common.Responses.Response, Network.Common.Error>
}

extension PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest { return request }
    func willSend(_ request: URLRequest, target: TargetType) {}
    func didReceive(_ result: Result<Network.Common.Responses.Response, Network.Common.Error>, target: TargetType) { }
    func process(_ result: Result<Network.Common.Responses.Response, Network.Common.Error>,
                 target: TargetType) -> Result<Network.Common.Responses.Response, Network.Common.Error> { return result }
}
