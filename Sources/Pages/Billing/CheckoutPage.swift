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
            Stack {
                Link(to: "/billing") {
                    Text { "← Billing" }
                }
                .font(.sans, size: 13, decoration: TextDecoration.none)

                Heading(.one) { "Upgrade Plan" }
                    .font(.sans, size: 24, weight: .bold)
            }
            .flex(.column, gap: 4)

            // Status message area
            Stack {}
                .htmlAttribute("id", "checkout-status")

            // Checkout form
            Stack {
                // Plan selection
                Stack {
                    Heading(.two) { "Select a Plan" }
                        .font(.sans, size: 15, weight: .semibold)

                    // Pro option
                    Stack {
                        Stack {
                            Input(type: .radio, name: "plan", id: "plan-pro")
                                .htmlAttribute("value", "pro")
                                .htmlAttribute("checked", "checked")
                            Label(for: "plan-pro") {
                                Stack {
                                    Text { "Pro" }
                                        .font(.sans, size: 14, weight: .semibold)
                                    Text { "$9 / month" }
                                        .font(.sans, size: 13)
                                }
                                .flex(.row, gap: 12, align: .center)
                            }
                        }
                        .flex(.row, gap: 10, align: .center)

                        Text { "Unlimited collections · 5 GB storage · custom domain · priority support" }
                            .font(.sans, size: 12)
                    }
                    .flex(.column, gap: 6)
                    .padding(14)
                    .radius(8)
                }
                .flex(.column, gap: 10)

                // Payment details
                Stack {
                    Heading(.two) { "Payment Details" }
                        .font(.sans, size: 15, weight: .semibold)

                    // TODO: embed Revolut card field JS component
                    Stack {
                        Paragraph { "Revolut card field will appear here." }
                            .font(.sans, size: 13)
                    }
                    .htmlAttribute("id", "revolut-card-field")
                    .padding(24)
                    .radius(8)
                }
                .flex(.column, gap: 10)

                // Confirm button
                Button(type: .button) {
                    Text { "Confirm Upgrade" }
                }
                .htmlAttribute("id", "confirm-btn")
                .htmlAttribute("onclick", "submitCheckout()")
                .font(.sans, size: 14, weight: .semibold)
                .padding(12, at: .horizontal)
                .padding(10, at: .vertical)
                .radius(6)
                .size(width: .percent(100))
            }
            .flex(.column, gap: 20)
            .padding(24)
            .radius(8)
            .size(maxWidth: 520)

            RawTextNode(checkoutScript)
        }
        .flex(.column, gap: 24)
        .padding(40)
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
  status.style.cssText = 'color:#fbbf24;font-size:13px';

  try {
    var res = await fetch('/api/billing/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ plan: selectedPlan })
    });
    var json = await res.json();
    if (res.ok) {
      // TODO: Use json.sessionId to initialise the Revolut card field JS component
      status.textContent = 'Session created. Redirecting to payment... (stub: ' + json.sessionId + ')';
      status.style.cssText = 'color:#4ade80;font-size:13px';
      // TODO: redirect to json.checkoutUrl or complete via Revolut JS SDK
    } else {
      status.textContent = 'Error: ' + (json.message || res.statusText);
      status.style.cssText = 'color:#f87171;font-size:13px';
      btn.disabled = false;
    }
  } catch (e) {
    status.textContent = 'Request failed: ' + e.message;
    status.style.cssText = 'color:#f87171;font-size:13px';
    btn.disabled = false;
  }
}
</script>
"""
