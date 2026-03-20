import Score

struct SettingsPage: Page {
    static let path = "/settings"

    var body: some Node {
        Stack {
            RawTextNode("<style>input,textarea,select{background:var(--color-elevated)!important;border:1px solid var(--color-border)!important;color:var(--color-text)!important;font-family:var(--font-mono)!important;font-size:14px!important;padding:12px 16px!important;border-radius:6px!important;outline:none!important}input::placeholder,textarea::placeholder{color:var(--color-muted)!important}select{appearance:none;cursor:pointer}</style>")

            // Header
            Section {
                Heading (.one) { "Settings" }
                    .font(.serif, size: 56, weight: .light, lineHeight: 1.15, color: .text)
                    .compact { $0.font(size: 36) }
                    .animate(.fadeIn, duration: 0.6)

                Paragraph { "Manage your profile and preferences." }
                    .font(.mono, size: 15, lineHeight: 1.6, color: .muted)
                    .animate(.fadeIn, duration: 0.6, delay: 0.15)
            }
            .flex(.column, gap: 28)
            .padding(80, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(60, at: .vertical).padding(20, at: .horizontal) }

            HorizontalRule().background(.border).size(height: 1).border(width: 0, color: .border, style: .none)

            // Profile form
            Section {
                Text { "PROFILE" }
                    .font(.mono, size: 12, weight: .medium, tracking: 3, color: .muted, transform: .uppercase)

                // Display name
                formField(label: "Display Name", inputId: "settings-displayName", type: .text, placeholder: "Your name")

                // Username
                formField(label: "Username", inputId: "settings-username", type: .text, placeholder: "username")

                // Bio
                Stack {
                    RawTextNode("<label for=\"settings-bio\" style=\"font-family:var(--font-mono);font-size:12px;font-weight:500;letter-spacing:0.05em;text-transform:uppercase;color:var(--color-muted)\">Bio</label>")
                    RawTextNode("<textarea id=\"settings-bio\" rows=\"3\" placeholder=\"A short bio\" style=\"padding:14px;font-family:var(--font-mono);font-size:13px;color:var(--color-text);background:var(--color-bg);border:1px solid var(--color-border);width:100%;box-sizing:border-box;resize:vertical\"></textarea>")
                }
                .flex(.column, gap: 8)

                // Email
                formField(label: "Email", inputId: "settings-email", type: .email, placeholder: "you@example.com")

                Text { "SOCIAL LINKS" }
                    .font(.mono, size: 12, weight: .medium, tracking: 3, color: .muted, transform: .uppercase)

                formField(label: "GitHub URL", inputId: "settings-github", type: .text, placeholder: "https://github.com/username")
                formField(label: "Twitter / X URL", inputId: "settings-twitter", type: .text, placeholder: "https://x.com/username")
                formField(label: "Website URL", inputId: "settings-website", type: .text, placeholder: "https://example.com")

                // Status message
                Paragraph { "" }
                    .htmlAttribute("id", "settings-status")
                    .font(.mono, size: 13, color: .muted)

                // Save button
                Button(type: .button) {
                    Text { "Save Changes" }
                }
                .htmlAttribute("id", "settings-save-btn")
                .font(.mono, size: 13, weight: .medium, color: .bg)
                .padding(14, at: .vertical)
                .padding(28, at: .horizontal)
                .background(.accent)
                .hover { $0.opacity(0.85) }
            }
            .flex(.column, gap: 16)
            .padding(80, at: .vertical)
            .padding(56, at: .horizontal)
            .size(maxWidth: 740)
            .compact { $0.padding(60, at: .vertical).padding(20, at: .horizontal) }

            RawTextNode(settingsScript)
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }

    private func formField(label: String, inputId: String, type: InputType, placeholder: String) -> some Node {
        Stack {
            RawTextNode("<label for=\"\(inputId)\" style=\"font-family:var(--font-mono);font-size:12px;font-weight:500;letter-spacing:0.05em;text-transform:uppercase;color:var(--color-muted)\">\(label)</label>")
            Input(type: type, name: inputId.replacingOccurrences(of: "settings-", with: ""), placeholder: placeholder)
                .htmlAttribute("id", inputId)
                .padding(14)
                .font(.mono, size: 13)
                .border(width: 1, color: .border, style: .solid)
        }
        .flex(.column, gap: 8)
    }
}

private let settingsScript = """
<script>
(function() {
  // Load current profile
  fetch('/api/profile', { credentials: 'include' })
    .then(function(r) {
      if (r.status === 401) { window.location.href = '/login'; return null; }
      return r.ok ? r.json() : null;
    })
    .then(function(p) {
      if (!p) return;
      setValue('settings-displayName', p.displayName || '');
      setValue('settings-username', p.username || '');
      setValue('settings-email', p.email || '');
      var bio = document.getElementById('settings-bio');
      if (bio) bio.value = p.bio || '';
      var links = p.socialLinks || [];
      links.forEach(function(l) {
        if (l.platform === 'github') setValue('settings-github', l.url);
        else if (l.platform === 'twitter') setValue('settings-twitter', l.url);
        else if (l.platform === 'website') setValue('settings-website', l.url);
      });
    })
    .catch(function() {});

  // Save
  var btn = document.getElementById('settings-save-btn');
  var status = document.getElementById('settings-status');
  if (!btn) return;

  btn.addEventListener('click', function() {
    var socialLinks = [];
    var github = getValue('settings-github');
    var twitter = getValue('settings-twitter');
    var website = getValue('settings-website');
    if (github) socialLinks.push({ platform: 'github', url: github });
    if (twitter) socialLinks.push({ platform: 'twitter', url: twitter });
    if (website) socialLinks.push({ platform: 'website', url: website });

    var bio = document.getElementById('settings-bio');
    var payload = {
      displayName: getValue('settings-displayName'),
      username: getValue('settings-username'),
      email: getValue('settings-email'),
      bio: bio ? bio.value.trim() : '',
      socialLinks: socialLinks,
    };

    btn.disabled = true;
    status.textContent = 'Saving...';
    fetch('/api/profile', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify(payload),
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
      if (data.error) {
        status.textContent = 'Error: ' + data.error;
      } else {
        status.textContent = 'Saved!';
      }
    })
    .catch(function() { status.textContent = 'Network error. Please try again.'; })
    .finally(function() { btn.disabled = false; });
  });

  function getValue(id) {
    var el = document.getElementById(id);
    return el ? el.value.trim() : '';
  }
  function setValue(id, val) {
    var el = document.getElementById(id);
    if (el) el.value = val;
  }
})();
</script>
"""
