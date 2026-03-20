import Score

/// Checkout page at `/billing/checkout`.
///
/// Presents plan selection (Pro) and a placeholder for the
/// Revolut card field embed, then confirms the upgrade.
struct CheckoutPage: Page {
    static let path = "/billing/checkout"

    var body: some Node {
        Stack {
            // Header
            Section {
                Link(to: "/billing") {
                    Text { "\u{2190} Billing" }
                }
                .font(.mono, size: 13, color: .muted, decoration: TextDecoration.none)
                .hover { $0.opacity(0.85) }

                Heading(.one) { "Upgrade Plan" }
                    .font(.serif, size: 56, weight: .light, lineHeight: 1.15, color: .text)
                    .compact { $0.font(size: 36) }
                    .animate(.fadeIn, duration: 0.6)
            }
            .flex(.column, gap: 12)
            .padding(80, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(60, at: .vertical).padding(20, at: .horizontal) }

            HorizontalRule().background(.border).size(height: 1).border(width: 0, color: .border, style: .none)

            // Status message area
            Stack {}
                .htmlAttribute("id", "checkout-status")

            // Checkout form
            Section {
                Stack {
                    // Plan selection
                    Stack {
                        Text { "SELECT A PLAN" }
                            .font(.mono, size: 12, weight: .medium, tracking: 3, color: .muted, transform: .uppercase)

                        // Pro option
                        Stack {
                            Stack {
                                Input(type: .radio, name: "plan", id: "plan-pro")
                                    .htmlAttribute("value", "pro")
                                    .htmlAttribute("checked", "checked")
                                Label(for: "plan-pro") {
                                    Stack {
                                        Text { "Pro" }
                                            .font(.mono, size: 13, weight: .medium, color: .text)
                                        Text { "$9 / month" }
                                            .font(.mono, size: 13, color: .muted)
                                    }
                                    .flex(.row, gap: 12, align: .center)
                                }
                            }
                            .flex(.row, gap: 10, align: .center)

                            Text { "Unlimited collections \u{00b7} 5 GB storage \u{00b7} custom domain \u{00b7} priority support" }
                                .font(.mono, size: 11, color: .muted)
                        }
                        .flex(.column, gap: 6)
                        .padding(24)
                        .background(.elevated)
                        .border(width: 1, color: .border, style: .solid)
                    }
                    .flex(.column, gap: 10)

                    // Payment details
                    Stack {
                        Text { "PAYMENT DETAILS" }
                            .font(.mono, size: 12, weight: .medium, tracking: 3, color: .muted, transform: .uppercase)

                        // TODO: embed Revolut card field JS component
                        Stack {
                            Paragraph { "Revolut card field will appear here." }
                                .font(.mono, size: 13, color: .muted)
                        }
                        .htmlAttribute("id", "revolut-card-field")
                        .padding(24)
                        .background(.elevated)
                        .border(width: 1, color: .border, style: .solid)
                    }
                    .flex(.column, gap: 10)

                    // Confirm button
                    Button(type: .button) {
                        Text { "Confirm Upgrade" }
                    }
                    .htmlAttribute("id", "confirm-btn")
                    .htmlAttribute("onclick", "submitCheckout()")
                    .font(.mono, size: 13, weight: .medium, color: .bg)
                    .padding(14, at: .vertical)
                    .padding(28, at: .horizontal)
                    .background(.accent)
                    .hover { $0.opacity(0.85) }
                    .size(width: .percent(100))
                }
                .flex(.column, gap: 20)
                .size(maxWidth: 580)
            }
            .flex(.column, gap: 0)
            .padding(80, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(60, at: .vertical).padding(20, at: .horizontal) }

            RawTextNode(checkoutScript)
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }
}

// MARK: - Client Script

private let checkoutScript = """
<script>
async function submitCheckout() {
  var btn = document.getElementById('confirm-btn');
  var status = document.getElementById('checkout-status');
  var planRadios = document.querySelectorAll('input[name="plan"]');
  var selectedPlan = 'pro';
  planRadios.forEach(function(r) { if (r.checked) selectedPlan = r.value; });

  btn.disabled = true;
  status.textContent = 'Creating checkout session...';
  status.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:var(--color-muted);padding:0 56px';

  try {
    var res = await fetch('/api/billing/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ plan: selectedPlan })
    });
    var json = await res.json();
    if (res.ok) {
      status.textContent = 'Session created. Redirecting to payment... (stub: ' + json.sessionId + ')';
      status.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:var(--color-accent);padding:0 56px';
    } else {
      status.textContent = 'Error: ' + (json.message || res.statusText);
      status.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:#e53e3e;padding:0 56px';
      btn.disabled = false;
    }
  } catch (e) {
    status.textContent = 'Request failed: ' + e.message;
    status.style.cssText = 'font-family:var(--font-mono);font-size:13px;color:#e53e3e;padding:0 56px';
    btn.disabled = false;
  }
}
</script>
"""
