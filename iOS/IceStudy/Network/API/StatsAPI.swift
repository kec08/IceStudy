import Foundation
import Moya
internal import Alamofire

enum StatsAPI {
    case weekly(weekOffset: Int)
    case daily(date: String)
    case calendar(year: Int, month: Int)
    case profile
}

extension StatsAPI: TargetType {

    var baseURL: URL {
        URL(string: "https://icestudy-api-production.up.railway.app")!
    }

    var path: String {
        switch self {
        case .weekly:   "/api/stats/weekly"
        case .daily:    "/api/stats/daily"
        case .calendar: "/api/stats/calendar"
        case .profile:  "/api/stats/profile"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .weekly(weekOffset):
            .requestParameters(parameters: ["weekOffset": weekOffset], encoding: URLEncoding.queryString)
        case let .daily(date):
            .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
        case let .calendar(year, month):
            .requestParameters(parameters: ["year": year, "month": month], encoding: URLEncoding.queryString)
        case .profile:
            .requestPlain
        }
    }

    var headers: [String: String]? {
        var h: [String: String] = ["Accept": "application/json"]
        if let token = TokenStorage.accessToken {
            h["Authorization"] = "Bearer \(token)"
        }
        return h
    }
}
