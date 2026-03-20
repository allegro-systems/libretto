import Score

struct PostPage: Page {
    static let path = "/post"

    var body: some Node {
        Stack {
            Stack {}
                .htmlAttribute("id", "post-root")

            RawTextNode(postPageScript)
        }
        .flex(.column, gap: 0)
        .padding(40)
    }
}

private let postPageScript = """
<script>
(function() {
  var root = document.getElementById('post-root');
  if (!root) return;

  var parts = window.location.pathname.split('/').filter(Boolean);
  var username = null;
  var slug = null;

  if (parts.length >= 2 && parts[0].startsWith('@')) {
    username = parts[0].slice(1);
    slug = parts[1];
  } else {
    var params = new URLSearchParams(window.location.search);
    slug = params.get('slug');
    username = params.get('username');
  }

  if (!slug) {
    root.textContent = 'Post not found.';
    return;
  }

  root.textContent = 'Loading...';

  fetch('/api/public/post/' + encodeURIComponent(slug))
    .then(function(res) {
      if (!res.ok) throw new Error('not found');
      return res.json();
    })
    .then(function(post) {
      var pub = post.publishedAt
        ? new Date(post.publishedAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
        : '';

      root.textContent = '';

      var article = document.createElement('article');
      article.style.cssText = 'max-width:720px;margin:0 auto;';

      var h1 = document.createElement('h1');
      h1.style.cssText = 'font-size:2rem;font-weight:700;margin-bottom:12px;';
      h1.textContent = post.title;
      article.appendChild(h1);

      var meta = document.createElement('div');
      meta.style.cssText = 'display:flex;gap:8px;align-items:center;font-size:14px;color:#666;margin-bottom:32px;flex-wrap:wrap;';

      var authorLink = document.createElement('a');
      authorLink.href = '/@' + encodeURIComponent(post.authorId);
      authorLink.style.cssText = 'font-weight:500;text-decoration:none;';
      authorLink.textContent = post.authorId;
      meta.appendChild(authorLink);

      ['·', pub, '·', (post.estimatedReadMinutes || 1) + ' min read', '·', (post.likeCount || 0) + ' likes'].forEach(function(t) {
        var s = document.createElement('span');
        s.textContent = t;
        meta.appendChild(s);
      });

      article.appendChild(meta);

      var bodyEl = document.createElement('div');
      bodyEl.style.cssText = 'line-height:1.75;font-size:16px;white-space:pre-wrap;';
      bodyEl.textContent = post.body;
      article.appendChild(bodyEl);

      // LikeButton placeholder (L8)
      var likeDiv = document.createElement('div');
      likeDiv.id = 'post-like-btn';
      likeDiv.style.marginTop = '40px';
      article.appendChild(likeDiv);

      // CommentList placeholder (L8)
      var commentsDiv = document.createElement('div');
      commentsDiv.id = 'post-comments';
      commentsDiv.style.marginTop = '40px';
      article.appendChild(commentsDiv);

      root.appendChild(article);
    })
    .catch(function() {
      root.textContent = 'Post not found.';
    });
})();
</script>
"""
