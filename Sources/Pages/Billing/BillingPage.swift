import Score
import ScoreLucide

/// Billing overview page at `/billing`.
///
/// Shows the current plan, usage stats, upgrade button, and feature comparison.
/// Data is populated via JS from `/api/billing`.
struct BillingPage: Page {
    static let path = "/billing"

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
                .border(width: 1, color: .border, style: .solid, at: .trailing)
                .size(minHeight: .percent(100))
                .compact { $0.size(width: .percent(100)).border(width: 0, color: .border, style: .solid, at: .trailing).border(width: 1, color: .border, style: .solid, at: .bottom) }

                // Main content
                Section {
                    Heading(.one) { "Billing" }
                        .font(.serif, size: 32, weight: .bold, color: .text)

                    Paragraph { "Manage your plan and usage." }
                        .font(.sans, size: 14, lineHeight: 1.6, color: .muted)

                    // Current Plan Card
                    Stack {
                        Stack {
                            Text { "CURRENT PLAN" }
                                .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)
                            Stack {}
                                .htmlAttribute("id", "billing-plan-badge")
                        }
                        .flex(.row, gap: 12, align: .center)

                        Heading(.two) { "" }
                            .htmlAttribute("id", "billing-plan-name")
                            .font(.serif, size: 24, weight: .bold, color: .text)

                        Paragraph { "Loading plan details..." }
                            .htmlAttribute("id", "billing-plan-description")
                            .font(.sans, size: 13, lineHeight: 1.6, color: .muted)

                        // Upgrade button
                        Stack {
                            Link(to: "/billing/checkout") {
                                Text { "Upgrade to Pro" }
                            }
                            .font(.sans, size: 13, weight: .medium, color: .bg, align: .center, decoration: TextDecoration.none)
                            .padding(10, at: .vertical)
                            .padding(20, at: .horizontal)
                            .background(.composer)
                            .border(radius: 4)
                            .hover { $0.opacity(0.85) }
                        }
                        .flex(.row, gap: 10)
                    }
                    .flex(.column, gap: 14)
                    .padding(24)
                    .background(.elevated)
                    .border(width: 1, color: .border, style: .solid)
                    .border(radius: 8)

                    // Feature comparison table
                    Stack {
                        Text { "PLAN COMPARISON" }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)

