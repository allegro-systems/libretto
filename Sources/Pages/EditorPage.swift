import Score
import ScoreLucide

struct EditorPage: Page {
    // Handles both /write (new post) and /write/:postId (edit existing)
    static let path = "/write"

    var body: some Node {
        Stack {
            // Top bar (56px, surface bg, bottom border)
            Stack {
                Link(to: "/drafts") {
                    Stack {
                        Icon("arrow-left", size: 16, color: .muted)
                        Text { "Back" }
                    }
                    .flex(.row, gap: 6, align: .center)
                }
                .font(.sans, size: 14, color: .muted, decoration: TextDecoration.none)
                .hover { $0.opacity(0.7) }

                Stack {}
                    .flex(grow: 1)

                Text { "" }
                    .htmlAttribute("id", "editor-word-count")
                    .font(.mono, size: 12, color: .muted)

                Button(type: .button) { Text { "Save Draft" } }
                    .htmlAttribute("id", "btn-save-draft")
                    .font(.sans, size: 13, weight: .medium, color: .text)
                    .padding(8, at: .vertical)
                    .padding(16, at: .horizontal)
                    .border(width: 1, color: .border, style: .solid)
                    .hover { $0.background(.elevated) }

                Button(type: .button) { Text { "Publish" } }
                    .htmlAttribute("id", "btn-publish")
                    .font(.sans, size: 13, weight: .medium, color: .bg)
                    .padding(8, at: .vertical)
                    .padding(16, at: .horizontal)
                    .background(.composer)
                    .border(radius: 4)
                    .hover { $0.opacity(0.85) }
            }
            .flex(.row, gap: 12, align: .center)
            .padding(0, at: .vertical)
            .padding(16, at: .horizontal)
            .size(height: 56)
            .background(.surface)
            .border(width: 0, color: .border, style: .none)
            .border(width: 1, color: .border, style: .solid, at: .bottom)

            // Title area
            Section {
                RawTextNode(
                    """
                    <input id="editor-title" type="text" name="title" placeholder="Post title\u{2026}" style="width:100%;box-sizing:border-box;border:none;outline:none;background:transparent;color:var(--color-text);font-family:var(--font-serif);font-size:32px;font-weight:700;line-height:1.2;padding:0;" />
                    """)
            }
            .padding(32, at: .top)
            .padding(0, at: .bottom)
            .padding(64, at: .horizontal)
            .compact { $0.padding(20, at: .horizontal) }

            // Formatting toolbar
            Stack {
                toolbarButton(id: "btn-bold", icon: "bold", title: "Bold")
                toolbarButton(id: "btn-italic", icon: "italic", title: "Italic")
                toolbarButton(id: "btn-strikethrough", icon: "strikethrough", title: "Strikethrough")
                toolbarButton(id: "btn-link", icon: "link", title: "Link")
                toolbarButton(id: "btn-quote", icon: "quote", title: "Blockquote")
                toolbarButton(id: "btn-code", icon: "code", title: "Inline code")
                toolbarButton(id: "btn-image", icon: "image", title: "Image")
                toolbarButton(id: "btn-list", icon: "list", title: "Bullet list")
                toolbarButton(id: "btn-heading", icon: "heading", title: "Heading")
            }
            .flex(.row, gap: 8, wraps: true)
            .padding(12, at: .vertical)
            .padding(64, at: .horizontal)
            .compact { $0.padding(20, at: .horizontal) }

            // Editor body area
            Section {
                RawTextNode(
                    """
                    <textarea id="editor-body" placeholder="Write in Markdown\u{2026}" style="flex:1;width:100%;min-height:480px;box-sizing:border-box;padding:0;background:transparent;color:var(--color-text);border:none;outline:none;font-family:var(--font-sans);font-size:16px;line-height:1.7;resize:vertical;"></textarea>
                    """)
            }
            .flex(grow: 1)
            .padding(16, at: .vertical)
            .padding(64, at: .horizontal)
            .compact { $0.padding(20, at: .horizontal) }

            // Status bar (36px, surface bg, top border)
            Stack {
                Text { "" }
                    .htmlAttribute("id", "editor-char-count")
                    .font(.mono, size: 11, color: .muted)

                Text { "" }
                    .htmlAttribute("id", "editor-word-count-bar")
                    .font(.mono, size: 11, color: .muted)

                Text { "" }
                    .htmlAttribute("id", "editor-read-time")
                    .font(.mono, size: 11, color: .muted)

                Stack {}
                    .flex(grow: 1)

                Text { "" }
                    .htmlAttribute("id", "editor-status")
                    .font(.mono, size: 11, color: .muted)
            }
            .flex(.row, gap: 16, align: .center)
            .padding(0, at: .vertical)
            .padding(16, at: .horizontal)
            .size(height: 36)
            .background(.surface)
            .border(width: 1, color: .border, style: .solid, at: .top)

            RawTextNode(editorScript)
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }

    private func toolbarButton(id: String, icon: String, title: String) -> some Node {
        Button(type: .button) {
            Icon(icon, size: 16, color: .muted)
        }
        .htmlAttribute("id", id)
        .htmlAttribute("title", title)
        .padding(6)
        .background(.elevated)
        .border(width: 1, color: .border, style: .solid)
        .border(radius: 4)
        .cursor(.pointer)
        .flex(.row, align: .center, justify: .center)
        .hover { $0.background(.surface) }
    }
}

// MARK: - Script

private let editorScript = #"""
    <script>
    (function() {
      var textarea = document.getElementById('editor-body');
      var title    = document.getElementById('editor-title');
      var status   = document.getElementById('editor-status');
      var wordCountTop = document.getElementById('editor-word-count');
      var charCount    = document.getElementById('editor-char-count');
      var wordCountBar = document.getElementById('editor-word-count-bar');
      var readTime     = document.getElementById('editor-read-time');

      function countWords(text) {
        var trimmed = text.trim();
        if (!trimmed) return 0;
        return trimmed.split(/\s+/).length;
      }

      function updateStats() {
        if (!textarea) return;
        var text = textarea.value;
        var words = countWords(text);
        var chars = text.length;
        var minutes = Math.max(1, Math.ceil(words / 200));
        if (wordCountTop) wordCountTop.textContent = words + ' words';
        if (charCount) charCount.textContent = chars + ' chars';
        if (wordCountBar) wordCountBar.textContent = words + ' words';
        if (readTime) readTime.textContent = minutes + ' min read';
      }

      if (textarea) textarea.addEventListener('input', updateStats);
      if (title) title.addEventListener('input', updateStats);
      updateStats();

      // Toolbar helpers
      function wrapSelection(prefix, suffix) {
        if (!textarea) return;
        var start = textarea.selectionStart;
        var end   = textarea.selectionEnd;
        var sel   = textarea.value.substring(start, end) || 'text';
        var repl  = prefix + sel + suffix;
        textarea.value = textarea.value.substring(0, start) + repl + textarea.value.substring(end);
        textarea.selectionStart = start + prefix.length;
        textarea.selectionEnd   = start + prefix.length + sel.length;
        textarea.focus();
        updateStats();
      }

      function prependLine(prefix) {
        if (!textarea) return;
        var start     = textarea.selectionStart;
        var lineStart = textarea.value.lastIndexOf('\n', start - 1) + 1;
        var lineEnd   = textarea.value.indexOf('\n', start);
        if (lineEnd === -1) lineEnd = textarea.value.length;
        var line = textarea.value.substring(lineStart, lineEnd);
        textarea.value = textarea.value.substring(0, lineStart) + prefix + line + textarea.value.substring(lineEnd);
        textarea.selectionStart = lineStart + prefix.length;
        textarea.selectionEnd   = lineStart + prefix.length + line.length;
        textarea.focus();
        updateStats();
      }

      function bindBtn(id, fn) {
        var el = document.getElementById(id);
        if (el) el.addEventListener('click', fn);
      }

      bindBtn('btn-bold',          function() { wrapSelection('**', '**'); });
      bindBtn('btn-italic',        function() { wrapSelection('*', '*'); });
      bindBtn('btn-strikethrough', function() { wrapSelection('~~', '~~'); });
      bindBtn('btn-heading',       function() { prependLine('## '); });
      bindBtn('btn-link',          function() { wrapSelection('[', '](https://)'); });
      bindBtn('btn-code',          function() { wrapSelection('`', '`'); });
      bindBtn('btn-list',          function() { prependLine('- '); });
      bindBtn('btn-quote',         function() { prependLine('> '); });
      bindBtn('btn-image',         function() { wrapSelection('![', '](https://)'); });

      // Load existing post
      function getPostIdFromUrl() {
        var parts = window.location.pathname.split('/').filter(Boolean);
        if (parts.length >= 2 && parts[0] === 'write') return parts[1];
        return null;
      }

      var currentPostId = getPostIdFromUrl();

      if (currentPostId) {
        fetch('/api/posts/' + currentPostId, { credentials: 'include' })
          .then(function(r) { return r.json(); })
          .then(function(post) {
            if (title)    title.value    = post.title || '';
            if (textarea) textarea.value = post.body  || '';
            updateStats();
          })
          .catch(function() {
            if (status) status.textContent = 'Failed to load post.';
          });
      }

      // Save / Publish
      async function savePost(publish) {
        var t = title    ? title.value.trim() : '';
        var b = textarea ? textarea.value     : '';
        if (!t) { if (status) status.textContent = 'Title is required.'; return; }
        if (status) status.textContent = 'Saving\u2026';

        try {
          var res, data;
          if (currentPostId) {
            res = await fetch('/api/posts/' + currentPostId, {
              method: 'PUT', credentials: 'include',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ title: t, body: b })
            });
          } else {
            res = await fetch('/api/posts', {
              method: 'POST', credentials: 'include',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ title: t, body: b })
            });
          }
          data = await res.json();
          if (!res.ok) { if (status) status.textContent = data.error || 'Save failed.'; return; }
          if (!currentPostId && data.id) {
            currentPostId = data.id;
            history.replaceState(null, '', '/write/' + data.id);
          }

          if (publish && currentPostId) {
            var pRes  = await fetch('/api/posts/' + currentPostId + '/publish', { method: 'POST', credentials: 'include' });
            var pData = await pRes.json();
            if (!pRes.ok) { if (status) status.textContent = pData.error || 'Publish failed.'; return; }
            if (status) status.textContent = 'Published!';
          } else {
            var now = new Date();
            if (status) status.textContent = 'Last saved ' + now.toLocaleTimeString();
          }
        } catch (e) {
          if (status) status.textContent = 'Network error.';
        }
      }

      var draftBtn   = document.getElementById('btn-save-draft');
      var publishBtn = document.getElementById('btn-publish');
      if (draftBtn)   draftBtn.addEventListener('click',   function() { savePost(false); });
      if (publishBtn) publishBtn.addEventListener('click', function() { savePost(true);  });
    })();
    </script>
    """#
