import Foundation

// MARK: - Request
struct SessionCreateRequest: Encodable {
    let cupSize: String
    let totalDuration: Int
}

struct SessionUpdateRequest: Encodable {
    let elapsedTime: Int
    let waterMl: Double
}

// MARK: - Response
struct SessionResponse: Decodable {
    let sessionId: Int
    let cupSize: String?
    let totalDuration: Int?
    let isCompleted: Bool?
    let elapsedTime: Int?
    let waterMl: Double?
    let createdAt: String?
}
