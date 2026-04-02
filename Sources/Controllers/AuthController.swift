import Foundation
import Score
import ScoreAuth

// MARK: - Response Types

private struct ErrorResponse: Codable {
    let error: String
}

private struct OkMessageResponse: Codable {
    let ok: Bool
    let message: String
}

private struct SuccessResponse: Codable {
    let success: Bool
}

@Controller("/auth")
struct AuthController {

    @Route("magic-link", method: .post)
    func sendMagicLink(_ ctx: RequestContext) async throws -> Response {
        guard let body = ctx.body,
            let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let email = json["email"] as? String, !email.isEmpty
        else {
            return Response.json(
                try JSONEncoder().encode(ErrorResponse(error: "email is required")),
                status: .badRequest
            )
        }

        do {
            try await AuthHelper.shared.magicLinks.send(to: email)
        } catch {
            return Response.json(
                try JSONEncoder().encode(ErrorResponse(error: "Failed to send email. Please try again.")),
                status: .internalServerError
            )
        }

        return Response.json(
            try JSONEncoder().encode(OkMessageResponse(ok: true, message: "Magic link sent. Check your email."))
        )
    }

    @Route("verify", method: .get)
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

    @Route("logout", method: .post)
    func logout(_ ctx: RequestContext) async throws -> Response {
        if let sessionId = SessionCookie.extract(from: ctx) {
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

    @Route("passkey/options", method: .post)
    func passkeyOptions(_ ctx: RequestContext) async throws -> Response {
        let options = try await AuthHelper.shared.passkeys.authenticationOptions()
        let data = try JSONSerialization.data(withJSONObject: options)
        return Response.json(data)
    }

    @Route("passkey/verify", method: .post)
    func passkeyVerify(_ ctx: RequestContext) async throws -> Response {
        guard let body = ctx.body,
            let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let credentialId = json["id"] as? String,
            let responseObj = json["response"] as? [String: Any],
            let authDataB64 = responseObj["authenticatorData"] as? String,
            let clientDataB64 = responseObj["clientDataJSON"] as? String,
            let signatureB64 = responseObj["signature"] as? String,
            let clientDataJSON = Data(base64Encoded: clientDataB64),
            let signature = Data(base64Encoded: signatureB64)
        else {
            return Response.json(
                try JSONEncoder().encode(ErrorResponse(error: "Invalid passkey response")),
                status: .badRequest
            )
        }

        // Parse sign count from authenticatorData (bytes 33-36, big-endian)
        guard let authData = Data(base64Encoded: authDataB64), authData.count >= 37 else {
            return Response.json(
                try JSONEncoder().encode(ErrorResponse(error: "Invalid authenticator data")),
                status: .badRequest
            )
        }
        let signCount = authData[33...36].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }

        guard
            let credential = try await AuthHelper.shared.passkeys.verifyAuthentication(
                credentialId: credentialId,
                clientDataJSON: clientDataJSON,
                authenticatorData: authData,
                signature: signature,
                signCount: signCount
            )
        else {
            return Response.json(
                try JSONEncoder().encode(ErrorResponse(error: "Passkey verification failed")),
                status: .unauthorized
            )
        }

        let store = try LibrettoStore.persistent()
        guard let user = try await store.getUser(id: credential.userId) else {
            return Response.json(
                try JSONEncoder().encode(ErrorResponse(error: "User not found")),
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
            body: try JSONEncoder().encode(SuccessResponse(success: true))
        )
    }

}
