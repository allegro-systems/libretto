import Foundation
import Score

struct PostController: Controller {
    var base: String { "/api/posts" }

    var routes: [Route] {
        [
            Route(method: .get, handler: listMyPosts),
            Route(method: .post, handler: createPost),
            Route(method: .get, path: ":postId", handler: getPost),
            Route(method: .put, path: ":postId", handler: updatePost),
            Route(method: .delete, path: ":postId", handler: deletePost),
            Route(method: .post, path: ":postId/publish", handler: publishPost),
            Route(method: .post, path: ":postId/unpublish", handler: unpublishPost),
        ]
    }

    // MARK: - Handlers

    func listMyPosts(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        let posts = try await store.listPosts(authorId: user.id)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(posts)
        return Response.json(data)
    }

    func createPost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let body = ctx.body,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
              let title = json["title"] as? String, !title.isEmpty
        else {
            return Response.json(Data(#"{"error":"title is required"}"#.utf8), status: .badRequest)
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

    func getPost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(Data(#"{"error":"missing postId"}"#.utf8), status: .badRequest)
        }
        guard let post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(Data(#"{"error":"not found"}"#.utf8), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(Data(#"{"error":"forbidden"}"#.utf8), status: .forbidden)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(post)
        return Response.json(data)
    }

    func updatePost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(Data(#"{"error":"missing postId"}"#.utf8), status: .badRequest)
        }
        guard var post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(Data(#"{"error":"not found"}"#.utf8), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(Data(#"{"error":"forbidden"}"#.utf8), status: .forbidden)
        }
        guard let body = ctx.body,
              let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any]
        else {
            return Response.json(Data(#"{"error":"invalid body"}"#.utf8), status: .badRequest)
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

    func deletePost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(Data(#"{"error":"missing postId"}"#.utf8), status: .badRequest)
        }
        guard let post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(Data(#"{"error":"not found"}"#.utf8), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(Data(#"{"error":"forbidden"}"#.utf8), status: .forbidden)
        }
        try await store.deletePost(authorId: user.id, postId: postId)
        return Response.json(Data(#"{"ok":true}"#.utf8))
    }

    func publishPost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(Data(#"{"error":"missing postId"}"#.utf8), status: .badRequest)
        }
        guard var post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(Data(#"{"error":"not found"}"#.utf8), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(Data(#"{"error":"forbidden"}"#.utf8), status: .forbidden)
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

    func unpublishPost(_ ctx: RequestContext) async throws -> Response {
        if let denied = try await AuthHelper.shared.requireAuth(ctx) { return denied }
        let store = try LibrettoStore.persistent()
        guard let user = try await AuthHelper.shared.currentUser(from: ctx, store: store) else {
            return Response.json(Data(#"{"error":"user not found"}"#.utf8), status: .unauthorized)
        }
        guard let postId = ctx.pathParameters["postId"] else {
            return Response.json(Data(#"{"error":"missing postId"}"#.utf8), status: .badRequest)
        }
        guard var post = try await store.getPost(authorId: user.id, postId: postId) else {
            return Response.json(Data(#"{"error":"not found"}"#.utf8), status: .notFound)
        }
        guard post.authorId == user.id else {
            return Response.json(Data(#"{"error":"forbidden"}"#.utf8), status: .forbidden)
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

struct PublicPostController: Controller {
    var base: String { "/api/public" }

    var routes: [Route] {
        [
            Route(method: .get, path: "posts", handler: listPublished),
            Route(method: .get, path: "post/:slug", handler: getBySlug),
        ]
    }

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

    func getBySlug(_ ctx: RequestContext) async throws -> Response {
        guard let slug = ctx.pathParameters["slug"] else {
            return Response.json(Data(#"{"error":"missing slug"}"#.utf8), status: .badRequest)
        }
        let store = try LibrettoStore.persistent()
        guard let post = try await store.getPostBySlug(slug), post.status == .published else {
            return Response.json(Data(#"{"error":"not found"}"#.utf8), status: .notFound)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(post)
        return Response.json(data)
    }
}
