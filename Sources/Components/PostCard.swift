import Score

struct PostCard: Node {
    let title: String
    let postBody: String
    let authorName: String
    let username: String
    let slug: String
    let publishedAt: String
    let readMinutes: Int
    let likeCount: Int

    private var excerpt: String {
        let stripped = postBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard stripped.count > 160 else { return stripped }
        let idx = stripped.index(stripped.startIndex, offsetBy: 160)
        return String(stripped[..<idx]) + "\u{2026}"
    }

    var body: some Node {
        Stack {
            Link(to: "/@\(username)/\(slug)") {
                Text { title }
            }
            .font(.serif, size: 22, weight: .light, color: .text, decoration: TextDecoration.none)

            Paragraph { excerpt }
                .font(.mono, size: 13, lineHeight: 1.6, color: .muted)

            Stack {
                Text { authorName }
                    .font(.mono, size: 11, color: .muted)

                Text { "\u{00b7}" }
                    .font(.mono, size: 11, color: .muted)

                Text { publishedAt }
                    .font(.mono, size: 11, color: .muted)

                Text { "\u{00b7}" }
                    .font(.mono, size: 11, color: .muted)

                ReadTime(minutes: readMinutes)

                Text { "\u{00b7}" }
                    .font(.mono, size: 11, color: .muted)

                Text { "\(likeCount) likes" }
                    .font(.mono, size: 11, color: .muted)
            }
            .flex(.row, gap: 6)
        }
        .flex(.column, gap: 8)
        .padding(24)
        .background(.elevated)
        .border(width: 1, color: .border, style: .solid)
    }
}
