import AllegroTheme
import Score

struct LoginPage: Page {
    static let path = "/login"

    var body: some Node {
        AuthLoginPage(product: .libretto)
    }
}
