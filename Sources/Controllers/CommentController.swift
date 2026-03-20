import Foundation
import Score

struct CommentController: Controller {
    var base: String { "/api/comments" }

    var routes: [Route] {
        [
            Route(method: .get, path: ":postId", handler: listComments),
            Route(method: .post, path: ":postId", handler: addComment),
            Route(method: .delete, path: ":commentId", handler: deleteComment),
        ]
    }

    // MARK: - Handlers

    func listComments(_ ctx: RequestContext) async throws -> Response {
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(Data(#"{"error":"missing postId"}"#.utf8), status: .badRequest)
        }
        let store = try LibrettoStore.persistent()
        let comments = try await store.listComments(postId: postId)
        var items: [[String: Any]] = []
        for comment in comments {
            let author = try await store.getUser(id: comment.authorId)
            let authorName = author?.displayName ?? author?.username ?? comment.authorId
            let isoDate = ISO8601DateFormatter().string(from: comment.createdAt)
            items.append([
                "id": comment.id,
                "postId": comment.postId,
                "authorId": comment.authorId,
                "authorName": authorName,
                "body": comment.body,
                "createdAt": isoDate,
            ])
        }
        let data = try JSONSerialization.data(withJSONObject: items)
        return Response.json(data)
    }

    func addComment(_ ctx: RequestContext) async throws -> Response {
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
        guard let body = ctx.body,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
              let commentBody = json["body"] as? String, !commentBody.isEmpty
        else {
            return Response.json(Data(#"{"error":"body is required"}"#.utf8), status: .badRequest)
        }
        let comment = Comment(postId: postId, authorId: user.id, body: commentBody)
        try await store.addComment(comment)
        let count = try await store.commentCount(postId: postId)
        post.commentCount = count
        try await store.savePost(post)
        let isoDate = ISO8601DateFormatter().string(from: comment.createdAt)
        let responseObj: [String: Any] = [
            "id": comment.id,
            "postId": comment.postId,
            "authorId": comment.authorId,
            "authorName": user.displayName,
            "body": comment.body,
            "createdAt": isoDate,
        ]
        let data = try JSONSerialization.data(withJSONObject: responseObj)
        return Response.json(data, status: .created)
    }

    func deleteComment(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let commentId = ctx.pathParameters["commentId"] else {
            return Response.json(Data(#"{"error":"missing commentId"}"#.utf8), status: .badRequest)
        }
        guard let comment = try await store.getCommentById(commentId) else {
            return Response.json(Data(#"{"error":"comment not found"}"#.utf8), status: .notFound)
        }
        guard comment.authorId == user.id else {
            return Response.json(Data(#"{"error":"forbidden"}"#.utf8), status: .forbidden)
        }
        try await store.deleteComment(postId: comment.postId, commentId: comment.id)
        if var post = try await store.getPostById(comment.postId) {
            let count = try await store.commentCount(postId: comment.postId)
            post.commentCount = count
            try await store.savePost(post)
        }
        return Response.json(Data(#"{"ok":true}"#.utf8))
    }
}
