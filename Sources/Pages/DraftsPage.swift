import Score

struct DraftsPage: Page {
    static let path = "/drafts"

    var body: some Node {
        Stack {
            // Header row
            Stack {
                Heading(.one) { "My Drafts" }
                    .font(.sans, size: 26, weight: .bold)

                Link(to: "/write") {
                    Text { "+ New Post" }
                }
                .font(.sans, size: 14, weight: .medium, decoration: TextDecoration.none)
                .htmlAttribute("style", "color:#7eb8f7;")
            }
            .flex(.row, gap: 16)
            .htmlAttribute("style", "align-items:baseline;")

            // Draft list container
            RawTextNode("<div id=\"drafts-list\" style=\"display:flex;flex-direction:column;gap:12px;\"></div>")

            Paragraph { "" }
                .htmlAttribute("id", "drafts-status")
                .font(.sans, size: 13)
                .htmlAttribute("style", "color:#aaa;margin:0;")

            RawTextNode(draftsScript)
        }
        .flex(.column, gap: 24)
        .padding(40)
    }
}

private let draftsScript = #"""
<script>
(function() {
  var list   = document.getElementById('drafts-list');
  var status = document.getElementById('drafts-status');

  function formatDate(iso) {
    try { return new Date(iso).toLocaleDateString(undefined, { year:'numeric', month:'short', day:'numeric' }); }
    catch(e) { return iso || ''; }
  }

  function makeDraftRow(post) {
    var item = document.createElement('div');
    item.style.cssText = 'display:flex;align-items:center;justify-content:space-between;padding:14px 16px;background:#111;border:1px solid #333;border-radius:6px;gap:12px;';

    var left = document.createElement('div');
    left.style.cssText = 'display:flex;flex-direction:column;gap:4px;min-width:0;';

    var titleEl = document.createElement('span');
    titleEl.style.cssText = 'font-size:16px;font-weight:600;color:#eee;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;';
    titleEl.textContent = post.title || '(Untitled)';

    var metaEl = document.createElement('span');
    metaEl.style.cssText = 'font-size:12px;color:#666;';
    metaEl.textContent = 'Updated ' + formatDate(post.updatedAt) + ' \u00b7 ' + (post.wordCount || 0) + ' words';

    left.appendChild(titleEl);
    left.appendChild(metaEl);

    var right = document.createElement('div');
    right.style.cssText = 'display:flex;gap:8px;flex-shrink:0;';

    var editLink = document.createElement('a');
    editLink.href = '/write/' + String(post.id || '');
    editLink.textContent = 'Edit';
    editLink.style.cssText = 'font-size:13px;color:#7eb8f7;text-decoration:none;padding:4px 10px;border:1px solid #444;border-radius:3px;';

    right.appendChild(editLink);
    item.appendChild(left);
    item.appendChild(right);
    return item;
  }

  fetch('/api/posts', { credentials: 'include' })
    .then(function(r) {
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.json();
    })
    .then(function(posts) {
      var drafts = (posts || []).filter(function(p) { return p.status === 'draft'; });
      if (!list) return;

      if (drafts.length === 0) {
        if (status) status.textContent = 'No drafts yet. Write your first post!';
        return;
      }

      drafts.forEach(function(post) {
        list.appendChild(makeDraftRow(post));
      });
    })
    .catch(function() {
      if (status) status.textContent = 'Failed to load drafts. Are you signed in?';
    });
})();
</script>
"""#
