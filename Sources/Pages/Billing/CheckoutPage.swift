import Score
import ScoreLucide

/// Checkout page at `/billing/checkout`.
///
/// Presents plan selection (Pro) and a placeholder for the
/// Revolut card field embed, then confirms the upgrade.
struct CheckoutPage: Page {
    static let path = "/billing/checkout"

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
                        sidebarLink(to: "/settings", label: "Settings", icon: "settings")
                        sidebarLink(to: "/billing", label: "Billing", icon: "credit-card", active: true)
                    }
                    .flex(.column, gap: 2)
                    .padding(8, at: .horizontal)
                }
                .flex(.column, gap: 0)
                .size(width: 240)
                .background(.surface)
                .htmlAttribute("style", "border-right:1px solid var(--color-border);min-height:100vh")
                .compact { $0.htmlAttribute("style", "width:auto;border-right:none;border-bottom:1px solid var(--color-border)") }

                // Main content
                Section {
                    Link(to: "/billing") {
                        Stack {
                            Icon("arrow-left", size: 16, color: .muted)
                            Text { "Billing" }
                        }
                        .flex(.row, gap: 6, align: .center)
                    }
                    .font(.sans, size: 14, color: .muted, decoration: TextDecoration.none)
                    .hover { $0.opacity(0.7) }

                    Heading(.one) { "Upgrade to Pro" }
                        .font(.serif, size: 32, weight: .bold, color: .text)

                    // Status message area
                    Stack {}
                        .htmlAttribute("id", "checkout-status")

                    // Plan features
                    Stack {
                        Text { "PRO PLAN FEATURES" }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)

                        Stack {
                            Stack {
                                Input(type: .radio, name: "plan", id: "plan-pro")
                                    .htmlAttribute("value", "pro")
                                    .htmlAttribute("checked", "checked")
                                Label(for: "plan-pro") {
                                    Stack {
                                        Text { "Pro" }
                                            .font(.sans, size: 14, weight: .semibold, color: .text)
                                        Text { "$9 / month" }
                                            .font(.sans, size: 14, color: .muted)
                                    }
                                    .flex(.row, gap: 12, align: .center)
                                }
                            }
                            .flex(.row, gap: 10, align: .center)

                            Text { "Unlimited collections, 5 GB storage, custom domain, priority support" }
                                .font(.sans, size: 13, color: .muted)
                        }
                        .flex(.column, gap: 8)
                        .padding(24)
                        .background(.elevated)
                        .border(width: 1, color: .border, style: .solid)
                        .radius(8)
                    }
                    .flex(.column, gap: 12)

                    // Payment details
                    Stack {
                        Text { "PAYMENT DETAILS" }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)

                        Stack {
                            Paragraph { "Revolut card field will appear here." }
                                .font(.sans, size: 13, color: .muted)
                        }
                        .htmlAttribute("id", "revolut-card-field")
                        .padding(24)
                        .background(.elevated)
                        .border(width: 1, color: .border, style: .solid)
                        .radius(8)
                    }
                    .flex(.column, gap: 12)

                    // Confirm button
                    Button(type: .button) {
                        Text { "Confirm Upgrade" }
                    }
                    .htmlAttribute("id", "confirm-btn")
                    .htmlAttribute("onclick", "submitCheckout()")
                    .font(.sans, size: 14, weight: .medium, color: .bg)
                    .padding(12, at: .vertical)
                    .padding(24, at: .horizontal)
                    .background(.composer)
                    .radius(4)
                    .hover { $0.opacity(0.85) }
                    .size(width: .percent(100))
                }
                .flex(.column, gap: 20)
                .padding(48, at: .vertical)
                .padding(64, at: .horizontal)
                .size(maxWidth: 640)
                .compact { $0.padding(24, at: .vertical).padding(20, at: .horizontal) }
                .htmlAttribute("style", "flex:1")
            }
            .flex(.row, gap: 0)
            .compact { $0.flex(.column, gap: 0) }

            RawTextNode(checkoutScript)
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
        .radius(6)
        .background(active ? .elevated : .surface)
        .hover { $0.background(.elevated) }
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
  status.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-muted);padding:0';

  try {
    var res = await fetch('/api/billing/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ plan: selectedPlan })
    });
    var json = await res.json();
    if (res.ok) {
      status.textContent = 'Session created. Redirecting to payment...';
      status.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:var(--color-composer);padding:0';
    } else {
      status.textContent = 'Error: ' + (json.message || res.statusText);
      status.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:#e53e3e;padding:0';
      btn.disabled = false;
    }
  } catch (e) {
    status.textContent = 'Request failed: ' + e.message;
    status.style.cssText = 'font-family:var(--font-sans);font-size:13px;color:#e53e3e;padding:0';
    btn.disabled = false;
  }
}
</script>
"""
