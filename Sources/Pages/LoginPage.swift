import Score

struct LoginPage: Page {
    static let path = "/login"

    var body: some Node {
        Stack {
            Section {
                Heading(.one) { "Sign in to Libretto" }
                    .font(.serif, size: 56, weight: .light, lineHeight: 1.15, color: .text, align: .center)
                    .size(maxWidth: 740)
                    .compact { $0.font(size: 36) }
                    .animate(.fadeIn, duration: 0.6)

                Paragraph { "Enter your email to get started." }
                    .font(.mono, size: 15, lineHeight: 1.6, color: .muted, align: .center)
                    .size(maxWidth: 580)
                    .compact { $0.font(size: 13) }
                    .animate(.fadeIn, duration: 0.6, delay: 0.15)
            }
            .flex(.column, gap: 28, align: .center)
            .padding(120, at: .vertical)
            .padding(56, at: .horizontal)
            .backgroundGradient(.radial(color: .libretto, opacity: 0.04, width: 120, height: 80, at: .top))
            .compact { $0.padding(80, at: .vertical).padding(20, at: .horizontal) }

            HorizontalRule().background(.border).size(height: 1).border(width: 0, color: .border, style: .none)

            // Login form
            Section {
                Stack {
                    // Magic link section
                    Stack {
                        Text { "EMAIL" }
                            .font(.mono, size: 12, weight: .medium, tracking: 3, color: .muted, transform: .uppercase)

                        Stack {
                            Input(type: .email, name: "email", placeholder: "you@example.com")
                                .htmlAttribute("id", "magic-link-email")
                                .padding(14)
                                .font(.mono, size: 13)
                                .background(.elevated)
                                .border(width: 1, color: .border, style: .solid)

                            Button(type: .button) {
                                Text { "Send Magic Link" }
                            }
                            .htmlAttribute("id", "magic-link-btn")
                            .font(.mono, size: 13, weight: .medium, color: .bg)
                            .padding(14, at: .vertical)
                            .padding(28, at: .horizontal)
                            .background(.accent)
                            .hover { $0.opacity(0.85) }
                        }
                        .flex(.row, gap: 12)
                        .compact { $0.flex(.column, gap: 12) }

                        Paragraph { "" }
                            .htmlAttribute("id", "magic-link-status")
                            .font(.mono, size: 13, color: .muted)
                    }
                    .flex(.column, gap: 16)

                    // Divider with extra spacing
                    HorizontalRule()
                        .background(.border)
                        .size(height: 1)
                        .border(width: 0, color: .border, style: .none)
                        .padding(8, at: .vertical)

                    // OAuth / passkey section
                    Stack {
                        Button(type: .button) {
                            Text { "Sign in with Passkey" }
                        }
                        .htmlAttribute("disabled", "true")
                        .font(.mono, size: 13, weight: .medium, color: .text)
                        .padding(14, at: .vertical)
                        .padding(28, at: .horizontal)
                        .border(width: 1, color: .border, style: .solid)
                        .opacity(0.5)

                        Link(to: "/auth/oauth/github/login") {
                            Text { "Sign in with GitHub" }
                        }
                        .font(.mono, size: 13, weight: .medium, color: .text, align: .center, decoration: TextDecoration.none)
                        .padding(14, at: .vertical)
                        .padding(28, at: .horizontal)
                        .border(width: 1, color: .border, style: .solid)
                        .hover { $0.background(.elevated) }
                    }
                    .flex(.column, gap: 12, align: .center)
                }
                .flex(.column, gap: 24)
                .padding(40)
                .background(.elevated)
                .border(width: 1, color: .border, style: .solid)
                .size(maxWidth: 440)
                .radius(8)
                .compact { $0.padding(24) }
            }
            .flex(.column, gap: 0, align: .center)
            .padding(80, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(60, at: .vertical).padding(20, at: .horizontal) }

            // Client-side JS for magic link
            RawTextNode(loginScript)
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }
}

private let loginScript = """
<script>
(function() {
  var btn = document.getElementById('magic-link-btn');
  var input = document.getElementById('magic-link-email');
  var status = document.getElementById('magic-link-status');
  if (!btn || !input) return;

  btn.addEventListener('click', async function() {
    var email = input.value.trim();
    if (!email) { status.textContent = 'Please enter your email.'; return; }
    btn.disabled = true;
    status.textContent = 'Sending...';
    try {
      var res = await fetch('/auth/magic-link', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email })
      });
      var data = await res.json();
      status.textContent = data.message || data.error || 'Something went wrong.';
    } catch (e) {
      status.textContent = 'Network error. Please try again.';
    }
    btn.disabled = false;
  });
})();
</script>
"""
