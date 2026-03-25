// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Libretto",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/allegro-systems/score.git", branch: "main"),
        .package(url: "https://github.com/allegro-systems/score-oauth.git", branch: "main"),
        .package(url: "https://github.com/allegro-systems/score-payments.git", branch: "main"),
        .package(url: "https://github.com/allegro-systems/score-lucide.git", branch: "main"),
        .package(url: "https://github.com/allegro-systems/allegro-theme.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "Libretto",
            dependencies: [
                .product(name: "Score", package: "Score"),
                .product(name: "ScoreOAuth", package: "score-oauth"),
                .product(name: "ScorePayments", package: "score-payments"),
                .product(name: "ScoreLucide", package: "score-lucide"),
                .product(name: "AllegroTheme", package: "allegro-theme"),
            ],
            path: "Sources"
        )
    ]
)
