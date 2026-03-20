import Score

struct Editor: Node {
    var body: some Node {
        Stack {
            // Title input
            Input(type: .text, name: "title", placeholder: "Post title…")
                .htmlAttribute("id", "editor-title")
                .padding(12)
                .font(.sans, size: 22, weight: .bold)
                .htmlAttribute("style", "width:100%;box-sizing:border-box;border:1px solid #333;background:#111;color:#eee;border-radius:4px;")

            // Formatting toolbar
            Stack {
                toolbarButton(id: "btn-bold",    label: "B",   title: "Bold")
                toolbarButton(id: "btn-italic",  label: "I",   title: "Italic")
                toolbarButton(id: "btn-heading", label: "H",   title: "Heading")
                toolbarButton(id: "btn-link",    label: "Link", title: "Link")
                toolbarButton(id: "btn-code",    label: "</>", title: "Inline code")
                toolbarButton(id: "btn-list",    label: "List", title: "Bullet list")
                toolbarButton(id: "btn-quote",   label: "Quote", title: "Blockquote")
            }
            .flex(.row, gap: 6)
            .htmlAttribute("style", "flex-wrap:wrap;")

            // Editor + preview split
            Stack {
                // Textarea
                RawTextNode("""
<textarea id="editor-body" placeholder="Write in Markdown…" style="flex:1;min-width:0;height:480px;box-sizing:border-box;padding:12px;background:#111;color:#eee;border:1px solid #333;border-radius:4px;font-family:monospace;font-size:14px;resize:vertical;"></textarea>
""")

                // Preview panel
                Stack {
                    Heading(.three) { "Preview" }
                        .font(.sans, size: 13, weight: .semibold)
                        .htmlAttribute("style", "color:#888;margin-bottom:8px;")
                    RawTextNode("""
<div id="editor-preview" style="min-height:480px;padding:12px;background:#0d0d0d;border:1px solid #333;border-radius:4px;color:#eee;font-family:serif;font-size:15px;line-height:1.7;overflow-y:auto;word-break:break-word;"></div>
""")
                }
                .flex(.column, gap: 0)
                .htmlAttribute("style", "flex:1;min-width:0;")
            }
            .flex(.row, gap: 16)
            .htmlAttribute("style", "align-items:flex-start;")

            // Action buttons + status
            Stack {
                Button(type: .button) { Text { "Save Draft" } }
                    .htmlAttribute("id", "btn-save-draft")
                    .padding(10, at: .horizontal)
                    .padding(10, at: .vertical)
                    .font(.sans, size: 14, weight: .medium)

                Button(type: .button) { Text { "Publish" } }
                    .htmlAttribute("id", "btn-publish")
                    .padding(10, at: .horizontal)
                    .padding(10, at: .vertical)
                    .font(.sans, size: 14, weight: .medium)

                Paragraph { "" }
                    .htmlAttribute("id", "editor-status")
                    .font(.sans, size: 13)
                    .htmlAttribute("style", "color:#aaa;margin:0;")
            }
            .flex(.row, gap: 12)
            .htmlAttribute("style", "align-items:center;")

            RawTextNode(editorScript)
        }
        .flex(.column, gap: 16)
    }

    // MARK: - Helpers

    private func toolbarButton(id: String, label: String, title: String) -> some Node {
        Button(type: .button) { Text { label } }
            .htmlAttribute("id", id)
            .htmlAttribute("title", title)
            .padding(6, at: .horizontal)
            .padding(6, at: .vertical)
            .font(.sans, size: 13, weight: .medium)
            .htmlAttribute("style", "background:#1e1e1e;border:1px solid #444;border-radius:3px;color:#ccc;cursor:pointer;")
    }
}

// MARK: - Script

