import Score
import ScoreLucide

struct NavBar: Node {
    var body: some Node {
        Header {
            // Logo — matches Site's SiteLogo pattern
            Link(to: "/") {
                Stack {
                    Text { "Libretto" }
                        .font(.serif, size: 20, weight: .light, color: .text)
                    Text { "by Allegro" }
                        .font(.serif, size: 9, weight: .light, color: .muted)
                        .htmlAttribute("style", "font-style:italic;position:absolute;bottom:-1px;right:-2px;")
                }
                .htmlAttribute("style", "position:relative;padding-right:6px;")
            }
            .font(decoration: TextDecoration.none)
            .flexItem(grow: 1)

            // Center — search bar
            Stack {
                Stack {
                    Icon("search", size: 16, color: .dimmer)
                    Input(type: .search, name: "q", placeholder: "Search posts, writers, topics\u{2026}")
                        .htmlAttribute("id", "search-input")
                        .htmlAttribute("style", "background:transparent;border:none;outline:none;width:100%;color:var(--color-text);font-family:var(--font-sans);font-size:13px;")
                }
                .flex(.row, gap: 10, align: .center)
                .padding(8, at: .vertical)
                .padding(14, at: .horizontal)
                .background(.elevated)
                .border(width: 1, color: .border, style: .solid, radius: 8)
                .size(width: .percent(100), maxWidth: 400)
            }
            .flex(.row, justify: .center)
            .flexItem(grow: 1)
            .compact { $0.hidden() }

            // Right — logged-out state (shown by default, hidden when authed)
            Stack {
                Link(to: "/login") {
                    Text { "Get Started" }
                }
                .font(.sans, size: 13, weight: .medium, color: .bg, decoration: TextDecoration.none)
                .padding(8, at: .vertical)
                .padding(20, at: .horizontal)
                .background(.accent)
                .radius(6)
                .flex(.row, align: .center, justify: .center)
                .hover { $0.opacity(0.85) }
            }
            .flex(.row, gap: 12, align: .center, justify: .end)
            .flexItem(grow: 1)
            .htmlAttribute("id", "nav-logged-out")

            // Right — logged-in state (hidden by default, shown when authed)
            Stack {
                Link(to: "/write") {
                    Icon("plus", size: 18, color: .muted)
                    Text { "New Post" }
                }
                .font(.mono, size: 13, color: .muted, decoration: TextDecoration.none)
                .flex(.row, gap: 6, align: .center)
                .hover { $0.font(color: .text) }

                // Profile avatar
                Link(to: "/settings") {
                    Stack {}
                        .size(width: 32, height: 32)
                        .background(.accent)
                        .radius(16)
                        .htmlAttribute("id", "nav-avatar")
                }
                .font(decoration: TextDecoration.none)
            }
            .flex(.row, gap: 20, align: .center, justify: .end)
            .flexItem(grow: 1)
            .htmlAttribute("id", "nav-logged-in")
            .htmlAttribute("style", "display:none;")

            RawTextNode(navAuthScript)
        }
        .flex(.row, align: .center)
        .padding(16, at: .vertical)
        .padding(56, at: .horizontal)
        .compact { $0.padding(16, at: .vertical).padding(20, at: .horizontal) }
        .border(width: 1, color: .border, style: .solid, at: .bottom)
    }
}

/// Client-side script to toggle nav state based on auth
private let navAuthScript = """
<script>
(function() {
  fetch('/auth/me', { credentials: 'same-origin' })
    .then(function(r) { return r.ok ? r.json() : null; })
    .then(function(user) {
      if (user && user.id) {
        var lo = document.getElementById('nav-logged-out');
        var li = document.getElementById('nav-logged-in');
        if (lo) lo.style.display = 'none';
        if (li) li.style.display = 'flex';
      }
    })
    .catch(function() {});
})();
</script>
"""
