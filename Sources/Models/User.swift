import Foundation

struct LibrettoUser: Codable, Sendable {
    let id: String
    var username: String
    var displayName: String
    var email: String
    var bio: String?
    var avatarURL: String?
    var socialLinks: [SocialLink]
    var plan: Plan
    let createdAt: Date
    var updatedAt: Date

    struct SocialLink: Codable, Sendable {
        let platform: String  // "github", "twitter", "website"
        let url: String
    }

    init(id: String = UUID().uuidString, username: String, displayName: String, email: String, plan: Plan = .free) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.socialLinks = []
        self.plan = plan
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
