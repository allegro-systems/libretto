// SCORE-GAP: requires client-side fetch API, dynamic DOM creation, and event listeners.
// These shared JavaScript utilities consolidate duplicated client-side logic across components.

// MARK: - Date Formatting

/// Shared date formatting utility with named format presets.
/// Usage in JS: `formatDate(dateString, 'short')` or `formatDate(dateString, 'long')`
let sharedDateFormatScript = """
    function formatDate(dateStr, format) {
      if (!dateStr) return '';
      var d = new Date(dateStr);
      if (isNaN(d)) return '';
      var opts;
      switch (format) {
        case 'short':
          opts = { month: 'short', day: 'numeric' };
          break;
        case 'long':
          opts = { year: 'numeric', month: 'long', day: 'numeric' };
          break;
        case 'full':
          opts = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
          break;
        default:
          opts = { year: 'numeric', month: 'short', day: 'numeric' };
          break;
      }
      return d.toLocaleDateString('en-US', opts);
    }
    """

// MARK: - Comment Logic

/// Shared comment function definitions (renderComment, loadComments, window.submitComment).
/// These are pure function definitions with no side effects — call `loadComments(postId)` separately.
let sharedCommentFunctionsScript = """
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
      ts.textContent = formatDate(c.createdAt, 'default');
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
    """

// MARK: - Like Handler

/// Shared like handler script. Registers `window.handleLike` for the fetch-toggle-update-UI pattern.
let sharedLikeHandlerScript = """
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
          if (btn) {
            var ic = btn.querySelector('.lucide');
            if (ic) { ic.style.color = data.liked ? '#e53e3e' : 'var(--color-accent)'; }
            else { btn.textContent = data.liked ? '\\u2665' : '\\u2661'; btn.style.color = data.liked ? '#e53e3e' : 'var(--color-muted)'; }
          }
          if (countEl) countEl.textContent = data.count;
        })
        .catch(function() {});
    };
    """

// MARK: - Post Card Rendering

