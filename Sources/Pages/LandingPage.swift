import Score

struct LandingPage: Page {
    static let path = "/"

    var body: some Node {
        Stack {
            // Hero section
            Stack {
                Heading(.one) { "Libretto" }
                    .font(.sans, size: 56, weight: .bold)

                Paragraph { "Write. Publish. Connect." }
                    .font(.sans, size: 22, color: .muted)

                Stack {
                    Link(to: "/login") { "Start Writing" }
                        .font(.sans, size: 16, weight: .semibold, decoration: TextDecoration.none)
                        .padding(12, at: .vertical)
                        .padding(24, at: .horizontal)
                        .background(ColorToken("accent"))
                        .radius(8)

                    Link(to: "/blog") { "Read Blog" }
                        .font(.sans, size: 16, weight: .semibold, decoration: TextDecoration.none)
                        .padding(12, at: .vertical)
                        .padding(24, at: .horizontal)
                        .background(ColorToken("elevated"))
                        .radius(8)
                }
                .flex(.row, gap: 16)
            }
            .flex(.column, gap: 20)
            .padding(80, at: .vertical)
            .htmlAttribute("style", "align-items:center;text-align:center;")

            // Featured posts section
            Stack {
                Heading(.two) { "Recent Posts" }
                    .font(.sans, size: 28, weight: .bold)

                Stack {}
                    .htmlAttribute("id", "landing-posts-root")

                RawTextNode(landingPostsScript)
            }
            .flex(.column, gap: 24)
        }
        .flex(.column, gap: 0)
        .padding(40)
        .htmlAttribute("style", "max-width:900px;margin:0 auto;")
    }
}

private let landingPostsScript = """
<script>
(function() {
  var root = document.getElementById('landing-posts-root');
  if (!root) return;

  root.textContent = 'Loading posts...';

  fetch('/api/public/posts')
    .then(function(res) {
      if (!res.ok) throw new Error('failed');
      return res.json();
    })
    .then(function(posts) {
      root.textContent = '';

      if (!posts || posts.length === 0) {
        root.style.cssText = 'color:#888;font-size:15px;';
        root.textContent = 'No posts yet — be the first to write something.';
        return;
      }

      var top6 = posts.slice(0, 6);
      var grid = document.createElement('div');
      grid.style.cssText = 'display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:20px;';

      top6.forEach(function(post) {
        var card = document.createElement('div');
        card.style.cssText = 'padding:20px;background:var(--color-elevated,#f7f7f9);border-radius:8px;display:flex;flex-direction:column;gap:8px;';

        var pub = post.publishedAt
          ? new Date(post.publishedAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
          : '';

        var raw = post.body || '';
        var excerpt = raw.length > 160 ? raw.slice(0, 160) + '\\u2026' : raw;

        var titleLink = document.createElement('a');
        titleLink.href = '/@' + encodeURIComponent(post.authorId) + '/' + encodeURIComponent(post.slug);
        titleLink.style.cssText = 'font-size:18px;font-weight:600;text-decoration:none;color:inherit;';
        titleLink.textContent = post.title;
        card.appendChild(titleLink);

        var excerptEl = document.createElement('p');
        excerptEl.style.cssText = 'font-size:14px;color:#666;margin:0;flex:1;';
        excerptEl.textContent = excerpt;
        card.appendChild(excerptEl);

        var meta = document.createElement('div');
        meta.style.cssText = 'display:flex;gap:6px;align-items:center;font-size:12px;color:#888;flex-wrap:wrap;margin-top:4px;';

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
      root.style.cssText = 'color:#888;font-size:15px;';
      root.textContent = 'Could not load posts.';
    });
})();
</script>
"""
