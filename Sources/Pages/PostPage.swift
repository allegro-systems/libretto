import Score

struct PostPage: Page {
    static let path = "/post"

    var body: some Node {
        Stack {
            NavBar()

            Stack {}
                .htmlAttribute("id", "post-root")

            RawTextNode(postPageScript)
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }
}

private let postPageScript = """
<script>
// LikeButton mount
function mountLikeButton(postId, container) {
  container.innerHTML = '<button id="like-heart-' + postId + '" onclick="handleLike(\\'' + postId + '\\')" style="display:inline-flex;align-items:center;gap:8px;height:40px;padding:0 20px;border:1px solid var(--color-border);border-radius:0;background:none;cursor:pointer;" aria-label="Like" title="Like"><i class="lucide lucide-heart" style="font-size:18px;color:var(--color-accent);"></i> <span id="like-count-' + postId + '" style="font-family:var(--font-mono);font-size:13px;color:var(--color-text);">...</span></button>';
  fetch('/api/likes/' + encodeURIComponent(postId), { credentials: 'same-origin' })
    .then(function(res) { return res.ok ? res.json() : null; })
    .then(function(data) {
      if (!data) return;
      var btn = document.getElementById('like-heart-' + postId);
      var countEl = document.getElementById('like-count-' + postId);
      if (btn) { var ic = btn.querySelector('.lucide'); if (ic) ic.style.color = data.liked ? '#e53e3e' : 'var(--color-accent)'; }
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
      if (btn) { var ic = btn.querySelector('.lucide'); if (ic) ic.style.color = data.liked ? '#e53e3e' : 'var(--color-accent)'; }
      if (countEl) countEl.textContent = data.count;
    })
    .catch(function() {});
};

// CommentList mount
function mountCommentList(postId, container) {
  container.innerHTML = '<h3 style="font-family:var(--font-serif);font-size:22px;font-weight:600;color:var(--color-text);margin-bottom:16px;">Comments</h3><div id="comments-items-' + postId + '" style="display:flex;flex-direction:column;gap:16px;"></div><div style="margin-top:24px;"><textarea id="comment-input-' + postId + '" placeholder="Add a comment\\u2026" rows="3" style="width:100%;padding:14px;border:1px solid var(--color-border);border-radius:8px;font-family:var(--font-sans);font-size:14px;color:var(--color-text);background:var(--color-elevated);resize:vertical;box-sizing:border-box;"></textarea><div style="margin-top:8px;display:flex;align-items:center;gap:10px;"><button onclick="submitComment(\\'' + postId + '\\')" style="padding:10px 20px;background:var(--color-accent);color:var(--color-bg);border:none;border-radius:6px;font-family:var(--font-sans);font-size:13px;font-weight:500;cursor:pointer;">Post Comment</button><span id="comment-error-' + postId + '" style="font-family:var(--font-sans);font-size:13px;color:#e53e3e;"></span></div></div>';
  loadComments(postId);
}
function renderComment(c, listEl) {
  var el = document.createElement('div');
  el.style.cssText = 'padding:24px;background:var(--color-elevated);border:1px solid var(--color-border);border-radius:8px;';
  var meta = document.createElement('div');
  meta.style.cssText = 'font-family:var(--font-sans);font-size:11px;color:var(--color-muted);margin-bottom:8px;';
  var d = new Date(c.createdAt);
  meta.textContent = (c.authorName || c.authorId) + ' \\u00b7 ' + d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
  var body = document.createElement('p');
  body.style.cssText = 'margin:0;font-family:var(--font-sans);font-size:14px;line-height:1.6;color:var(--color-text);white-space:pre-wrap;';
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
        empty.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);';
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

  root.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);padding:48px;';
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
      root.style.cssText = 'padding:48px;';

      var article = document.createElement('article');
      article.style.cssText = 'max-width:720px;margin:0 auto;';

      // Author row
      var authorRow = document.createElement('div');
      authorRow.style.cssText = 'display:flex;gap:12px;align-items:center;margin-bottom:24px;';

      var avatar = document.createElement('div');
      avatar.style.cssText = 'width:48px;height:48px;border-radius:50%;background:var(--color-accent);flex-shrink:0;';
      authorRow.appendChild(avatar);

      var authorInfo = document.createElement('div');
      authorInfo.style.cssText = 'display:flex;flex-direction:column;gap:2px;';

      var authorLink = document.createElement('a');
      authorLink.href = '/@' + encodeURIComponent(post.authorId);
      authorLink.style.cssText = 'font-family:var(--font-sans);font-size:14px;font-weight:500;text-decoration:none;color:var(--color-text);';
      authorLink.textContent = post.authorId;
      authorInfo.appendChild(authorLink);

      var dateLine = document.createElement('span');
      dateLine.style.cssText = 'font-family:var(--font-sans);font-size:12px;color:var(--color-muted);';
      dateLine.textContent = pub + ' \\u00b7 ' + (post.estimatedReadMinutes || 1) + ' min read';
      authorInfo.appendChild(dateLine);

      authorRow.appendChild(authorInfo);
      article.appendChild(authorRow);

      // Title
      var h1 = document.createElement('h1');
      h1.style.cssText = 'font-family:var(--font-serif);font-size:32px;font-weight:700;line-height:1.2;color:var(--color-text);margin-bottom:24px;';
      h1.textContent = post.title;
      article.appendChild(h1);

      // Body
      var bodyEl = document.createElement('div');
      bodyEl.style.cssText = 'line-height:1.75;font-family:var(--font-sans);font-size:15px;color:var(--color-text);white-space:pre-wrap;';
      bodyEl.textContent = post.body;
      article.appendChild(bodyEl);

      // LikeButton
      var likeDiv = document.createElement('div');
      likeDiv.id = 'post-like-btn';
      likeDiv.style.marginTop = '40px';
      article.appendChild(likeDiv);
      mountLikeButton(post.id, likeDiv);

      // CommentList
      var commentsDiv = document.createElement('div');
      commentsDiv.id = 'post-comments';
      commentsDiv.style.marginTop = '40px';
      article.appendChild(commentsDiv);
      mountCommentList(post.id, commentsDiv);

      root.appendChild(article);
    })
    .catch(function() {
      root.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);padding:48px;';
      root.textContent = 'Post not found.';
    });
})();
</script>
"""
