import Foundation

enum TokenStorage {
    private static let accessTokenKey = "icestudy_access_token"
    private static let refreshTokenKey = "icestudy_refresh_token"
    private static let userIdKey = "icestudy_user_id"
    private static let nicknameKey = "icestudy_nickname"
    private static let emailKey = "icestudy_email"

    static var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: accessTokenKey) }
    }

    static var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: refreshTokenKey) }
    }

    static var userId: Int? {
        get {
            let val = UserDefaults.standard.integer(forKey: userIdKey)
            return val == 0 ? nil : val
        }
        set { UserDefaults.standard.set(newValue, forKey: userIdKey) }
    }

    static var nickname: String? {
        get { UserDefaults.standard.string(forKey: nicknameKey) }
        set { UserDefaults.standard.set(newValue, forKey: nicknameKey) }
    }

    static var email: String? {
        get { UserDefaults.standard.string(forKey: emailKey) }
        set { UserDefaults.standard.set(newValue, forKey: emailKey) }
    }

    static var isLoggedIn: Bool {
        accessToken != nil && refreshToken != nil
    }

    static func save(from token: TokenResponse, email: String? = nil) {
        accessToken = token.accessToken
        refreshToken = token.refreshToken
        userId = token.userId
        nickname = token.nickname
        if let email { self.email = email }
        else if let tokenEmail = token.email { self.email = tokenEmail }
    }

    static func clear() {
        accessToken = nil
        refreshToken = nil
        userId = nil
        nickname = nil
        email = nil
    }
}
