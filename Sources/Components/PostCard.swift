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
            .font(.serif, size: 18, weight: .semibold, color: .text, decoration: TextDecoration.none)

            Paragraph { excerpt }
                .font(.sans, size: 13, lineHeight: 1.5, color: .muted)

            Stack {
                Stack {}
                    .size(width: 20, height: 20)
                    .border(radius: 10)
                    .background(.accent)
                    .flex(shrink: 0)

                Text { authorName }
                    .font(.sans, size: 11, color: .muted)

                Text { "\u{00b7}" }
                    .font(.sans, size: 11, color: .muted)

                Text { publishedAt }
                    .font(.sans, size: 11, color: .muted)

                Text { "\u{00b7}" }
                    .font(.sans, size: 11, color: .muted)

                ReadTime(minutes: readMinutes)
            }
            .flex(.row, gap: 6, align: .center)
        }
        .flex(.column, gap: 16)
        .padding(24)
        .background(.surface)
        .border(width: 1, color: .border, style: .solid, radius: 8)
    }
}
