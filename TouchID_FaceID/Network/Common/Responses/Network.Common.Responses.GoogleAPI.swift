import Foundation

// MARK: - Network.Common.Responses.SampleAPI
extension Network.Common.Responses {
    struct SampleAPI<T: Decodable>: Decodable {
        let data: T
        
        // MARK: Decodable
        init(from decoder: Decoder) throws {
            data = try .init(from: decoder)
        }
    }
}
