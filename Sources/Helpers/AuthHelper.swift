import Foundation
import Score
import ScoreAuth

final class AuthHelper: Sendable {
    static let shared = AuthHelper()

    let sessions: MemorySessionStore
    let csrf: CSRFProtection
    let magicLinks: MagicLinkManager
    let passkeys: PasskeyManager
    let guard_: AuthGuard

    private init() {
        let baseURL =
            ProcessInfo.processInfo.environment["BASE_URL"]
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
        self.guard_ = AuthGuard(sessionStore: sessions)
    }

    // MARK: - Session helpers

    /// Extracts the session cookie, validates, and returns the LibrettoUser.
    func currentUser(from ctx: RequestContext, store: LibrettoStore) async throws -> LibrettoUser? {
        guard let session = await guard_.currentSession(from: ctx) else { return nil }
        return try await store.getUser(id: session.userId)
    }

    /// Returns nil if authenticated, or a redirect Response if not.
    func requireAuth(_ ctx: RequestContext) async throws -> Response? {
        await guard_.requireAuth(ctx)
    }
}
