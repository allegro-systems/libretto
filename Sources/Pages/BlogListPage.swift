import Score
import ScoreLucide

struct BlogListPage: Page {
    static let path = "/blog"

    var body: some Node {
        Stack {
            NavBar()

            Section {
                // Header
                Stack {
                    Heading(.two) { "All Posts" }
                        .font(.serif, size: 32, weight: .semibold, color: .text)

                    Paragraph { "Stories, ideas, and perspectives from our community of writers." }
                        .font(.sans, size: 15, color: .muted)
                }
                .flex(.column, gap: 8)

                Stack {}
                    .htmlAttribute("id", "blog-list-root")

                RawTextNode(blogListScript)
            }
            .flex(.column, gap: 40)
            .padding(48)
            .compact { $0.padding(24) }
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

  root.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);';
  root.textContent = 'Loading posts...';

  fetch('/api/public/posts')
    .then(function(res) {
      if (!res.ok) throw new Error('failed');
      return res.json();
    })
    .then(function(posts) {
      root.textContent = '';

      if (!posts || posts.length === 0) {
        root.style.cssText = 'font-family:var(--font-sans);font-size:15px;color:var(--color-muted);text-align:center;padding:80px 0;';
        root.textContent = 'No posts yet.';
        return;
      }

      var style = document.createElement('style');
      style.textContent = '@media(max-width:900px){#blog-list-root .blog-grid{grid-template-columns:repeat(2,1fr)!important}}@media(max-width:600px){#blog-list-root .blog-grid{grid-template-columns:1fr!important}}';
      root.appendChild(style);

      var grid = document.createElement('div');
      grid.className = 'blog-grid';
      grid.style.cssText = 'display:grid;grid-template-columns:repeat(3,1fr);gap:24px;';

      posts.forEach(function(post) {
        var card = document.createElement('a');
        card.href = '/@' + encodeURIComponent(post.authorId) + '/' + encodeURIComponent(post.slug);
        card.style.cssText = 'background:var(--color-surface);border:1px solid var(--color-border);padding:24px;display:flex;flex-direction:column;gap:16px;text-decoration:none;transition:background 0.15s;';
        card.onmouseenter = function() { card.style.background = 'var(--color-elevated)'; };
        card.onmouseleave = function() { card.style.background = 'var(--color-surface)'; };

        // Title
        var title = document.createElement('div');
        title.style.cssText = 'font-family:var(--font-serif);font-size:18px;font-weight:600;color:var(--color-text);line-height:1.3;';
        title.textContent = post.title;
        card.appendChild(title);

        // Excerpt
        var raw = post.excerpt || post.body || '';
        var excerpt = raw.length > 160 ? raw.slice(0, 160) + '\\u2026' : raw;
        var excerptEl = document.createElement('p');
        excerptEl.style.cssText = 'font-family:var(--font-sans);font-size:14px;color:var(--color-muted);margin:0;flex:1;line-height:1.5;';
        excerptEl.textContent = excerpt;
        card.appendChild(excerptEl);

        // Meta row
        var meta = document.createElement('div');
        meta.style.cssText = 'display:flex;gap:12px;align-items:center;font-family:var(--font-sans);font-size:12px;color:var(--color-muted);flex-wrap:wrap;';

        var avatar = document.createElement('div');
        avatar.style.cssText = 'width:24px;height:24px;border-radius:50%;background:var(--color-accent);flex-shrink:0;';
        meta.appendChild(avatar);

        var authorSpan = document.createElement('span');
        authorSpan.textContent = post.authorId;
        meta.appendChild(authorSpan);

        var pub = post.publishedAt
          ? new Date(post.publishedAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
          : '';

        if (pub) {
          appendDot(meta);
          var dateSpan = document.createElement('span');
          dateSpan.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);';
          dateSpan.textContent = pub;
          meta.appendChild(dateSpan);
        }

        appendDot(meta);
        var readSpan = document.createElement('span');
        readSpan.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);';
        readSpan.textContent = (post.estimatedReadMinutes || 1) + ' min';
        meta.appendChild(readSpan);

        if (typeof post.likeCount === 'number') {
          appendDot(meta);
          var heartIcon = document.createElement('i');
          heartIcon.className = 'lucide lucide-heart';
          heartIcon.style.cssText = 'font-size:14px;color:var(--color-dimmer);';
          meta.appendChild(heartIcon);
          var likeSpan = document.createElement('span');
          likeSpan.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);';
          likeSpan.textContent = post.likeCount;
          meta.appendChild(likeSpan);
        }

        card.appendChild(meta);
        grid.appendChild(card);
      });

      root.appendChild(grid);
    })
    .catch(function() {
      root.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);';
      root.textContent = 'Failed to load posts.';
    });

  function appendDot(parent) {
    var d = document.createElement('span');
    d.style.cssText = 'color:var(--color-dimmer);font-size:12px;';
    d.textContent = '\\u00b7';
    parent.appendChild(d);
  }
})();
</script>
"""
