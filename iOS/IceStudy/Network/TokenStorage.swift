import Foundation
import Security

enum TokenStorage {
    // MARK: - Keychain Keys
    private static let accessTokenKey = "icestudy_access_token"
    private static let refreshTokenKey = "icestudy_refresh_token"

    // MARK: - UserDefaults Keys (비민감 데이터)
    private static let userIdKey = "icestudy_user_id"
    private static let nicknameKey = "icestudy_nickname"
    private static let emailKey = "icestudy_email"

    // MARK: - Keychain 저장 토큰
    static var accessToken: String? {
        get { keychainRead(key: accessTokenKey) }
        set {
            if let value = newValue {
                keychainSave(key: accessTokenKey, value: value)
            } else {
                keychainDelete(key: accessTokenKey)
            }
        }
    }

    static var refreshToken: String? {
        get { keychainRead(key: refreshTokenKey) }
        set {
            if let value = newValue {
                keychainSave(key: refreshTokenKey, value: value)
            } else {
                keychainDelete(key: refreshTokenKey)
            }
        }
    }

    // MARK: - UserDefaults 저장 (비민감)
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

    // MARK: - Keychain Helpers
    private static func keychainSave(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        // 기존 항목 삭제 후 새로 추가
        keychainDelete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.silver.icestudy",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private static func keychainRead(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.silver.icestudy",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    private static func keychainDelete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: "com.silver.icestudy"
        ]
        SecItemDelete(query as CFDictionary)
    }
}
