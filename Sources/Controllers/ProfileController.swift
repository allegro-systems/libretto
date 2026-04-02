import Foundation
import Score

// MARK: - Response Types

private struct ErrorResponse: Codable {
    let error: String
}

private struct SocialLinkResponse: Codable {
    let platform: String
    let url: String
}

private struct PublicProfileResponse: Codable {
    let username: String
    let displayName: String
    let bio: String?
    let avatarURL: String?
    let socialLinks: [SocialLinkResponse]
}

@Controller("/api/profile")
struct ProfileController {

    // MARK: - GET /api/profile (auth required)

    @Route(method: .get)
    func getMyProfile(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        return Response.json(data)
    }

    // MARK: - PUT /api/profile (auth required)

    @Route(method: .put)
    func updateMyProfile(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard var user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let body = ctx.body,
            let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any]
        else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "invalid body")), status: .badRequest)
        }

        if let displayName = json["displayName"] as? String, !displayName.isEmpty {
            user.displayName = displayName
        }
        if let bio = json["bio"] as? String {
            user.bio = bio.isEmpty ? nil : bio
        }
        if let username = json["username"] as? String, !username.isEmpty, username != user.username {
            // Check uniqueness
            if let existing = try await store.getUserByUsername(username), existing.id != user.id {
                return Response.json(try JSONEncoder().encode(ErrorResponse(error: "username already taken")), status: .conflict)
            }
            user.username = username
        }
        if let email = json["email"] as? String, !email.isEmpty {
            user.email = email
        }
        if let rawLinks = json["socialLinks"] as? [[String: String]] {
            user.socialLinks = rawLinks.compactMap { dict -> LibrettoUser.SocialLink? in
                guard let platform = dict["platform"], let url = dict["url"],
                    !platform.isEmpty, !url.isEmpty
                else { return nil }
                return LibrettoUser.SocialLink(platform: platform, url: url)
            }
        }
        user.updatedAt = Date()
        try await store.saveUser(user)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        return Response.json(data)
    }

    // MARK: - GET /api/profile/:username (public, no auth)

    @Route(":username", method: .get)
    func getPublicProfile(_ ctx: RequestContext) async throws -> Response {
        guard let username = ctx.pathParameters["username"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing username")), status: .badRequest)
        }
        let store = try LibrettoStore.persistent()
        guard let user = try await store.getUserByUsername(username) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "not found")), status: .notFound)
        }
        // Return a safe public subset
        let publicProfile = PublicProfileResponse(
            username: user.username,
            displayName: user.displayName,
            bio: user.bio,
            avatarURL: user.avatarURL,
            socialLinks: user.socialLinks.map { SocialLinkResponse(platform: $0.platform, url: $0.url) }
        )
        let data = try JSONEncoder().encode(publicProfile)
        return Response.json(data)
    }
}
