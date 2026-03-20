import Foundation
import Score
import ScoreAuth

struct AuthController: Controller {
    var base: String { "/auth" }

    var routes: [Route] {
        [
            Route(method: .post, path: "magic-link", handler: sendMagicLink),
            Route(method: .get, path: "verify", handler: verifyMagicLink),
            Route(method: .post, path: "logout", handler: logout),
        ]
    }

    func sendMagicLink(_ ctx: RequestContext) async throws -> Response {
        guard let body = ctx.body,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
              let email = json["email"] as? String, !email.isEmpty
        else {
            return Response.json(
                Data(#"{"error":"email is required"}"#.utf8),
                status: .badRequest
            )
        }

        try await AuthHelper.shared.magicLinks.send(to: email)

        return Response.json(
            Data(#"{"ok":true,"message":"Magic link sent. Check your email."}"#.utf8)
        )
    }

    func verifyMagicLink(_ ctx: RequestContext) async throws -> Response {
        guard let token = ctx.queryParameters["token"], !token.isEmpty else {
            return Response.text("Missing token", status: .badRequest)
        }

        guard let email = AuthHelper.shared.magicLinks.verify(token: token) else {
            return Response.text("Invalid or expired token", status: .unauthorized)
        }

        let store = try LibrettoStore.persistent()
        let user: LibrettoUser
        if let existing = try await store.getUserByEmail(email) {
            user = existing
        } else {
            // Create a new user from the email
            let username = email.split(separator: "@").first.map(String.init) ?? email
            let newUser = LibrettoUser(username: username, displayName: username, email: email)
            try await store.saveUser(newUser)
            user = newUser
        }

        let session = Session(userId: user.id)
        try await AuthHelper.shared.sessions.save(session)

        // Redirect new users (no bio set) to settings, returning users to drafts
        let destination = user.bio == nil ? "/settings" : "/drafts"

        return Response(
            status: .seeOther,
            headers: [
                "location": destination,
                "set-cookie": "session=\(session.id); Path=/; HttpOnly; SameSite=Lax",
            ]
        )
    }

    func logout(_ ctx: RequestContext) async throws -> Response {
        if let sessionId = extractSessionId(from: ctx) {
            try await AuthHelper.shared.sessions.delete(sessionID: sessionId)
        }

        return Response(
            status: .seeOther,
            headers: [
                "location": "/",
                "set-cookie": "session=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0",
            ]
        )
    }

    // MARK: - Private

    private func extractSessionId(from ctx: RequestContext) -> String? {
        guard let cookieHeader = ctx.headers["cookie"] ?? ctx.headers["Cookie"] else {
            return nil
        }
        for part in cookieHeader.split(separator: ";") {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("session=") {
                return String(trimmed.dropFirst("session=".count))
            }
        }
        return nil
    }
}
