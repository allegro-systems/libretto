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
        return String(stripped[..<idx]) + "…"
    }

    var body: some Node {
        Stack {
            Link(to: "/@\(username)/\(slug)") {
                Text { title }
            }
            .font(.sans, size: 18, weight: .semibold, decoration: TextDecoration.none)

            Paragraph { excerpt }
                .font(.sans, size: 14, color: .muted)

            Stack {
                Text { authorName }
                    .font(.sans, size: 13)

                Text { "·" }
                    .font(.sans, size: 13, color: .muted)

                Text { publishedAt }
                    .font(.sans, size: 13, color: .muted)

                Text { "·" }
                    .font(.sans, size: 13, color: .muted)

                ReadTime(minutes: readMinutes)

                Text { "·" }
                    .font(.sans, size: 13, color: .muted)

                Text { "\(likeCount) likes" }
                    .font(.sans, size: 13, color: .muted)
            }
            .flex(.row, gap: 6)
        }
        .flex(.column, gap: 8)
        .padding(20)
        .background(ColorToken("elevated"))
        .radius(8)
    }
}
