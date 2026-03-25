import Score
import ScoreLucide

struct DraftsPage: Page {
    static let path = "/drafts"

    var body: some Node {
        Stack {
            // Top nav bar (56px)
            Stack {
                Text { "Libretto" }
                    .font(.serif, size: 18, weight: .bold, color: .text)

                Stack {
                    navLink(to: "/blog", label: "Blog")
                    navLink(to: "/drafts", label: "Drafts", active: true)
                    navLink(to: "/write", label: "Write")
                }
                .flex(.row, gap: 24, align: .center)

                Stack {}
                    .htmlAttribute("style", "flex:1")

                Link(to: "/write") {
                    Text { "New Post" }
                }
                .font(.sans, size: 13, weight: .medium, color: .bg, decoration: TextDecoration.none)
                .padding(8, at: .vertical)
                .padding(16, at: .horizontal)
                .background(.composer)
                .radius(4)
                .hover { $0.opacity(0.85) }
            }
            .flex(.row, gap: 24, align: .center)
            .padding(0, at: .vertical)
            .padding(24, at: .horizontal)
            .size(height: 56)
            .background(.surface)
            .htmlAttribute("style", "border-bottom:1px solid var(--color-border)")

            // Content area
            Section {
                Stack {
                    Heading(.two) { "Your Drafts" }
                        .font(.serif, size: 28, weight: .bold, color: .text)

                    Text { "" }
                        .htmlAttribute("id", "drafts-count-badge")
                        .font(.mono, size: 11, weight: .medium, color: .muted)
                        .padding(2, at: .vertical)
                        .padding(8, at: .horizontal)
                        .background(.elevated)
                        .border(width: 1, color: .border, style: .solid)
                        .radius(4)
                }
                .flex(.row, gap: 12, align: .center)

                RawTextNode("<div id=\"drafts-list\"></div>")

                Paragraph { "" }
                    .htmlAttribute("id", "drafts-status")
                    .font(.sans, size: 13, color: .muted)

                RawTextNode(draftsScript)
            }
            .flex(.column, gap: 24)
            .padding(40, at: .vertical)
            .padding(48, at: .horizontal)
            .compact { $0.padding(24, at: .vertical).padding(20, at: .horizontal) }
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }

    private func navLink(to href: String, label: String, active: Bool = false) -> some Node {
        Link(to: href) {
            Text { label }
        }
        .font(.sans, size: 14, weight: active ? .semibold : .regular, color: active ? .text : .muted, decoration: TextDecoration.none)
        .hover { $0.opacity(0.7) }
    }
}

private let draftsScript = #"""
<script>
(function() {
  var list   = document.getElementById('drafts-list');
  var status = document.getElementById('drafts-status');
  var badge  = document.getElementById('drafts-count-badge');

  function formatDate(iso) {
    try { return new Date(iso).toLocaleDateString(undefined, { year:'numeric', month:'short', day:'numeric' }); }
    catch(e) { return iso || ''; }
  }

  function makeTable(drafts) {
    var table = document.createElement('table');
    table.style.cssText = 'width:100%;border-collapse:collapse;';

    var thead = document.createElement('thead');
    var hr = document.createElement('tr');
    var headers = ['Title', 'Words', 'Date', 'Actions'];
    var aligns  = ['left', 'right', 'right', 'right'];
    headers.forEach(function(text, i) {
      var th = document.createElement('th');
      th.textContent = text;
      th.style.cssText = 'text-align:' + aligns[i] + ';padding:10px 12px;border-bottom:1px solid var(--color-border);font-family:var(--font-mono);font-size:11px;font-weight:500;color:var(--color-muted);text-transform:uppercase;letter-spacing:0.05em;';
      hr.appendChild(th);
    });
    thead.appendChild(hr);
    table.appendChild(thead);

    var tbody = document.createElement('tbody');
    drafts.forEach(function(post) {
      var tr = document.createElement('tr');
      tr.style.cssText = 'border-bottom:1px solid var(--color-border);';

      // Title + status
      var tdTitle = document.createElement('td');
      tdTitle.style.cssText = 'padding:12px;';
      var titleSpan = document.createElement('div');
      titleSpan.textContent = post.title || '(Untitled)';
      titleSpan.style.cssText = 'font-family:var(--font-sans);font-size:14px;font-weight:600;color:var(--color-text);';
      tdTitle.appendChild(titleSpan);
      var statusSpan = document.createElement('div');
      statusSpan.textContent = post.status || 'draft';
      statusSpan.style.cssText = 'font-family:var(--font-mono);font-size:11px;color:var(--color-muted);margin-top:4px;';
      tdTitle.appendChild(statusSpan);
      tr.appendChild(tdTitle);

      // Words
      var tdWords = document.createElement('td');
      tdWords.textContent = (post.wordCount || 0).toLocaleString();
      tdWords.style.cssText = 'padding:12px;text-align:right;font-family:var(--font-mono);font-size:13px;color:var(--color-muted);';
      tr.appendChild(tdWords);

      // Date
      var tdDate = document.createElement('td');
      tdDate.textContent = formatDate(post.updatedAt);
      tdDate.style.cssText = 'padding:12px;text-align:right;font-family:var(--font-mono);font-size:13px;color:var(--color-muted);';
      tr.appendChild(tdDate);

      // Actions
      var tdActions = document.createElement('td');
      tdActions.style.cssText = 'padding:12px;text-align:right;';
      var actionsWrap = document.createElement('div');
      actionsWrap.style.cssText = 'display:flex;gap:8px;justify-content:flex-end;align-items:center;';

      var editLink = document.createElement('a');
      editLink.href = '/write/' + String(post.id || '');
      editLink.textContent = 'Edit';
      editLink.style.cssText = 'font-family:var(--font-sans);font-size:13px;font-weight:500;color:var(--color-text);text-decoration:none;padding:6px 12px;border:1px solid var(--color-border);border-radius:4px;';

      var deleteBtn = document.createElement('button');
      deleteBtn.type = 'button';
      deleteBtn.title = 'Delete draft';
      deleteBtn.textContent = '\u{1F5D1}';
      deleteBtn.style.cssText = 'background:none;border:1px solid var(--color-border);border-radius:4px;padding:6px 8px;color:var(--color-muted);cursor:pointer;font-size:14px;line-height:1;';
      deleteBtn.addEventListener('click', function() {
        if (!confirm('Delete this draft?')) return;
        fetch('/api/posts/' + post.id, { method: 'DELETE', credentials: 'include' })
          .then(function() { tr.remove(); })
          .catch(function() {});
      });

      actionsWrap.appendChild(editLink);
      actionsWrap.appendChild(deleteBtn);
      tdActions.appendChild(actionsWrap);
      tr.appendChild(tdActions);

      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    return table;
  }

  fetch('/api/posts', { credentials: 'include' })
    .then(function(r) {
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.json();
    })
    .then(function(posts) {
      var drafts = (posts || []).filter(function(p) { return p.status === 'draft'; });
      if (badge) badge.textContent = drafts.length;
      if (!list) return;

      if (drafts.length === 0) {
        if (status) status.textContent = 'No drafts yet. Write your first post!';
        return;
      }

      list.appendChild(makeTable(drafts));
    })
    .catch(function() {
      if (status) status.textContent = 'Failed to load drafts. Are you signed in?';
    });
})();
</script>
"""#
