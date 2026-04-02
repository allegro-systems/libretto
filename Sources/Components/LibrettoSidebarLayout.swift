import AllegroTheme
import Score
import ScoreLucide

/// Shared sidebar layout for authenticated Libretto pages (Settings, Billing, etc.).
///
/// Uses `SidebarLayout` from allegro-theme with the standard Libretto sidebar navigation.
struct LibrettoSidebarLayout<Content: Node>: Component {
    let activePath: String
    let content: Content

    init(activePath: String, @NodeBuilder content: () -> Content) {
        self.activePath = activePath
        self.content = content()
    }

    var body: some Node {
        SidebarLayout(authGated: true) {
            AppSidebar {
                Link(to: "/") {
                    Stack {
                        Icon("feather", size: 18, color: .accent)
                        Text { "Libretto" }
                            .font(.serif, size: 18, weight: .bold, color: .text)
                    }
                    .flex(.row, gap: 8, align: .center)
                }
                .font(decoration: TextDecoration.none)
            } nav: {
                NavLink(to: "/blog", icon: "book-open", label: "Blog", active: activePath == "/blog")
                NavLink(to: "/drafts", icon: "file-text", label: "Drafts", active: activePath == "/drafts")
                NavLink(to: "/write", icon: "pen-line", label: "Write", active: activePath == "/write")
                NavLink(to: "/settings", icon: "settings", label: "Settings", active: activePath == "/settings")
                NavLink(to: "/billing", icon: "credit-card", label: "Billing", active: activePath == "/billing")
            } bottom: {
                EmptyNode()
            }
        } content: {
            content
        }
    }
}
