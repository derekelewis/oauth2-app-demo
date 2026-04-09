import Foundation

struct User: Codable, Sendable {
    let sub: String
    let email: String?
    let preferredUsername: String?
    let name: String?
    let givenName: String?
    let familyName: String?
    let emailVerified: Bool?

    enum CodingKeys: String, CodingKey {
        case sub
        case email
        case preferredUsername = "preferred_username"
        case name
        case givenName = "given_name"
        case familyName = "family_name"
        case emailVerified = "email_verified"
    }
}
