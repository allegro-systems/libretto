import Score

struct ProfileHeader: Node {
    let displayName: String
    let username: String
    let bio: String?
    let avatarURL: String?
    let socialLinks: [LibrettoUser.SocialLink]

    var body: some Node {
        Stack {
            // Avatar placeholder or image
            avatarNode

            // Name + username
            Stack {
                Heading(.two) { displayName }
                    .font(.serif, size: 22, weight: .semibold, color: .text)

                Paragraph { "@\(username)" }
                    .font(.mono, size: 13, color: .dimmer)
            }
            .flex(.column, gap: 4)

            // Bio
            if let bio, !bio.isEmpty {
                Paragraph { bio }
                    .font(.sans, size: 14, lineHeight: 1.6, color: .muted)
            }

            // Social links
            if !socialLinks.isEmpty {
                SocialLinks(links: socialLinks)
            }
        }
        .flex(.column, gap: 12, align: .center)
        .padding(24)
    }

    @NodeBuilder
    private var avatarNode: some Node {
        if let url = avatarURL, !url.isEmpty {
            Image(src: url, alt: displayName)
                .size(width: 72, height: 72)
                .objectFit(.cover)
                .border(radius: 36)
        } else {
            // Initials placeholder
            let initials = String(displayName.prefix(1)).uppercased()
            Stack {
                Text { initials }
                    .font(.sans, size: 28, weight: .medium, color: .bg)
            }
            .size(width: 72, height: 72)
            .border(radius: 36)
            .background(.accent)
            .flex(.row, align: .center, justify: .center)
        }
    }
}
