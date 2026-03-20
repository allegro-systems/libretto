import Score

struct LandingPage: Page {
    static let path = "/"
    var body: some Node {
        Stack {
            Heading(.one) { "Libretto" }
            Paragraph { "A writing and publishing platform." }
        }
        .padding(40)
    }
}
