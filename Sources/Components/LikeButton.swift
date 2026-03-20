import Score

struct LikeButton: Node {
    let postId: String
    let initialCount: Int
    let initialLiked: Bool

    var body: some Node {
        Stack {
            RawTextNode(likeButtonScript(postId: postId, initialCount: initialCount, initialLiked: initialLiked))
        }
    }
}

private func likeButtonScript(postId: String, initialCount: Int, initialLiked: Bool) -> String {
    """
    <div id="like-btn-\(postId)" style="display:inline-flex;align-items:center;gap:8px;">
      <button
        onclick="handleLike('\(postId)')"
        id="like-heart-\(postId)"
        style="background:none;border:none;cursor:pointer;font-size:22px;padding:0;line-height:1;color:\(initialLiked ? "#e53e3e" : "#aaa");"
        aria-label="Like this post"
        title="Like"
      >\(initialLiked ? "♥" : "♡")</button>
      <span id="like-count-\(postId)" style="font-size:14px;color:#666;">\(initialCount)</span>
    </div>
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
            btn.style.color = data.liked ? '#e53e3e' : '#aaa';
            countEl.textContent = data.count;
          })
          .catch(function() {});
      };
    })();
    </script>
    """
}
