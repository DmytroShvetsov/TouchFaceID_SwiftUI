import Foundation
import Combine

private typealias DataProvider = Network.Core.DataProvider

// MARK: - DataProvider
extension Network.Core {
    final class DataProvider {
        static let shared: DataProvider = DataProvider()
        
        private let session: URLSession
        // swiftlint:disable:next weak_delegate
        private let delegate: SessionDelegate
        private let plugins: [PluginType]
        
        private init() {
            plugins = [Network.Core.Plugins.TimeoutRequest(),
                       Network.Core.Plugins.NetworkActivity(),
                       Network.Core.Plugins.NetworkLogger()]
            delegate = .init()
            session = .init(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)
            session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        }
    }
}

// MARK: - Requests
extension DataProvider {
    func request<Target: TargetType, T: Decodable, Scheduler: Combine.Scheduler>(_ target: Target, scheduler: Scheduler) -> AnyPublisher<T, Network.Common.Error> {
        request(target)
            .tryMap(Network.Common.Parsers.parseResponse)
            .mapError(Self.mapError)
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func request<Target: TargetType>(_ target: Target) -> AnyPublisher<Network.Common.Responses.Response, Network.Common.Error> {
        CurrentValueSubject<TargetType, Network.Common.Error>(target)
            .tryMap(Self.buildRequest)
            .map {
                // Allow plugins to modify a request
                self.plugins.reduce($0) { $1.prepare($0, target: target) } 
            }
            .handleEvents(receiveOutput: { request in
                // Give plugins the chance to alter the outgoing request
                self.plugins.forEach { $0.willSend(request, target: target) }
            })
            .flatMap { request in
                self.session.dataTaskPublisher(for: request)
                    .map { (request, $0.response, $0.data) }
                    .mapError { $0 as Error }
                
        }
        .tryMap(Self.parseResponse)
        .mapError(Self.mapError)
        .handleEvents(receiveOutput: { response in
            // Inform all plugins about the response
            self.plugins.forEach { $0.didReceive(.success(response), target: target) }
        }, receiveCompletion: {
            // Inform all plugins about the response
            guard case .failure(let error) = $0 else { return }
            self.plugins.forEach { $0.didReceive(.failure(error), target: target) }
        })
        .tryMap {
            // Allow plugins to modify a response
            try self.plugins.reduce(.success($0)) { $1.process($0, target: target) }.get()
        }
        .mapError(Self.mapError)
        .tryCatch { error -> Just<Network.Common.Responses.Response> in
            // Allow plugins to modify response
            let response = try self.plugins.reduce(.failure(error)) { $1.process($0, target: target) }.get()
            return Just(response)
        }
        .mapError(Self.mapError)
        .eraseToAnyPublisher()
    }
}

// MARK: - internal logic
private extension DataProvider {
    static func buildRequest(for target: TargetType) throws -> URLRequest {
        let url: URL
        
        if target.path.isEmpty {
            url = target.baseURL
        } else {
            url = target.baseURL.appendingPathComponent(target.path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        
        switch target.task {
            case .requestPlain:
                return request
            case .requestJSONEncodable(let encodable):
                return try request.encoded(encodable: encodable)
            case .requestParameters(let parameters):
                return try request.encoded(parameters: parameters)
        }
    }
    
    static func parseResponse(request: URLRequest, response: URLResponse, data: Data) throws -> Network.Common.Responses.Response {
        guard let response = response as? HTTPURLResponse else {
            throw Network.Common.Error.underlying(NSError(domain: NSURLErrorDomain,
                                                          code: NSURLErrorUnknown,
                                                          userInfo: nil),
                                                  nil)
        }
        
        return Network.Common.Responses.Response(statusCode: response.statusCode,
                                                 data: data,
                                                 request: request,
                                                 response: response)
    }
    
    static func mapError(_ error: Error) -> Network.Common.Error {
        guard let _error = error as? Network.Common.Error else {
            return Network.Common.Error.underlying(error, nil)
        }
        
        return _error
    }
}
