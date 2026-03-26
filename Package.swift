// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Libretto",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(name: "Score", path: "../../framework/score"),
        .package(name: "Stage", path: "../../infra/stage"),
        .package(name: "score-oauth", path: "../../framework/plugins/score-oauth"),
        .package(name: "score-payments", path: "../../framework/plugins/score-payments"),
        .package(name: "score-lucide", path: "../../framework/plugins/score-lucide"),
        .package(name: "allegro-theme", path: "../../framework/plugins/allegro-theme"),
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
