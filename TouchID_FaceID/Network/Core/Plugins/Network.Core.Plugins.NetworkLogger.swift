import Foundation

// MARK: - NetworkLogger
extension Network.Core.Plugins {
    final class NetworkLogger {
        
    }
}

// MARK: - PluginType
extension Network.Core.Plugins.NetworkLogger: PluginType {
    func willSend(_ request: URLRequest, target: TargetType) {
        print("------Request------")
        print("Method: \(target.method.rawValue)")
        print("URL: \(request.url?.absoluteString ?? "")")
        print("HTTP Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Task: \(target.task)")
        if BuildEnvironment.current != .release, let body = request.httpBody {
            if let bodyJson = try? JSONSerialization.jsonObject(with: body, options: []) {
                print("Body: \(bodyJson)")
            } else if let bodyString = String.init(data: body, encoding: .utf8) {
                print("Body: \(bodyString)")
            }
        }
        print("------END------")
    }
    
    func didReceive(_ result: Result<Network.Common.Responses.Response, Network.Common.Error>, target: TargetType) {
        defer { print("------END------") }
        print("------Response------")
        
        switch result {
            case let .success(response):
                print("URL: \(response.request?.url?.absoluteString ?? "")")
                print("Code: \(response.statusCode)")
                
                //Log only bad status code response data
                if response.statusCode >= 300 {
                    logResponse(response: response)
                }
            
            case let .failure(error):
                print("ERROR: \(error.localizedDescription)")
                guard let response = error.response else { return }
                logResponse(response: response)
        }
    }
}

private extension Network.Core.Plugins.NetworkLogger {
    private func logResponse(response: Network.Common.Responses.Response) {
        guard let json = try? response.mapJSON(), let jsonDic = json as? [String: Any] else {
            return print("JSON: Can't decode json")
        }
        print("JSON: \(jsonDic)")
        print("cURL: \(response.request?.curlString ?? "error")")
    }
}
