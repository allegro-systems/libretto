import Foundation
import Score
import ScoreAuth

final class AuthHelper: Sendable {
    static let shared = AuthHelper()

    let sessions: MemorySessionStore
    let csrf: CSRFProtection
    let magicLinks: MagicLinkManager
    let passkeys: PasskeyManager

    private init() {
        let baseURL = ProcessInfo.processInfo.environment["BASE_URL"]
            ?? "http://localhost:8080"
        let resendKey = ProcessInfo.processInfo.environment["RESEND_API_KEY"] ?? ""

        self.sessions = MemorySessionStore()
        self.csrf = CSRFProtection()
        self.magicLinks = MagicLinkManager(
            configuration: MagicLinkConfiguration(baseURL: baseURL),
            sender: ResendMagicLinkSender(
                apiKey: resendKey,
                from: "Libretto <noreply@maclong.dev>",
                subject: "Sign in to Libretto",
                productName: "Libretto"
            )
        )
        self.passkeys = PasskeyManager(
            configuration: PasskeyConfiguration(
                relyingPartyId: "localhost",
                relyingPartyName: "Libretto"
            )
        )
    }

    // MARK: - Session helpers

    /// Extracts the session cookie, validates, and returns the LibrettoUser.
    func currentUser(from ctx: RequestContext, store: LibrettoStore) async throws -> LibrettoUser? {
        guard let sessionId = extractSessionId(from: ctx) else { return nil }
        guard let session = try await sessions.get(sessionID: sessionId) else { return nil }
        return try await store.getUser(id: session.userId)
    }

    /// Returns nil if authenticated, or a redirect Response if not.
    func requireAuth(_ ctx: RequestContext) async throws -> Response? {
        guard let sessionId = extractSessionId(from: ctx) else {
            return redirectToLogin(ctx)
        }
        guard let session = try await sessions.get(sessionID: sessionId) else {
            return redirectToLogin(ctx)
        }
        guard !session.isExpired else {
            try await sessions.delete(sessionID: session.id)
            return redirectToLogin(ctx)
        }
        return nil
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

    private func redirectToLogin(_ ctx: RequestContext) -> Response {
        let accept = ctx.headers["accept"] ?? ctx.headers["Accept"] ?? ""
        if accept.contains("application/json") {
            return Response.json(
                Data(#"{"error":"unauthorized"}"#.utf8),
                status: .unauthorized
            )
        }
        return Response(
            status: .seeOther,
            headers: ["location": "/login"]
        )
    }
}
