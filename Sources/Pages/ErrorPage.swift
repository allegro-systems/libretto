import Score

struct LibrettoErrorPage: ErrorPage {
    var context: ErrorContext

    init(context: ErrorContext) {
        self.context = context
    }

    var body: some Node {
        Stack {
            Heading(.one) { "\(context.statusCode)" }
                .font(.sans, size: 64, weight: .bold)

            Paragraph { errorTitle }
                .font(.sans, size: 24, weight: .semibold)

            Paragraph { context.message }
                .font(.sans, size: 16, color: .muted)

            Link(to: "/") { "Back to Home" }
                .font(.sans, size: 15, weight: .semibold, decoration: TextDecoration.none)
                .padding(10, at: .vertical)
                .padding(20, at: .horizontal)
                .background(ColorToken("elevated"))
                .radius(8)
        }
        .flex(.column, gap: 16)
        .padding(80)
        .htmlAttribute("style", "align-items:center;text-align:center;max-width:600px;margin:0 auto;")
    }

    private var errorTitle: String {
        switch context.statusCode {
        case 404: return "Page Not Found"
        case 403: return "Access Denied"
        case 500: return "Something Went Wrong"
        default:  return "Error"
        }
    }
}
