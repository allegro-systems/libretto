import Score

struct CommentList: Node {
    let postId: String

    var body: some Node {
        Stack {
            RawTextNode(commentListScript(postId: postId))
        }
    }
}

private func commentListScript(postId: String) -> String {
    """
    <div id="comment-list-\(postId)">
      <h3 style="font-family:var(--font-serif);font-size:22px;font-weight:600;color:var(--color-text);margin-bottom:16px;">Comments</h3>
      <div id="comments-items-\(postId)" style="display:flex;flex-direction:column;gap:16px;"></div>
      <div style="margin-top:24px;">
        <textarea
          id="comment-input-\(postId)"
          placeholder="Add a comment\u{2026}"
          rows="3"
          style="width:100%;padding:14px;border:1px solid var(--color-border);border-radius:8px;font-family:var(--font-sans);font-size:14px;color:var(--color-text);background:var(--color-elevated);resize:vertical;box-sizing:border-box;"
        ></textarea>
        <div style="margin-top:8px;display:flex;align-items:center;gap:10px;">
          <button
            onclick="submitComment('\(postId)')"
            style="padding:10px 20px;background:var(--color-accent);color:var(--color-bg);border:none;border-radius:6px;font-family:var(--font-sans);font-size:13px;font-weight:500;cursor:pointer;"
          >Post Comment</button>
          <span id="comment-error-\(postId)" style="font-family:var(--font-sans);font-size:13px;color:#e53e3e;"></span>
        </div>
      </div>
    </div>
    <script>
    (function() {
      function renderComment(c, container) {
        var el = document.createElement('div');
        el.style.cssText = 'padding:24px;background:var(--color-elevated);border:1px solid var(--color-border);border-radius:8px;';
        var meta = document.createElement('div');
        meta.style.cssText = 'font-family:var(--font-sans);font-size:11px;color:var(--color-muted);margin-bottom:8px;display:flex;gap:8px;align-items:center;';
        var author = document.createElement('span');
        author.style.fontWeight = '600';
        author.textContent = c.authorName || c.authorId;
        var sep = document.createElement('span');
        sep.textContent = '\\u00b7';
        var ts = document.createElement('span');
        var d = new Date(c.createdAt);
        ts.textContent = d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
        meta.appendChild(author);
        meta.appendChild(sep);
        meta.appendChild(ts);
        var body = document.createElement('p');
        body.style.cssText = 'margin:0;font-family:var(--font-sans);font-size:14px;line-height:1.6;color:var(--color-text);white-space:pre-wrap;';
        body.textContent = c.body;
        el.appendChild(meta);
        el.appendChild(body);
        container.appendChild(el);
      }

      function loadComments(postId) {
        var container = document.getElementById('comments-items-' + postId);
        if (!container) return;
        fetch('/api/comments/' + encodeURIComponent(postId))
          .then(function(res) { return res.json(); })
          .then(function(comments) {
            container.textContent = '';
            if (!comments || comments.length === 0) {
              var empty = document.createElement('p');
              empty.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);';
              empty.textContent = 'No comments yet. Be the first!';
              container.appendChild(empty);
              return;
            }
            comments.forEach(function(c) { renderComment(c, container); });
          })
          .catch(function() {});
      }

      window.submitComment = function(postId) {
        var input = document.getElementById('comment-input-' + postId);
        var errEl = document.getElementById('comment-error-' + postId);
        var body = input ? input.value.trim() : '';
        if (!body) {
          if (errEl) errEl.textContent = 'Comment cannot be empty.';
          return;
        }
        fetch('/api/comments/' + encodeURIComponent(postId), {
          method: 'POST',
          credentials: 'same-origin',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ body: body })
        })
          .then(function(res) {
            if (res.status === 401 || res.redirected) {
              window.location.href = '/login';
              return null;
            }
            if (!res.ok) { return res.json().then(function(e) { throw new Error(e.error || 'Failed'); }); }
            return res.json();
          })
          .then(function(comment) {
            if (!comment) return;
            if (errEl) errEl.textContent = '';
            if (input) input.value = '';
            var container = document.getElementById('comments-items-' + postId);
            if (container && container.querySelector('p')) { container.textContent = ''; }
            if (container) renderComment(comment, container);
          })
          .catch(function(err) {
            if (errEl) errEl.textContent = err.message || 'Failed to post comment.';
          });
      };

      loadComments('\(postId)');
    })();
    </script>
    """
}
