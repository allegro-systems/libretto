import Score

struct LikeButton: Node {
    let postId: String
    let initialCount: Int
    let initialLiked: Bool

    var body: some Node {
        Stack {
            Stack {
                // SCORE-GAP: Button uses onclick handler for client-side fetch to toggle
                // like state. Needs @Action + client-side fetch support in Score.
                RawTextNode(likeHeartButton(postId: postId, initialLiked: initialLiked))
                Text { "\(initialCount)" }
                    .htmlAttribute("id", "like-count-\(postId)")
                    .font(.sans, size: 13, color: .muted)
            }
            .htmlAttribute("id", "like-btn-\(postId)")
            .flex(.row, gap: 8, align: .center)

            // SCORE-GAP: Client-side fetch for like toggling and DOM updates require raw JS.
            RawTextNode(likeScript(postId: postId, initialLiked: initialLiked))
        }
    }
}

private func likeHeartButton(postId: String, initialLiked: Bool) -> String {
    """
    <button
      onclick="handleLike('\(postId)')"
      id="like-heart-\(postId)"
      style="background:none;border:none;cursor:pointer;font-size:22px;padding:0;line-height:1;color:\(initialLiked ? "#e53e3e" : "var(--color-muted)");"
      aria-label="Like this post"
      title="Like"
    >\(initialLiked ? "\u{2665}" : "\u{2661}")</button>
    """
}

private func likeScript(postId: String, initialLiked: Bool) -> String {
    """
    <script>
    (function() {
      var _likedState = \(initialLiked ? "true" : "false");
      window.handleLike = function(postId) {
        var btn = document.getElementById('like-heart-' + postId);
        var countEl = document.getElementById('like-count-' + postId);
        fetch('/api/likes/' + encodeURIComponent(postId), { method: 'POST', credentials: 'same-origin' })
          .then(function(res) {
            if (res.status === 401 || res.redirected) {
              window.location.href = '/login';
              return null;
            }
            return res.json();
          })
          .then(function(data) {
            if (!data) return;
            _likedState = data.liked;
            btn.textContent = data.liked ? '\\u2665' : '\\u2661';
            btn.style.color = data.liked ? '#e53e3e' : 'var(--color-muted)';
            countEl.textContent = data.count;
          })
          .catch(function() {});
      };
    })();
    </script>
    """
}
