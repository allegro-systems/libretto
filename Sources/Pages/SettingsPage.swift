import Score

struct SettingsPage: Page {
    static let path = "/settings"

    var body: some Node {
        Stack {
            Heading(.one) { "Settings" }
                .font(.sans, size: 28, weight: .bold)

            // Profile form
            Stack {
                Heading(.two) { "Profile" }
                    .font(.sans, size: 18, weight: .semibold)

                // Display name
                formField(label: "Display Name", inputId: "settings-displayName", type: .text, placeholder: "Your name")

                // Username
                formField(label: "Username", inputId: "settings-username", type: .text, placeholder: "username")

                // Bio
                Stack {
                    RawTextNode("<label for=\"settings-bio\" style=\"font-size:14px;font-weight:500\">Bio</label>")
                    RawTextNode("<textarea id=\"settings-bio\" rows=\"3\" placeholder=\"A short bio\" style=\"padding:10px;font-size:14px;font-family:system-ui,-apple-system,sans-serif;border:1px solid oklch(0.85 0.015 260);border-radius:8px;width:100%;box-sizing:border-box;resize:vertical\"></textarea>")
                }
                .flex(.column, gap: 6)

                // Email
                formField(label: "Email", inputId: "settings-email", type: .email, placeholder: "you@example.com")

                Heading(.two) { "Social Links" }
                    .font(.sans, size: 16, weight: .semibold)

                formField(label: "GitHub URL", inputId: "settings-github", type: .text, placeholder: "https://github.com/username")
                formField(label: "Twitter / X URL", inputId: "settings-twitter", type: .text, placeholder: "https://x.com/username")
                formField(label: "Website URL", inputId: "settings-website", type: .text, placeholder: "https://example.com")

                // Status message
                Paragraph { "" }
                    .htmlAttribute("id", "settings-status")
                    .font(.sans, size: 13)

                // Save button
                Button(type: .button) {
                    Text { "Save Changes" }
                }
                .htmlAttribute("id", "settings-save-btn")
                .padding(10, at: .horizontal)
                .padding(10, at: .vertical)
                .font(.sans, size: 14, weight: .medium)
            }
            .flex(.column, gap: 16)

            RawTextNode(settingsScript)
        }
        .flex(.column, gap: 24)
        .padding(40)
    }

    private func formField(label: String, inputId: String, type: InputType, placeholder: String) -> some Node {
        Stack {
            RawTextNode("<label for=\"\(inputId)\" style=\"font-size:14px;font-weight:500\">\(label)</label>")
            Input(type: type, name: inputId.replacingOccurrences(of: "settings-", with: ""), placeholder: placeholder)
                .htmlAttribute("id", inputId)
                .padding(10)
                .font(.sans, size: 14)
                .htmlAttribute("style", "border:1px solid oklch(0.85 0.015 260);border-radius:8px;width:100%;box-sizing:border-box")
        }
        .flex(.column, gap: 6)
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
