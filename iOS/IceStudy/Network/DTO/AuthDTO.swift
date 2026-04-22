import Foundation

// MARK: - Request
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SignUpRequest: Encodable {
    let email: String
    let password: String
    let nickname: String
}

struct RefreshRequest: Encodable {
    let refreshToken: String
}

// MARK: - Response
struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let userId: Int
    let nickname: String
}

struct SignUpResponse: Decodable {
    let userId: Int
    let email: String
    let nickname: String
}
