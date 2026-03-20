import Foundation
import Score

struct LikeController: Controller {
    var base: String { "/api/likes" }

    var routes: [Route] {
        [
            Route(method: .post, path: ":postId", handler: toggleLike),
            Route(method: .get, path: ":postId", handler: getLikeStatus),
        ]
    }

    // MARK: - Handlers

    func toggleLike(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(Data(#"{"error":"missing postId"}"#.utf8), status: .badRequest)
        }
        guard var post = try await store.getPostById(postId) else {
            return Response.json(Data(#"{"error":"post not found"}"#.utf8), status: .notFound)
        }
        let liked = try await store.toggleLike(postId: postId, userId: user.id)
        let count = try await store.likeCount(postId: postId)
        post.likeCount = count
        try await store.savePost(post)
        let responseJSON = #"{"liked":\#(liked),"count":\#(count)}"#
        return Response.json(Data(responseJSON.utf8))
    }

    func getLikeStatus(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(Data(#"{"error":"missing postId"}"#.utf8), status: .badRequest)
        }
        let liked = try await store.isLiked(postId: postId, userId: user.id)
        let count = try await store.likeCount(postId: postId)
        let responseJSON = #"{"liked":\#(liked),"count":\#(count)}"#
        return Response.json(Data(responseJSON.utf8))
    }
}
