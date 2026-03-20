import Score

struct LandingPage: Page {
    static let path = "/"

    var body: some Node {
        Stack {
            // Hero
            Section {
                Heading(.one) { "Libretto" }
                    .font(.serif, size: 56, weight: .light, lineHeight: 1.15, color: .text, align: .center)
                    .size(maxWidth: 740)
                    .compact { $0.font(size: 36) }
                    .animate(.fadeIn, duration: 0.6)

                Paragraph { "A place to write, publish, and connect." }
                    .font(.mono, size: 15, lineHeight: 1.6, color: .muted, align: .center)
                    .size(maxWidth: 580)
                    .compact { $0.font(size: 13) }
                    .animate(.fadeIn, duration: 0.6, delay: 0.15)

                Stack {
                    Link(to: "/login") { "Start Writing" }
                        .font(.mono, size: 13, weight: .medium, color: .bg, align: .center, decoration: TextDecoration.none)
                        .padding(14, at: .vertical)
                        .padding(28, at: .horizontal)
                        .background(.accent)
                        .hover { $0.opacity(0.85) }

                    Link(to: "/blog") { "Read Blog" }
                        .font(.mono, size: 13, weight: .medium, color: .text, align: .center, decoration: TextDecoration.none)
                        .padding(14, at: .vertical)
                        .padding(28, at: .horizontal)
                        .border(width: 1, color: .border, style: .solid)
                        .hover { $0.background(.elevated) }
                }
                .flex(.row, gap: 16, align: .center)
                .compact { $0.flex(.column, gap: 12).size(width: .percent(100)) }
                .animate(.fadeIn, duration: 0.6, delay: 0.3)
            }
            .flex(.column, gap: 28, align: .center)
            .padding(120, at: .vertical)
            .padding(56, at: .horizontal)
            .backgroundGradient(.radial(color: .libretto, opacity: 0.04, width: 120, height: 80, at: .top))
            .compact { $0.padding(80, at: .vertical).padding(20, at: .horizontal) }

            HorizontalRule().background(.border).size(height: 1).border(width: 0, color: .border, style: .none)

            // Recent Posts
            Section {
                Text { "RECENT POSTS" }
                    .font(.mono, size: 12, weight: .medium, tracking: 3, color: .muted, transform: .uppercase)
                    .animateOnScroll(.fadeIn)

                Stack {}
                    .htmlAttribute("id", "landing-posts-root")
                    .animateOnScroll(.slideUp, duration: 0.5)

                RawTextNode(landingPostsScript)
            }
            .flex(.column, gap: 24)
            .padding(80, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(60, at: .vertical).padding(20, at: .horizontal) }
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }
}

private let landingPostsScript = """
<script>
(function() {
  var root = document.getElementById('landing-posts-root');
  if (!root) return;

  root.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:var(--color-muted);';
  root.textContent = 'Loading posts...';

  fetch('/api/public/posts')
    .then(function(res) {
      if (!res.ok) throw new Error('failed');
      return res.json();
    })
    .then(function(posts) {
      root.textContent = '';

      if (!posts || posts.length === 0) {
        root.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:var(--color-muted);';
        root.textContent = 'No posts yet \\u2014 be the first to write something.';
        return;
      }

      var top6 = posts.slice(0, 6);
      var grid = document.createElement('div');
      grid.style.cssText = 'display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:20px;';

      top6.forEach(function(post) {
        var card = document.createElement('div');
        card.style.cssText = 'background:var(--color-elevated);border:1px solid var(--color-border);border-radius:8px;padding:24px;display:flex;flex-direction:column;gap:8px;';

        var pub = post.publishedAt
          ? new Date(post.publishedAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
          : '';

        var raw = post.body || '';
        var excerpt = raw.length > 160 ? raw.slice(0, 160) + '\\u2026' : raw;

        var titleLink = document.createElement('a');
        titleLink.href = '/@' + encodeURIComponent(post.authorId) + '/' + encodeURIComponent(post.slug);
        titleLink.style.cssText = 'font-family:var(--font-serif);font-size:20px;font-weight:300;color:var(--color-text);text-decoration:none;';
        titleLink.textContent = post.title;
        card.appendChild(titleLink);

        var excerptEl = document.createElement('p');
        excerptEl.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:var(--color-muted);margin:0;flex:1;line-height:1.6;';
        excerptEl.textContent = excerpt;
        card.appendChild(excerptEl);

        var meta = document.createElement('div');
        meta.style.cssText = 'display:flex;gap:6px;align-items:center;font-family:var(--font-mono);font-size:11px;color:var(--color-muted);flex-wrap:wrap;margin-top:4px;';

        var authorSpan = document.createElement('span');
        authorSpan.textContent = post.authorId;
        meta.appendChild(authorSpan);

        if (pub) {
          var dot = document.createElement('span');
          dot.textContent = '\\u00b7';
          meta.appendChild(dot);
          var dateSpan = document.createElement('span');
          dateSpan.textContent = pub;
          meta.appendChild(dateSpan);
        }

        var dot2 = document.createElement('span');
        dot2.textContent = '\\u00b7';
        meta.appendChild(dot2);

        var readSpan = document.createElement('span');
        readSpan.textContent = (post.estimatedReadMinutes || 1) + ' min read';
        meta.appendChild(readSpan);

        card.appendChild(meta);
        grid.appendChild(card);
      });

      root.appendChild(grid);
    })
    .catch(function() {
      root.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:var(--color-muted);';
      root.textContent = 'Could not load posts.';
    });
})();
</script>
"""
