import Score
import ScoreLucide

struct LandingPage: Page {
    static let path = "/"

    var body: some Node {
        Stack {
            NavBar()

            // Main content area
            Stack {
                // Left column — feed
                Section {
                    // Section heading
                    Stack {
                        Icon("trending-up", size: 18, color: .accent)
                        Heading(.two) { "Recent Posts" }
                            .font(.serif, size: 24, weight: .semibold, color: .text)
                    }
                    .flex(.row, gap: 10, align: .center)

                    // Post feed — hydrated client-side
                    Stack {}
                        .htmlAttribute("id", "posts-root")

                    RawTextNode(postsScript)
                }
                .flex(.column, gap: 28)
                .flexItem(grow: 1)

                // Right sidebar — discover
                Aside {
                    // About block
                    Stack {
                        Paragraph { "Libretto is a writing platform where ideas find their audience. Read, write, and connect." }
                            .font(.sans, size: 13, lineHeight: 1.6, color: .muted)

                        Link(to: "/login") {
                            Text { "Start Writing" }
                        }
                        .font(.sans, size: 13, weight: .medium, color: .bg, align: .center, decoration: TextDecoration.none)
                        .size(width: .percent(100))
                        .padding(10, at: .vertical)
                        .background(.accent)
                        .radius(6)
                        .hover { $0.opacity(0.85) }
                    }
                    .flex(.column, gap: 16)
                    .padding(20)
                    .background(.surface)
                    .border(width: 1, color: .border, style: .solid)

                    // Topics
                    Stack {
                        Text { "TOPICS" }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .dimmer, transform: .uppercase)

                        Stack {
                            topicPill("Swift")
                            topicPill("Web Development")
                            topicPill("Design")
                            topicPill("Productivity")
                            topicPill("Open Source")
                            topicPill("Writing")
                        }
                        .flex(.row, gap: 8)
                        .htmlAttribute("style", "flex-wrap:wrap;")
                    }
                    .flex(.column, gap: 12)
                    .padding(20)
                    .background(.surface)
                    .border(width: 1, color: .border, style: .solid)
                }
                .flex(.column, gap: 16)
                .size(width: 280)
                .flexItem(shrink: 0)
                .compact { $0.hidden() }
            }
            .flex(.row, gap: 40)
            .padding(32, at: .vertical)
            .padding(48, at: .horizontal)
            .compact { $0.padding(24) }
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }
}

// MARK: - Sub-components

private func topicPill(_ label: String) -> some Node {
    Text { label }
        .font(.sans, size: 12, color: .muted)
        .padding(6, at: .vertical)
        .padding(12, at: .horizontal)
        .border(width: 1, color: .border, style: .solid, radius: 16)
        .hover { $0.background(.elevated).font(color: .text) }
}

// MARK: - Client Script

private let postsScript = """
<script>
(function() {
  var root = document.getElementById('posts-root');
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
        root.textContent = 'No posts yet \\u2014 be the first to write something.';
        return;
      }

      var feed = document.createElement('div');
      feed.style.cssText = 'display:flex;flex-direction:column;gap:0;';

      posts.forEach(function(post, i) {
        var card = document.createElement('a');
        card.href = '/@' + encodeURIComponent(post.authorId) + '/' + encodeURIComponent(post.slug);
        card.style.cssText = 'display:flex;flex-direction:column;gap:12px;padding:24px 0;text-decoration:none;transition:opacity 0.15s;';
        if (i > 0) card.style.borderTop = '1px solid var(--color-border)';
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

        var pub = post.publishedAt
          ? new Date(post.publishedAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
          : '';
        if (pub) {
          var dateSpan = document.createElement('span');
          dateSpan.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);';
          dateSpan.textContent = pub;
          authorInfo.appendChild(dateSpan);
        }

        authorRow.appendChild(authorInfo);
        card.appendChild(authorRow);

        // Title
        var title = document.createElement('div');
        title.style.cssText = 'font-family:var(--font-serif);font-size:20px;font-weight:600;color:var(--color-text);line-height:1.3;';
        title.textContent = post.title;
        card.appendChild(title);

        // Excerpt
        var raw = post.excerpt || post.body || '';
        var excerpt = raw.length > 200 ? raw.slice(0, 200) + '\\u2026' : raw;
        var excerptEl = document.createElement('p');
        excerptEl.style.cssText = 'font-family:var(--font-sans);font-size:14px;color:var(--color-muted);margin:0;line-height:1.6;';
        excerptEl.textContent = excerpt;
        card.appendChild(excerptEl);

        // Footer meta
        var meta = document.createElement('div');
        meta.style.cssText = 'display:flex;gap:16px;align-items:center;font-family:var(--font-mono);font-size:11px;color:var(--color-dimmer);margin-top:4px;';

        var readSpan = document.createElement('span');
        readSpan.textContent = (post.estimatedReadMinutes || 1) + ' min read';
        meta.appendChild(readSpan);

        if (typeof post.likeCount === 'number') {
          var likeSpan = document.createElement('span');
          likeSpan.textContent = '\\u2665 ' + post.likeCount;
          meta.appendChild(likeSpan);
        }

        card.appendChild(meta);
        feed.appendChild(card);
      });

      root.appendChild(feed);
    })
    .catch(function() {
      root.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);';
      root.textContent = 'Could not load posts.';
    });

  // Search wiring
  var searchInput = document.getElementById('search-input');
  if (searchInput) {
    searchInput.addEventListener('input', function() {
      var q = searchInput.value.toLowerCase().trim();
      var cards = root.querySelectorAll('a');
      cards.forEach(function(c) {
        c.style.display = (!q || c.textContent.toLowerCase().indexOf(q) >= 0) ? 'flex' : 'none';
      });
    });
  }
})();
</script>
"""
