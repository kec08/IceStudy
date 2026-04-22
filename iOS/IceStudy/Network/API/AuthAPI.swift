import Foundation
import Moya
internal import Alamofire

enum AuthAPI {
    case login(email: String, password: String)
    case signup(email: String, password: String, nickname: String)
    case refresh(refreshToken: String)
}

extension AuthAPI: TargetType {

    var baseURL: URL {
        URL(string: "https://icestudy-api-production.up.railway.app")!
    }

    var path: String {
        switch self {
        case .login:    "/api/auth/login"
        case .signup:   "/api/auth/signup"
        case .refresh:  "/api/auth/refresh"
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
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
