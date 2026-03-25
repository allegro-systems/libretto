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
            RawTextNode("<img src=\"\(url)\" alt=\"\(displayName)\" style=\"width:72px;height:72px;border-radius:50%;object-fit:cover;\">")
        } else {
            // Initials placeholder
            let initials = String(displayName.prefix(1)).uppercased()
            Stack {
                Text { initials }
                    .font(.sans, size: 28, weight: .medium, color: .bg)
            }
            .htmlAttribute("style", "width:72px;height:72px;border-radius:50%;background:var(--color-accent);display:flex;align-items:center;justify-content:center;")
        }
    }
}
