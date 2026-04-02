import Foundation
import Score

// MARK: - Response Types

private struct ErrorResponse: Codable {
    let error: String
}

private struct OkResponse: Codable {
    let ok: Bool
}

@Controller("/api/posts")
struct PostController {

    @Route(method: .get)
    func listMyPosts(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        let posts = try await store.listPosts(authorId: user.id)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(posts)
        return Response.json(data)
    }

    @Route(method: .post)
    func createPost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let body = ctx.body,
            let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
            let title = json["title"] as? String, !title.isEmpty
        else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "title is required")), status: .badRequest)
        }
        let postBody = json["body"] as? String ?? ""
        var post = Post(authorId: user.id, title: title, body: postBody)
        post.updateWordCount()
        try await store.savePost(post)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(post)
        return Response.json(data, status: .created)
    }

    @Route(":postId", method: .get)
    func getPost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing postId")), status: .badRequest)
        }
        guard let post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "not found")), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "forbidden")), status: .forbidden)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(post)
        return Response.json(data)
    }

    @Route(":postId", method: .put)
    func updatePost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing postId")), status: .badRequest)
        }
        guard var post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "not found")), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "forbidden")), status: .forbidden)
        }
        guard let body = ctx.body,
            let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any]
        else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "invalid body")), status: .badRequest)
        }
        if let title = json["title"] as? String, !title.isEmpty {
            post.title = title
            post.slug = Post.slugify(title)
        }
        if let postBody = json["body"] as? String {
            post.body = postBody
        }
        post.updatedAt = Date()
        post.updateWordCount()
        try await store.savePost(post)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(post)
        return Response.json(data)
    }

    @Route(":postId", method: .delete)
    func deletePost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing postId")), status: .badRequest)
        }
        guard let post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "not found")), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "forbidden")), status: .forbidden)
        }
        try await store.deletePost(authorId: user.id, postId: postId)
        return Response.json(try JSONEncoder().encode(OkResponse(ok: true)))
    }

    @Route(":postId/publish", method: .post)
    func publishPost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing postId")), status: .badRequest)
        }
        guard var post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "not found")), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "forbidden")), status: .forbidden)
        }
        post.status = .published
        post.publishedAt = Date()
        post.updatedAt = Date()
        try await store.savePost(post)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(post)
        return Response.json(data)
    }

    @Route(":postId/unpublish", method: .post)
    func unpublishPost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "user not found")), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing postId")), status: .badRequest)
        }
        guard var post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "not found")), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "forbidden")), status: .forbidden)
        }
        post.status = .draft
        post.updatedAt = Date()
        try await store.savePost(post)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(post)
        return Response.json(data)
    }
}

// MARK: - Public

@Controller("/api/public")
struct PublicPostController {

    @Route("posts", method: .get)
    func listPublished(_ ctx: RequestContext) async throws -> Response {
        let store = try LibrettoStore.persistent()
        var posts = try await store.listPublishedPosts()
        // Optional ?author=username filter
        if let authorUsername = ctx.queryParameters["author"], !authorUsername.isEmpty {
            if let author = try await store.getUserByUsername(authorUsername) {
                posts = posts.filter { $0.authorId == author.id }
            } else {
                posts = []
            }
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(posts)
        return Response.json(data)
    }

    @Route("post/:slug", method: .get)
    func getBySlug(_ ctx: RequestContext) async throws -> Response {
        guard let slug = ctx.pathParameters["slug"] else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "missing slug")), status: .badRequest)
        }
        let store = try LibrettoStore.persistent()
        guard let post = try await store.getPostBySlug(slug), post.status == .published else {
            return Response.json(try JSONEncoder().encode(ErrorResponse(error: "not found")), status: .notFound)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(post)
        return Response.json(data)
    }
}
