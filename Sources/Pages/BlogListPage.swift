import Score

struct BlogListPage: Page {
    static let path = "/blog"

    var body: some Node {
        Stack {
            Heading(.one) { "Blog" }
                .font(.sans, size: 32, weight: .bold)

            Stack {}
                .htmlAttribute("id", "blog-list-root")

            RawTextNode(blogListScript)
        }
        .flex(.column, gap: 24)
        .padding(40)
    }
}

private let blogListScript = """
<script>
(function() {
  var root = document.getElementById('blog-list-root');
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
        root.textContent = 'No posts yet.';
        return;
      }

      var list = document.createElement('div');
      list.style.cssText = 'display:flex;flex-direction:column;gap:16px;';

      posts.forEach(function(post) {
        var card = document.createElement('div');
        card.style.cssText = 'padding:20px;background:#f7f7f9;border-radius:8px;display:flex;flex-direction:column;gap:8px;';

        var pub = post.publishedAt
          ? new Date(post.publishedAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
          : '';

        var raw = post.body || '';
        var excerpt = raw.length > 160 ? raw.slice(0, 160) + '…' : raw;

        var titleLink = document.createElement('a');
        titleLink.href = '/@' + encodeURIComponent(post.authorId) + '/' + encodeURIComponent(post.slug);
        titleLink.style.cssText = 'font-size:18px;font-weight:600;text-decoration:none;';
        titleLink.textContent = post.title;
        card.appendChild(titleLink);

        var excerptEl = document.createElement('p');
        excerptEl.style.cssText = 'font-size:14px;color:#666;margin:0;';
        excerptEl.textContent = excerpt;
        card.appendChild(excerptEl);

        var meta = document.createElement('div');
        meta.style.cssText = 'display:flex;gap:6px;align-items:center;font-size:13px;color:#888;flex-wrap:wrap;';

        var authorSpan = document.createElement('span');
        authorSpan.textContent = post.authorId;
        meta.appendChild(authorSpan);

        ['·', pub, '·', (post.estimatedReadMinutes || 1) + ' min read', '·', (post.likeCount || 0) + ' likes'].forEach(function(t) {
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
      root.textContent = 'Failed to load posts.';
    });
})();
</script>
"""
