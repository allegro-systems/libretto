import Score

struct EditorPage: Page {
    // Handles both /write (new post) and /write/:postId (edit existing)
    static let path = "/write"

    var body: some Node {
        Stack {
            // Header row
            Section {
                Stack {
                    Heading(.one) { "Write" }
                        .font(.serif, size: 56, weight: .light, lineHeight: 1.15, color: .text)
                        .compact { $0.font(size: 36) }

                    Link(to: "/drafts") {
                        Text { "My Drafts" }
                    }
                    .font(.mono, size: 13, weight: .medium, color: .text, align: .center, decoration: TextDecoration.none)
                    .padding(14, at: .vertical)
                    .padding(28, at: .horizontal)
                    .border(width: 1, color: .border, style: .solid)
                    .hover { $0.background(.elevated) }
                }
                .flex(.row, gap: 24, align: .center, justify: .spaceBetween)
                .compact { $0.flex(.column, gap: 16, align: .start) }
            }
            .padding(80, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(60, at: .vertical).padding(20, at: .horizontal) }

            HorizontalRule().background(.border).size(height: 1).border(width: 0, color: .border, style: .none)

            Section {
                Editor()
            }
            .padding(40, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(20, at: .horizontal) }
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }
}
