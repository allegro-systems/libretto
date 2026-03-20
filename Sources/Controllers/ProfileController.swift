import Foundation
import Score

struct ProfileController: Controller {
    var base: String { "/api/profile" }

    var routes: [Route] {
        [
            Route(method: .get, handler: getMyProfile),
            Route(method: .put, handler: updateMyProfile),
            Route(method: .get, path: ":username", handler: getPublicProfile),
        ]
    }

    // MARK: - GET /api/profile (auth required)

    func getMyProfile(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        return Response.json(data)
    }

    // MARK: - PUT /api/profile (auth required)

    func updateMyProfile(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard var user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let body = ctx.body,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any]
        else {
            return Response.json(Data(#"{"error":"invalid body"}"#.utf8), status: .badRequest)
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
                return Response.json(Data(#"{"error":"username already taken"}"#.utf8), status: .conflict)
            }
            user.username = username
        }
        if let email = json["email"] as? String, !email.isEmpty {
            user.email = email
        }
        if let rawLinks = json["socialLinks"] as? [[String: String]] {
            user.socialLinks = rawLinks.compactMap { dict -> LibrettoUser.SocialLink? in
                guard let platform = dict["platform"], let url = dict["url"],
                      !platform.isEmpty, !url.isEmpty else { return nil }
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

    func getPublicProfile(_ ctx: RequestContext) async throws -> Response {
        guard let username = ctx.pathParameters["username"] else {
            return Response.json(Data(#"{"error":"missing username"}"#.utf8), status: .badRequest)
        }
        let store = try LibrettoStore.persistent()
        guard let user = try await store.getUserByUsername(username) else {
            return Response.json(Data(#"{"error":"not found"}"#.utf8), status: .notFound)
        }
        // Return a safe public subset
        let publicProfile: [String: Any] = [
            "username": user.username,
            "displayName": user.displayName,
            "bio": user.bio as Any,
            "avatarURL": user.avatarURL as Any,
            "socialLinks": user.socialLinks.map { ["platform": $0.platform, "url": $0.url] },
        ]
        let data = try JSONSerialization.data(withJSONObject: publicProfile)
        return Response.json(data)
    }
}
