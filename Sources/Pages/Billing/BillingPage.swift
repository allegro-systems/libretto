import Score

/// Billing overview page at `/billing`.
///
/// Shows the current plan, usage stats, upgrade button, and feature comparison.
/// Data is populated via JS from `/api/billing`.
struct BillingPage: Page {
    static let path = "/billing"

    var body: some Node {
        Stack {
            // Header
            Stack {
                Heading(.one) { "Billing" }
                    .font(.sans, size: 24, weight: .bold)
                Paragraph { "Manage your plan and usage." }
                    .font(.sans, size: 14)
            }
            .flex(.column, gap: 4)

            // Current Plan Card
            Stack {
                Stack {
                    Heading(.two) { "Current Plan" }
                        .font(.sans, size: 16, weight: .semibold)
                    Stack {}
                        .htmlAttribute("id", "billing-plan-badge")
                }
                .flex(.row, gap: 12, align: .center)

                Paragraph { "Loading plan details..." }
                    .htmlAttribute("id", "billing-plan-description")
                    .font(.sans, size: 13)

                // Upgrade button
                Stack {
                    Link(to: "/billing/checkout") {
                        Text { "Upgrade to Pro" }
                    }
                    .font(.sans, size: 13, weight: .semibold, decoration: TextDecoration.none)
                    .padding(8, at: .horizontal)
                    .padding(6, at: .vertical)
                    .background(.oklch(0.45, 0.18, 260))
                    .radius(6)
                }
                .flex(.row, gap: 10)
            }
            .flex(.column, gap: 14)
            .padding(24)
            .radius(8)

            // Feature comparison table
            Stack {
                Heading(.two) { "Plan Comparison" }
                    .font(.sans, size: 16, weight: .semibold)

                RawTextNode("""
                <table style="width:100%;border-collapse:collapse;font-size:13px">
                  <thead>
                    <tr>
                      <th style="text-align:left;padding:8px 0;border-bottom:1px solid #333">Feature</th>
                      <th style="text-align:center;padding:8px 0;border-bottom:1px solid #333">Free</th>
                      <th style="text-align:center;padding:8px 0;border-bottom:1px solid #333">Pro</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr>
                      <td style="padding:8px 0;border-bottom:1px solid #222">Collections</td>
                      <td style="text-align:center;padding:8px 0;border-bottom:1px solid #222">Up to 100</td>
                      <td style="text-align:center;padding:8px 0;border-bottom:1px solid #222">Unlimited</td>
                    </tr>
                    <tr>
                      <td style="padding:8px 0;border-bottom:1px solid #222">Storage</td>
                      <td style="text-align:center;padding:8px 0;border-bottom:1px solid #222">500 MB</td>
                      <td style="text-align:center;padding:8px 0;border-bottom:1px solid #222">5 GB</td>
                    </tr>
                    <tr>
                      <td style="padding:8px 0;border-bottom:1px solid #222">Custom domain</td>
                      <td style="text-align:center;padding:8px 0;border-bottom:1px solid #222">—</td>
                      <td style="text-align:center;padding:8px 0;border-bottom:1px solid #222">✓</td>
                    </tr>
                    <tr>
                      <td style="padding:8px 0">Priority support</td>
                      <td style="text-align:center;padding:8px 0">—</td>
                      <td style="text-align:center;padding:8px 0">✓</td>
                    </tr>
                  </tbody>
                </table>
                """)
            }
            .flex(.column, gap: 14)
            .padding(24)
            .radius(8)

            // Usage Section
            Stack {
                Heading(.two) { "Usage" }
                    .font(.sans, size: 16, weight: .semibold)

                // Collections usage bar
                Stack {
                    Stack {
                        Text { "Collections" }
                            .font(.sans, size: 13, weight: .medium)
                        Text { "—" }
                            .htmlAttribute("id", "usage-collections-label")
                            .font(.sans, size: 12)
                    }
                    .flex(.row, gap: 0, align: .center, justify: .spaceBetween)

                    Stack {
                        Stack {}
                            .htmlAttribute("id", "usage-collections-fill")
                            .size(height: 6)
                            .radius(3)
                            .background(.oklch(0.45, 0.18, 260))
                    }
                    .size(height: 6)
                    .radius(3)
                }
                .flex(.column, gap: 6)

                // Storage usage bar
                Stack {
                    Stack {
                        Text { "Storage" }
                            .font(.sans, size: 13, weight: .medium)
                        Text { "—" }
                            .htmlAttribute("id", "usage-storage-label")
                            .font(.sans, size: 12)
                    }
                    .flex(.row, gap: 0, align: .center, justify: .spaceBetween)

                    Stack {
                        Stack {}
                            .htmlAttribute("id", "usage-storage-fill")
                            .size(height: 6)
                            .radius(3)
                            .background(.oklch(0.60, 0.18, 50))
                    }
                    .size(height: 6)
                    .radius(3)
                }
                .flex(.column, gap: 6)
            }
            .flex(.column, gap: 16)
            .padding(24)
            .radius(8)

            // Payment History Section
            Stack {
                Heading(.two) { "Payment History" }
                    .font(.sans, size: 16, weight: .semibold)

                Stack {
                    Paragraph { "No payment history yet." }
                        .htmlAttribute("id", "payment-history-placeholder")
                        .font(.sans, size: 13)
                }
                .htmlAttribute("id", "payment-history-container")
            }
            .flex(.column, gap: 14)
            .padding(24)
            .radius(8)

            RawTextNode(billingScript)
        }
        .flex(.column, gap: 24)
        .padding(40)
    }
}

