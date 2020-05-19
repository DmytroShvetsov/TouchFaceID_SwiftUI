import Foundation

// MARK: - SampleAPI
extension Network.Common {
    enum SampleAPI {
        case
            signIn(request: Requests.SignIn)
    }
}

// MARK: - TargetType
extension Network.Common.SampleAPI: TargetType {
    var baseURL: URL { Common.Constants.network.sampleApiUrl }
    
    var path: String {
        switch self {
            case .signIn:
                return "auth"
        }
    }
    
    var method: Network.Common.Method {
        switch self {
            default:
                return .post
        }
    }
    
    var task: Network.Common.Task {
        switch self {
            case .signIn(let request as Encodable):
                return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String: String]? { nil }
}

// MARK: - RequestTimeoutPresentable
extension Network.Common.SampleAPI: RequestTimeoutPresentable {
    var requestTimeoutInterval: TimeInterval { 15 }
}
