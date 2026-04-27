import Foundation
import Moya
internal import Alamofire

enum AuthAPI {
    case login(email: String, password: String)
    case signup(email: String, password: String, nickname: String)
    case refresh(refreshToken: String)
    case appleLogin(identityToken: String, nickname: String?, email: String?)
}

extension AuthAPI: TargetType {

    var baseURL: URL {
        URL(string: "http://13.125.255.219:8080")!
    }

    var path: String {
        switch self {
        case .login:      "/api/auth/login"
        case .signup:     "/api/auth/signup"
        case .refresh:    "/api/auth/refresh"
        case .appleLogin: "/api/auth/apple"
        }
    }

    var method: Moya.Method { .post }

    var task: Task {
        switch self {
        case let .login(email, password):
            .requestJSONEncodable(LoginRequest(email: email, password: password))
        case let .signup(email, password, nickname):
            .requestJSONEncodable(SignUpRequest(email: email, password: password, nickname: nickname))
        case let .refresh(refreshToken):
            .requestJSONEncodable(RefreshRequest(refreshToken: refreshToken))
        case let .appleLogin(identityToken, nickname, email):
            .requestJSONEncodable(AppleLoginRequest(identityToken: identityToken, nickname: nickname, email: email))
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
