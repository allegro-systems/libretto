import Foundation
import Score

// MARK: - Response Types

private struct ErrorResponse: Codable {
    let error: String
}

private struct UsageDetail: Codable {
    let used: Int
    let limit: Int
}

private struct BillingUsage: Codable {
    let collections: UsageDetail
    let storageBytes: UsageDetail
}

private struct BillingResponse: Codable {
    let plan: String
    let usage: BillingUsage
    let paymentHistory: [String]
}

private struct CheckoutResponse: Codable {
    let sessionId: String
    let checkoutUrl: String
}

private struct WebhookResponse: Codable {
    let received: Bool
}

@Controller("/api/billing")
struct BillingController {

    /// GET /api/billing — returns current user's plan and usage stats.
    @Route(method: .get)
    func getBilling(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }

        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }

        let posts = try await store.listPosts(authorId: user.id)
        let collectionsCount = posts.count

        let plan = user.plan.rawValue
        let storageLimit = user.plan == .pro ? 5_368_709_120 : 524_288_000  // 5 GB pro, 500 MB free
        let collectionsLimit = user.plan == .pro ? 0 : 100  // 0 = unlimited for pro

        let billing = BillingResponse(
            plan: plan,
            usage: BillingUsage(
                collections: UsageDetail(used: collectionsCount, limit: collectionsLimit),
                storageBytes: UsageDetail(used: 0, limit: storageLimit)
            ),
            paymentHistory: []
        )
        let data = try JSONEncoder().encode(billing)
        return Response.json(data)
    }

    /// POST /api/billing/checkout — creates a Revolut checkout session.
    /// Stub: returns a mock session ID.
    @Route("checkout", method: .post)
    func createCheckout(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }

        // TODO: Integrate with ScorePayments / Revolut Orders API to create a real session
        let checkout = CheckoutResponse(
            sessionId: "mock_session_\(UUID().uuidString.lowercased())",
            checkoutUrl: "/billing/checkout"
        )
        let data = try JSONEncoder().encode(checkout)
        return Response.json(data)
    }

    /// POST /api/billing/webhook — Revolut webhook handler.
    /// Stub: logs the event and returns 200.
    @Route("webhook", method: .post)
    func handleWebhook(_ ctx: RequestContext) async throws -> Response {
        // TODO: Validate Revolut webhook signature using REVOLUT_WEBHOOK_SECRET
        // TODO: Parse event type (ORDER_COMPLETED, ORDER_FAILED, etc.) and update subscription
        print("[BillingController] Received Revolut webhook event")
        let data = try JSONEncoder().encode(WebhookResponse(received: true))
        return Response.json(data)
    }
}
