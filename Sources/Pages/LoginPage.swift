import Score

struct LoginPage: Page {
    static let path = "/login"

    var body: some Node {
        Stack {
            // Header
            Heading(.one) { "Sign in to Libretto" }
                .font(.sans, size: 28, weight: .bold)

            // Magic link form
            Stack {
                Heading(.two) { "Email" }
                    .font(.sans, size: 18, weight: .semibold)

                Stack {
                    Input(type: .email, name: "email", placeholder: "you@example.com")
                        .htmlAttribute("id", "magic-link-email")
                        .padding(10)
                        .font(.sans, size: 14)

                    Button(type: .button) {
                        Text { "Send Magic Link" }
                    }
                    .htmlAttribute("id", "magic-link-btn")
                    .padding(10, at: .horizontal)
                    .padding(10, at: .vertical)
                    .font(.sans, size: 14, weight: .medium)
                }
                .flex(.row, gap: 8)

                Paragraph { "" }
                    .htmlAttribute("id", "magic-link-status")
                    .font(.sans, size: 13)
            }
            .flex(.column, gap: 12)

            // Divider
            RawTextNode("<hr style=\"border:none;border-top:1px solid #333;margin:16px 0\">")

            // Passkey (stub)
            Button(type: .button) {
                Text { "Sign in with Passkey" }
            }
            .htmlAttribute("disabled", "true")
            .padding(10, at: .horizontal)
            .padding(10, at: .vertical)
            .font(.sans, size: 14, weight: .medium)

            // GitHub OAuth
            Link(to: "/auth/oauth/github/login") {
                Text { "Sign in with GitHub" }
            }
            .font(.sans, size: 14, weight: .medium, decoration: TextDecoration.none)
            .padding(10, at: .horizontal)
            .padding(10, at: .vertical)

            // Client-side JS for magic link
            RawTextNode(loginScript)
        }
        .flex(.column, gap: 16)
        .padding(40)
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
