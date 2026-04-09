import Foundation

actor TokenManager {
    private let keychain = KeychainService()
    private var refreshTask: Task<String, Error>?

    func storeTokens(_ response: TokenResponse) {
        keychain.save(key: .accessToken, value: response.accessToken)
        if let refreshToken = response.refreshToken {
            keychain.save(key: .refreshToken, value: refreshToken)
        }
        if let idToken = response.idToken {
            keychain.save(key: .idToken, value: idToken)
        }
    }

    func validAccessToken() async throws -> String {
        guard let accessToken = keychain.load(key: .accessToken) else {
            throw AuthError.tokenRefreshFailed
        }

        if !isTokenExpired(accessToken) {
            return accessToken
        }

        return try await refreshAccessToken()
    }

    func hasStoredTokens() -> Bool {
        keychain.load(key: .accessToken) != nil
    }

    func clearTokens() {
        keychain.deleteAll()
        refreshTask?.cancel()
        refreshTask = nil
    }

    private func refreshAccessToken() async throws -> String {
        if let existingTask = refreshTask {
            return try await existingTask.value
        }

        let task = Task<String, Error> {
            defer { refreshTask = nil }

            guard let refreshToken = keychain.load(key: .refreshToken) else {
                throw AuthError.tokenRefreshFailed
            }

            var request = URLRequest(url: AuthConfiguration.tokenEndpoint)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let body = [
                "grant_type": "refresh_token",
                "client_id": AuthConfiguration.clientID,
                "refresh_token": refreshToken,
            ]
            request.httpBody = body
                .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
                .joined(separator: "&")
                .data(using: .utf8)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw AuthError.tokenRefreshFailed
            }

            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            storeTokens(tokenResponse)
            return tokenResponse.accessToken
        }

        refreshTask = task
        return try await task.value
    }

    private func isTokenExpired(_ token: String) -> Bool {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { return true }

        var payload = String(parts[1])
        // Pad base64 string
        let remainder = payload.count % 4
        if remainder > 0 {
            payload += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return true
        }

        // Consider expired 30 seconds before actual expiry
        return Date().timeIntervalSince1970 >= (exp - 30)
    }
}
