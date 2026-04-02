import Foundation
import Score

// MARK: - Response Types

private struct ErrorResponse: Codable {
    let error: String
}

private struct LikeResponse: Codable {
    let liked: Bool
    let count: Int
}

@Controller("/api/likes")
struct LikeController {

    @Route(":postId", method: .post)
    func toggleLike(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing postId")), status: .badRequest)
        }
        guard var post = try await store.getPostById(postId) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "post not found")), status: .notFound)
        }
        let liked = try await store.toggleLike(postId: postId, userId: user.id)
        let count = try await store.likeCount(postId: postId)
        post.likeCount = count
        try await store.savePost(post)
        let data = try JSONEncoder().encode(LikeResponse(liked: liked, count: count))
        return Response.json(data)
    }

    @Route(":postId", method: .get)
    func getLikeStatus(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing postId")), status: .badRequest)
        }
        let liked = try await store.isLiked(postId: postId, userId: user.id)
        let count = try await store.likeCount(postId: postId)
        let data = try JSONEncoder().encode(LikeResponse(liked: liked, count: count))
        return Response.json(data)
    }
}
