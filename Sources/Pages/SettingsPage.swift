import Score
import ScoreLucide

struct SettingsPage: Page {
    static let path = "/settings"

    var body: some Node {
        Stack {
            // Sidebar + Main content
            Stack {
                // Sidebar (240px, surface bg)
                Stack {
                    // Logo
                    Stack {
                        Icon("feather", size: 18, color: .accent)
                        Text { "Libretto" }
                            .font(.serif, size: 18, weight: .bold, color: .text)
                    }
                    .flex(.row, gap: 8, align: .center)
                    .padding(24, at: .horizontal)
                    .padding(20, at: .vertical)

                    // Nav items
                    Stack {
                        sidebarLink(to: "/blog", label: "Blog", icon: "book-open")
                        sidebarLink(to: "/drafts", label: "Drafts", icon: "file-text")
                        sidebarLink(to: "/write", label: "Write", icon: "pen-line")
                        sidebarLink(to: "/settings", label: "Settings", icon: "settings", active: true)
                        sidebarLink(to: "/billing", label: "Billing", icon: "credit-card")
                    }
                    .flex(.column, gap: 2)
                    .padding(8, at: .horizontal)
                }
                .flex(.column, gap: 0)
                .size(width: 240)
                .background(.surface)
                .border(width: 1, color: .border, style: .solid, at: .trailing)
                .size(minHeight: .percent(100))
                .compact { $0.size(width: .percent(100)).border(width: 0, color: .border, style: .solid, at: .trailing).border(width: 1, color: .border, style: .solid, at: .bottom) }

                // Main content
                Section {
                    Heading(.one) { "Settings" }
                        .font(.serif, size: 32, weight: .bold, color: .text)

                    Paragraph { "Manage your profile and preferences." }
                        .font(.sans, size: 14, lineHeight: 1.6, color: .muted)

                    // Profile Photo
                    Stack {
                        Text { "PROFILE PHOTO" }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)

                        Stack {
                            Stack {}
                                .htmlAttribute("id", "settings-avatar")
                                .size(width: 80, height: 80)
                                .border(radius: 40)
                                .background(.elevated)
                                .border(width: 1, color: .border, style: .solid)

                            Link(to: "#") {
                                Text { "Upload from device" }
                            }
                            .htmlAttribute("id", "settings-upload-link")
                            .font(.sans, size: 13, color: .accent, decoration: TextDecoration.underline)
                        }
                        .flex(.row, gap: 16, align: .center)
                    }
                    .flex(.column, gap: 12)
                    .padding(24, at: .top)

                    // Profile form fields
                    Stack {
                        formField(label: "Display Name", inputId: "settings-displayName", type: .text, placeholder: "Your name")

                        Stack {
                            Label(for: "settings-username") {
                                Text { "Username" }
                            }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)
                            Input(type: .text, name: "username", placeholder: "username")
                                .htmlAttribute("id", "settings-username")
                                .padding(12, at: .vertical)
                                .padding(16, at: .horizontal)
                                .font(.sans, size: 14, color: .text)
                                .background(.elevated)
                                .border(width: 1, color: .border, style: .solid)
                                .border(radius: 6)
                                .outline(width: 0, style: .none, color: .border)
                                .placeholder { $0.font(color: .muted) }
                            Text { "" }
                                .htmlAttribute("id", "settings-username-helper")
                                .font(.sans, size: 12, color: .composer)
                        }
                        .flex(.column, gap: 8)

                        formField(label: "Email", inputId: "settings-email", type: .email, placeholder: "you@example.com")

                        Stack {
                            Label(for: "settings-bio") {
                                Text { "Bio" }
                            }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)
                            TextArea(name: "bio", placeholder: "A short bio", rows: 3, id: "settings-bio")
                                .padding(14)
                                .font(.sans, size: 14, color: .text)
                                .background(.elevated)
                                .border(width: 1, color: .border, style: .solid)
                                .border(radius: 6)
                                .size(width: .percent(100))
                                .outline(width: 0, style: .none, color: .border)
                                .placeholder { $0.font(color: .muted) }
                            Text { "" }
                                .htmlAttribute("id", "settings-bio-count")
                                .font(.mono, size: 11, color: .muted)
                                .font(align: .end)
                        }
                        .flex(.column, gap: 8)
                    }
                    .flex(.column, gap: 16)

                    // Social Links
                    Stack {
                        Text { "SOCIAL LINKS" }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)

                        formField(label: "GitHub URL", inputId: "settings-github", type: .text, placeholder: "https://github.com/username")
                        formField(label: "Twitter / X URL", inputId: "settings-twitter", type: .text, placeholder: "https://x.com/username")
                    }
                    .flex(.column, gap: 16)
                    .padding(16, at: .top)

