import AuthenticationServices
import CryptoKit
import Foundation

struct AuthService: Sendable {
    struct AuthResult: Sendable {
        let code: String
        let codeVerifier: String
    }

    static func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    static func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    @MainActor
    static func authorize() async throws -> AuthResult {
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)

        var components = URLComponents(url: AuthConfiguration.authorizationEndpoint, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: AuthConfiguration.clientID),
            URLQueryItem(name: "redirect_uri", value: AuthConfiguration.redirectURI),
            URLQueryItem(name: "scope", value: AuthConfiguration.scopes),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]

        let url = components.url!
        let contextProvider = AnchorProvider()

        let callbackURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            let session = ASWebAuthenticationSession(
                url: url,
                callback: .customScheme("oauth2appdemo")
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                }
            }
            session.presentationContextProvider = contextProvider
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }

        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw AuthError.missingAuthorizationCode
        }

        return AuthResult(code: code, codeVerifier: codeVerifier)
    }

    static func exchangeCodeForTokens(code: String, codeVerifier: String) async throws -> TokenResponse {
        var request = URLRequest(url: AuthConfiguration.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = [
            "grant_type": "authorization_code",
            "client_id": AuthConfiguration.clientID,
            "code": code,
            "redirect_uri": AuthConfiguration.redirectURI,
            "code_verifier": codeVerifier,
        ]
        request.httpBody = body
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.tokenExchangeFailed
        }

        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }
}

enum AuthError: LocalizedError {
    case missingAuthorizationCode
    case tokenExchangeFailed
    case tokenRefreshFailed

    var errorDescription: String? {
        switch self {
        case .missingAuthorizationCode: "No authorization code received"
        case .tokenExchangeFailed: "Failed to exchange code for tokens"
        case .tokenRefreshFailed: "Failed to refresh token"
        }
    }
}

private final class AnchorProvider: NSObject, ASWebAuthenticationPresentationContextProviding, @unchecked Sendable {
    @MainActor
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        else {
            return ASPresentationAnchor()
        }
        return window
    }
}
