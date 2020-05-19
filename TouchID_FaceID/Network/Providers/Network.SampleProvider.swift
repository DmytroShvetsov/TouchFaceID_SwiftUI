import Foundation
import Combine

private extension Network.SampleProvider {
    static func _request<T: Decodable, Scheduler: Combine.Scheduler>(_ target: Network.Common.SampleAPI, scheduler: Scheduler) -> AnyPublisher<T, Network.Common.Error> {
        Network.Core.DataProvider.shared.request(target, scheduler: scheduler)
    }
}

extension Network.SampleProvider {
    static func signIn(login: String, password: String, scheduler: DispatchQueue = .main) -> AnyPublisher<Network.Common.Responses.AuthResponse, Network.Common.Error> {
        _request(.signIn(request: .init(login: login, password: password)), scheduler: scheduler)
    }
}
