import AuthenticationServices
import Foundation
import Observation

@Observable
@MainActor
final class AuthViewModel {
    var isAuthenticated = false
    var isLoading = false
    var user: User?
    var errorMessage: String?

    let tokenManager = TokenManager()

    private var apiClient: APIClient {
        APIClient(tokenManager: tokenManager)
    }

    func checkSession() async {
        let hasTokens = await tokenManager.hasStoredTokens()
        guard hasTokens else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            user = try await apiClient.fetchMe()
            isAuthenticated = true
        } catch {
            await tokenManager.clearTokens()
        }
    }

    func login() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await AuthService.authorize()
            let tokens = try await AuthService.exchangeCodeForTokens(
                code: result.code,
                codeVerifier: result.codeVerifier
            )
            await tokenManager.storeTokens(tokens)
            user = try await apiClient.fetchMe()
            isAuthenticated = true
        } catch {
            if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                return
            }
            errorMessage = error.localizedDescription
        }
    }

    func logout() async {
        await tokenManager.clearTokens()
        user = nil
        isAuthenticated = false
        errorMessage = nil
    }
}
