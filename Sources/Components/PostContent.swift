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
                .font(.sans, size: 32, weight: .bold)

            Stack {
                Link(to: "/@\(username)") {
                    Text { authorName }
                }
                .font(.sans, size: 14, weight: .medium, decoration: TextDecoration.none)

                Text { "·" }
                    .font(.sans, size: 14, color: .muted)

                Text { publishedAt }
                    .font(.sans, size: 14, color: .muted)

                Text { "·" }
                    .font(.sans, size: 14, color: .muted)

                ReadTime(minutes: readMinutes)
            }
            .flex(.row, gap: 8)

            MarkdownNode(postBody)
        }
        .flex(.column, gap: 24)
    }
}
