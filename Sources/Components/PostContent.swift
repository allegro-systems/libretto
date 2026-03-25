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
            // Author row
            Stack {
                Stack {}
                    .htmlAttribute("style", "width:48px;height:48px;border-radius:50%;background:var(--color-accent);flex-shrink:0;")

                Stack {
                    Link(to: "/@\(username)") {
                        Text { authorName }
                    }
                    .font(.sans, size: 14, weight: .medium, color: .text, decoration: TextDecoration.none)

                    Stack {
                        Text { publishedAt }
                            .font(.sans, size: 12, color: .muted)

                        Text { "\u{00b7}" }
                            .font(.sans, size: 12, color: .muted)

                        ReadTime(minutes: readMinutes)
                    }
                    .flex(.row, gap: 6, align: .center)
                }
                .flex(.column, gap: 2)
            }
            .flex(.row, gap: 12, align: .center)

            Heading(.one) { title }
                .font(.serif, size: 32, weight: .bold, lineHeight: 1.2, color: .text)
                .compact { $0.font(size: 24) }

            MarkdownNode(postBody)
        }
        .flex(.column, gap: 24)
    }
}