// MARK: - Client Script

private let billingScript = """
<script>
(function() {
  var PLAN_LABELS = { free: 'Free', pro: 'Pro' };
  var PLAN_DESC  = {
    free: 'Up to 100 collections, 500 MB storage.',
    pro:  'Unlimited collections, 5 GB storage, custom domain, priority support.'
  };

  function formatBytes(b) {
    if (b < 1048576) return (b / 1024).toFixed(1) + ' KB';
    if (b < 1073741824) return (b / 1048576).toFixed(1) + ' MB';
    return (b / 1073741824).toFixed(2) + ' GB';
  }

  function setBar(fillId, labelId, used, limit, fmt) {
    var fill  = document.getElementById(fillId);
    var label = document.getElementById(labelId);
    if (!fill || !label) return;
    var pct = limit > 0 ? Math.min(100, (used / limit) * 100) : 0;
    fill.style.width = pct.toFixed(1) + '%';
    label.textContent = limit === 0
      ? fmt(used) + ' / Unlimited'
      : fmt(used) + ' / ' + fmt(limit);
  }

  function makeBadge(plan) {
    var span = document.createElement('span');
    span.textContent = PLAN_LABELS[plan] || plan;
    span.style.cssText = 'background:#333;font-size:11px;font-weight:600;padding:2px 8px;border-radius:4px;text-transform:capitalize';
    return span;
  }

  function buildPaymentRow(p) {
    var tr = document.createElement('tr');
    var cellStyle = 'padding:8px 0;border-bottom:1px solid #222';
    var cells = [p.date || '', p.description || '', p.amount || '', p.status || ''];
    cells.forEach(function(text, i) {
      var td = document.createElement('td');
      td.textContent = text;
      td.style.cssText = cellStyle + (i >= 2 ? ';text-align:right' : '');
      tr.appendChild(td);
    });
    return tr;
  }

  fetch('/api/billing')
    .then(function(r) { return r.json(); })
    .then(function(data) {
      var plan = data.plan || 'free';

      var badgeEl = document.getElementById('billing-plan-badge');
      if (badgeEl) badgeEl.appendChild(makeBadge(plan));

      var desc = document.getElementById('billing-plan-description');
      if (desc) desc.textContent = PLAN_DESC[plan] || '';

      var u = data.usage || {};
      if (u.collections) {
        setBar('usage-collections-fill', 'usage-collections-label',
          u.collections.used, u.collections.limit, function(v) { return String(v); });
      }
      if (u.storageBytes) {
        setBar('usage-storage-fill', 'usage-storage-label',
          u.storageBytes.used, u.storageBytes.limit, formatBytes);
      }

      var history = data.paymentHistory;
      if (history && history.length > 0) {
        var placeholder = document.getElementById('payment-history-placeholder');
        if (placeholder) placeholder.style.display = 'none';
        var container = document.getElementById('payment-history-container');
        if (container) {
          var table = document.createElement('table');
          table.style.cssText = 'width:100%;border-collapse:collapse;font-size:13px';
          var thead = document.createElement('thead');
          var headerRow = document.createElement('tr');
          ['Date', 'Description', 'Amount', 'Status'].forEach(function(text, i) {
            var th = document.createElement('th');
            th.textContent = text;
            th.style.cssText = 'text-align:' + (i >= 2 ? 'right' : 'left') +
              ';padding:8px 0;border-bottom:1px solid #333';
            headerRow.appendChild(th);
          });
          thead.appendChild(headerRow);
          table.appendChild(thead);
          var tbody = document.createElement('tbody');
          history.forEach(function(p) { tbody.appendChild(buildPaymentRow(p)); });
          table.appendChild(tbody);
          container.appendChild(table);
        }
      }
    })
    .catch(function(e) { console.error('Failed to load billing data:', e); });
})();
</script>
"""
