import Foundation
import Score

struct BillingController: Controller {
    var base: String { "/api/billing" }

    var routes: [Route] {
        [
            Route(method: .get, handler: getBilling),
            Route(method: .post, path: "checkout", handler: createCheckout),
            Route(method: .post, path: "webhook", handler: handleWebhook),
        ]
    }

    /// GET /api/billing — returns current user's plan and usage stats.
    func getBilling(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }

        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }

        let posts = try await store.listPosts(authorId: user.id)
        let collectionsCount = posts.count

        let plan = user.plan.rawValue
        let storageLimit = user.plan == .pro ? 5_368_709_120 : 524_288_000  // 5 GB pro, 500 MB free
        let collectionsLimit = user.plan == .pro ? 0 : 100  // 0 = unlimited for pro

        let payload = """
        {
          "plan": "\(plan)",
          "usage": {
            "collections": { "used": \(collectionsCount), "limit": \(collectionsLimit) },
            "storageBytes": { "used": 0, "limit": \(storageLimit) }
          },
          "paymentHistory": []
        }
        """
        return Response.json(Data(payload.utf8))
    }

    /// POST /api/billing/checkout — creates a Revolut checkout session.
    /// Stub: returns a mock session ID.
    func createCheckout(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }

        // TODO: Integrate with ScorePayments / Revolut Orders API to create a real session
        let payload = """
        {
          "sessionId": "mock_session_\(UUID().uuidString.lowercased())",
          "checkoutUrl": "/billing/checkout"
        }
        """
        return Response.json(Data(payload.utf8))
    }

    /// POST /api/billing/webhook — Revolut webhook handler.
    /// Stub: logs the event and returns 200.
    func handleWebhook(_ ctx: RequestContext) async throws -> Response {
        // TODO: Validate Revolut webhook signature using REVOLUT_WEBHOOK_SECRET
        // TODO: Parse event type (ORDER_COMPLETED, ORDER_FAILED, etc.) and update subscription
        print("[BillingController] Received Revolut webhook event")
        return Response.json(Data(#"{"received":true}"#.utf8))
    }
}
