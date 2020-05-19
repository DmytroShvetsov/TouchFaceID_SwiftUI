import Foundation

// MARK: - curlString
extension URLRequest {
    var curlString: String {
        guard let url = url else { return "" }
        var baseCommand = "curl \(url.absoluteString)"
        
        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }
        
        var command = [baseCommand]
        
        if let method = httpMethod, method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }
        
        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }
        
        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }
        
        return command.joined(separator: " \\\n\t")
    }
}

// MARK: - query / encoding
extension URLRequest {
    func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape(value.boolValue ? "1" : "0")))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape(bool ? "1" : "0")))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}

// MARK: - encoded:encodable / encoded:parameters
extension URLRequest {
    @discardableResult
    mutating func encoded(encodable: Encodable, encoder: JSONEncoder = JSONEncoder.defaultEncoder()) throws -> URLRequest {
        do {
            let encodable = AnyCodable(encodable)
            httpBody = try encoder.encode(encodable)
            setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return self
        } catch {
            throw Network.Common.Error.encodableMapping(error)
        }
    }
    
    @discardableResult
    mutating func encoded(parameters: [String: Any]) throws -> URLRequest {
        do {
            if let method = Network.Common.Method(rawValue: httpMethod ?? "GET"), method == .get {
                guard let url = url else { throw Network.Common.Error.parameterEncoding }
                
                if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                    let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                    urlComponents.percentEncodedQuery = percentEncodedQuery
                    self.url = urlComponents.url
                }
            } else {
                setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                httpBody = query(parameters).data(using: .utf8, allowLossyConversion: false)
            }
        }
        
        return self
    }
}
