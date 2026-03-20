import Foundation
import Score
import ScoreOAuth
import ScorePayments
import ScoreLucide

@main
struct LibrettoApp: Application {
    var theme: (any Theme)? { LibrettoTheme() }

    var plugins: [any ScorePlugin] {
        [
            LucidePlugin(),
            OAuthPlugin(providers: [
                .github(
                    clientId: ProcessInfo.processInfo.environment["GITHUB_CLIENT_ID"] ?? "",
                    clientSecret: ProcessInfo.processInfo.environment["GITHUB_CLIENT_SECRET"] ?? ""
                ),
            ]),
            PaymentsPlugin(providers: [
                .revolut(
                    apiKey: ProcessInfo.processInfo.environment["REVOLUT_API_KEY"] ?? "",
                    webhookSecret: ProcessInfo.processInfo.environment["REVOLUT_WEBHOOK_SECRET"] ?? "",
                    sandbox: ProcessInfo.processInfo.environment["REVOLUT_SANDBOX"] == "true"
                ),
            ]),
        ]
    }

    @PageBuilder
    var pages: [any Page] {
        LandingPage()
        LoginPage()
        EditorPage()
        DraftsPage()
        PostPage()
        BlogListPage()
        BillingPage()
        CheckoutPage()
        ProfilePage()
        SettingsPage()
    }

    var errorPage: (any ErrorPage.Type)? { LibrettoErrorPage.self }

    var controllers: [any Controller] {
        [
            AuthController(),
            PostController(),
            PublicPostController(),
            BillingController(),
            ProfileController(),
            FeedController(),
            LikeController(),
            CommentController(),
        ]
    }
}
