import Foundation

struct Post: Codable, Sendable {
    let id: String
    let authorId: String
    var slug: String
    var title: String
    var body: String  // Markdown
    var excerpt: String?
    var status: PostStatus
    var publishedAt: Date?
    var updatedAt: Date
    let createdAt: Date
    var wordCount: Int
    var estimatedReadMinutes: Int
    var likeCount: Int
    var commentCount: Int

    enum PostStatus: String, Codable, Sendable {
        case draft
        case published
    }

    init(id: String = UUID().uuidString, authorId: String, title: String, body: String = "") {
        self.id = id
        self.authorId = authorId
        self.slug = Self.slugify(title)
        self.title = title
        self.body = body
        self.status = .draft
        self.updatedAt = Date()
        self.createdAt = Date()
        self.wordCount = 0
        self.estimatedReadMinutes = 1
        self.likeCount = 0
        self.commentCount = 0
    }

    static func slugify(_ title: String) -> String {
        title.lowercased()
            .replacingOccurrences(of: "[^a-z0-9\\s-]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    mutating func updateWordCount() {
        wordCount = body.split(separator: " ").count
        estimatedReadMinutes = max(1, Int((Double(wordCount) / 200.0).rounded(.up)))
    }
}
