import Score

struct LibrettoErrorPage: ErrorPage {
    var context: ErrorContext

    init(context: ErrorContext) {
        self.context = context
    }

    var body: some Node {
        Stack {
            Section {
                Heading(.one) { "\(context.statusCode)" }
                    .font(.serif, size: 56, weight: .light, lineHeight: 1.15, color: .text, align: .center)
                    .animate(.fadeIn, duration: 0.6)

                Paragraph { errorTitle }
                    .font(.serif, size: 22, weight: .light, color: .text, align: .center)
                    .animate(.fadeIn, duration: 0.6, delay: 0.15)

                Paragraph { context.message }
                    .font(.sans, size: 14, lineHeight: 1.6, color: .muted, align: .center)
                    .size(maxWidth: 580)
                    .animate(.fadeIn, duration: 0.6, delay: 0.3)

                Link(to: "/") { "Back to Home" }
                    .font(.sans, size: 13, weight: .medium, color: .text, align: .center, decoration: TextDecoration.none)
                    .padding(10, at: .vertical)
                    .padding(20, at: .horizontal)
                    .border(width: 1, color: .border, style: .solid)
                    .border(radius: 4)
                    .hover { $0.background(.elevated) }
                    .animate(.fadeIn, duration: 0.6, delay: 0.45)
            }
            .flex(.column, gap: 28, align: .center)
            .padding(120, at: .vertical)
            .padding(56, at: .horizontal)
            .compact { $0.padding(80, at: .vertical).padding(20, at: .horizontal) }
        }
        .flex(.column, gap: 0)
        .background(.bg)
        .size(minHeight: .percent(100))
    }

    private var errorTitle: String {
        switch context.statusCode {
        case 404: return "Page Not Found"
        case 403: return "Access Denied"
        case 500: return "Something Went Wrong"
        default: return "Error"
        }
    }
}
