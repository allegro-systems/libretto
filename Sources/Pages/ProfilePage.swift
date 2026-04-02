import Score

struct ProfilePage: Page {
    static let path = "/@:username"

    var body: some Node {
        Stack {
            NavBar()

            Stack {
                // Profile header -- populated by JS
                Stack {}
                    .htmlAttribute("id", "profile-header")

                // Posts list -- populated by JS
                Stack {}
                    .htmlAttribute("id", "profile-posts")
            }
            .flex(.column, gap: 24)
            .padding(48)
            .size(maxWidth: 720)
            .margin(0, at: .horizontal)
            .compact { $0.padding(24) }

            RawTextNode(profileScript)
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }
}

private let profileScript = """
    <script>
    (function() {
      var username = (window.location.pathname.match(/^\\/@([^/]+)/) || [])[1];
      if (!username) return;

      document.title = '@' + username + ' \\u2014 Libretto';

      fetch('/api/profile/' + encodeURIComponent(username))
        .then(function(r) { return r.ok ? r.json() : Promise.reject(r.status); })
        .then(function(p) {
          renderProfile(p);
          return fetch('/api/public/posts?author=' + encodeURIComponent(username));
        })
        .then(function(r) { return r.ok ? r.json() : []; })
        .then(renderPosts)
        .catch(function() {
          var el = document.getElementById('profile-header');
          var msg = document.createElement('p');
          msg.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);';
          msg.textContent = 'Profile not found.';
          el.appendChild(msg);
        });

      function renderProfile(p) {
        var header = document.getElementById('profile-header');
        header.style.cssText = 'display:flex;flex-direction:column;gap:12px;align-items:center;text-align:center;';

        // Avatar
        if (p.avatarURL) {
          var img = document.createElement('img');
          img.src = p.avatarURL;
          img.alt = p.displayName || '';
          img.style.cssText = 'width:72px;height:72px;border-radius:50%;object-fit:cover';
          header.appendChild(img);
        } else {
          var av = document.createElement('div');
          av.style.cssText = 'width:72px;height:72px;border-radius:50%;background:var(--color-accent);display:flex;align-items:center;justify-content:center;font-family:var(--font-sans);font-size:28px;font-weight:500;color:var(--color-bg)';
          av.textContent = (p.displayName || '?')[0].toUpperCase();
          header.appendChild(av);
        }

        // Name block
        var nameBlock = document.createElement('div');
        var h2 = document.createElement('h2');
        h2.style.cssText = 'margin:0;font-family:var(--font-serif);font-size:22px;font-weight:600;color:var(--color-text)';
        h2.textContent = p.displayName || '';
        var handle = document.createElement('p');
        handle.style.cssText = 'margin:4px 0 0;font-family:var(--font-mono);font-size:13px;color:var(--color-dimmer)';
        handle.textContent = '@' + (p.username || '');
        nameBlock.appendChild(h2);
        nameBlock.appendChild(handle);
        header.appendChild(nameBlock);

        // Bio
        if (p.bio) {
          var bio = document.createElement('p');
          bio.style.cssText = 'font-family:var(--font-sans);font-size:14px;line-height:1.6;color:var(--color-muted);margin:0';
          bio.textContent = p.bio;
          header.appendChild(bio);
        }

        // Social links
        if (p.socialLinks && p.socialLinks.length > 0) {
          var linksRow = document.createElement('div');
          linksRow.style.cssText = 'display:flex;gap:12px;flex-wrap:wrap';
          p.socialLinks.forEach(function(l) {
            var label = l.platform === 'github' ? 'GitHub'
              : l.platform === 'twitter' ? 'X / Twitter'
              : l.platform === 'website' ? 'Website'
              : l.platform;
            var a = document.createElement('a');
            a.href = l.url;
            a.textContent = label;
            a.target = '_blank';
            a.rel = 'noopener noreferrer';
            a.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-accent);text-decoration:none';
            linksRow.appendChild(a);
          });
          header.appendChild(linksRow);
        }
      }

      function renderPosts(posts) {
        var el = document.getElementById('profile-posts');
        if (!posts || posts.length === 0) {
          var msg = document.createElement('p');
          msg.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);';
          msg.textContent = 'No published posts yet.';
          el.appendChild(msg);
          return;
        }
        var heading = document.createElement('h3');
        heading.style.cssText = 'font-family:var(--font-serif);font-size:20px;font-weight:600;color:var(--color-text);margin:0 0 12px';
        heading.textContent = 'Published Posts';
        el.appendChild(heading);

        posts.forEach(function(post) {
          var card = document.createElement('div');
          card.style.cssText = 'border-bottom:1px solid var(--color-border);padding:16px 0';

          var a = document.createElement('a');
          a.href = '/@' + encodeURIComponent(username) + '/' + encodeURIComponent(post.slug || '');
          a.style.cssText = 'font-family:var(--font-serif);font-size:18px;font-weight:600;color:var(--color-text);text-decoration:none';
          a.textContent = post.title || '';
          card.appendChild(a);

          if (post.publishedAt) {
            var date = document.createElement('p');
            date.style.cssText = 'margin:4px 0 0;font-family:var(--font-sans);font-size:12px;color:var(--color-muted)';
            date.textContent = new Date(post.publishedAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
            card.appendChild(date);
          }
          el.appendChild(card);
        });
      }
    })();
    </script>
    """
