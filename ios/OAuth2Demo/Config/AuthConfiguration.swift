import Foundation

enum AuthConfiguration {
    #if targetEnvironment(simulator)
    static let defaultKeycloakHost = "localhost"
    static let defaultAPIHost = "localhost"
    #else
    static let defaultKeycloakHost = "localhost"
    static let defaultAPIHost = "localhost"
    #endif

    static var keycloakHost: String {
        UserDefaults.standard.string(forKey: "keycloak_host") ?? defaultKeycloakHost
    }

    static var apiHost: String {
        UserDefaults.standard.string(forKey: "api_host") ?? defaultAPIHost
    }

    static let keycloakPort = 8080
    static let apiPort = 8000
    static let realm = "oauth2-demo"
    static let clientID = "oauth2-demo-app"
    static let redirectURI = "oauth2appdemo://callback"
    static let scopes = "openid profile email"

    static var keycloakBaseURL: URL {
        URL(string: "http://\(keycloakHost):\(keycloakPort)")!
    }

    static var apiBaseURL: URL {
        URL(string: "http://\(apiHost):\(apiPort)")!
    }

    static var authorizationEndpoint: URL {
        keycloakBaseURL
            .appendingPathComponent("realms/\(realm)/protocol/openid-connect/auth")
    }

    static var tokenEndpoint: URL {
        keycloakBaseURL
            .appendingPathComponent("realms/\(realm)/protocol/openid-connect/token")
    }

    static var logoutEndpoint: URL {
        keycloakBaseURL
            .appendingPathComponent("realms/\(realm)/protocol/openid-connect/logout")
    }
}