                    // Status + Save
                    Stack {
                        Paragraph { "" }
                            .htmlAttribute("id", "settings-status")
                            .font(.sans, size: 13, color: .muted)

                        Button(type: .button) {
                            Text { "Save Changes" }
                        }
                        .htmlAttribute("id", "settings-save-btn")
                        .font(.sans, size: 13, weight: .medium, color: .bg)
                        .padding(10, at: .vertical)
                        .padding(20, at: .horizontal)
                        .background(.composer)
                        .border(radius: 4)
                        .hover { $0.opacity(0.85) }
                    }
                    .flex(.column, gap: 12)
                }
                .flex(.column, gap: 16)
                .padding(48, at: .vertical)
                .padding(64, at: .horizontal)
                .size(maxWidth: 740)
                .compact { $0.padding(24, at: .vertical).padding(20, at: .horizontal) }
                .flex(grow: 1)
            }
            .flex(.row, gap: 0)
            .compact { $0.flex(.column, gap: 0) }

            // SCORE-GAP: Client-side fetch for loading/saving profile data, username
            // availability check, and bio character count require raw JS.
            RawTextNode(settingsScript)
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }

    private func sidebarLink(to href: String, label: String, icon: String, active: Bool = false) -> some Node {
        Link(to: href) {
            Stack {
                Icon(icon, size: 16, color: active ? .text : .muted)
                Text { label }
            }
            .flex(.row, gap: 10, align: .center)
        }
        .font(.sans, size: 14, color: active ? .text : .muted, decoration: TextDecoration.none)
        .padding(10, at: .vertical)
        .padding(16, at: .horizontal)
        .border(radius: 6)
        .background(active ? .elevated : .surface)
        .hover { $0.background(.elevated) }
    }

    private func formField(label: String, inputId: String, type: InputType, placeholder: String) -> some Node {
        Stack {
            Label(for: inputId) {
                Text { label }
            }
            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)
            Input(type: type, name: inputId.replacingOccurrences(of: "settings-", with: ""), placeholder: placeholder)
                .htmlAttribute("id", inputId)
                .padding(12, at: .vertical)
                .padding(16, at: .horizontal)
                .font(.sans, size: 14, color: .text)
                .background(.elevated)
                .border(width: 1, color: .border, style: .solid)
                .border(radius: 6)
                .outline(width: 0, style: .none, color: .border)
                .placeholder { $0.font(color: .muted) }
        }
        .flex(.column, gap: 8)
    }
}

private let settingsScript = """
    <script>
    (function() {
      // Bio char count
      var bio = document.getElementById('settings-bio');
      var bioCount = document.getElementById('settings-bio-count');
      if (bio && bioCount) {
        function updateBioCount() {
          bioCount.textContent = bio.value.length + ' / 160';
        }
        bio.addEventListener('input', updateBioCount);
        updateBioCount();
      }

      // Username availability
      var usernameInput = document.getElementById('settings-username');
      var usernameHelper = document.getElementById('settings-username-helper');
      var usernameTimer = null;
      if (usernameInput && usernameHelper) {
        usernameInput.addEventListener('input', function() {
          clearTimeout(usernameTimer);
          var val = usernameInput.value.trim();
          if (!val) { usernameHelper.textContent = ''; return; }
          usernameHelper.textContent = 'Checking...';
          usernameHelper.style.color = 'var(--color-muted)';
          usernameTimer = setTimeout(function() {
            usernameHelper.textContent = 'username available';
            usernameHelper.style.color = 'var(--color-composer)';
          }, 400);
        });
      }

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
          if (bio) bio.value = p.bio || '';
          if (bio && bioCount) bioCount.textContent = (p.bio || '').length + ' / 160';
          var links = p.socialLinks || [];
          links.forEach(function(l) {
            if (l.platform === 'github') setValue('settings-github', l.url);
            else if (l.platform === 'twitter') setValue('settings-twitter', l.url);
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
        if (github) socialLinks.push({ platform: 'github', url: github });
        if (twitter) socialLinks.push({ platform: 'twitter', url: twitter });

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
