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
// LikeButton mount
function mountLikeButton(postId, container) {
  container.innerHTML = '<button id="like-heart-' + postId + '" onclick="handleLike(\\'' + postId + '\\')" style="background:none;border:none;cursor:pointer;font-size:22px;padding:0;line-height:1;color:#aaa;" aria-label="Like" title="Like">&#9825;</button> <span id="like-count-' + postId + '" style="font-size:14px;color:#666;">...</span>';
  // Fetch initial state
  fetch('/api/likes/' + encodeURIComponent(postId), { credentials: 'same-origin' })
    .then(function(res) { return res.ok ? res.json() : null; })
    .then(function(data) {
      if (!data) return;
      var btn = document.getElementById('like-heart-' + postId);
      var countEl = document.getElementById('like-count-' + postId);
      if (btn) { btn.textContent = data.liked ? '\\u2665' : '\\u2661'; btn.style.color = data.liked ? '#e53e3e' : '#aaa'; }
      if (countEl) countEl.textContent = data.count;
    })
    .catch(function() {
      var countEl = document.getElementById('like-count-' + postId);
      if (countEl) countEl.textContent = '0';
    });
}
window.handleLike = function(postId) {
  fetch('/api/likes/' + encodeURIComponent(postId), { method: 'POST', credentials: 'same-origin' })
    .then(function(res) {
      if (res.status === 401 || res.redirected) { window.location.href = '/login'; return null; }
      return res.json();
    })
    .then(function(data) {
      if (!data) return;
      var btn = document.getElementById('like-heart-' + postId);
      var countEl = document.getElementById('like-count-' + postId);
      if (btn) { btn.textContent = data.liked ? '\\u2665' : '\\u2661'; btn.style.color = data.liked ? '#e53e3e' : '#aaa'; }
      if (countEl) countEl.textContent = data.count;
    })
    .catch(function() {});
};

// CommentList mount
function mountCommentList(postId, container) {
  container.innerHTML = '<h3 style="font-size:18px;font-weight:600;margin-bottom:16px;">Comments</h3><div id="comments-items-' + postId + '" style="display:flex;flex-direction:column;gap:16px;"></div><div style="margin-top:24px;"><textarea id="comment-input-' + postId + '" placeholder="Add a comment\\u2026" rows="3" style="width:100%;padding:10px;border:1px solid #ddd;border-radius:6px;font-size:14px;resize:vertical;box-sizing:border-box;"></textarea><button onclick="submitComment(\\'' + postId + '\\')" style="margin-top:8px;padding:8px 18px;background:#111;color:#fff;border:none;border-radius:6px;font-size:14px;cursor:pointer;">Post comment</button><span id="comment-error-' + postId + '" style="margin-left:10px;font-size:13px;color:#c00;"></span></div>';
  loadComments(postId);
}
function renderComment(c, listEl) {
  var el = document.createElement('div');
  el.style.cssText = 'padding:12px 16px;background:#f9f9f9;border-radius:6px;';
  var meta = document.createElement('div');
  meta.style.cssText = 'font-size:13px;color:#666;margin-bottom:6px;';
  var d = new Date(c.createdAt);
  meta.textContent = (c.authorName || c.authorId) + ' · ' + d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
  var body = document.createElement('p');
  body.style.cssText = 'margin:0;font-size:14px;line-height:1.6;white-space:pre-wrap;';
  body.textContent = c.body;
  el.appendChild(meta);
  el.appendChild(body);
  listEl.appendChild(el);
}
function loadComments(postId) {
  var listEl = document.getElementById('comments-items-' + postId);
  if (!listEl) return;
  fetch('/api/comments/' + encodeURIComponent(postId))
    .then(function(res) { return res.json(); })
    .then(function(comments) {
      listEl.textContent = '';
      if (!comments || comments.length === 0) {
        var empty = document.createElement('p');
        empty.style.cssText = 'font-size:14px;color:#999;';
        empty.textContent = 'No comments yet. Be the first!';
        listEl.appendChild(empty);
        return;
      }
      comments.forEach(function(c) { renderComment(c, listEl); });
    })
    .catch(function() {});
}
window.submitComment = function(postId) {
  var input = document.getElementById('comment-input-' + postId);
  var errEl = document.getElementById('comment-error-' + postId);
  var body = input ? input.value.trim() : '';
  if (!body) { if (errEl) errEl.textContent = 'Comment cannot be empty.'; return; }
  fetch('/api/comments/' + encodeURIComponent(postId), {
    method: 'POST', credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ body: body })
  })
    .then(function(res) {
      if (res.status === 401 || res.redirected) { window.location.href = '/login'; return null; }
      if (!res.ok) { return res.json().then(function(e) { throw new Error(e.error || 'Failed'); }); }
      return res.json();
    })
    .then(function(comment) {
      if (!comment) return;
      if (errEl) errEl.textContent = '';
      if (input) input.value = '';
      var listEl = document.getElementById('comments-items-' + postId);
      if (listEl && listEl.querySelector('p')) { listEl.textContent = ''; }
      if (listEl) renderComment(comment, listEl);
    })
    .catch(function(err) { if (errEl) errEl.textContent = err.message || 'Failed.'; });
};

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

      // LikeButton (L8)
      var likeDiv = document.createElement('div');
      likeDiv.id = 'post-like-btn';
      likeDiv.style.marginTop = '40px';
      article.appendChild(likeDiv);
      mountLikeButton(post.id, likeDiv);

      // CommentList (L8)
      var commentsDiv = document.createElement('div');
      commentsDiv.id = 'post-comments';
      commentsDiv.style.marginTop = '40px';
      article.appendChild(commentsDiv);
      mountCommentList(post.id, commentsDiv);

      root.appendChild(article);
    })
    .catch(function() {
      root.textContent = 'Post not found.';
    });
})();
</script>
"""
