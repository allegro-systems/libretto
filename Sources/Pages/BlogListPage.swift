import Score

struct BlogListPage: Page {
    static let path = "/blog"

    var body: some Node {
        Stack {
            // Hero
            Section {
                Heading(.one) { "Blog" }
                    .font(.serif, size: 56, weight: .light, lineHeight: 1.15, color: .text, align: .center)
                    .size(maxWidth: 740)
                    .compact { $0.font(size: 36) }
                    .animate(.fadeIn, duration: 0.6)

                Paragraph { "Stories and ideas from the community." }
                    .font(.mono, size: 15, lineHeight: 1.6, color: .muted, align: .center)
                    .size(maxWidth: 580)
                    .compact { $0.font(size: 13) }
                    .animate(.fadeIn, duration: 0.6, delay: 0.15)
            }
            .flex(.column, gap: 28, align: .center)
            .padding(120, at: .vertical)
            .padding(56, at: .horizontal)
            .backgroundGradient(.radial(color: .libretto, opacity: 0.04, width: 120, height: 80, at: .top))
            .compact { $0.padding(80, at: .vertical).padding(20, at: .horizontal) }

            HorizontalRule().background(.border).size(height: 1).border(width: 0, color: .border, style: .none)

            // Posts
            Section {
                Text { "ALL POSTS" }
                    .font(.mono, size: 12, weight: .medium, tracking: 3, color: .muted, transform: .uppercase)
                    .animateOnScroll(.fadeIn)

                Stack {}
                    .htmlAttribute("id", "blog-list-root")
                    .animateOnScroll(.slideUp, duration: 0.5)

                RawTextNode(blogListScript)
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

private let blogListScript = """
<script>
(function() {
  var root = document.getElementById('blog-list-root');
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
        root.textContent = 'No posts yet.';
        return;
      }

      var list = document.createElement('div');
      list.style.cssText = 'display:flex;flex-direction:column;gap:16px;';

      posts.forEach(function(post) {
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
        excerptEl.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:var(--color-muted);margin:0;line-height:1.6;';
        excerptEl.textContent = excerpt;
        card.appendChild(excerptEl);

        var meta = document.createElement('div');
        meta.style.cssText = 'display:flex;gap:6px;align-items:center;font-family:var(--font-mono);font-size:11px;color:var(--color-muted);flex-wrap:wrap;';

        var authorSpan = document.createElement('span');
        authorSpan.textContent = post.authorId;
        meta.appendChild(authorSpan);

        ['\\u00b7', pub, '\\u00b7', (post.estimatedReadMinutes || 1) + ' min read', '\\u00b7', (post.likeCount || 0) + ' likes'].forEach(function(t) {
          var s = document.createElement('span');
          s.textContent = t;
          meta.appendChild(s);
        });

        card.appendChild(meta);
        list.appendChild(card);
      });

      root.appendChild(list);
    })
    .catch(function() {
      root.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:var(--color-muted);';
      root.textContent = 'Failed to load posts.';
    });
})();
</script>
"""
