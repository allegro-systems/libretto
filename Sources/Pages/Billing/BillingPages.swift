import Score

struct BillingPages: PageProvider {
    var pages: [any Page] {
        [
            BillingPage(),
            CheckoutPage(),
        ]
    }
}
