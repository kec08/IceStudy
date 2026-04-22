import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: ErrorInfo?

    struct ErrorInfo: Decodable {
        let code: String
        let message: String
    }
}
