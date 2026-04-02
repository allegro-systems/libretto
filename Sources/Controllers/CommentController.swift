import Foundation
import Score

// MARK: - Response Types

private struct ErrorResponse: Codable {
    let error: String
}

private struct OkResponse: Codable {
    let ok: Bool
}

private struct CommentResponse: Codable {
    let id: String
    let postId: String
    let authorId: String
    let authorName: String
    let body: String
    let createdAt: String
}

private let isoFormatter = ISO8601DateFormatter()

@Controller("/api/comments")
struct CommentController {

    @Route(":postId", method: .get)
    func listComments(_ ctx: RequestContext) async throws -> Response {
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing postId")), status: .badRequest)
        }
        let store = try LibrettoStore.persistent()
        let comments = try await store.listComments(postId: postId)
        var items: [CommentResponse] = []
        for comment in comments {
            let author = try await store.getUser(id: comment.authorId)
            let authorName = author?.displayName ?? author?.username ?? comment.authorId
            let isoDate = isoFormatter.string(from: comment.createdAt)
            items.append(
                CommentResponse(
                    id: comment.id,
                    postId: comment.postId,
                    authorId: comment.authorId,
                    authorName: authorName,
                    body: comment.body,
                    createdAt: isoDate
                ))
        }
        let data = try JSONEncoder().encode(items)
        return Response.json(data)
    }

    @Route(":postId", method: .post)
    func addComment(_ ctx: RequestContext) async throws -> Response {
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
        guard let body = ctx.body,
            let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let commentBody = json["body"] as? String, !commentBody.isEmpty
        else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "body is required")), status: .badRequest)
        }
        let comment = Comment(postId: postId, authorId: user.id, body: commentBody)
        try await store.addComment(comment)
        let count = try await store.commentCount(postId: postId)
        post.commentCount = count
        try await store.savePost(post)
        let isoDate = isoFormatter.string(from: comment.createdAt)
        let data = try JSONEncoder().encode(
            CommentResponse(
                id: comment.id,
                postId: comment.postId,
                authorId: comment.authorId,
                authorName: user.displayName,
                body: comment.body,
                createdAt: isoDate
            ))
        return Response.json(data, status: .created)
    }

    @Route(":commentId", method: .delete)
    func deleteComment(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let commentId = ctx.pathParameters["commentId"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing commentId")), status: .badRequest)
        }
        guard let comment = try await store.getCommentById(commentId) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "comment not found")), status: .notFound)
        }
        guard comment.authorId == user.id else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "forbidden")), status: .forbidden)
        }
        try await store.deleteComment(postId: comment.postId, commentId: comment.id)
        if var post = try await store.getPostById(comment.postId) {
            let count = try await store.commentCount(postId: comment.postId)
            post.commentCount = count
            try await store.savePost(post)
        }
        return Response.json(try JSONEncoder().encode(OkResponse(ok: true)))
    }
}
