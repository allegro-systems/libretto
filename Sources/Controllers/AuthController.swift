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
            Route(method: .post, path: "passkey/options", handler: passkeyOptions),
            Route(method: .post, path: "passkey/verify", handler: passkeyVerify),
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

    // MARK: - Passkey

    func passkeyOptions(_ ctx: RequestContext) async throws -> Response {
        let options = try await AuthHelper.shared.passkeys.authenticationOptions()
        let data = try JSONSerialization.data(withJSONObject: options)
        return Response.json(data)
    }

    func passkeyVerify(_ ctx: RequestContext) async throws -> Response {
        guard let body = ctx.body,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
              let credentialId = json["id"] as? String,
              let responseObj = json["response"] as? [String: Any],
              let authDataB64 = responseObj["authenticatorData"] as? String
        else {
            return Response.json(
                Data(#"{"error":"Invalid passkey response"}"#.utf8),
                status: .badRequest
            )
        }

        // Parse sign count from authenticatorData (bytes 33-36, big-endian)
        guard let authData = Data(base64Encoded: authDataB64), authData.count >= 37 else {
            return Response.json(
                Data(#"{"error":"Invalid authenticator data"}"#.utf8),
                status: .badRequest
            )
        }
        let signCount = authData[33...36].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }

        guard let credential = try await AuthHelper.shared.passkeys.verifyAuthentication(
            credentialId: credentialId,
            signCount: signCount
        ) else {
            return Response.json(
                Data(#"{"error":"Passkey verification failed"}"#.utf8),
                status: .unauthorized
            )
        }

        let store = try LibrettoStore.persistent()
        guard let user = try await store.getUser(id: credential.userId) else {
            return Response.json(
                Data(#"{"error":"User not found"}"#.utf8),
                status: .unauthorized
            )
        }

        let session = Session(userId: user.id)
        try await AuthHelper.shared.sessions.save(session)

        return Response(
            status: .ok,
            headers: [
                "content-type": "application/json",
                "set-cookie": "session=\(session.id); Path=/; HttpOnly; SameSite=Lax",
            ],
            body: Data(#"{"success":true}"#.utf8)
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
