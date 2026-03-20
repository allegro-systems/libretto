import Score

struct DraftsPage: Page {
    static let path = "/drafts"

    var body: some Node {
        Stack {
            // Header
            Section {
                Stack {
                    Heading(.one) { "My Drafts" }
                        .font(.serif, size: 56, weight: .light, lineHeight: 1.15, color: .text)
                        .compact { $0.font(size: 36) }
                        .animate(.fadeIn, duration: 0.6)

                    Link(to: "/write") {
                        Text { "+ New Post" }
                    }
                    .font(.mono, size: 13, weight: .medium, color: .bg, align: .center, decoration: TextDecoration.none)
                    .padding(14, at: .vertical)
                    .padding(28, at: .horizontal)
                    .background(.accent)
                    .hover { $0.opacity(0.85) }
                    .animate(.fadeIn, duration: 0.6, delay: 0.15)
                }
                .flex(.row, gap: 24, align: .center, justify: .spaceBetween)
                .compact { $0.flex(.column, gap: 16, align: .start) }
            }
            .padding(80, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(60, at: .vertical).padding(20, at: .horizontal) }

            HorizontalRule().background(.border).size(height: 1).border(width: 0, color: .border, style: .none)

            // Draft list
            Section {
                Text { "DRAFTS" }
                    .font(.mono, size: 12, weight: .medium, tracking: 3, color: .muted, transform: .uppercase)
                    .animateOnScroll(.fadeIn)

                RawTextNode("<div id=\"drafts-list\" style=\"display:flex;flex-direction:column;gap:12px;\"></div>")

                Paragraph { "" }
                    .htmlAttribute("id", "drafts-status")
                    .font(.mono, size: 13, color: .muted)

                RawTextNode(draftsScript)
            }
            .flex(.column, gap: 24)
            .padding(80, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(60, at: .vertical).padding(20, at: .horizontal) }
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
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
    item.style.cssText = 'display:flex;align-items:center;justify-content:space-between;background:var(--color-elevated);border:1px solid var(--color-border);border-radius:8px;padding:24px;gap:12px;';

    var left = document.createElement('div');
    left.style.cssText = 'display:flex;flex-direction:column;gap:4px;min-width:0;';

    var titleEl = document.createElement('span');
    titleEl.style.cssText = 'font-family:var(--font-serif);font-size:20px;font-weight:300;color:var(--color-text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;';
    titleEl.textContent = post.title || '(Untitled)';

    var metaEl = document.createElement('span');
    metaEl.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-muted);';
    metaEl.textContent = 'Updated ' + formatDate(post.updatedAt) + ' \u00b7 ' + (post.wordCount || 0) + ' words';

    left.appendChild(titleEl);
    left.appendChild(metaEl);

    var right = document.createElement('div');
    right.style.cssText = 'display:flex;gap:8px;flex-shrink:0;';

    var editLink = document.createElement('a');
    editLink.href = '/write/' + String(post.id || '');
    editLink.textContent = 'Edit';
    editLink.style.cssText = 'font-family:var(--font-mono);font-size:13px;font-weight:500;color:var(--color-text);text-decoration:none;padding:14px 28px;border:1px solid var(--color-border);';

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
