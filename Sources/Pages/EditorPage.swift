import Score

struct EditorPage: Page {
    // Handles both /write (new post) and /write/:postId (edit existing)
    static let path = "/write"

    var body: some Node {
        Stack {
            // Header row
            Stack {
                Heading(.one) { "Write" }
                    .font(.sans, size: 26, weight: .bold)

                Link(to: "/drafts") {
                    Text { "My Drafts" }
                }
                .font(.sans, size: 14, weight: .medium, decoration: TextDecoration.none)
                .htmlAttribute("style", "color:#7eb8f7;")
            }
            .flex(.row, gap: 16)
            .htmlAttribute("style", "align-items:baseline;")

            Editor()
        }
        .flex(.column, gap: 24)
        .padding(40)
    }
}
