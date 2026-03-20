import Score

struct PostContent: Node {
    let title: String
    let authorName: String
    let username: String
    let publishedAt: String
    let readMinutes: Int
    let postBody: String

    var body: some Node {
        Stack {
            Heading(.one) { title }
                .font(.serif, size: 56, weight: .light, lineHeight: 1.15, color: .text)
                .compact { $0.font(size: 36) }

            Stack {
                Link(to: "/@\(username)") {
                    Text { authorName }
                }
                .font(.mono, size: 13, weight: .medium, color: .text, decoration: TextDecoration.none)

                Text { "\u{00b7}" }
                    .font(.mono, size: 13, color: .muted)

                Text { publishedAt }
                    .font(.mono, size: 13, color: .muted)

                Text { "\u{00b7}" }
                    .font(.mono, size: 13, color: .muted)

                ReadTime(minutes: readMinutes)
            }
            .flex(.row, gap: 8)

            MarkdownNode(postBody)
        }
        .flex(.column, gap: 24)
    }
}
