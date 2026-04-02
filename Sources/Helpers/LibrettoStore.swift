import Foundation
import ScoreData

final class LibrettoStore: Sendable {
    private let store: KVStore

    init(store: KVStore) {
        self.store = store
    }

    static func persistent() throws -> LibrettoStore {
        let path =
            ProcessInfo.processInfo.environment["LIBRETTO_DATA_PATH"]
            ?? ".score/data.db"
        return LibrettoStore(store: try .persistent(path: path))
    }

    // MARK: - Users

    func saveUser(_ user: LibrettoUser) async throws {
        try await store.set(key: ["users", user.id], value: user)
        // Secondary index by username
        try await store.set(key: ["usernames", user.username], value: user.id)
    }

    func getUser(id: String) async throws -> LibrettoUser? {
        try await store.get(key: ["users", id])
    }

    func getUserByUsername(_ username: String) async throws -> LibrettoUser? {
        guard let userId: String = try await store.get(key: ["usernames", username]) else { return nil }
        return try await getUser(id: userId)
    }

    func getUserByEmail(_ email: String) async throws -> LibrettoUser? {
        let entries = try await store.list(prefix: ["users"], limit: 1000)
        for entry in entries {
            if let user = try? entry.decode(LibrettoUser.self), user.email == email {
                return user
            }
        }
        return nil
    }

    // MARK: - Posts

    func savePost(_ post: Post) async throws {
        try await store.set(key: ["posts", post.authorId, post.id], value: post)
        // Post-ID index for lookup by id alone (used by likes/comments)
        try await store.set(key: ["postids", post.id], value: "\(post.authorId)/\(post.id)")
        if post.status == .published {
            // Slug index for URL lookup
            try await store.set(key: ["slugs", post.slug], value: "\(post.authorId)/\(post.id)")
        }
    }

    func getPostById(_ postId: String) async throws -> Post? {
        guard let ref: String = try await store.get(key: ["postids", postId]) else { return nil }
        let parts = ref.split(separator: "/")
        guard parts.count == 2 else { return nil }
        return try await getPost(authorId: String(parts[0]), postId: String(parts[1]))
    }

    func getPost(authorId: String, postId: String) async throws -> Post? {
        try await store.get(key: ["posts", authorId, postId])
    }

    func getPostBySlug(_ slug: String) async throws -> Post? {
        guard let ref: String = try await store.get(key: ["slugs", slug]) else { return nil }
        let parts = ref.split(separator: "/")
        guard parts.count == 2 else { return nil }
        return try await getPost(authorId: String(parts[0]), postId: String(parts[1]))
    }

    func listPosts(authorId: String) async throws -> [Post] {
        let entries = try await store.list(prefix: ["posts", authorId], limit: 1000)
        return entries.compactMap { try? $0.decode(Post.self) }
    }

    func listPublishedPosts(limit: Int = 50) async throws -> [Post] {
        let entries = try await store.list(prefix: ["posts"], limit: 5000)
        return entries.compactMap { try? $0.decode(Post.self) }
            .filter { $0.status == .published }
            .sorted { ($0.publishedAt ?? .distantPast) > ($1.publishedAt ?? .distantPast) }
            .prefix(limit)
            .map { $0 }
    }

    func deletePost(authorId: String, postId: String) async throws {
        if let post = try await getPost(authorId: authorId, postId: postId) {
            try await store.delete(key: ["slugs", post.slug])
        }
        try await store.delete(key: ["postids", postId])
        try await store.delete(key: ["posts", authorId, postId])
    }

    // MARK: - Likes

    func toggleLike(postId: String, userId: String) async throws -> Bool {
        let key = ["likes", postId, userId]
        guard try await store.exists(key: key) else {
            try await store.set(key: key, value: Like(postId: postId, userId: userId))
            return true  // liked
        }
        try await store.delete(key: key)
        return false  // unliked
    }

    func isLiked(postId: String, userId: String) async throws -> Bool {
        try await store.exists(key: ["likes", postId, userId])
    }

    func likeCount(postId: String) async throws -> Int {
        try await store.list(prefix: ["likes", postId], limit: 100000).count
    }

    // MARK: - Comments

    func addComment(_ comment: Comment) async throws {
        try await store.set(key: ["comments", comment.postId, comment.id], value: comment)
        // Comment-ID index for lookup by id alone (used by delete)
        try await store.set(key: ["commentids", comment.id], value: "\(comment.postId)/\(comment.id)")
    }

    func getCommentById(_ commentId: String) async throws -> Comment? {
        guard let ref: String = try await store.get(key: ["commentids", commentId]) else { return nil }
        let parts = ref.split(separator: "/")
        guard parts.count == 2 else { return nil }
        return try await store.get(key: ["comments", String(parts[0]), String(parts[1])])
    }

    func listComments(postId: String) async throws -> [Comment] {
        let entries = try await store.list(prefix: ["comments", postId], limit: 1000)
        return entries.compactMap { try? $0.decode(Comment.self) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func deleteComment(postId: String, commentId: String) async throws {
        try await store.delete(key: ["commentids", commentId])
        try await store.delete(key: ["comments", postId, commentId])
    }

    func commentCount(postId: String) async throws -> Int {
        try await store.list(prefix: ["comments", postId], limit: 100000).count
    }
}
