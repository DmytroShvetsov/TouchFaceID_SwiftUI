import Foundation

struct AppError: LocalizedError {
    var errorDescription: String?
    init(error: String?) { errorDescription = error }
}
