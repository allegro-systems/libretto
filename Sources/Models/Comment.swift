import Foundation

struct Comment: Codable, Sendable {
    let id: String
    let postId: String
    let authorId: String
    var body: String
    let createdAt: Date

    init(id: String = UUID().uuidString, postId: String, authorId: String, body: String) {
        self.id = id
        self.postId = postId
        self.authorId = authorId
        self.body = body
        self.createdAt = Date()
    }
}