/// Shared post card DOM construction for feed/grid views.
/// - `layout`: `"grid"` for BlogListPage cards, `"feed"` for LandingPage cards
/// - `excerptLength`: max characters for the excerpt (e.g. 160 for grid, 200 for feed)
func sharedPostCardScript(layout: String = "grid", excerptLength: Int = 160) -> String {
    """
    function renderPostCard(post, index) {
      var layout = '\(layout)';
      var maxExcerpt = \(excerptLength);

      var card = document.createElement('a');
      card.href = '/@' + encodeURIComponent(post.authorId) + '/' + encodeURIComponent(post.slug);

      if (layout === 'feed') {
        card.style.cssText = 'display:flex;flex-direction:column;gap:12px;padding:24px 0;text-decoration:none;transition:opacity 0.15s;';
        if (index > 0) card.style.borderTop = '1px solid var(--color-border)';
        card.onmouseenter = function() { card.style.opacity = '0.8'; };
        card.onmouseleave = function() { card.style.opacity = '1'; };

        // Author row
        var authorRow = document.createElement('div');
        authorRow.style.cssText = 'display:flex;gap:10px;align-items:center;';
        var avatar = document.createElement('div');
        avatar.style.cssText = 'width:28px;height:28px;border-radius:50%;background:var(--color-accent);flex-shrink:0;';
        authorRow.appendChild(avatar);
        var authorInfo = document.createElement('div');
        authorInfo.style.cssText = 'display:flex;flex-direction:column;gap:1px;';
        var authorName = document.createElement('span');
        authorName.style.cssText = 'font-family:var(--font-sans);font-size:13px;font-weight:500;color:var(--color-text);';
        authorName.textContent = post.authorId;
        authorInfo.appendChild(authorName);
        var pub = formatDate(post.publishedAt, 'short');
        if (pub) {
          var dateSpan = document.createElement('span');
          dateSpan.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);';
          dateSpan.textContent = pub;
          authorInfo.appendChild(dateSpan);
        }
        authorRow.appendChild(authorInfo);
        card.appendChild(authorRow);
      } else {
        card.style.cssText = 'background:var(--color-surface);border:1px solid var(--color-border);padding:24px;display:flex;flex-direction:column;gap:16px;text-decoration:none;transition:background 0.15s;';
        card.onmouseenter = function() { card.style.background = 'var(--color-elevated)'; };
        card.onmouseleave = function() { card.style.background = 'var(--color-surface)'; };
      }

      // Title
      var title = document.createElement('div');
      title.style.cssText = layout === 'feed'
        ? 'font-family:var(--font-serif);font-size:20px;font-weight:600;color:var(--color-text);line-height:1.3;'
        : 'font-family:var(--font-serif);font-size:18px;font-weight:600;color:var(--color-text);line-height:1.3;';
      title.textContent = post.title;
      card.appendChild(title);

      // Excerpt
      var raw = post.excerpt || post.body || '';
      var excerpt = raw.length > maxExcerpt ? raw.slice(0, maxExcerpt) + '\\u2026' : raw;
      var excerptEl = document.createElement('p');
      excerptEl.style.cssText = layout === 'feed'
        ? 'font-family:var(--font-sans);font-size:14px;color:var(--color-muted);margin:0;line-height:1.6;'
        : 'font-family:var(--font-sans);font-size:14px;color:var(--color-muted);margin:0;flex:1;line-height:1.5;';
      excerptEl.textContent = excerpt;
      card.appendChild(excerptEl);

      // Meta row
      var meta = document.createElement('div');
      if (layout === 'feed') {
        meta.style.cssText = 'display:flex;gap:16px;align-items:center;font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);margin-top:4px;';
        var readSpan = document.createElement('span');
        readSpan.textContent = (post.estimatedReadMinutes || 1) + ' min read';
        meta.appendChild(readSpan);
        if (typeof post.likeCount === 'number') {
          var likeSpan = document.createElement('span');
          likeSpan.textContent = '\\u2665 ' + post.likeCount;
          meta.appendChild(likeSpan);
        }
      } else {
        meta.style.cssText = 'display:flex;gap:12px;align-items:center;font-family:var(--font-sans);font-size:12px;color:var(--color-muted);flex-wrap:wrap;';
        var gridAvatar = document.createElement('div');
        gridAvatar.style.cssText = 'width:24px;height:24px;border-radius:50%;background:var(--color-accent);flex-shrink:0;';
        meta.appendChild(gridAvatar);
        var authorSpan = document.createElement('span');
        authorSpan.textContent = post.authorId;
        meta.appendChild(authorSpan);
        var gridPub = formatDate(post.publishedAt, 'short');
        if (gridPub) {
          appendDot(meta);
          var gridDateSpan = document.createElement('span');
          gridDateSpan.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);';
          gridDateSpan.textContent = gridPub;
          meta.appendChild(gridDateSpan);
        }
        appendDot(meta);
        var gridReadSpan = document.createElement('span');
        gridReadSpan.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);';
        gridReadSpan.textContent = (post.estimatedReadMinutes || 1) + ' min';
        meta.appendChild(gridReadSpan);
        if (typeof post.likeCount === 'number') {
          appendDot(meta);
          var heartIcon = document.createElement('i');
          heartIcon.className = 'lucide lucide-heart';
          heartIcon.style.cssText = 'font-size:14px;color:var(--color-dimmer);';
          meta.appendChild(heartIcon);
          var gridLikeSpan = document.createElement('span');
          gridLikeSpan.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);';
          gridLikeSpan.textContent = post.likeCount;
          meta.appendChild(gridLikeSpan);
        }
      }
      card.appendChild(meta);
      return card;
    }

    function appendDot(parent) {
      var d = document.createElement('span');
      d.style.cssText = 'color:var(--color-dimmer);font-size:12px;';
      d.textContent = '\\u00b7';
      parent.appendChild(d);
    }
    """
}

// MARK: - Avatar Placeholder

/// Shared avatar placeholder rendering in JavaScript.
/// Creates a circle with initials, matching the ProfileHeader Swift component.
let sharedAvatarPlaceholderScript = """
    function renderAvatarPlaceholder(container, displayName, size) {
      size = size || 72;
      var av = document.createElement('div');
      av.style.cssText = 'width:' + size + 'px;height:' + size + 'px;border-radius:50%;background:var(--color-accent);display:flex;align-items:center;justify-content:center;font-family:var(--font-sans);font-size:' + Math.round(size * 0.39) + 'px;font-weight:500;color:var(--color-bg)';
      av.textContent = (displayName || '?')[0].toUpperCase();
      container.appendChild(av);
      return av;
    }
    function renderAvatarOrPlaceholder(container, avatarURL, displayName, size) {
      size = size || 72;
      if (avatarURL) {
        var img = document.createElement('img');
        img.src = avatarURL;
        img.alt = displayName || '';
        img.style.cssText = 'width:' + size + 'px;height:' + size + 'px;border-radius:50%;object-fit:cover';
        container.appendChild(img);
        return img;
      }
      return renderAvatarPlaceholder(container, displayName, size);
    }
    """
