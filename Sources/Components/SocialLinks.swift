import Score

struct SocialLinks: Node {
    let links: [LibrettoUser.SocialLink]

    var body: some Node {
        Stack {
            ForEachNode(links) { link in
                Link(to: link.url) {
                    Text { link.platform.capitalized }
                }
                .font(.mono, size: 13, color: .accent, decoration: TextDecoration.none)
            }
        }
        .flex(.row, gap: 12)
    }
}