private let editorScript = #"""
<script>
(function() {
  var textarea = document.getElementById('editor-body');
  var preview  = document.getElementById('editor-preview');
  var title    = document.getElementById('editor-title');
  var status   = document.getElementById('editor-status');

  // ---------- Lightweight Markdown renderer ----------
  function escHtml(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }

  function renderMarkdown(raw) {
    var lines = raw.split('\n');
    var out = [];
    var inPre = false;
    var preBuf = [];

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];

      // Fenced code block
      if (line.startsWith('```')) {
        if (inPre) {
          out.push('<pre style="background:#1a1a1a;padding:10px;border-radius:4px;overflow:auto;"><code>' + escHtml(preBuf.join('\n')) + '</code></pre>');
          preBuf = []; inPre = false;
        } else { inPre = true; }
        continue;
      }
      if (inPre) { preBuf.push(line); continue; }

      var esc = escHtml(line);

      // Headings
      var hm = esc.match(/^(#{1,6}) (.+)$/);
      if (hm) {
        var lvl = hm[1].length;
        out.push('<h' + lvl + '>' + hm[2] + '</h' + lvl + '>');
        continue;
      }

      // Blockquote
      if (esc.startsWith('&gt; ')) {
        out.push('<blockquote style="border-left:3px solid #555;padding-left:12px;color:#aaa;margin:8px 0;">' + inlineFormat(esc.slice(5)) + '</blockquote>');
        continue;
      }

      // Bullet list
      if (/^[*\-] /.test(esc)) {
        out.push('<li style="list-style:disc;margin-left:20px;">' + inlineFormat(esc.slice(2)) + '</li>');
        continue;
      }

      // Numbered list
      if (/^\d+\. /.test(esc)) {
        out.push('<li style="list-style:decimal;margin-left:20px;">' + inlineFormat(esc.replace(/^\d+\. /,'')) + '</li>');
        continue;
      }

      // Blank line
      if (esc.trim() === '') { out.push('<br>'); continue; }

      // Paragraph line
      out.push('<p style="margin:0 0 4px;">' + inlineFormat(esc) + '</p>');
    }

    if (inPre) {
      out.push('<pre style="background:#1a1a1a;padding:10px;border-radius:4px;overflow:auto;"><code>' + escHtml(preBuf.join('\n')) + '</code></pre>');
    }

    return out.join('\n');
  }

  function inlineFormat(s) {
    return s
      .replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>')
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/\*(.+?)\*/g, '<em>$1</em>')
      .replace(/`([^`]+)`/g, '<code style="background:#1a1a1a;padding:2px 4px;border-radius:2px;">$1</code>')
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" style="color:#7eb8f7;">$1</a>');
  }

  // ---------- Live preview ----------
  function updatePreview() {
    if (preview && textarea) {
      preview.innerHTML = renderMarkdown(textarea.value);
    }
  }
  if (textarea) textarea.addEventListener('input', updatePreview);

  // ---------- Toolbar helpers ----------
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
    updatePreview();
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
    updatePreview();
  }

  function bindBtn(id, fn) {
    var el = document.getElementById(id);
    if (el) el.addEventListener('click', fn);
  }

  bindBtn('btn-bold',    function() { wrapSelection('**', '**'); });
  bindBtn('btn-italic',  function() { wrapSelection('*', '*'); });
  bindBtn('btn-heading', function() { prependLine('## '); });
  bindBtn('btn-link',    function() { wrapSelection('[', '](https://)'); });
  bindBtn('btn-code',    function() { wrapSelection('`', '`'); });
  bindBtn('btn-list',    function() { prependLine('- '); });
  bindBtn('btn-quote',   function() { prependLine('> '); });

  // ---------- Load existing post ----------
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
        updatePreview();
      })
      .catch(function() {
        if (status) status.textContent = 'Failed to load post.';
      });
  }

  // ---------- Save / Publish ----------
  async function savePost(publish) {
    var t = title    ? title.value.trim() : '';
    var b = textarea ? textarea.value     : '';
    if (!t) { if (status) status.textContent = 'Title is required.'; return; }
    if (status) status.textContent = 'Saving\u2026';

    try {
      var res, data;
      if (currentPostId) {
        res  = await fetch('/api/posts/' + currentPostId, {
          method: 'PUT', credentials: 'include',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ title: t, body: b })
        });
      } else {
        res  = await fetch('/api/posts', {
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
        if (status) status.textContent = 'Draft saved.';
      }
    } catch (e) {
      if (status) status.textContent = 'Network error.';
    }
  }

  var draftBtn   = document.getElementById('btn-save-draft');
  var publishBtn = document.getElementById('btn-publish');
  if (draftBtn)   draftBtn.addEventListener('click',   function() { savePost(false); });
  if (publishBtn) publishBtn.addEventListener('click', function() { savePost(true);  });

  updatePreview();
})();
</script>
"""#
