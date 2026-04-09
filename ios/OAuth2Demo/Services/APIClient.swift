import Foundation

struct APIClient: Sendable {
    let tokenManager: TokenManager

    func fetchMe() async throws -> User {
        let data = try await authenticatedRequest(path: "/api/me")
        return try JSONDecoder().decode(User.self, from: data)
    }

    private func authenticatedRequest(path: String) async throws -> Data {
        let token = try await tokenManager.validAccessToken()
        let url = AuthConfiguration.apiBaseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