                        Table {
                            TableHead {
                                TableRow {
                                    TableHeaderCell(scope: .column) { "Feature" }
                                        .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, align: .start, transform: .uppercase)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                    TableHeaderCell(scope: .column) { "Free" }
                                        .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, align: .center, transform: .uppercase)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                    TableHeaderCell(scope: .column) { "Pro" }
                                        .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, align: .center, transform: .uppercase)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                }
                            }
                            TableBody {
                                TableRow {
                                    TableCell { "Collections" }
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                    TableCell { "Up to 100" }
                                        .font(align: .center)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                    TableCell { "Unlimited" }
                                        .font(align: .center)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                }
                                TableRow {
                                    TableCell { "Storage" }
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                    TableCell { "500 MB" }
                                        .font(align: .center)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                    TableCell { "5 GB" }
                                        .font(align: .center)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                }
                                TableRow {
                                    TableCell { "Custom domain" }
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                    TableCell { "\u{2014}" }
                                        .font(align: .center)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                    TableCell { "\u{2713}" }
                                        .font(align: .center)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                        .border(width: 1, color: .border, style: .solid, at: .bottom)
                                }
                                TableRow {
                                    TableCell { "Priority support" }
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                    TableCell { "\u{2014}" }
                                        .font(align: .center)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                    TableCell { "\u{2713}" }
                                        .font(align: .center)
                                        .padding(10, at: .vertical)
                                        .padding(12, at: .horizontal)
                                }
                            }
                        }
                        .size(width: .percent(100))
                        .font(.sans, size: 13, color: .text)
                    }
                    .flex(.column, gap: 14)
                    .padding(24)
                    .background(.elevated)
                    .border(width: 1, color: .border, style: .solid)
                    .border(radius: 8)

                    // Usage Section
                    Stack {
                        Text { "USAGE" }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)

                        // Collections usage bar
                        Stack {
                            Stack {
                                Text { "Collections" }
                                    .font(.sans, size: 13, weight: .medium, color: .text)
                                Text { "\u{2014}" }
                                    .htmlAttribute("id", "usage-collections-label")
                                    .font(.mono, size: 11, color: .muted)
                            }
                            .flex(.row, gap: 0, align: .center, justify: .spaceBetween)

                            Stack {
                                Stack {}
                                    .htmlAttribute("id", "usage-collections-fill")
                                    .size(height: 6)
                                    .border(radius: 3)
                                    .background(.composer)
                            }
                            .size(height: 6)
                            .border(radius: 3)
                            .background(.border)
                        }
                        .flex(.column, gap: 6)

                        // Storage usage bar
                        Stack {
                            Stack {
                                Text { "Storage" }
                                    .font(.sans, size: 13, weight: .medium, color: .text)
                                Text { "\u{2014}" }
                                    .htmlAttribute("id", "usage-storage-label")
                                    .font(.mono, size: 11, color: .muted)
                            }
                            .flex(.row, gap: 0, align: .center, justify: .spaceBetween)

                            Stack {
                                Stack {}
                                    .htmlAttribute("id", "usage-storage-fill")
                                    .size(height: 6)
                                    .border(radius: 3)
                                    .background(.composer)
                            }
                            .size(height: 6)
                            .border(radius: 3)
                            .background(.border)
                        }
                        .flex(.column, gap: 6)
                    }
                    .flex(.column, gap: 16)
                    .padding(24)
                    .background(.elevated)
                    .border(width: 1, color: .border, style: .solid)
                    .border(radius: 8)

                    // Payment History Section
                    Stack {
                        Text { "PAYMENT HISTORY" }
                            .font(.mono, size: 11, weight: .medium, tracking: 2, color: .muted, transform: .uppercase)

                        Stack {
                            Paragraph { "No payment history yet." }
                                .htmlAttribute("id", "payment-history-placeholder")
                                .font(.sans, size: 13, color: .muted)
                        }
                        .htmlAttribute("id", "payment-history-container")
                    }
                    .flex(.column, gap: 14)
                    .padding(24)
                    .background(.elevated)
                    .border(width: 1, color: .border, style: .solid)
                    .border(radius: 8)
                }
                .flex(.column, gap: 24)
                .padding(48, at: .vertical)
                .padding(64, at: .horizontal)
                .compact { $0.padding(24, at: .vertical).padding(20, at: .horizontal) }
                .flex(grow: 1)
            }
            .flex(.row, gap: 0)
            .compact { $0.flex(.column, gap: 0) }

            // SCORE-GAP: Client-side fetch for billing data, DOM manipulation for
            // usage bars, plan badge, and dynamic payment history table require raw JS.
            RawTextNode(billingScript)
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
        span.style.cssText = 'background:var(--color-elevated);border:1px solid var(--color-border);font-family:var(--font-mono);font-size:11px;font-weight:500;padding:2px 8px;border-radius:4px;text-transform:capitalize;color:var(--color-text)';
        return span;
      }

      function buildPaymentRow(p) {
        var tr = document.createElement('tr');
        var cellStyle = 'padding:10px 12px;border-bottom:1px solid var(--color-border);font-family:var(--font-sans);font-size:13px';
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

          var nameEl = document.getElementById('billing-plan-name');
          if (nameEl) nameEl.textContent = PLAN_LABELS[plan] || plan;

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
              table.style.cssText = 'width:100%;border-collapse:collapse;font-family:var(--font-sans);font-size:13px;color:var(--color-text)';
              var thead = document.createElement('thead');
              var headerRow = document.createElement('tr');
              ['Date', 'Description', 'Amount', 'Status'].forEach(function(text, i) {
                var th = document.createElement('th');
                th.textContent = text;
                th.style.cssText = 'text-align:' + (i >= 2 ? 'right' : 'left') +
                  ';padding:10px 12px;border-bottom:1px solid var(--color-border);font-family:var(--font-mono);font-size:11px;color:var(--color-muted);text-transform:uppercase;letter-spacing:0.05em;font-weight:500';
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
