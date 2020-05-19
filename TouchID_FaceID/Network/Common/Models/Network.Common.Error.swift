import Foundation

extension Network.Common {
    enum Error: Swift.Error {
        case
            requestMapping(Swift.Error),
            encodableMapping(Swift.Error),
            parameterEncoding,
            underlying(Swift.Error, Network.Common.Responses.Response?),
            jsonMapping(Network.Common.Responses.Response),
            modelMapping(Network.Common.Responses.Response?),
            custom(error: Swift.Error),
            statusCode(Int, Swift.Error?)
    }
}

// MARK: - Depending on error type, returns a `Response` object.
extension Network.Common.Error {
    var response: Network.Common.Responses.Response? {
        switch self {
            case .underlying(_, let response),
                 .modelMapping(let response):
                return response
            case .jsonMapping(let response):
                return response
            default:
                return nil
        }
    }
}

// MARK: - LocalizedError
extension Network.Common.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
            case .requestMapping:
                return "requestMapping"
            case .encodableMapping:
                return "encodableMapping"
            case .parameterEncoding:
                return "parameterEncoding"
            case .underlying(let error, _),
                 .custom(let error):
                return error.localizedDescription
            case .jsonMapping:
                return "jsonMapping"
            case .modelMapping:
                return "modelMapping"
            case .statusCode(let statusCode, let error):
                if statusCode == 401 {
                    return "statusCode == 401"
                } else if statusCode == 404 {
                    return "statusCode == 404"
                } else if let error = error {
                    return error.localizedDescription
                } else {
                    return "internal_error"
                }
        }
    }
}
