import Foundation

struct Like: Codable, Sendable {
    let postId: String
    let userId: String
    let createdAt: Date

    init(postId: String, userId: String) {
        self.postId = postId
        self.userId = userId
        self.createdAt = Date()
    }
}
